@echo off

:: AUTO_OPEN: Set to 1 to automatically open output file in default text editor
set AUTO_OPEN=1

REM Drag-and-drop log file onto this script. Patterns are hardcoded in this file.
if "%~1"=="" (
    echo Drag and drop a log file onto this script.
    pause
    exit /b 1
)
set "infile=%~1"
set "outfile=%~dpn1_filtered.txt"

echo Filtering errors from: %infile%
echo Output will be saved to: %outfile%

REM Patterns: adjust as needed (case-insensitive, | = OR)
set "patterns=error|failed|fatal|exception|traceback|lnk|undefined reference|unresolved external|compilation terminated|collect2: error|ld returned|ninja: build stopped|make: \*\*\*|cmake error|msbuild failed|subprocess-exited-with-error|building editable|failed building|failed to build|incompatible|requires.*but you have|version conflict|modulenotfounderror|importerror|syntaxerror|runtimeerror|attributeerror|typeerror|valueerror|keyerror|indexerror|cuda error|gpu error|not compatible|out of memory|device-side assert|cudnn error|cublas error|sm_|package.*not found|could not find|missing|not installed|permission denied|access denied|disk space|invalid|unsupported|abort|terminated|killed|crash|exit code|file not found|directory not found|linker error|compiler error|deprecated|obsolete"

> "%output_file%" echo Error Log Filter - Generated on %date% %time%
>> "%output_file%" echo Original file: %~nx1
>> "%output_file%" echo.

REM Call PowerShell with stats logic
powershell -NoLogo -Command ^
    "$num_lines = 0; $num_err = 0; " ^
    "Get-Content -Path '%infile%' | ForEach-Object { $num_lines++; if ($_ -match '%patterns%') { $num_err++; Write-Output ('<|{0}|> {1}' -f $num_lines, $_) } } | Set-Content -Path '%outfile%'; " ^
    "Write-Host ('Total lines processed: {0}' -f $num_lines); " ^
    "Write-Host ('Total lines matched: {0}' -f $num_err); " ^
    "Write-Host 'Output written to: %outfile%'; "


if %AUTO_OPEN%==1 start "" "%outfile%"
pause
