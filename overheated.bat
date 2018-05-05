@echo off
title overheated [main]
mode con cols=60 lines=15
color E0
goto :check_admin

:check_admin
at > nul
IF %ERRORLEVEL% EQU 0 (
    goto :set_up
) ELSE (
    echo Please run overheated with elevated privileges!
    pause >nul
    exit
)


:set_up
set /p timer="Check temp every... (seconds): "
set /p criticaltemp="Enter critical temp (ex. 90): "
title overheated [temperature watching mode]
cls
echo overheated is watching PC temperature now.
goto :temp_check


:temp_check
timeout /t %timer% /nobreak >nul

for /f "delims== tokens=2" %%a in (
    'wmic /namespace:\\root\wmi PATH MSAcpi_ThermalZoneTemperature get CurrentTemperature /value'
) do (
    set /a degrees_celsius=%%a / 10 - 273
)

if %degrees_celsius% geq %criticaltemp% goto :preventoverheat
title overheated [temp: %degrees_celsius%]
goto :temp_check


:preventoverheat
cd %systemdrive%\Users\%username%\Desktop\ >nul
echo %time% ; %date% - PC shutted down. Temperature was %degrees_celsius% and critical temperature was %criticaltemp%. >> overheated.log
shutdown /s /t 1