@echo off
setlocal enabledelayedexpansion

:: Function to check if running as administrator
openfiles >nul 2>&1
if %errorlevel% neq 0 (
    echo Requesting administrative privileges...
    powershell -command "Start-Process '%~f0' -Verb RunAs"
    exit /b
)

:: Set time zone to GMT +05:00 (Islamabad, Karachi)
echo Setting time zone to GMT +05:00 (Islamabad, Karachi)...
tzutil /s "Pakistan Standard Time"
if %errorlevel% neq 0 (
    echo Failed to set time zone.
)

:: Ensure the Windows Time service is enabled and started
echo Ensuring the Windows Time service is enabled and started...
sc config w32time start= auto
if %errorlevel% neq 0 (
    echo Failed to enable the Windows Time service.
)
net start w32time
if %errorlevel% neq 0 (
    echo Failed to start the Windows Time service.
)

:: Synchronize time with an NTP server
echo Synchronizing system time...
w32tm /resync
if %errorlevel% neq 0 (
    echo Failed to synchronize time.
)

:: Define known non-essential processes to target
set "targetProcesses=zoom.exe,anydesk.exe,chrome.exe,msedge.exe,msteams.exe,ms-teams.exe,openvpnserv2.exe,openvpnserv.exe,dbeaver.exe,Receiver.exe,SelfServicePlugin.exe,BCompare.exe,skype.exe,obs.exe,webex.exe,gotomeeting.exe,slack.exe,discord.exe,vnc.exe,teamviewer.exe,bluejeans.exe,jitsi.exe,camtasia.exe,loom.exe,googlemeet.exe,zoomgov.exe,msra.exe,quickassist.exe,hangouts.exe,join.me.exe,zoho.exe,powershell.exe,firefox.exe,notepad++.exe,putty.exe,virtualbox.exe,vmware.exe,python.exe,taskmgr.exe,logmein.exe,zoomit.exe,screenrecorder.exe,snagit32.exe,snagit64.exe,bandicam.exe,camstudio.exe,icecream.exe,tinytake.exe,ispring.exe,screencast-o-matic.exe,ezvid.exe,screenflick.exe,sharex.exe,flashback.exe,filmora.exe,screenshots.exe,recording.exe,capture.exe,opera.exe,brave.exe,waterfox.exe,whatsapp.exe,line.exe,wechat.exe,telegram.exe,signal.exe,facebookmessenger.exe,facetime.exe,duo.exe,tango.exe,houseparty.exe,zoomrooms.exe,gomeet.exe,freedcam.exe,screenrecord.exe,flashbackexpress.exe,moavi.exe,camtasia2021.exe,screencastify.exe,tinychat.exe,ustream.exe,livestream.exe,manycam.exe,periscope.exe,liveme.exe,bigo.exe,discordscreen.exe,screenshare.exe,meet.exe,skypescreen.exe,skypescreenshare.exe,skypeweb.exe,recordmyscreen.exe,streamlabs.exe,xsplit.exe,capturly.exe,captureweb.exe,captureanything.exe,captureme.exe,screenrecorderpro.exe,webexrecorder.exe,goomeet.exe,snippingtool.exe,onenote.exe"
:: Log and terminate non-essential processes one by one
:LogAndTerminateNonEssentialProcesses
echo Logging and terminating non-essential processes to terminate_log.txt
for %%b in (%targetProcesses%) do (
    tasklist /FI "IMAGENAME eq %%b" 2>NUL | find /I "%%b" >NUL
    if "%errorlevel%"=="0" (
        echo Found and terminating process: %%b >> terminate_log.txt
        taskkill /IM %%b /F >> terminate_log.txt 2>&1
        echo Process %%b terminated. >> terminate_log.txt
        @REM timeout /t 1 /nobreak >nul
    )
)
echo Your current action has been reported to administrators.
goto :EnsureSingleChromeTab

:EnsureSingleChromeTab
:: Ensure only one Chrome tab is open
set chromeCount=0
echo "Please wait for 5 minutes; it will automatically start the quiz."
for /f "tokens=1 delims=," %%a in ('tasklist /fo csv /nh ^| find /i "chrome.exe"') do (
    set /a chromeCount+=1
)
if %chromeCount% gtr 1 (
    echo More than one Chrome tab detected. Please close additional tabs manually. >> terminate_log.txt
    tasklist /FI "IMAGENAME eq chrome.exe" /FO TABLE >> terminate_log.txt
    pause
    exit /b
) else (
    if %chromeCount%==0 (
        echo Chrome is not running. Starting Chrome... >> terminate_log.txt
        start chrome.exe "https://quiz.governorsindh.com/"
    ) else (
        echo Single Chrome tab is open. >> terminate_log.txt
    )
)

:KeepOpen
:: Keep the Command Prompt window open
echo Press any key to close this window...
pause >nul

endlocal
exit /b
