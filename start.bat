@echo off
chcp 65001 >nul
setlocal EnableDelayedExpansion

echo ===================================================
echo    Mutli-Audio Track Synthesizer / ver.20260903
echo ===================================================
echo.

set /p "VIDEO=Video File Name: "

if not exist "%VIDEO%" (
    echo.
    echo [ERROR] Video File NOT Found!
    pause
    exit /b
)

echo.
echo ----------------------------------------
echo Remove original audio from video
echo ----------------------------------------
echo Y - Remove the original audio
echo N - Retain the original audio and modify the original track name
echo.

set /p "REMOVE_ORIGINAL=Enter（Y/N）："

if "%REMOVE_ORIGINAL%"=="Y" (
    set "KEEP_ORIGINAL=0"
) else if "%REMOVE_ORIGINAL%"=="N" (
    set "KEEP_ORIGINAL=1"
) else (
    echo.
    echo [ERROR] Please Type Y or N !
    pause
    exit /b
)

echo.

if "%KEEP_ORIGINAL%"=="1" (
    set /p "ORIGINAL_NAME=Enter the original audio track title: "
    if not defined ORIGINAL_NAME (
        echo.
        echo [ERROR] Audio Track Cant Be Empty
        pause
        exit /b
    )
)

echo.
set /p "COUNT=Enter the number of audio tracks: "

if not defined COUNT (
    echo.
    echo [ERROR] The Number of Audio Track Cant Be Zero!
    pause
    exit /b
)

echo.

set /p "OUTPUT_NAME=Enter output file name (without extension): "

if not defined OUTPUT_NAME (
    echo.
    echo [ERROR] Output File Name Cant Be Empty!
    pause
    exit /b
)

set "OUTPUT_FILE=%OUTPUT_NAME%.mp4"

echo.
echo Output file will be: %OUTPUT_FILE%
echo.

REM ========================================
REM FFmpeg
REM ========================================

set "INPUTS=-i "%VIDEO%""

set "MAPS=-map 0:v:0"

set "METADATA="
set "DISPOSITION="

if "%KEEP_ORIGINAL%"=="1" (
    set "MAPS=!MAPS! -map 0:a:0"
    set "METADATA=!METADATA! -metadata:s:a:0 title="!ORIGINAL_NAME!""
    set "DISPOSITION=!DISPOSITION! -disposition:a:0 default"
)

for /L %%i in (1,1,%COUNT%) do (

    echo ----------------------------------------
    echo No. %%i Audio Track
    echo ----------------------------------------

    set /p "AUDIO=Please Enter Audio File Name:"

    if not exist "!AUDIO!" (
        echo.
        echo [ERROR] Audio File NOT Found: !AUDIO!
        pause
        exit /b
    )

    set /p "NAME=Please Enter Audio Track Name:"

    if not defined NAME (
        echo.
        echo [ERROR] Audio Track Name Cant Be Empty!
        pause
        exit /b
    )

    set "INPUTS=!INPUTS! -i "!AUDIO!""

    set "MAPS=!MAPS! -map %%i:a:0"

    if "%KEEP_ORIGINAL%"=="1" (
        set /a AUDIO_INDEX=%%i
    ) else (
        set /a AUDIO_INDEX=%%i-1
    )

    set "METADATA=!METADATA! -metadata:s:a:!AUDIO_INDEX! title="!NAME!""

    if "%KEEP_ORIGINAL%"=="1" (
        set "DISPOSITION=!DISPOSITION! -disposition:a:!AUDIO_INDEX! 0"
    ) else (
        if %%i==1 (
            set "DISPOSITION=!DISPOSITION! -disposition:a:0 default"
        ) else (
            set "DISPOSITION=!DISPOSITION! -disposition:a:!AUDIO_INDEX! 0"
        )
    )
)

echo.
echo ========================================
echo Synthesizing, Please Wait...
echo ========================================
echo.

ffmpeg !INPUTS! ^
!MAPS! ^
-c:v copy ^
-c:a aac ^
-b:a 192k ^
!METADATA! ^
!DISPOSITION! ^
-movflags +faststart ^
"%OUTPUT_FILE%"

echo.
echo ========================================
echo              Finished!
echo ========================================
echo.
echo Output File: %OUTPUT_FILE%
echo.

pause
