#Requires -Version 5.1
[CmdletBinding()]
param(
    [Parameter(Mandatory=$true)][string]$Version,
    [string]$SourceDirectory,
    [string]$OutputDirectory,
    [switch]$RequiresNewGame,
    [string]$Notes=''
)
$ErrorActionPreference='Stop'
if (!$SourceDirectory) { $SourceDirectory=Split-Path -Parent $PSScriptRoot }
Import-Module (Join-Path $PSScriptRoot '../gameupdate/WcfUpdater.psm1') -Force -DisableNameChecking
$null=ConvertTo-WcfVersion $Version
$source=[IO.Path]::GetFullPath($SourceDirectory).TrimEnd('\','/')
if (!$OutputDirectory) { $OutputDirectory=Join-Path $source ('dist/wcf-'+$Version) }
$out=[IO.Path]::GetFullPath($OutputDirectory).TrimEnd('\','/')
if ($out -eq $source -or (Test-Path -LiteralPath $out)) { throw 'Use a new output directory. Existing builds are never overwritten.' }
foreach ($folder in @('Data','Audio','Graphics','Movies','System','gameupdate')) {
    $prefix=(Join-Path $source $folder).TrimEnd('\')+'\'
    if ($out.StartsWith($prefix,[StringComparison]::OrdinalIgnoreCase)) { throw 'Output cannot be placed inside runtime source directories.' }
}
foreach ($required in @('Game.exe','Game.ini','Data/Scripts.rvdata2','GameUpdate.bat','gameupdate/Update.ps1','gameupdate/WcfUpdater.psm1','gameupdate/config.json')) {
    $path=Resolve-WcfChild $source $required
    if (!(Test-Path -LiteralPath $path -PathType Leaf)) { throw "Missing build input: $required" }
}
$release=Join-Path $out 'release'; $game=Join-Path $out 'game'
[IO.Directory]::CreateDirectory($release) | Out-Null
[IO.Directory]::CreateDirectory($game) | Out-Null
$paths=New-Object 'System.Collections.Generic.List[string]'
foreach ($name in @('Game.exe','Game.ini','Khas Graphics Library.dll','GameUpdate.bat','gameupdate/Update.ps1','gameupdate/WcfUpdater.psm1')) {
    if (Test-Path -LiteralPath (Join-Path $source $name) -PathType Leaf) { $paths.Add($name) }
}
$skipped=@()
foreach ($folder in @('Data','Graphics','Audio','Movies','System')) {
    $directory=Join-Path $source $folder
    if (!(Test-Path -LiteralPath $directory)) { continue }
    foreach ($file in Get-ChildItem -LiteralPath $directory -Recurse -File) {
        $relative=$file.FullName.Substring($source.Length+1).Replace('\','/')
        if (Test-WcfManagedPath $relative) { $paths.Add($relative) }
        else { $skipped += $relative }
    }
}
$ordered=$paths.ToArray(); [Array]::Sort($ordered,[StringComparer]::Ordinal)
$groups=@{}; $files=@()
foreach ($relative in $ordered) {
    $path=Resolve-WcfChild $source $relative
    $parts=$relative.Split('/')
    $bucket='core'
    if ($parts[0] -in @('Graphics','Audio')) {
        $segment=if ($parts.Count -gt 2) {$parts[1].ToLowerInvariant()} else {'root'}
        $segment=$segment -replace '[^a-z0-9-]','-'
        $bucket=$parts[0].ToLowerInvariant()+'-'+$segment
    } elseif ($parts[0] -in @('Data','Movies','System')) { $bucket=$parts[0].ToLowerInvariant() }
    $name='wcf-'+$bucket+'.zip'
    if (!$groups.ContainsKey($name)) { $groups[$name]=New-Object 'System.Collections.Generic.List[string]' }
    $groups[$name].Add($relative)
    $dest=Resolve-WcfChild $game $relative
    [IO.Directory]::CreateDirectory([IO.Path]::GetDirectoryName($dest)) | Out-Null
    [IO.File]::Copy($path,$dest,$false)
    $files += [pscustomobject]@{path=$relative; size=(Get-Item -LiteralPath $dest).Length; sha256=(Get-WcfHash $dest); package=$name}
}
function New-WcfBuildZip([string]$Path,[string]$Base,[string[]]$Entries) {
    $stream=[IO.File]::Open($Path,[IO.FileMode]::CreateNew)
    $zip=New-Object IO.Compression.ZipArchive($stream,[IO.Compression.ZipArchiveMode]::Create)
    try {
        foreach ($relative in $Entries) {
            $entry=$zip.CreateEntry($relative,[IO.Compression.CompressionLevel]::Optimal)
            $entry.LastWriteTime=New-Object DateTimeOffset(2000,1,1,0,0,0,[TimeSpan]::Zero)
            $inputStream=[IO.File]::OpenRead((Resolve-WcfChild $Base $relative)); $outputStream=$entry.Open()
            try {$inputStream.CopyTo($outputStream)} finally {$outputStream.Dispose();$inputStream.Dispose()}
        }
    } finally { $zip.Dispose();$stream.Dispose() }
}
$packages=@(); $names=@($groups.Keys); [Array]::Sort($names,[StringComparer]::Ordinal)
foreach ($name in $names) {
    $zip=Join-Path $release $name
    New-WcfBuildZip $zip $game $groups[$name].ToArray()
    $packages += [pscustomobject]@{name=$name; size=(Get-Item -LiteralPath $zip).Length; sha256=(Get-WcfHash $zip)}
}
$commit=$null; $dirty=$null
if (Test-Path -LiteralPath (Join-Path $source '.git')) {
    $commit=(& git -C $source rev-parse HEAD 2>$null | Out-String).Trim()
    $dirty=[bool]@(& git -C $source status --porcelain 2>$null).Count
}
$manifest=[pscustomobject]@{schemaVersion=1; gameId='wonder-christmas-fiesta'; version=$Version;
    createdUtc=[DateTime]::UtcNow.ToString('o'); requiresNewGame=[bool]$RequiresNewGame; notes=$Notes;
    sourceCommit=$commit; sourceDirty=$dirty; files=@($files); packages=@($packages)}
Write-WcfJson (Join-Path $release 'wcf-update.json') $manifest
$null=Read-WcfManifest (Join-Path $release 'wcf-update.json')
[IO.File]::Copy((Join-Path $release 'wcf-update.json'),(Resolve-WcfChild $game 'gameupdate/installed.json'),$false)
[IO.File]::Copy((Resolve-WcfChild $source 'gameupdate/config.json'),(Resolve-WcfChild $game 'gameupdate/config.json'),$false)
$fullEntries=@($ordered)+@('gameupdate/config.json','gameupdate/installed.json')
New-WcfBuildZip (Join-Path $release ('wcf-game-'+$Version+'.zip')) $game $fullEntries
# First-time testers can add the updater to an existing unpacked game without
# downloading the full game. No installed manifest or player data is included.
$bootstrapEntries=@('GameUpdate.bat','gameupdate/Update.ps1','gameupdate/WcfUpdater.psm1','gameupdate/config.json')
New-WcfBuildZip (Join-Path $release 'wcf-updater-bootstrap.zip') $game $bootstrapEntries
Write-WcfJson (Join-Path $out 'build-report.json') ([pscustomobject]@{version=$Version; files=$files.Count;
    packages=$packages.Count; skipped=@($skipped); sourceCommit=$commit; sourceDirty=$dirty; published=$false})
Write-Host ('Built '+$Version+': '+$files.Count+' runtime files in '+$packages.Count+' update packages.')
Write-Host ('Unpacked game: '+$game)
Write-Host ('Release assets (not published): '+$release)
