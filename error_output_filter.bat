@echo off

REM Whether to automatically open the output file or not
set AUTO_OPEN=1

REM The number of lines to include before and after the error to preserve context.
set N=3

REM Drag-and-drop log file onto this script.
if "%~1"=="" (
    echo Drag and drop a log file onto this script.
    pause
    exit /b 1
)
set "infile=%~1"
set "outfile=%~dpn1_filtered.txt"

REM Create PowerShell script file to avoid escaping issues
set "ps_script=%temp%\filter_script.ps1"

> "%ps_script%" echo $lines = Get-Content -Path '%infile%'
>> "%ps_script%" echo $patterns = 'abort^|assert^|\bbad\b^| bad^|bad ^|but you have^|catastrophic^|caution^|conflict^|connection^|corrupt^|could not^|crash^|critical^|deadlock^|denied^|deprecated^|disk space^|dump^|error^|exception^|\bexit\b^|exit code^|fail^|fatal^|forbidden^|halted^|illegal^|incompatible^|invalid^|killed^|\blimit\b^| limit^|limit ^|malformed^|misconfigured^|missing^|mismatch^|not found^|not installed^|obsolete^|\boom\b^| oom^|overflow^|panic^|quota^|returned^|segfault^|stopped^|terminate^|throttle^|timeout^|traceback^|\bunable\b^|unavailable^|unauthorized^|undefined^|unexpected^|unrecognized^|unresolved^|unsupported^|unreachable^|violation^|warning'
>> "%ps_script%" echo $pattern = [regex]"(?i)$patterns"
>> "%ps_script%" echo $match_indexes = @()
>> "%ps_script%" echo $count_lines = $lines.Count
>> "%ps_script%" echo for ($i = 0; $i -lt $count_lines; $i++) { if ($lines[$i] -match $pattern) { $match_indexes += $i } }
>> "%ps_script%" echo $ranges = @()
>> "%ps_script%" echo foreach ($idx in $match_indexes) { $start = [Math]::Max(0, $idx - %N%); $end = [Math]::Min($count_lines - 1, $idx + %N%); $ranges += ,@($start, $end) }
>> "%ps_script%" echo $merged = @()
>> "%ps_script%" echo if ($ranges.Count -gt 0) {
>> "%ps_script%" echo   $ranges = $ranges ^| Sort-Object { $_[0] }
>> "%ps_script%" echo   $current = $ranges[0]
>> "%ps_script%" echo   for ($j = 1; $j -lt $ranges.Count; $j++) {
>> "%ps_script%" echo     if ($ranges[$j][0] -le $current[1] + 1) { $current[1] = [Math]::Max($current[1], $ranges[$j][1]) }
>> "%ps_script%" echo     else { $merged += ,$current; $current = $ranges[$j] }
>> "%ps_script%" echo   }
>> "%ps_script%" echo   $merged += ,$current
>> "%ps_script%" echo }
>> "%ps_script%" echo $out = @()
>> "%ps_script%" echo $total_matched = $match_indexes.Count
>> "%ps_script%" echo $total_lines = $count_lines
>> "%ps_script%" echo $match_set = [System.Collections.Generic.HashSet[int]]::new()
>> "%ps_script%" echo $match_indexes ^| ForEach-Object { $match_set.Add($_) }
>> "%ps_script%" echo foreach ($rng in $merged) {
>> "%ps_script%" echo   $out += '========================='
>> "%ps_script%" echo   for ($k = $rng[0]; $k -le $rng[1]; $k++) {
>> "%ps_script%" echo     $star = if ($match_set.Contains($k)) { '*' } else { ' ' }
>> "%ps_script%" echo     $out += "<|{0}{1}|> {2}" -f ($k+1), $star, $lines[$k]
>> "%ps_script%" echo   }
>> "%ps_script%" echo }
>> "%ps_script%" echo $out += '========================='
>> "%ps_script%" echo $out += ''
>> "%ps_script%" echo $out += "Total lines processed: $total_lines"
>> "%ps_script%" echo $out += "Total error lines matched: $total_matched"
>> "%ps_script%" echo $out ^| Set-Content -Path '%outfile%'
>> "%ps_script%" echo Write-Host "Total lines processed: $total_lines"
>> "%ps_script%" echo Write-Host "Total error lines matched: $total_matched"
>> "%ps_script%" echo Write-Host 'Output written to: %outfile%'

powershell -NoLogo -ExecutionPolicy Bypass -File "%ps_script%"

del "%ps_script%"

echo.
if "%AUTO_OPEN%"=="1" start "" "%outfile%"
pause
