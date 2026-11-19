#Requires -Version 5.1
[CmdletBinding()]
param(
    [string]$GameRoot,
    [string]$PackageDirectory,
    [switch]$CheckOnly,
    [switch]$Rollback,
    [switch]$Pause,
    [ValidateSet('','Check','Update','Apply')][string]$StartupMode='',
    [string]$Session,
    [int]$ParentId=0,
    [string]$CurrentVersion='0.1.0-test.6'
)
$ErrorActionPreference = 'Stop'
if (!$GameRoot) { $GameRoot=Split-Path -Parent $PSScriptRoot }
$worker = Join-Path ([IO.Path]::GetTempPath()) ('wcf-worker-' + [guid]::NewGuid().ToString('N'))
$exitCode = 1

function Get-StartupFolder {
    if ($Session -notmatch '^[0-9]+-[0-9]+-[0-9]+$') { throw 'Invalid startup session.' }
    $folder=Resolve-WcfChild ([IO.Path]::GetFullPath($GameRoot)) ('gameupdate/startup-'+$Session)
    [IO.Directory]::CreateDirectory($folder) | Out-Null
    $folder
}

function Clear-StartupFolder([string]$Folder) {
    $base=[IO.Path]::GetFullPath((Join-Path $GameRoot 'gameupdate')).TrimEnd('\')+'\'
    $path=[IO.Path]::GetFullPath($Folder)
    if (!$path.StartsWith($base,[StringComparison]::OrdinalIgnoreCase) -or
        [IO.Path]::GetFileName($path) -notmatch '^startup-[0-9]+-[0-9]+-[0-9]+$') { return }
    if (!(Test-Path -LiteralPath $path)) { return }
    if ((Get-Item -LiteralPath $path -Force).Attributes -band [IO.FileAttributes]::ReparsePoint) { return }
    # Session directories are flat. Never recurse through an unexpected child.
    foreach ($file in Get-ChildItem -LiteralPath $path -File -Force) { [IO.File]::Delete($file.FullName) }
    try { [IO.Directory]::Delete($path) } catch { }
}

function Invoke-StartupCheck {
    $folder=Get-StartupFolder
    try {
        try { $result=Get-WcfStartupVersion -GameRoot $GameRoot -CurrentVersion $CurrentVersion }
        catch { $result=[pscustomobject]@{status='offline';version=$CurrentVersion} }
        if (!(Test-Path -LiteralPath (Join-Path $folder 'cancel'))) {
            $bytes=(New-Object Text.UTF8Encoding($false)).GetBytes(('status='+$result.status+"`nversion="+$result.version+"`n"))
            & (Get-Module WcfUpdater) { param($p,$b) Write-WcfAtomicBytes $p $b } (Join-Path $folder 'check.txt') $bytes
        }
        $deadline=[DateTime]::UtcNow.AddSeconds(8)
        while ([DateTime]::UtcNow -lt $deadline) {
            if (Test-Path -LiteralPath (Join-Path $folder 'handoff')) { return }
            if (Test-Path -LiteralPath (Join-Path $folder 'cancel')) { break }
            Start-Sleep -Milliseconds 100
        }
    } finally {
        if (!(Test-Path -LiteralPath (Join-Path $folder 'handoff'))) { Clear-StartupFolder $folder }
    }
}

function Invoke-StartupApply {
    $folder=Get-StartupFolder
    $progress=Join-Path $folder 'progress.json'
    $callback={ param($event)
        Write-WcfJson $progress ([pscustomobject]@{status='running';stage=$event.stage;done=$event.done;total=$event.total})
    }.GetNewClosure()
    try {
        $result=Invoke-WcfUpdate -GameRoot $GameRoot -PackageDirectory $PackageDirectory -Progress $callback
        if ($result.status -eq 'recovered') {
            $result=Invoke-WcfUpdate -GameRoot $GameRoot -PackageDirectory $PackageDirectory -Progress $callback
        }
        if ($result.status -notin @('updated','up-to-date','newer-installed','no-release')) { throw $result.message }
        Write-WcfJson $progress ([pscustomobject]@{status='complete';stage='complete';done=1;total=1;canPlay=$true;message=$result.message})
    } catch {
        $safe=!(Test-Path -LiteralPath (Join-Path $GameRoot 'gameupdate/pending.json'))
        Write-WcfJson $progress ([pscustomobject]@{status='failed';stage='failed';done=0;total=0;canPlay=$safe;message=$_.Exception.Message})
        throw
    }
}

function Show-StartupUpdater([string]$WorkerScript) {
    $folder=Get-StartupFolder
    [IO.File]::WriteAllText((Join-Path $folder 'handoff'),'1')
    Add-Type -AssemblyName System.Windows.Forms
    Add-Type -AssemblyName System.Drawing
    [Windows.Forms.Application]::EnableVisualStyles()
    $form=New-Object Windows.Forms.Form
    $form.Text='Wonder Christmas Fiesta — Cập nhật'
    $form.ClientSize=New-Object Drawing.Size(560,360)
    $form.StartPosition='CenterScreen';$form.FormBorderStyle='FixedDialog';$form.MaximizeBox=$false
    $form.BackColor=[Drawing.Color]::FromArgb(15,23,39);$form.ForeColor=[Drawing.Color]::FromArgb(235,241,255)
    $form.Font=New-Object Drawing.Font('Segoe UI',11)
    $heading=New-Object Windows.Forms.Label
    $heading.SetBounds(24,20,512,36);$heading.Text='Đang cập nhật game';$heading.Font=New-Object Drawing.Font('Segoe UI',18,[Drawing.FontStyle]::Bold)
    $detail=New-Object Windows.Forms.Label
    $detail.SetBounds(26,70,506,44);$detail.Text='Đang chờ game đóng để cập nhật…'
    $detail.ForeColor=[Drawing.Color]::FromArgb(211,201,244)
    $bar=[pscustomobject]@{Style='Marquee';Value=0}
    $stage=New-Object Windows.Forms.Panel
    $stage.SetBounds(28,122,504,128)
    $doubleBuffer=$stage.GetType().GetProperty('DoubleBuffered',[Reflection.BindingFlags]'Instance,NonPublic')
    $doubleBuffer.SetValue($stage,$true,$null)
    $palette=@([Drawing.Color]::FromArgb(255,183,118),[Drawing.Color]::FromArgb(239,174,216),
        [Drawing.Color]::FromArgb(242,126,153),[Drawing.Color]::FromArgb(190,143,250),[Drawing.Color]::FromArgb(117,219,244))
    $brushes=@($palette|ForEach-Object {New-Object Drawing.SolidBrush($_)})
    $shadow=New-Object Drawing.SolidBrush([Drawing.Color]::FromArgb(10,18,33))
    $trackBrush=New-Object Drawing.SolidBrush([Drawing.Color]::FromArgb(80,83,119))
    $insideBrush=New-Object Drawing.SolidBrush([Drawing.Color]::FromArgb(12,20,37))
    $shineBrush=New-Object Drawing.SolidBrush([Drawing.Color]::FromArgb(150,255,255,255))
    $alienImages=@()
    foreach($i in 0..4) {
        $image=$null
        try {
            # Detach from disk so future asset updates never hit a held PNG file.
            $bytes=[IO.File]::ReadAllBytes((Join-Path $GameRoot ('Graphics/Invaders/alien'+$i+'.png')))
            $stream=New-Object IO.MemoryStream(,$bytes)
            try {
                $original=[Drawing.Image]::FromStream($stream)
                try {$image=New-Object Drawing.Bitmap($original)} finally {$original.Dispose()}
            } finally {$stream.Dispose()}
        } catch { }
        $alienImages+=,$image
    }
    $danceClock=[Diagnostics.Stopwatch]::StartNew()
    $stage.Add_Paint({param($sender,$event)
        $g=$event.Graphics
        $g.InterpolationMode=[Drawing.Drawing2D.InterpolationMode]::NearestNeighbor
        $g.PixelOffsetMode=[Drawing.Drawing2D.PixelOffsetMode]::Half
        $frame=$danceClock.Elapsed.TotalSeconds*60
        foreach($i in 0..4) {
            $beat=($frame+$i*6)*[Math]::PI*2/40
            $bounce=([Math]::Sin($beat)+1)/2
            $cx=$sender.Width/2-156+$i*78
            $g.FillEllipse($shadow,([single]($cx-17)),[single]80,[single]34,[single]7)
            $saved=$g.Save()
            try {
                $g.TranslateTransform([single]$cx,[single](78-$bounce*$bounce*12))
                $g.RotateTransform([single]([Math]::Sin($beat)*5))
                $sx=1-($bounce-0.5)*0.10;$sy=1+($bounce-0.5)*0.16
                if($alienImages[$i]) {
                    $rect=New-Object Drawing.RectangleF([single](-25*$sx),[single](-50*$sy),[single](50*$sx),[single](50*$sy))
                    $g.DrawImage($alienImages[$i],$rect)
                } else {$g.FillEllipse($brushes[$i],-15,-30,30,30)}
            } finally {$g.Restore($saved)}
        }
        $x=16;$y=104;$w=$sender.Width-32;$h=18
        $outer=New-Object Drawing.Drawing2D.GraphicsPath
        $inner=New-Object Drawing.Drawing2D.GraphicsPath
        try {
            foreach($shape in @(@($outer,$x,$y,$w,$h),@($inner,($x+2),($y+2),($w-4),($h-4)))) {
                $path=$shape[0];$px=[int]$shape[1];$py=[int]$shape[2];$pw=[int]$shape[3];$ph=[int]$shape[4]
                $path.AddArc($px,$py,$ph,$ph,90,180);$path.AddArc($px+$pw-$ph,$py,$ph,$ph,270,180);$path.CloseFigure()
            }
            $g.SmoothingMode=[Drawing.Drawing2D.SmoothingMode]::AntiAlias
            $g.FillPath($trackBrush,$outer);$g.FillPath($insideBrush,$inner)
            $saved=$g.Save()
            try {
                $g.SetClip($inner)
                if($bar.Style -eq 'Marquee') {
                    $lead=([Math]::Sin($frame/36)+1)*0.5*($w-110)
                    foreach($i in 0..4) {
                        $g.FillEllipse($brushes[$i],[single]($x+$lead+5+$i*20),[single]($y+3),[single]22,[single]12)
                        $g.FillRectangle($brushes[$i],[single]($x+$lead+15+$i*20),[single]($y+3),[single]12,[single]12)
                    }
                } else {
                    $fill=($w-4)*[Math]::Min(100,[Math]::Max(0,$bar.Value))/100
                    foreach($i in 0..4) {
                        $segment=($w-4)/5;$width=[Math]::Min($segment,$fill-$i*$segment)
                        if($width -gt 0){$g.FillRectangle($brushes[$i],[single]($x+2+$i*$segment),[single]($y+2),[single]$width,[single]($h-4))}
                    }
                }
                $g.FillRectangle($shineBrush,$x+8,$y+3,$w-16,2)
            } finally {$g.Restore($saved)}
        } finally {$outer.Dispose();$inner.Dispose()}
    })
    $foot=New-Object Windows.Forms.Label
    $foot.SetBounds(26,268,506,30);$foot.Text='Vui lòng chờ. Save và bộ sưu tập được giữ nguyên.';$foot.Font=New-Object Drawing.Font('Segoe UI',9)
    $retry=New-Object Windows.Forms.Button
    $retry.SetBounds(270,310,126,34);$retry.Text='Thử lại';$retry.Visible=$false
    $play=New-Object Windows.Forms.Button
    $play.SetBounds(405,310,126,34);$play.Text='Chơi bản hiện tại';$play.Visible=$false
    $form.Controls.AddRange(@($heading,$detail,$stage,$foot,$retry,$play))
    $state=@{process=$null;started=$false;failed=$false;canPlay=$false;launch=$false;doneAt=$null;waitUntil=[DateTime]::UtcNow.AddSeconds(20)}
    $startApply={
        $retry.Visible=$false;$play.Visible=$false;$state.failed=$false;$state.doneAt=$null
        $heading.Text='Đang cập nhật game';$detail.Text='Đang kết nối tới máy chủ cập nhật…';$bar.Style='Marquee'
        $progress=Join-Path $folder 'progress.json'
        if (Test-Path -LiteralPath $progress) { [IO.File]::Delete($progress) }
        $args=@('-NoLogo','-NoProfile','-ExecutionPolicy','Bypass','-File',('"'+$WorkerScript+'"'),
            '-StartupMode','Apply','-GameRoot',('"'+$GameRoot+'"'),'-Session',$Session,'-CurrentVersion',$CurrentVersion)
        if ($PackageDirectory) { $args+=@('-PackageDirectory',('"'+$PackageDirectory+'"')) }
        $childStart=New-Object Diagnostics.ProcessStartInfo
        $childStart.FileName=Join-Path $PSHOME 'powershell.exe'
        $childStart.Arguments=$args -join ' '
        $childStart.WorkingDirectory=$GameRoot
        $childStart.UseShellExecute=$false;$childStart.CreateNoWindow=$true
        $childStart.RedirectStandardOutput=$true;$childStart.RedirectStandardError=$true
        $state.process=New-Object Diagnostics.Process
        $state.process.StartInfo=$childStart
        $null=$state.process.Start()
        $state.outputTask=$state.process.StandardOutput.ReadToEndAsync()
        $state.errorTask=$state.process.StandardError.ReadToEndAsync()
        $state.started=$true
    }
    $fail={ param([bool]$CanPlay)
        $state.failed=$true;$state.canPlay=$CanPlay
        $heading.Text='Chưa cập nhật được'
        $detail.Text='Bạn có thể thử lại. Chi tiết lỗi nằm trong gameupdate/update.log.'
        if (!$CanPlay) { $detail.Text='Cần phục hồi cập nhật trước khi chơi. Hãy chọn Thử lại.' }
        $bar.Style='Continuous';$bar.Value=0;$retry.Visible=$true;$play.Visible=$true
        $play.Text=if ($CanPlay) {'Chơi bản hiện tại'} else {'Đóng'}
    }
    $retry.Add_Click({ try { & $startApply } catch { & $fail $true } })
    $play.Add_Click({ $state.launch=$state.canPlay;$form.Close() })
    $timer=New-Object Windows.Forms.Timer
    $timer.Interval=150
    $timer.Add_Tick({
        try {
            if (!$state.started -and (Test-Path -LiteralPath (Join-Path $folder 'cancel'))) { $form.Close();return }
            if (!$state.started -and !$state.failed) {
                $parent=if ($ParentId -gt 0) { Get-Process -Id $ParentId -ErrorAction SilentlyContinue } else {$null}
                if ($parent) {
                    if ([DateTime]::UtcNow -ge $state.waitUntil) { & $fail $false }
                    return
                }
                & $startApply
            }
            if ($state.failed -or !$state.process) { return }
            $progress=Join-Path $folder 'progress.json'
            if (Test-Path -LiteralPath $progress) {
                $p=Read-WcfJson $progress 65536
                if ($p.status -eq 'running') {
                    $detail.Text=switch($p.stage) {
                        'download' { 'Đang tải và kiểm tra gói '+[Math]::Min(([int]$p.done+1),[int]$p.total)+'/'+$p.total+'…' }
                        'install' { 'Đang cài đặt '+$p.done+'/'+$p.total+' file…' }
                        default { 'Đang kiểm tra dữ liệu cập nhật…' }
                    }
                    if ($p.total -gt 0) { $bar.Style='Continuous';$bar.Value=[Math]::Min(100,[int](100*$p.done/$p.total)) }
                    else { $bar.Style='Marquee' }
                }
            }
            if ($state.process.HasExited) {
                [IO.File]::WriteAllText((Join-Path $folder 'apply.log'),$state.outputTask.Result)
                [IO.File]::WriteAllText((Join-Path $folder 'apply-error.log'),$state.errorTask.Result)
                if ($state.process.ExitCode -eq 0 -and (Test-Path -LiteralPath $progress) -and (Read-WcfJson $progress).status -eq 'complete') {
                    $heading.Text='Cập nhật hoàn tất';$detail.Text='Đang mở lại game…';$bar.Style='Continuous';$bar.Value=100
                    if (!$state.doneAt) { $state.doneAt=[DateTime]::UtcNow.AddMilliseconds(600) }
                    if ([DateTime]::UtcNow -ge $state.doneAt) { $state.launch=$true;$form.Close() }
                } else {
                    & $fail (!(Test-Path -LiteralPath (Join-Path $GameRoot 'gameupdate/pending.json')))
                }
            }
        } catch {
            try { [IO.File]::AppendAllText((Join-Path $GameRoot 'gameupdate/update.log'),('Startup UI: '+$_.Exception.Message+"`r`n")) } catch { }
            # A progress redraw must not interrupt a live transaction.
            if (!$state.process -or $state.process.HasExited) { & $fail (!(Test-Path -LiteralPath (Join-Path $GameRoot 'gameupdate/pending.json'))) }
        }
    })
    $form.Add_FormClosing({ param($sender,$event)
        if ($state.process -and !$state.process.HasExited) { $event.Cancel=$true }
    })
    $form.Add_Shown({$form.Activate()})
    [IO.File]::WriteAllText((Join-Path $folder 'ready'),'1')
    $danceTimer=New-Object Windows.Forms.Timer
    $danceTimer.Interval=50;$danceTimer.Add_Tick({$stage.Invalidate()});$danceTimer.Start()
    $timer.Start()
    try { $null=$form.ShowDialog() }
    finally {
        $danceTimer.Stop();$danceTimer.Dispose();$danceClock.Stop()
        $timer.Stop();$timer.Dispose();$form.Dispose()
        foreach($image in $alienImages){if($image){$image.Dispose()}}
        foreach($brush in @($brushes)+@($shadow,$trackBrush,$insideBrush,$shineBrush)){$brush.Dispose()}
        if ($state.process) { $state.process.Dispose() }
        Clear-StartupFolder $folder
    }
    if ($state.launch) {
        $old=$env:WCF_SKIP_STARTUP_CHECK
        try {
            $env:WCF_SKIP_STARTUP_CHECK='1'
            # This is the interactive game requested by the player.
            $gameStart=New-Object Diagnostics.ProcessStartInfo
            $gameStart.FileName=Join-Path $GameRoot 'Game.exe'
            $gameStart.WorkingDirectory=$GameRoot
            $gameStart.WindowStyle=[Diagnostics.ProcessWindowStyle]::Normal
            $gameStart.UseShellExecute=$true
            [Diagnostics.Process]::Start($gameStart) | Out-Null
        } finally { $env:WCF_SKIP_STARTUP_CHECK=$old }
    }
}

try {
    [IO.Directory]::CreateDirectory($worker) | Out-Null
    # Run a detached copy so the installed updater can replace itself safely.
    Copy-Item -LiteralPath (Join-Path $PSScriptRoot 'WcfUpdater.psm1') -Destination $worker
    Copy-Item -LiteralPath $PSCommandPath -Destination (Join-Path $worker 'Update.ps1')
    Import-Module (Join-Path $worker 'WcfUpdater.psm1') -Force -DisableNameChecking
    switch ($StartupMode) {
        'Check' { Invoke-StartupCheck }
        'Update' { Show-StartupUpdater (Join-Path $worker 'Update.ps1') }
        'Apply' { Invoke-StartupApply }
        default {
            $result = Invoke-WcfUpdate -GameRoot $GameRoot -PackageDirectory $PackageDirectory -CheckOnly:$CheckOnly -Rollback:$Rollback
            Write-Host $result.message
        }
    }
    $exitCode = 0
} catch {
    Write-Host ('UPDATE FAILED: ' + $_.Exception.Message) -ForegroundColor Red
    Write-Host 'Your save files have not been removed. See gameupdate/update.log for details.'
    if ($StartupMode -eq 'Update') {
        Add-Type -AssemblyName System.Windows.Forms
        [Windows.Forms.MessageBox]::Show('Không mở được cửa sổ cập nhật. Hãy chạy GameUpdate.bat để thử lại.','Wonder Christmas Fiesta') | Out-Null
    }
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
