#Requires -Version 5.1
[CmdletBinding()]
param(
    [string]$GameRoot,
    [string]$PackageDirectory,
    [switch]$CheckOnly,
    [switch]$Rollback,
    [switch]$Pause
)
$ErrorActionPreference = 'Stop'
if (!$GameRoot) { $GameRoot=Split-Path -Parent $PSScriptRoot }
$worker = Join-Path ([IO.Path]::GetTempPath()) ('wcf-worker-' + [guid]::NewGuid().ToString('N'))
$exitCode = 1
try {
    [IO.Directory]::CreateDirectory($worker) | Out-Null
    # Run a detached copy so the installed updater can replace itself safely.
    Copy-Item -LiteralPath (Join-Path $PSScriptRoot 'WcfUpdater.psm1') -Destination $worker
    Import-Module (Join-Path $worker 'WcfUpdater.psm1') -Force -DisableNameChecking
    $result = Invoke-WcfUpdate -GameRoot $GameRoot -PackageDirectory $PackageDirectory -CheckOnly:$CheckOnly -Rollback:$Rollback
    Write-Host $result.message
    $exitCode = 0
} catch {
    Write-Host ('UPDATE FAILED: ' + $_.Exception.Message) -ForegroundColor Red
    Write-Host 'Your save files have not been removed. See gameupdate/update.log for details.'
} finally {
    Remove-Module WcfUpdater -ErrorAction SilentlyContinue
    $tempRoot = [IO.Path]::GetFullPath([IO.Path]::GetTempPath()).TrimEnd('\') + '\'
    $resolvedWorker = [IO.Path]::GetFullPath($worker)
    if ($resolvedWorker.StartsWith($tempRoot,[StringComparison]::OrdinalIgnoreCase) -and
        [IO.Path]::GetFileName($resolvedWorker) -match '^wcf-worker-[a-f0-9]{32}$' -and
        (Test-Path -LiteralPath $resolvedWorker)) {
        Remove-Item -LiteralPath $resolvedWorker -Recurse -Force
    }
}
if ($Pause) { Read-Host 'Press Enter to close' | Out-Null }
exit $exitCode
