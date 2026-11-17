#Requires -Version 5.1
# No Pester, network, GitHub credentials, real game process or real saves needed.
$ErrorActionPreference='Stop'
$root=Split-Path -Parent $PSScriptRoot
Import-Module (Join-Path $root 'gameupdate/WcfUpdater.psm1') -Force -DisableNameChecking
$caseRoot=Join-Path $root ('Save/UpdaterQA/'+[guid]::NewGuid().ToString('N'))
[IO.Directory]::CreateDirectory($caseRoot) | Out-Null
$script:checks=0
function Assert-Update($Condition,[string]$Message) {
    if (!$Condition) { throw ('FAIL: '+$Message) }
    $script:checks++; Write-Host ('PASS '+$Message)
}
function Expect-UpdateFailure([scriptblock]$Action,[string]$Message) {
    $failed=$false
    try { & $Action | Out-Null } catch { $failed=$true; Write-Host ('EXPECTED: '+$_.Exception.Message) }
    Assert-Update $failed $Message
}
function Set-TestFile([string]$Base,[string]$Relative,[string]$Text) {
    $p=Resolve-WcfChild $Base $Relative
    [IO.Directory]::CreateDirectory([IO.Path]::GetDirectoryName($p)) | Out-Null
    [IO.File]::WriteAllText($p,$Text,(New-Object Text.UTF8Encoding($false)))
}
function Copy-TestTree([string]$From,[string]$To) {
    [IO.Directory]::CreateDirectory($To) | Out-Null
    foreach ($f in Get-ChildItem -LiteralPath $From -Recurse -File) {
        $relative=$f.FullName.Substring($From.Length+1).Replace('\','/')
        $dest=Resolve-WcfChild $To $relative
        [IO.Directory]::CreateDirectory([IO.Path]::GetDirectoryName($dest)) | Out-Null
        [IO.File]::Copy($f.FullName,$dest,$false)
    }
}
function Snapshot-TestGame([string]$Base) {
    $snapshot=@{}
    foreach ($f in Get-ChildItem -LiteralPath $Base -Recurse -File) {
        $p=$f.FullName.Substring($Base.Length+1).Replace('\','/')
        if ($p -match '^gameupdate/(backups/|update\.(log|lock)$|pending\.json$|last-success\.json$)') {continue}
        $snapshot[$p]=Get-WcfHash $f.FullName
    }
    $snapshot
}
function Assert-Snapshot([string]$Base,$Before,[string]$Message) {
    $after=Snapshot-TestGame $Base
    $equal=$Before.Count -eq $after.Count
    foreach ($p in $Before.Keys) { if (!$after.ContainsKey($p) -or $after[$p] -ne $Before[$p]) {$equal=$false} }
    Assert-Update $equal $Message
}

try {
    $seed=Join-Path $caseRoot 'source'
    [IO.Directory]::CreateDirectory($seed) | Out-Null
    foreach ($p in @('Game.exe','Khas Graphics Library.dll','Data/Scripts.rvdata2','Data/Map001.rvdata2','Data/Map099.rvdata2','System/RGSS301.dll','Audio/SE/a.ogg')) {
        Set-TestFile $seed $p ('v1 '+$p)
    }
    Set-TestFile $seed 'Game.ini' "[Game]`r`nTitle=Wonder Christmas Fiesta`r`nLibrary=System\RGSS301.dll`r`nScripts=Data\Scripts.rvdata2`r`n"
    Set-TestFile $seed 'Game.rvproj2' 'RPGVXAce 1.02'
    $image='Graphics/Pictures/$H'+[char]0x1EA3+'i Qu'+[char]0x1EF3+' [1]! %.png'
    Set-TestFile $seed $image 'picture one'
    Set-TestFile $seed 'Graphics/Pictures/source.psd' 'not for players'
    Set-TestFile $seed 'Data/codex_backup_dummy/Map001.rvdata2' 'backup must not ship'
    foreach ($p in @('GameUpdate.bat','gameupdate/Update.ps1','gameupdate/WcfUpdater.psm1','gameupdate/config.json')) {
        $dest=Resolve-WcfChild $seed $p
        [IO.Directory]::CreateDirectory([IO.Path]::GetDirectoryName($dest)) | Out-Null
        [IO.File]::Copy((Join-Path $root $p),$dest,$false)
    }
    Set-TestFile $seed 'Save01.rvdata2' 'developer save must not ship'
    Set-TestFile $seed 'HaiQuy.txt' 'developer easter flag must not ship'
    Set-TestFile $seed 'Graphics Settings.cfg' 'developer preferences must not ship'
    $v1=Join-Path $caseRoot 'v1'
    $fixtureBuilder=Join-Path $seed 'tools/Build-Update.ps1'
    [IO.Directory]::CreateDirectory([IO.Path]::GetDirectoryName($fixtureBuilder)) | Out-Null
    [IO.File]::Copy((Join-Path $PSScriptRoot 'Build-Update.ps1'),$fixtureBuilder,$false)
    $shell=(Get-Process -Id $PID).Path
    $buildArgs=@('-NoProfile','-ExecutionPolicy','Bypass','-File',('"'+$fixtureBuilder+'"'),
        '-Version','0.1.0-test.1','-OutputDirectory',('"'+$v1+'"'))
    $process=Start-Process -FilePath $shell -ArgumentList $buildArgs -WindowStyle Hidden -PassThru -Wait
    Assert-Update ($process.ExitCode -eq 0) 'standalone builder resolves its default source directory'
    $m1=Read-WcfManifest (Join-Path $v1 'release/wcf-update.json')
    Assert-Update (@($m1.files | Where-Object {$_.path -eq $image}).Count -eq 1) 'Unicode/special-character resource names are preserved'
    Assert-Update (!(Test-Path -LiteralPath (Join-Path $v1 'game/Save01.rvdata2'))) 'packager omits developer saves'
    Assert-Update (!(Test-Path -LiteralPath (Join-Path $v1 'game/HaiQuy.txt'))) 'packager omits mutable title-state flag'
    Assert-Update (@($m1.files | Where-Object {$_.path -match 'source.psd|codex_backup'}).Count -eq 0) 'packager omits source art and data backups'
    Set-TestFile $seed 'Data/Map001.rvdata2' 'v2 map'
    Set-TestFile $seed 'Data/Map002.rvdata2' 'new map'
    [IO.File]::Delete((Join-Path $seed 'Data/Map099.rvdata2'))
    Set-TestFile $seed $image 'picture two'
    $v2=Join-Path $caseRoot 'v2'
    & (Join-Path $PSScriptRoot 'Build-Update.ps1') -Version '0.1.0-test.2' -SourceDirectory $seed -OutputDirectory $v2 -RequiresNewGame -Notes 'Test only'
    $m2=Read-WcfManifest (Join-Path $v2 'release/wcf-update.json')
    $game=Join-Path $caseRoot ('Game '+[char]0x1ED9+' [test]! % space')
    Copy-TestTree (Join-Path $v1 'game') $game
    $protected=@('Save01.rvdata2','Save/GlobalGallery.rvdata2','Save/preferences.txt','Graphics Settings.cfg','HaiQuy.txt','Graphics/Pictures/user-mod.png')
    $protectedHashes=@{}
    foreach ($p in $protected) { Set-TestFile $game $p ('player '+$p); $protectedHashes[$p]=Get-WcfHash (Join-Path $game $p) }
    $before=Snapshot-TestGame $game
    $check=Invoke-WcfUpdate -GameRoot $game -PackageDirectory (Join-Path $v2 'release') -CheckOnly
    Assert-Update ($check.status -eq 'available') 'check-only finds an update'
    Assert-Snapshot $game $before 'check-only does not change game/state/player data'
    # Unchanged audio/core/system packages need not even be available locally.
    foreach ($p in @($m2.packages | Where-Object {$_.name -notin @('wcf-data.zip','wcf-graphics-pictures.zip')})) {
        [IO.File]::Delete((Join-Path $v2 ('release/'+$p.name)))
    }
    $result=Invoke-WcfUpdate -GameRoot $game -PackageDirectory (Join-Path $v2 'release')
    Assert-Update ($result.status -eq 'updated') 'only changed package groups are downloaded/applied'
    Assert-Update ([IO.File]::ReadAllText((Join-Path $game 'Data/Map001.rvdata2')) -eq 'v2 map') 'changed map updated'
    Assert-Update (!(Test-Path -LiteralPath (Join-Path $game 'Data/Map099.rvdata2'))) 'obsolete previously-managed file removed'
    Assert-Update (Test-Path -LiteralPath (Join-Path $game 'Data/Map002.rvdata2')) 'new managed file installed'
    foreach ($p in $protected) { Assert-Update ((Get-WcfHash (Join-Path $game $p)) -eq $protectedHashes[$p]) ('player data/mod preserved: '+$p) }
    Assert-Update ((Invoke-WcfUpdate -GameRoot $game -PackageDirectory (Join-Path $v2 'release')).status -eq 'up-to-date') 'repeated update is a no-op'
    Assert-Update ((Invoke-WcfUpdate -GameRoot $game -PackageDirectory (Join-Path $v1 'release')).status -eq 'newer-installed') 'older version never silently downgrades'
    $rolled=Invoke-WcfUpdate -GameRoot $game -Rollback
    Assert-Update ($rolled.status -eq 'rolled-back') 'manual rollback succeeds'
    Assert-Snapshot $game $before 'rollback restores exact game/state bytes and preserves player data'
    $module=Get-Module WcfUpdater
    $plan=& $module {param($g,$m,$old) Get-WcfUpdatePlan $g $m $old} $game $m2 $m1
    $stageWork=Join-Path $caseRoot 'stage'; [IO.Directory]::CreateDirectory($stageWork) | Out-Null
    $source=[pscustomobject]@{manifest=$m2;directory=(Join-Path $v2 'release')}
    $stage=& $module {param($s,$p,$w) Get-WcfStagedFiles $s $p $w} $source $plan $stageWork
    Expect-UpdateFailure { & $module {param($g,$m,$p,$s) Invoke-WcfTransaction $g $m $p $s {param($i)throw 'injected write failure'}} $game $m2 $plan $stage } 'mid-apply failure is caught'
    Assert-Snapshot $game $before 'automatic rollback restores all bytes after a write failure'
    $locked=New-Object IO.FileStream((Join-Path $game 'Data/Map001.rvdata2'),[IO.FileMode]::Open,[IO.FileAccess]::ReadWrite,[IO.FileShare]::None)
    try { Expect-UpdateFailure {Invoke-WcfUpdate -GameRoot $game -PackageDirectory (Join-Path $v2 'release')} 'locked file fails before altering live game' } finally {$locked.Dispose()}
    Assert-Snapshot $game $before 'locked-file failure leaves game intact'
    $copyManifest=Join-Path $caseRoot 'bad.json'
    foreach ($bad in @('../Save01.rvdata2','/outside.png','Data/a.rvdata2:stream','Save01.rvdata2','Save/GlobalGallery.rvdata2','Graphics Settings.cfg','HaiQuy.txt','gameupdate/config.json','Graphics/CON.png','Graphics/a.png.','Graphics//a.png','Graphics/a"b.png')) {
        $evil=$m2 | ConvertTo-Json -Depth 20 | ConvertFrom-Json
        $evil.files[0].path=$bad; Write-WcfJson $copyManifest $evil
        Expect-UpdateFailure {Read-WcfManifest $copyManifest} ('reject unsafe/protected manifest path '+$bad)
    }
    $evil=$m2 | ConvertTo-Json -Depth 20 | ConvertFrom-Json
    $evil.files[1].path=$evil.files[0].path.ToUpperInvariant(); Write-WcfJson $copyManifest $evil
    Expect-UpdateFailure {Read-WcfManifest $copyManifest} 'case-insensitive path duplicates rejected'
    $evil=$m2 | ConvertTo-Json -Depth 20 | ConvertFrom-Json
    $evil.gameId='another-game'; Write-WcfJson $copyManifest $evil
    Expect-UpdateFailure {Read-WcfManifest $copyManifest} 'wrong game manifest rejected'
    # ZIP corruption and ZIP-slip rejection before any live write.
    $badRelease=Join-Path $caseRoot 'bad-release'; Copy-TestTree (Join-Path $v2 'release') $badRelease
    [IO.File]::AppendAllText((Join-Path $badRelease 'wcf-data.zip'),'corrupt')
    Expect-UpdateFailure {Invoke-WcfUpdate -GameRoot $game -PackageDirectory $badRelease} 'corrupt package rejected'
    Assert-Snapshot $game $before 'bad download cannot partially update the game'
    $zipSlip=Join-Path $caseRoot 'zip-slip'; Copy-TestTree (Join-Path $v2 'release') $zipSlip
    $zipPath=Join-Path $zipSlip 'wcf-data.zip'
    $zip=[IO.Compression.ZipFile]::Open($zipPath,[IO.Compression.ZipArchiveMode]::Update)
    try {$entry=$zip.CreateEntry('../outside.txt');$stream=$entry.Open();$stream.WriteByte(88);$stream.Dispose()} finally {$zip.Dispose()}
    $evil=Read-WcfJson (Join-Path $zipSlip 'wcf-update.json')
    $p=@($evil.packages | Where-Object {$_.name -eq 'wcf-data.zip'})[0]
    $p.sha256=Get-WcfHash $zipPath; $p.size=(Get-Item -LiteralPath $zipPath).Length
    Write-WcfJson (Join-Path $zipSlip 'wcf-update.json') $evil
    Expect-UpdateFailure {Invoke-WcfUpdate -GameRoot $game -PackageDirectory $zipSlip} 'ZIP traversal rejected even with matching archive checksum'
    Assert-Snapshot $game $before 'ZIP traversal leaves game intact'
    # Reject a junction without following it outside the installation.
    $linkedTarget=Join-Path $caseRoot 'outside-game'
    [IO.Directory]::CreateDirectory($linkedTarget) | Out-Null
    $junction=Join-Path $game 'Graphics/linked'
    New-Item -ItemType Junction -Path $junction -Target $linkedTarget | Out-Null
    try {
        Expect-UpdateFailure {Resolve-WcfChild $game 'Graphics/linked/escape.png'} 'junction path cannot redirect an update outside the game'
    } finally {
        if ((Get-Item -LiteralPath $junction -Force).Attributes -band [IO.FileAttributes]::ReparsePoint) {
            [IO.Directory]::Delete($junction)
        }
    }
    # A harmless local ping process named Game.exe exercises the running-game guard.
    $running=Join-Path $caseRoot 'running-game'; Copy-TestTree (Join-Path $v1 'game') $running
    [IO.File]::Copy((Join-Path $env:SystemRoot 'System32/ping.exe'),(Join-Path $running 'Game.exe'),$true)
    $runningProcess=Start-Process -FilePath (Join-Path $running 'Game.exe') -ArgumentList @('-n','60','127.0.0.1') -WindowStyle Hidden -PassThru
    try {
        Expect-UpdateFailure {Invoke-WcfUpdate -GameRoot $running -PackageDirectory (Join-Path $v2 'release')} 'running game is rejected before update'
    } finally {
        if (!$runningProcess.HasExited) { $runningProcess.Kill(); $runningProcess.WaitForExit() }
        $runningProcess.Dispose()
    }
    Set-TestFile $game '.git' 'developer marker'
    $accepted=& $module {param($g) Assert-WcfGameRoot $g} $game
    Assert-Update ($accepted -eq [IO.Path]::GetFullPath($game)) 'project folder is accepted even with a Git marker'
    [IO.File]::Delete((Join-Path $game '.git'))
    $held=New-Object IO.FileStream((Join-Path $game 'gameupdate/update.lock'),[IO.FileMode]::OpenOrCreate,[IO.FileAccess]::ReadWrite,[IO.FileShare]::None)
    try {Expect-UpdateFailure {Invoke-WcfUpdate -GameRoot $game -PackageDirectory (Join-Path $v2 'release')} 'concurrent updater is rejected'} finally {$held.Dispose()}
    Assert-Update ((Compare-WcfVersion '1.0.0-test.10' '1.0.0-test.2') -gt 0) 'numeric prerelease ordering is correct'
    Assert-Update ((Compare-WcfVersion '1.0.0' '1.0.0-rc.2') -gt 0) 'stable version follows prerelease'
    Assert-Update ((Compare-WcfVersion '1.0.0+a' '1.0.0+b') -eq 0) 'build metadata does not change version precedence'
    Assert-Update ((Compare-WcfVersion '1.0.0-A' '1.0.0-a') -lt 0) 'prerelease identifiers use case-sensitive ASCII ordering'
    $releases=@(
        [pscustomobject]@{tag_name='v1.0.0';draft=$false;prerelease=$false;assets=@([pscustomobject]@{name='wcf-update.json'})},
        [pscustomobject]@{tag_name='v1.1.0-test.1';draft=$false;prerelease=$true;assets=@([pscustomobject]@{name='wcf-update.json'})},
        [pscustomobject]@{tag_name='v9.0.0';draft=$true;prerelease=$false;assets=@([pscustomobject]@{name='wcf-update.json'})})
    Assert-Update ((Select-WcfRelease $releases tester).tag_name -eq 'v1.1.0-test.1') 'tester channel includes published prereleases but not drafts'
    Assert-Update ((Select-WcfRelease $releases stable).tag_name -eq 'v1.0.0') 'stable channel excludes prereleases'
    Assert-Update ($null -eq (Select-WcfRelease @() tester)) 'no release is a normal empty result'
    # Abrupt process termination bypasses catch/finally, leaving a real journal.
    $child=Join-Path $caseRoot 'crash.ps1'
    $childText=@'
param($ModulePath,$GamePath,$ManifestPath,$OldPath,$StagePath)
Import-Module $ModulePath -Force -DisableNameChecking
$module=Get-Module WcfUpdater
$m=Read-WcfManifest $ManifestPath; $old=Read-WcfManifest $OldPath
$plan=& $module {param($g,$m,$o) Get-WcfUpdatePlan $g $m $o} $GamePath $m $old
& $module {param($g,$m,$p,$s) Invoke-WcfTransaction $g $m $p $s {param($i)[Environment]::Exit(86)}} $GamePath $m $plan $StagePath
'@
    [IO.File]::WriteAllText($child,$childText)
    $shell=(Get-Process -Id $PID).Path
    $childArguments=@('-NoProfile','-ExecutionPolicy','Bypass','-File',('"'+$child+'"'),
        '-ModulePath',('"'+(Join-Path $root 'gameupdate/WcfUpdater.psm1')+'"'),
        '-GamePath',('"'+$game+'"'),'-ManifestPath',('"'+(Join-Path $v2 'release/wcf-update.json')+'"'),
        '-OldPath',('"'+(Join-Path $v1 'release/wcf-update.json')+'"'),'-StagePath',('"'+$stage+'"'))
    $process=Start-Process -FilePath $shell -ArgumentList $childArguments -WindowStyle Hidden -PassThru -Wait
    Assert-Update ($process.ExitCode -eq 86) 'test updater really terminated mid-apply'
    Assert-Update (Test-Path -LiteralPath (Join-Path $game 'gameupdate/pending.json')) 'interrupted update retains recovery journal'
    Assert-Update ((Invoke-WcfUpdate -GameRoot $game -PackageDirectory (Join-Path $v2 'release')).status -eq 'recovered') 'next run recovers an interrupted update first'
    Assert-Snapshot $game $before 'interruption recovery restores exact previous version'
    # Entry script runs a detached module copy, including an updater self-update.
    Set-TestFile $seed 'gameupdate/WcfUpdater.psm1' ([IO.File]::ReadAllText((Join-Path $seed 'gameupdate/WcfUpdater.psm1'))+"`n# next updater build`n")
    $v3=Join-Path $caseRoot 'v3'
    & (Join-Path $PSScriptRoot 'Build-Update.ps1') -Version '0.1.0-test.3' -SourceDirectory $seed -OutputDirectory $v3
    $cliArgs=@('-NoProfile','-ExecutionPolicy','Bypass','-File',('"'+(Join-Path $game 'gameupdate/Update.ps1')+'"'),
        '-PackageDirectory',('"'+(Join-Path $v3 'release')+'"'))
    $process=Start-Process -FilePath $shell -ArgumentList $cliArgs -WindowStyle Hidden -PassThru -Wait
    Assert-Update ($process.ExitCode -eq 0) 'detached CLI completes a self-update'
    Assert-Update ((Get-WcfHash (Join-Path $game 'gameupdate/WcfUpdater.psm1')) -eq (Get-WcfHash (Join-Path $seed 'gameupdate/WcfUpdater.psm1'))) 'installed updater module replaced correctly'
    $report=[pscustomobject]@{checks=$script:checks; powershell=$PSVersionTable.PSVersion.ToString(); root=$caseRoot; completed=$true}
    Write-WcfJson (Join-Path $caseRoot 'results.json') $report
    Write-Host ('UPDATE_TESTS_OK checks='+$script:checks+' artifacts='+$caseRoot)
} catch {
    Write-Host ('UPDATE_TESTS_FAILED artifacts='+$caseRoot)
    throw
}
