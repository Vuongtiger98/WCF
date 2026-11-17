#Requires -Version 5.1
Set-StrictMode -Version 2.0
$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.IO.Compression
Add-Type -AssemblyName System.IO.Compression.FileSystem
$script:GameId = 'wonder-christmas-fiesta'
$script:Utf8 = New-Object System.Text.UTF8Encoding($false)

function Get-WcfHash([string]$Path) {
    (Get-FileHash -LiteralPath $Path -Algorithm SHA256).Hash.ToLowerInvariant()
}

function ConvertTo-WcfVersion([string]$Version) {
    $pattern = '^(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)\.(0|[1-9][0-9]*)(?:-([0-9A-Za-z-]+(?:\.[0-9A-Za-z-]+)*))?(?:\+([0-9A-Za-z-]+(?:\.[0-9A-Za-z-]+)*))?$'
    if ($Version -notmatch $pattern) { throw "Invalid version: $Version (use e.g. 0.1.0-test.1)." }
    $numbers = @([long]$Matches[1],[long]$Matches[2],[long]$Matches[3])
    $pre = @()
    if ($Matches[4]) {
        $pre = @($Matches[4].Split('.'))
        foreach ($part in $pre) {
            if ($part -match '^0[0-9]+$') { throw "Invalid numeric prerelease identifier: $Version" }
        }
    }
    [pscustomobject]@{ numbers=$numbers; pre=$pre }
}

function Compare-WcfVersion([string]$Left,[string]$Right) {
    $a = ConvertTo-WcfVersion $Left; $b = ConvertTo-WcfVersion $Right
    for ($i=0;$i -lt 3;$i++) {
        if ($a.numbers[$i] -gt $b.numbers[$i]) { return 1 }
        if ($a.numbers[$i] -lt $b.numbers[$i]) { return -1 }
    }
    if (!$a.pre.Count -and !$b.pre.Count) { return 0 }
    if (!$a.pre.Count) { return 1 }; if (!$b.pre.Count) { return -1 }
    for ($i=0;$i -lt [Math]::Min($a.pre.Count,$b.pre.Count);$i++) {
        $x=$a.pre[$i]; $y=$b.pre[$i]
        if ($x -ceq $y) { continue }
        $xn=$x -match '^[0-9]+$'; $yn=$y -match '^[0-9]+$'
        if ($xn -and $yn) {
            if ($x.Length -ne $y.Length) { return [Math]::Sign($x.Length-$y.Length) }
        } elseif ($xn -ne $yn) { if ($xn) { return -1 } else { return 1 } }
        return [Math]::Sign([StringComparer]::Ordinal.Compare($x,$y))
    }
    [Math]::Sign($a.pre.Count-$b.pre.Count)
}

