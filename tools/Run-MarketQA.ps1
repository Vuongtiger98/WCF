param(
    [Parameter(Mandatory=$true)][string]$CaseList,
    [ValidateRange(1,2)][int]$Parallel=2,
    [int]$TimeoutSeconds=180
)
$ErrorActionPreference='Stop'
$projectRoot=Split-Path -Parent $PSScriptRoot
$saveRoot=[IO.Path]::GetFullPath((Join-Path $projectRoot 'Save')).TrimEnd('\')+'\'
$listPath=[IO.Path]::GetFullPath($CaseList)
$pending=New-Object 'System.Collections.Generic.Queue[string]'
foreach ($line in [IO.File]::ReadAllLines($listPath)) {
    if ($line.Trim()) { $pending.Enqueue([IO.Path]::GetFullPath((Join-Path $projectRoot $line.Trim()))) }
}
$active=@();$results=@()
while ($pending.Count -gt 0 -or $active.Count -gt 0) {
    while ($pending.Count -gt 0 -and $active.Count -lt $Parallel) {
        $run=$pending.Dequeue()
        if (!$run.StartsWith($saveRoot,[StringComparison]::OrdinalIgnoreCase)) { throw 'QA must stay inside Save.' }
        if (Test-Path -LiteralPath (Join-Path $run 'completion.marshal')) {
            Write-Output ('EXISTING '+[IO.Path]::GetFileName($run));continue
        }
        if (Test-Path -LiteralPath (Join-Path $run 'native.log')) { throw ('Use a fresh QA case: '+$run) }
        foreach ($folder in @('Graphics','Audio','System')) {
            if (!(Test-Path -LiteralPath (Join-Path $run $folder))) {
                New-Item -ItemType Junction -Path (Join-Path $run $folder) -Target (Join-Path $projectRoot $folder) | Out-Null
            }
        }
        $exe=Join-Path $run 'Game.exe'
        $process=Start-Process -FilePath $exe -WorkingDirectory $run -WindowStyle Hidden -PassThru
        $active+= [pscustomobject]@{process=$process;run=$run;exe=$exe;started=[DateTime]::UtcNow}
        Write-Output ('START '+[IO.Path]::GetFileName($run)+' pid='+$process.Id)
    }
    foreach ($entry in @($active)) {
        $elapsed=([DateTime]::UtcNow-$entry.started).TotalSeconds
        $timeout=$elapsed -gt $TimeoutSeconds
        if (!$entry.process.HasExited -and !$timeout) { continue }
        if ($timeout -and !$entry.process.HasExited) {
            if ($entry.process.Path -eq $entry.exe) { $entry.process.Kill();$entry.process.WaitForExit() }
        }
        $status=if ($timeout) {'timeout'} elseif (Test-Path -LiteralPath (Join-Path $entry.run 'failure.marshal')) {'native-failure'}
            elseif (Test-Path -LiteralPath (Join-Path $entry.run 'completion.marshal')) {'recorded'} else {'missing-result'}
        $results+=[pscustomobject]@{name=[IO.Path]::GetFileName($entry.run);status=$status;seconds=[Math]::Round($elapsed,1);exitCode=$entry.process.ExitCode}
        Write-Output ('DONE '+[IO.Path]::GetFileName($entry.run)+' '+$status+' seconds='+[Math]::Round($elapsed,1))
        $entry.process.Dispose()
        $active=@($active | Where-Object {$_ -ne $entry})
        [IO.File]::WriteAllText((Join-Path ([IO.Path]::GetDirectoryName($listPath)) 'batch-results.json'),
            (ConvertTo-Json -InputObject @($results) -Depth 4),(New-Object Text.UTF8Encoding($false)))
    }
    Start-Sleep -Milliseconds 250
}
Write-Output 'MARKET_BATCH_FINISHED'
