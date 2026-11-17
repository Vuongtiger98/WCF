#Requires -Version 5.1
$ErrorActionPreference='Stop'
$root=Split-Path -Parent $PSScriptRoot
Import-Module (Join-Path $root 'gameupdate/WcfUpdater.psm1') -Force -DisableNameChecking
$qa=Join-Path $root ('Save/StartupUpdateQA/'+[guid]::NewGuid().ToString('N'))
[IO.Directory]::CreateDirectory($qa)|Out-Null
$checks=0
function Assert-Startup($Value,[string]$Name) {
    if(!$Value){throw ('FAIL '+$Name)}
    $script:checks++;Write-Output ('PASS '+$Name)
}
$seed=Join-Path $qa 'source'
[IO.Directory]::CreateDirectory((Join-Path $seed 'Data'))|Out-Null
[IO.Directory]::CreateDirectory((Join-Path $seed 'gameupdate'))|Out-Null
foreach($p in @('Game.exe','Data/Scripts.rvdata2')){[IO.File]::WriteAllText((Join-Path $seed $p),'fixture')}
[IO.File]::WriteAllText((Join-Path $seed 'Game.rvproj2'),'RPGVXAce 1.02')
[IO.File]::WriteAllText((Join-Path $seed 'Game.ini'),"[Game]`nTitle=Wonder Christmas Fiesta`n")
foreach($p in @('GameUpdate.bat','gameupdate/Update.ps1','gameupdate/WcfUpdater.psm1','gameupdate/config.json')){[IO.File]::Copy((Join-Path $root $p),(Join-Path $seed $p))}
$releases=@([pscustomobject]@{tag_name='v0.1.0-test.4';draft=$false;prerelease=$true;assets=@([pscustomobject]@{name='wcf-update.json'})})
$locked=New-Object IO.FileStream((Join-Path $seed 'Data/Scripts.rvdata2'),[IO.FileMode]::Open,[IO.FileAccess]::ReadWrite,[IO.FileShare]::None)
try {
    $v=Get-WcfStartupVersion -GameRoot $seed -CurrentVersion '0.1.0-test.3' -Releases $releases
    Assert-Startup ($v.status -eq 'available') 'new release detected without reading or hashing game data'
}finally{$locked.Dispose()}
Assert-Startup ((Get-WcfStartupVersion $seed '0.1.0-test.4' -Releases $releases).status -eq 'up-to-date') 'same version does not update'
Assert-Startup ((Get-WcfStartupVersion $seed '0.1.0-test.5' -Releases $releases).status -eq 'up-to-date') 'newer source never downgrades'
Assert-Startup ((Get-WcfStartupVersion $seed '0.1.0-test.3' -Releases @()).status -eq 'no-release') 'no published release allows play'
Write-WcfJson (Join-Path $seed 'gameupdate/installed.json') ([pscustomobject]@{gameId='wonder-christmas-fiesta';version='0.1.0-test.5'})
Assert-Startup ((Get-WcfStartupVersion $seed '0.1.0-test.3' -Releases $releases).current -eq '0.1.0-test.5') 'installed version can be newer than source floor'
Write-WcfJson (Join-Path $seed 'gameupdate/installed.json') ([pscustomobject]@{gameId='wonder-christmas-fiesta';version='0.1.0-test.1'})
Assert-Startup ((Get-WcfStartupVersion $seed '0.1.0-test.4' -Releases $releases).current -eq '0.1.0-test.4') 'source version can be newer than installed state'
[IO.File]::WriteAllText((Join-Path $seed 'gameupdate/pending.json'),'{}')
Assert-Startup ((Get-WcfStartupVersion $seed '0.1.0-test.3' -Releases @()).status -eq 'recovery') 'pending recovery is handled before play'
[IO.File]::Delete((Join-Path $seed 'gameupdate/pending.json'))
[IO.File]::Delete((Join-Path $seed 'gameupdate/installed.json'))

# Load only trusted function definitions, not the CLI entry point.
$tokens=$null;$parseErrors=$null
$ast=[Management.Automation.Language.Parser]::ParseFile((Join-Path $root 'gameupdate/Update.ps1'),[ref]$tokens,[ref]$parseErrors)
if($parseErrors.Count){throw ($parseErrors|Out-String)}
foreach($f in $ast.FindAll({param($node)$node -is [Management.Automation.Language.FunctionDefinitionAst]},$false)){Invoke-Expression $f.Extent.Text}
$GameRoot=$seed;$Session='111-222-1';$CurrentVersion='0.1.0-test.3'
$folder=Get-StartupFolder
[IO.File]::WriteAllText((Join-Path $folder 'handoff'),'1')
function Get-WcfStartupVersion { [pscustomobject]@{status='available';version='0.1.0-test.4'} }
Invoke-StartupCheck
Assert-Startup ([IO.File]::ReadAllText((Join-Path $folder 'check.txt')).Contains('status=available')) 'startup IPC writes a readable completed status'
Clear-StartupFolder $folder
$Session='111-222-2';$folder=Get-StartupFolder
[IO.File]::WriteAllText((Join-Path $folder 'cancel'),'1')
Invoke-StartupCheck
Assert-Startup (!(Test-Path -LiteralPath $folder)) 'cancelled startup leaves no late reply or session files'

$build=Join-Path $qa 'build'
& (Join-Path $PSScriptRoot 'Build-Update.ps1') -Version '0.1.0-test.3' -SourceDirectory $seed -OutputDirectory $build
$client=Join-Path $qa 'client'
[IO.Directory]::CreateDirectory((Join-Path $client 'Data'))|Out-Null
[IO.Directory]::CreateDirectory((Join-Path $client 'gameupdate'))|Out-Null
foreach($p in @('Game.exe','Game.ini','Game.rvproj2','Data/Scripts.rvdata2')){[IO.File]::Copy((Join-Path $seed $p),(Join-Path $client $p))}
[IO.File]::WriteAllText((Join-Path $client 'Save01.rvdata2'),'preserve me')
$GameRoot=$client;$Session='111-222-3';$PackageDirectory=Join-Path $build 'release'
Invoke-StartupApply
$folder=Get-StartupFolder;$state=Read-WcfJson (Join-Path $folder 'progress.json')
Assert-Startup ($state.status -eq 'complete' -and $state.canPlay) 'detached apply completes and reports safe restart'
Assert-Startup ([IO.File]::ReadAllText((Join-Path $client 'Save01.rvdata2')) -eq 'preserve me') 'startup apply preserves player save'
Assert-Startup ((Read-WcfManifest (Join-Path $client 'gameupdate/installed.json')).version -eq '0.1.0-test.3') 'startup apply installs the requested version'
Clear-StartupFolder $folder
Write-Output ('STARTUP_TESTS_OK checks='+$checks+' artifacts='+$qa)