function Assert-WcfRelativePath([string]$Path) {
    if ([string]::IsNullOrWhiteSpace($Path) -or $Path.Contains('\') -or
        $Path -match '[:*?"<>|\x00-\x1f\x7f]' -or [IO.Path]::IsPathRooted($Path)) {
        throw "Unsafe relative path: $Path"
    }
    foreach ($part in $Path.Split('/')) {
        if (!$part -or $part -in @('.','..') -or $part -match '[. ]$' -or
            $part -match '^(?i:CON|PRN|AUX|NUL|COM[1-9]|LPT[1-9])(?:\.|$)') {
            throw "Unsafe path component: $Path"
        }
    }
}

function Test-WcfManagedPath([string]$Path) {
    Assert-WcfRelativePath $Path
    if ($Path -in @('Game.exe','Game.ini','Game.rvproj2','Khas Graphics Library.dll','GameUpdate.bat',
        'gameupdate/Update.ps1','gameupdate/WcfUpdater.psm1')) { return $true }
    if ($Path -match '^Data/[^/]+\.rvdata2$') { return $true }
    if ($Path -match '^Graphics/.+\.(png|jpg|jpeg|bmp)$') { return $true }
    if ($Path -match '^Audio/.+\.(ogg|wav|mp3|mid|wma)$') { return $true }
    if ($Path -match '^Movies/.+\.(ogv|avi|mp4)$') { return $true }
    if ($Path -match '^System/.+\.(dll|klib)$') { return $true }
    return $false
}

function Resolve-WcfChild([string]$Root,[string]$Relative) {
    Assert-WcfRelativePath $Relative
    $base = [IO.Path]::GetFullPath($Root).TrimEnd('\','/')
    $full = [IO.Path]::GetFullPath((Join-Path $base ($Relative.Replace('/',[IO.Path]::DirectorySeparatorChar))))
    if (!$full.StartsWith($base+[IO.Path]::DirectorySeparatorChar,[StringComparison]::OrdinalIgnoreCase)) {
        throw "Path escaped game directory: $Relative"
    }
    $cursor = $full
    while ($cursor.Length -ge $base.Length) {
        if (Test-Path -LiteralPath $cursor) {
            $item=Get-Item -LiteralPath $cursor -Force
            if ($item.Attributes -band [IO.FileAttributes]::ReparsePoint) { throw "Linked paths are not supported: $cursor" }
        }
        if ($cursor -eq $base) { break }
        $cursor=[IO.Path]::GetDirectoryName($cursor)
    }
    $full
}

function Write-WcfAtomicBytes([string]$Path,[byte[]]$Bytes) {
    [IO.Directory]::CreateDirectory([IO.Path]::GetDirectoryName($Path)) | Out-Null
    $temp=$Path+'.wcf-new-'+[guid]::NewGuid().ToString('N')
    try {
        $stream=New-Object IO.FileStream($temp,[IO.FileMode]::CreateNew,[IO.FileAccess]::Write,[IO.FileShare]::None)
        try { $stream.Write($Bytes,0,$Bytes.Length); $stream.Flush($true) } finally { $stream.Dispose() }
        if ([IO.File]::Exists($Path)) { [IO.File]::Replace($temp,$Path,[System.Management.Automation.Language.NullString]::Value) }
        else { [IO.File]::Move($temp,$Path) }
    } finally { if ([IO.File]::Exists($temp)) { [IO.File]::Delete($temp) } }
}

function Write-WcfJson([string]$Path,$Value) {
    Write-WcfAtomicBytes $Path ($script:Utf8.GetBytes(($Value | ConvertTo-Json -Depth 20)))
}

function Read-WcfJson([string]$Path,[long]$MaxBytes=8388608) {
    $file=Get-Item -LiteralPath $Path
    if ($file.Length -gt $MaxBytes) { throw "JSON file too large: $Path" }
    [IO.File]::ReadAllText($Path,$script:Utf8) | ConvertFrom-Json
}

function Read-WcfManifest([string]$Path) {
    $m=Read-WcfJson $Path
    if ($m.schemaVersion -ne 1 -or $m.gameId -ne $script:GameId) { throw 'Wrong game or unsupported update format.' }
    $null=ConvertTo-WcfVersion ([string]$m.version)
    if ($m.requiresNewGame -isnot [bool]) { throw 'requiresNewGame must be a boolean.' }
    if (@($m.files).Count -lt 1 -or @($m.files).Count -gt 20000) { throw 'Invalid manifest file count.' }
    $packages=@{}; $paths=@{}; [long]$total=0
    foreach ($p in @($m.packages)) {
        if ($p.name -notmatch '^wcf-[a-z0-9-]+\.zip$' -or $packages.ContainsKey($p.name) -or
            $p.sha256 -notmatch '^[a-fA-F0-9]{64}$' -or [long]$p.size -lt 1 -or [long]$p.size -gt 2147483647) {
            throw 'Invalid or duplicate update package.'
        }
        $packages[$p.name]=$p
    }
    foreach ($f in @($m.files)) {
        if (!(Test-WcfManagedPath $f.path) -or $paths.ContainsKey($f.path) -or
            $f.sha256 -notmatch '^[a-fA-F0-9]{64}$' -or [long]$f.size -lt 0 -or [long]$f.size -gt 2147483647 -or
            !$packages.ContainsKey($f.package)) { throw "Invalid, duplicate or protected update file: $($f.path)" }
        $paths[$f.path]=$true; $total += [long]$f.size
    }
    if ($total -gt 8589934592) { throw 'Update exceeds the supported total size.' }
    foreach ($path in @($paths.Keys)) {
        $parent=$path
        while ($parent.Contains('/')) {
            $parent=$parent.Substring(0,$parent.LastIndexOf('/'))
            if ($paths.ContainsKey($parent)) { throw 'Manifest contains a file/directory collision.' }
        }
    }
    foreach ($required in @('Game.exe','Game.ini','Data/Scripts.rvdata2','GameUpdate.bat','gameupdate/Update.ps1','gameupdate/WcfUpdater.psm1')) {
        if (!$paths.ContainsKey($required)) { throw "Incomplete game manifest: $required missing." }
    }
    $m
}

function Assert-WcfGameRoot([string]$Root) {
    if (!(Test-Path -LiteralPath $Root -PathType Container)) { throw 'Game directory does not exist.' }
    $Root=[IO.Path]::GetFullPath($Root).TrimEnd('\','/')
    foreach ($p in @('Game.exe','Game.ini','Data/Scripts.rvdata2')) {
        $target=Resolve-WcfChild $Root $p
        if (!(Test-Path -LiteralPath $target -PathType Leaf)) { throw "Not a WCF game installation: $p missing." }
    }
    if (Test-Path -LiteralPath (Join-Path $Root 'Game.rgss3a')) { throw 'Packed RGSS archives are not supported by this unpacked-game updater.' }
    $ini=[IO.File]::ReadAllText((Join-Path $Root 'Game.ini'))
    if ($ini -notmatch '(?im)^Title=Wonder Christmas Fiesta\s*$') { throw 'The selected folder belongs to a different game.' }
    $null=Resolve-WcfChild $Root 'gameupdate/installed.json'
    $Root
}

function Assert-WcfGameClosed([string]$Root) {
    $expected=[IO.Path]::GetFullPath((Join-Path $Root 'Game.exe'))
    foreach ($p in @(Get-Process -Name Game -ErrorAction SilentlyContinue)) {
        try { $path=$p.Path } catch { $path=$null }
        if (!$path -or [string]::Equals($path,$expected,[StringComparison]::OrdinalIgnoreCase)) {
            throw 'Close the game before updating or recovering an update.'
        }
    }
}

function Write-WcfLog([string]$Root,[string]$Text) {
    $log=Resolve-WcfChild $Root 'gameupdate/update.log'
    [IO.Directory]::CreateDirectory([IO.Path]::GetDirectoryName($log)) | Out-Null
    [IO.File]::AppendAllText($log,([DateTime]::UtcNow.ToString('o')+' '+$Text+[Environment]::NewLine),$script:Utf8)
}

function Get-WcfUpdatePlan([string]$Root,$Manifest,$Installed) {
    $new=@{}; $writes=@(); $deletes=@()
    foreach ($f in @($Manifest.files)) {
        $new[$f.path]=$f
        $target=Resolve-WcfChild $Root $f.path
        if (Test-Path -LiteralPath $target -PathType Container) { throw "A directory blocks a managed file: $($f.path)" }
        if (!(Test-Path -LiteralPath $target -PathType Leaf) -or (Get-Item -LiteralPath $target).Length -ne [long]$f.size -or
            (Get-WcfHash $target) -ne $f.sha256) { $writes += $f }
    }
    if ($Installed) {
        foreach ($f in @($Installed.files)) {
            if (!$new.ContainsKey($f.path)) {
                $target=Resolve-WcfChild $Root $f.path
                if (Test-Path -LiteralPath $target -PathType Container) { throw 'A directory replaced a previously managed file.' }
                if (Test-Path -LiteralPath $target -PathType Leaf) { $deletes += [string]$f.path }
            }
        }
    }
    [pscustomobject]@{ writes=@($writes); deletes=@($deletes) }
}

function Save-WcfDownload([string]$Url,[string]$Destination,[long]$ExpectedSize=0) {
    $uri=[uri]$Url
    if ($uri.Scheme -ne 'https') { throw 'Update downloads must use HTTPS.' }
    [Net.ServicePointManager]::SecurityProtocol=[Net.SecurityProtocolType]::Tls12
    $oldProgress=$ProgressPreference; $ProgressPreference='SilentlyContinue'
    try {
        for ($attempt=1;$attempt -le 3;$attempt++) {
            try {
                Invoke-WebRequest -UseBasicParsing -Uri $Url -OutFile $Destination -TimeoutSec 120 -MaximumRedirection 10 -Headers @{'User-Agent'='WCF-Updater/1'}
                if ($ExpectedSize -gt 0 -and (Get-Item -LiteralPath $Destination).Length -ne $ExpectedSize) { throw 'Incomplete download.' }
                return
            } catch { if ($attempt -eq 3) { throw }; Start-Sleep -Seconds $attempt }
        }
    } finally { $ProgressPreference=$oldProgress }
}

function Assert-WcfAssetUrl([string]$Url,$Config,[string]$Name) {
    $uri=[uri]$Url
    $prefix='/'+$Config.owner+'/'+$Config.repo+'/releases/download/'
    if ($uri.Scheme -ne 'https' -or $uri.Host -ne 'github.com' -or $uri.UserInfo -or
        !$uri.AbsolutePath.StartsWith($prefix,[StringComparison]::OrdinalIgnoreCase) -or
        [uri]::UnescapeDataString(($uri.AbsolutePath.Split('/')[-1])) -cne $Name) { throw 'Release asset does not belong to the configured repository.' }
}

function Select-WcfRelease($Releases,[string]$Channel) {
    if ($Channel -notin @('tester','stable')) { throw 'Unknown update channel.' }
    $chosen=$null; $best=$null
    foreach ($r in @($Releases)) {
        if ($r.draft -or ($Channel -eq 'stable' -and $r.prerelease)) { continue }
        if (@($r.assets | Where-Object {$_.name -ceq 'wcf-update.json'}).Count -ne 1) { continue }
        $v=([string]$r.tag_name) -creplace '^v',''
        try { $parsed=ConvertTo-WcfVersion $v } catch { continue }
        if ($Channel -eq 'stable' -and $parsed.pre.Count) { continue }
        if (!$chosen -or (Compare-WcfVersion $v $best) -gt 0) { $chosen=$r; $best=$v }
    }
    $chosen
}

function Get-WcfRemoteSource([string]$Root,[string]$Work) {
    $config=Read-WcfJson (Resolve-WcfChild $Root 'gameupdate/config.json') 65536
    if ($config.schemaVersion -ne 1 -or $config.owner -notmatch '^[A-Za-z0-9][A-Za-z0-9-]*$' -or
        $config.repo -notmatch '^[A-Za-z0-9][A-Za-z0-9_.-]*$') { throw 'Invalid update repository configuration.' }
    $url='https://api.github.com/repos/'+$config.owner+'/'+$config.repo+'/releases?per_page=100'
    [Net.ServicePointManager]::SecurityProtocol=[Net.SecurityProtocolType]::Tls12
    $releases=Invoke-RestMethod -UseBasicParsing -Uri $url -TimeoutSec 30 -Headers @{
        'User-Agent'='WCF-Updater/1'; 'Accept'='application/vnd.github+json'; 'X-GitHub-Api-Version'='2026-03-10'
    }
    $release=Select-WcfRelease $releases $config.channel
    if (!$release) { return $null }
    $asset=@($release.assets | Where-Object {$_.name -ceq 'wcf-update.json'})[0]
    if ([long]$asset.size -gt 8388608) { throw 'Release manifest is too large.' }
    Assert-WcfAssetUrl $asset.browser_download_url $config 'wcf-update.json'
    $path=Join-Path $Work 'wcf-update.json'
    Save-WcfDownload $asset.browser_download_url $path ([long]$asset.size)
    if ($asset.PSObject.Properties['digest'] -and $asset.digest -match '^sha256:(.+)$') {
        if ((Get-WcfHash $path) -ne $Matches[1]) { throw 'Release manifest checksum mismatch.' }
    }
    $manifest=Read-WcfManifest $path
    if ($manifest.version -cne (([string]$release.tag_name) -creplace '^v','')) { throw 'Release tag and manifest version differ.' }
    [pscustomobject]@{ manifest=$manifest; release=$release; config=$config; directory=$null }
}

function Expand-WcfPackage([string]$Archive,[string]$Stage,$Package,$Manifest) {
    $file=Get-Item -LiteralPath $Archive
    if ($file.Length -ne [long]$Package.size -or (Get-WcfHash $Archive) -ne $Package.sha256) { throw "Package checksum/size mismatch: $($Package.name)" }
    $expected=@{}; $seen=@{}
    foreach ($f in @($Manifest.files | Where-Object {$_.package -eq $Package.name})) { $expected[$f.path]=$f }
    $zip=[IO.Compression.ZipFile]::OpenRead($Archive)
    try {
        foreach ($entry in $zip.Entries) {
            $relative=$entry.FullName
            Assert-WcfRelativePath $relative
            if (!$expected.ContainsKey($relative) -or $seen.ContainsKey($relative)) { throw "Unexpected or duplicate ZIP entry: $relative" }
            if ((($entry.ExternalAttributes -shr 16) -band 61440) -eq 40960) { throw 'ZIP symbolic links are not supported.' }
            $f=$expected[$relative]
            if ($entry.Length -ne [long]$f.size) { throw "ZIP expanded size mismatch: $relative" }
            $dest=Resolve-WcfChild $Stage $relative
            [IO.Directory]::CreateDirectory([IO.Path]::GetDirectoryName($dest)) | Out-Null
            $entryStream=$entry.Open(); $output=[IO.File]::Create($dest)
            try { $entryStream.CopyTo($output) } finally { $output.Dispose(); $entryStream.Dispose() }
            if ((Get-WcfHash $dest) -ne $f.sha256) { throw "File checksum mismatch: $relative" }
            $seen[$relative]=$true
        }
        if ($seen.Count -ne $expected.Count) { throw 'ZIP package is missing manifest files.' }
    } finally { $zip.Dispose() }
}

function Get-WcfStagedFiles($Source,$Plan,[string]$Work) {
    $stage=Join-Path $Work 'files'; [IO.Directory]::CreateDirectory($stage) | Out-Null
    $needed=@($Plan.writes | Select-Object -ExpandProperty package -Unique)
    foreach ($name in $needed) {
        $p=@($Source.manifest.packages | Where-Object {$_.name -ceq $name})[0]
        $archive=Join-Path $Work $name
        Write-Host ('Downloading package: '+$name)
        if ($Source.directory) {
            $from=Resolve-WcfChild $Source.directory $name
            Copy-Item -LiteralPath $from -Destination $archive
        } else {
            $assets=@($Source.release.assets | Where-Object {$_.name -ceq $name})
            if ($assets.Count -ne 1 -or [long]$assets[0].size -ne [long]$p.size) { throw "Missing or inconsistent release package: $name" }
            Assert-WcfAssetUrl $assets[0].browser_download_url $Source.config $name
            Save-WcfDownload $assets[0].browser_download_url $archive ([long]$p.size)
        }
        Expand-WcfPackage $archive $stage $p $Source.manifest
    }
    $stage
}

function Get-WcfTransactionPath([string]$Root,[string]$Id) {
    if ($Id -notmatch '^[a-f0-9]{32}$') { throw 'Invalid transaction ID.' }
    Resolve-WcfChild $Root ('gameupdate/backups/txn-'+$Id)
}

function Copy-WcfAtomicFile([string]$From,[string]$To) {
    # The source was verified before this function. Copy beside the target,
    # then replace it atomically, avoiding partially-written live files.
    [IO.Directory]::CreateDirectory([IO.Path]::GetDirectoryName($To)) | Out-Null
    $temp=$To+'.wcf-new-'+[guid]::NewGuid().ToString('N')
    try {
        [IO.File]::Copy($From,$temp,$false)
        if ([IO.File]::Exists($To)) { [IO.File]::Replace($temp,$To,[System.Management.Automation.Language.NullString]::Value) }
        else { [IO.File]::Move($temp,$To) }
    } finally { if ([IO.File]::Exists($temp)) { [IO.File]::Delete($temp) } }
}

function Restore-WcfTransaction([string]$Root,[string]$Id) {
    Assert-WcfGameClosed $Root
    $folder=Get-WcfTransactionPath $Root $Id
    $journal=Read-WcfJson (Resolve-WcfChild $folder 'journal.json')
    if ($journal.schemaVersion -ne 1 -or $journal.id -ne $Id) { throw 'Invalid recovery journal.' }
    # Validate everything before recovery touches the game. Never delete a
    # directory, a save or an arbitrary path supplied by a modified journal.
    foreach ($a in @($journal.actions)) {
        if (!(Test-WcfManagedPath $a.path) -or $a.existed -isnot [bool]) { throw 'Unsafe recovery action.' }
        $target=Resolve-WcfChild $Root $a.path
        if (Test-Path -LiteralPath $target -PathType Container) { throw 'Recovery target is a directory.' }
        if ($a.existed) {
            $backup=Resolve-WcfChild $folder ('files/'+$a.path)
            if (!(Test-Path -LiteralPath $backup -PathType Leaf) -or (Get-WcfHash $backup) -ne $a.sha256) { throw 'Recovery backup is missing or damaged.' }
        }
    }
    $state=Resolve-WcfChild $Root 'gameupdate/installed.json'
    if ($journal.hadState) {
        $original=Resolve-WcfChild $folder 'original-state.json'
        if ((Get-WcfHash $original) -ne $journal.stateSha256) { throw 'Original installed manifest is damaged.' }
    }
    foreach ($a in @($journal.actions)) {
        $target=Resolve-WcfChild $Root $a.path
        if ($a.existed) { Copy-WcfAtomicFile (Resolve-WcfChild $folder ('files/'+$a.path)) $target }
        elseif ([IO.File]::Exists($target)) { [IO.File]::Delete($target) }
    }
    if ($journal.hadState) { Copy-WcfAtomicFile $original $state }
    elseif ([IO.File]::Exists($state)) { [IO.File]::Delete($state) }
    $journal.phase='rolled-back'
    Write-WcfJson (Resolve-WcfChild $folder 'journal.json') $journal
    $pending=Resolve-WcfChild $Root 'gameupdate/pending.json'
    if ([IO.File]::Exists($pending)) { [IO.File]::Delete($pending) }
    Write-WcfLog $Root ('Restored transaction '+$Id)
}

function Repair-WcfInterruptedUpdate([string]$Root) {
    $pointer=Resolve-WcfChild $Root 'gameupdate/pending.json'
    if (!(Test-Path -LiteralPath $pointer)) { return $false }
    $id=[string](Read-WcfJson $pointer 4096).id
    $folder=Get-WcfTransactionPath $Root $id
    $journal=Read-WcfJson (Resolve-WcfChild $folder 'journal.json')
    if ($journal.phase -in @('committed','rolled-back')) { [IO.File]::Delete($pointer) }
    else {
        Write-Host 'Recovering an interrupted update...'
        Restore-WcfTransaction $Root $id
    }
    return $true
}

function Invoke-WcfTransaction([string]$Root,$Manifest,$Plan,[string]$Stage,[scriptblock]$AfterApply) {
    Assert-WcfGameClosed $Root
    $id=[guid]::NewGuid().ToString('N'); $folder=Get-WcfTransactionPath $Root $id
    [IO.Directory]::CreateDirectory($folder) | Out-Null
    $actions=@(); $paths=@($Plan.writes | ForEach-Object {$_.path})+@($Plan.deletes)
    foreach ($path in $paths) {
        $target=Resolve-WcfChild $Root $path
        $exists=[IO.File]::Exists($target); $hash=$null
        if ($exists) {
            $hash=Get-WcfHash $target
            $backup=Resolve-WcfChild $folder ('files/'+$path)
            [IO.Directory]::CreateDirectory([IO.Path]::GetDirectoryName($backup)) | Out-Null
            [IO.File]::Copy($target,$backup,$false)
            if ((Get-WcfHash $backup) -ne $hash) { throw 'Original file changed while backing up.' }
        }
        $actions += [pscustomobject]@{path=$path; existed=$exists; sha256=$hash}
    }
    $state=Resolve-WcfChild $Root 'gameupdate/installed.json'; $hadState=[IO.File]::Exists($state); $stateHash=$null
    if ($hadState) {
        $stateHash=Get-WcfHash $state
        [IO.File]::Copy($state,(Join-Path $folder 'original-state.json'),$false)
    }
    $journal=[pscustomobject]@{schemaVersion=1; id=$id; phase='prepared'; version=$Manifest.version;
        hadState=$hadState; stateSha256=$stateHash; actions=@($actions)}
    $journalPath=Join-Path $folder 'journal.json'
    Write-WcfJson $journalPath $journal
    $pointer=Resolve-WcfChild $Root 'gameupdate/pending.json'
    Write-WcfJson $pointer ([pscustomobject]@{id=$id})
    $journal.phase='applying'; Write-WcfJson $journalPath $journal
    try {
        Assert-WcfGameClosed $Root
        $index=0
        foreach ($f in @($Plan.writes)) {
            Assert-WcfGameClosed $Root
            $source=Resolve-WcfChild $Stage $f.path
            if ((Get-WcfHash $source) -ne $f.sha256) { throw 'Staged file changed before apply.' }
            Copy-WcfAtomicFile $source (Resolve-WcfChild $Root $f.path)
            $index++
            if ($AfterApply) { & $AfterApply $index }
        }
        foreach ($path in @($Plan.deletes)) { Assert-WcfGameClosed $Root; [IO.File]::Delete((Resolve-WcfChild $Root $path)) }
        Write-WcfJson $state $Manifest
        $journal.phase='committed'; Write-WcfJson $journalPath $journal
        Write-WcfJson (Resolve-WcfChild $Root 'gameupdate/last-success.json') ([pscustomobject]@{id=$id})
        [IO.File]::Delete($pointer)
        Write-WcfLog $Root ('Installed '+$Manifest.version+'; backup '+$id)
    } catch {
        $failure=$_.Exception.Message
        Write-WcfLog $Root ('Update failed: '+$failure)
        try { Restore-WcfTransaction $Root $id } catch {
            throw ('Recovery is pending. Close the game and run GameUpdate again. '+$_.Exception.Message)
        }
        throw ('Update was rolled back: '+$failure)
    }
    $id
}

function Invoke-WcfUpdate {
    [CmdletBinding()]
    param([Parameter(Mandatory=$true)][string]$GameRoot,[string]$PackageDirectory,
        [switch]$CheckOnly,[switch]$Rollback)
    $root=Assert-WcfGameRoot $GameRoot
    Assert-WcfGameClosed $root
    $lockPath=Resolve-WcfChild $root 'gameupdate/update.lock'
    [IO.Directory]::CreateDirectory([IO.Path]::GetDirectoryName($lockPath)) | Out-Null
    try { $lock=New-Object IO.FileStream($lockPath,[IO.FileMode]::OpenOrCreate,[IO.FileAccess]::ReadWrite,[IO.FileShare]::None) }
    catch { throw 'Another update is already running, or the game folder is not writable.' }
    $work=Join-Path ([IO.Path]::GetTempPath()) ('wcf-update-'+[guid]::NewGuid().ToString('N'))
    try {
        [IO.Directory]::CreateDirectory($work) | Out-Null
        Write-WcfLog $root 'Update started'
        $recovered=Repair-WcfInterruptedUpdate $root
        if ($Rollback) {
            $last=Resolve-WcfChild $root 'gameupdate/last-success.json'
            if (!(Test-Path -LiteralPath $last)) { throw 'No previous successful update is available to restore.' }
            $id=[string](Read-WcfJson $last 4096).id
            $folder=Get-WcfTransactionPath $root $id
            $journal=Read-WcfJson (Resolve-WcfChild $folder 'journal.json')
            if ($journal.phase -ne 'committed') { throw 'The previous update was already restored.' }
            Restore-WcfTransaction $root $id
            return [pscustomobject]@{status='rolled-back'; message='The previous game version has been restored.'}
        }
        if ($recovered) {
            return [pscustomobject]@{status='recovered'; message='Previous update recovered. Run GameUpdate again to check for updates.'}
        }
        if ($PackageDirectory) {
            $dir=[IO.Path]::GetFullPath($PackageDirectory)
            $source=[pscustomobject]@{manifest=(Read-WcfManifest (Resolve-WcfChild $dir 'wcf-update.json'));
                directory=$dir; release=$null; config=$null}
        } else {
            Write-Host 'Checking published WCF updates...'
            $source=Get-WcfRemoteSource $root $work
        }
        if (!$source) {
            return [pscustomobject]@{status='no-release'; message='No WCF update has been published for this channel yet. Game files are unchanged.'}
        }
        $manifest=$source.manifest
        $state=Resolve-WcfChild $root 'gameupdate/installed.json'; $installed=$null
        if (Test-Path -LiteralPath $state) { $installed=Read-WcfManifest $state }
        if ($installed -and (Compare-WcfVersion $manifest.version $installed.version) -lt 0) {
            return [pscustomobject]@{status='newer-installed'; message='This installation is newer than the published update. No downgrade applied.'}
        }
        Write-Host ('Available version: '+$manifest.version)
        if ($manifest.PSObject.Properties['notes'] -and $manifest.notes) { Write-Host ([string]$manifest.notes) }
        if ($manifest.requiresNewGame) { Write-Host 'This version requires New Game. Your existing saves will be kept.' -ForegroundColor Yellow }
        $plan=Get-WcfUpdatePlan $root $manifest $installed
        if (!$plan.writes.Count -and !$plan.deletes.Count -and $installed -and $installed.version -eq $manifest.version) {
            return [pscustomobject]@{status='up-to-date'; message='Your WCF game is up to date.'}
        }
        Write-Host ('Files to update: '+$plan.writes.Count+'; obsolete managed files: '+$plan.deletes.Count)
        if ($CheckOnly) {
            return [pscustomobject]@{status='available'; message=('Update '+$manifest.version+' is available. No game files changed.'); writes=$plan.writes.Count; deletes=$plan.deletes.Count}
        }
        $stage=Get-WcfStagedFiles $source $plan $work
        $null=Invoke-WcfTransaction $root $manifest $plan $stage
        $message='WCF updated to '+$manifest.version+'. Your saves and settings have been kept.'
        if ($manifest.requiresNewGame) { $message += ' Start a New Game for this version.' }
        [pscustomobject]@{status='updated'; message=$message}
    } catch {
        Write-WcfLog $root ('ERROR: '+$_.Exception.Message)
        throw
    } finally {
        $lock.Dispose()
        $tempBase=[IO.Path]::GetFullPath([IO.Path]::GetTempPath()).TrimEnd('\')+'\'
        $resolved=[IO.Path]::GetFullPath($work)
        if ($resolved.StartsWith($tempBase,[StringComparison]::OrdinalIgnoreCase) -and
            [IO.Path]::GetFileName($resolved) -match '^wcf-update-[a-f0-9]{32}$' -and (Test-Path -LiteralPath $resolved)) {
            Remove-Item -LiteralPath $resolved -Recurse -Force
        }
    }
}

Export-ModuleMember -Function Get-WcfHash,ConvertTo-WcfVersion,Compare-WcfVersion,Assert-WcfRelativePath,
    Test-WcfManagedPath,Resolve-WcfChild,Write-WcfJson,Read-WcfJson,Read-WcfManifest,Select-WcfRelease,Invoke-WcfUpdate
