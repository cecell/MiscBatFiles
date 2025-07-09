@echo off
setlocal enabledelayedexpansion

if "%~1"=="" (
    echo Usage: Drag and drop a log file onto this script
    echo Output will be saved as [filename]_filtered.txt
    pause
    exit /b 1
)

set "input_file=%~1"

set "output_file=%~dpn1_filtered.txt"

echo Filtering errors from: %~nx1
echo Output will be saved to: %~nx1_filtered.txt

:: Initialize line counter
set /a line_num=0

:: Clear output file if it exists
if exist "%output_file%" del "%output_file%"
> "%output_file%" echo Error Log Filter - Generated on %date% %time%
>> "%output_file%" echo Original file: %~nx1
>> "%output_file%" echo.

for /f "usebackq delims=" %%a in ("%input_file%") do (
    set /a line_num+=1
    set "line=%%a"
    
    :: Check for error patterns (case insensitive using findstr /i)
    set "is_error=0"
    
    :: Critical errors
    echo !line! | findstr /i /c:"error" >nul && set "is_error=1"
    echo !line! | findstr /i /c:"failed" >nul && set "is_error=1"
    echo !line! | findstr /i /c:"fatal" >nul && set "is_error=1"
    echo !line! | findstr /i /c:"exception" >nul && set "is_error=1"
    echo !line! | findstr /i /c:"traceback" >nul && set "is_error=1"
    
    :: Build system errors
    echo !line! | findstr /i /c:"lnk" >nul && set "is_error=1"
    echo !line! | findstr /i /c:"undefined reference" >nul && set "is_error=1"
    echo !line! | findstr /i /c:"unresolved external" >nul && set "is_error=1"
    echo !line! | findstr /i /c:"compilation terminated" >nul && set "is_error=1"
    echo !line! | findstr /i /c:"collect2: error" >nul && set "is_error=1"
    echo !line! | findstr /i /c:"ld returned" >nul && set "is_error=1"
    echo !line! | findstr /i /c:"ninja: build stopped" >nul && set "is_error=1"
    echo !line! | findstr /i /c:"make: ***" >nul && set "is_error=1"
    echo !line! | findstr /i /c:"cmake error" >nul && set "is_error=1"
    echo !line! | findstr /i /c:"msbuild failed" >nul && set "is_error=1"
    
    :: Python/pip errors
    echo !line! | findstr /i /c:"subprocess-exited-with-error" >nul && set "is_error=1"
    echo !line! | findstr /i /c:"building editable" >nul && set "is_error=1"
    echo !line! | findstr /i /c:"failed building" >nul && set "is_error=1"
    echo !line! | findstr /i /c:"failed to build" >nul && set "is_error=1"
    echo !line! | findstr /i /c:"incompatible" >nul && set "is_error=1"
    echo !line! | findstr /i /c:"requires.*but you have" >nul && set "is_error=1"
    echo !line! | findstr /i /c:"version conflict" >nul && set "is_error=1"
    echo !line! | findstr /i /c:"modulenotfounderror" >nul && set "is_error=1"
    echo !line! | findstr /i /c:"importerror" >nul && set "is_error=1"
    echo !line! | findstr /i /c:"syntaxerror" >nul && set "is_error=1"
    echo !line! | findstr /i /c:"runtimeerror" >nul && set "is_error=1"
    echo !line! | findstr /i /c:"attributeerror" >nul && set "is_error=1"
    echo !line! | findstr /i /c:"typeerror" >nul && set "is_error=1"
    echo !line! | findstr /i /c:"valueerror" >nul && set "is_error=1"
    echo !line! | findstr /i /c:"keyerror" >nul && set "is_error=1"
    echo !line! | findstr /i /c:"indexerror" >nul && set "is_error=1"
    
    :: CUDA/GPU specific errors
    echo !line! | findstr /i /c:"cuda error" >nul && set "is_error=1"
    echo !line! | findstr /i /c:"gpu error" >nul && set "is_error=1"
    echo !line! | findstr /i /c:"not compatible" >nul && set "is_error=1"
    echo !line! | findstr /i /c:"out of memory" >nul && set "is_error=1"
    echo !line! | findstr /i /c:"device-side assert" >nul && set "is_error=1"
    echo !line! | findstr /i /c:"cudnn error" >nul && set "is_error=1"
    echo !line! | findstr /i /c:"cublas error" >nul && set "is_error=1"
    echo !line! | findstr /i /c:"sm_" >nul && set "is_error=1"
    
    :: Package/dependency issues
    echo !line! | findstr /i /c:"package.*not found" >nul && set "is_error=1"
    echo !line! | findstr /i /c:"could not find" >nul && set "is_error=1"
    echo !line! | findstr /i /c:"missing" >nul && set "is_error=1"
    echo !line! | findstr /i /c:"not installed" >nul && set "is_error=1"
    
    :: Memory/resource errors
    echo !line! | findstr /i /c:"permission denied" >nul && set "is_error=1"
    echo !line! | findstr /i /c:"access denied" >nul && set "is_error=1"
    echo !line! | findstr /i /c:"disk space" >nul && set "is_error=1"
    
    :: Configuration errors
    echo !line! | findstr /i /c:"invalid" >nul && set "is_error=1"
    echo !line! | findstr /i /c:"unsupported" >nul && set "is_error=1"
    
    :: Generic critical patterns
    echo !line! | findstr /i /c:"abort" >nul && set "is_error=1"
    echo !line! | findstr /i /c:"terminated" >nul && set "is_error=1"
    echo !line! | findstr /i /c:"killed" >nul && set "is_error=1"
    echo !line! | findstr /i /c:"crash" >nul && set "is_error=1"
    echo !line! | findstr /i /c:"exit code" >nul && set "is_error=1"
    
    :: File system errors
    echo !line! | findstr /i /c:"file not found" >nul && set "is_error=1"
    echo !line! | findstr /i /c:"directory not found" >nul && set "is_error=1"
    
    :: Compilation specific
    echo !line! | findstr /i /c:"linker error" >nul && set "is_error=1"
    echo !line! | findstr /i /c:"compiler error" >nul && set "is_error=1"
    
    :: Important warnings
    echo !line! | findstr /i /c:"deprecated" >nul && set "is_error=1"
    echo !line! | findstr /i /c:"obsolete" >nul && set "is_error=1"
    
    :: If this line matches any pattern, write it to output
    if "!is_error!"=="1" (
        echo ^<^|!line_num!^|^> !line! >> "%output_file%"
    )
)

echo.
echo Filtering complete!
echo Total lines processed: !line_num!
echo Output saved to: %output_file%
echo.
echo Opening filtered file...
start notepad "%output_file%"

pause
