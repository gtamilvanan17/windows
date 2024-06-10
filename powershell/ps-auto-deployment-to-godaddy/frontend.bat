@echo off
setlocal

:: Fetch the current date and time
for /f "tokens=2 delims==" %%i in ('"wmic os get localdatetime /value"') do set datetime=%%i

:: Declaring variables:
set "CONFIG_DIR=C:\Users\tgowran\OneDrive - quadgen.com\Workitems\HRMS\Godaddy\Configurations"
set "HOME_DIR=C:\Users\tgowran\Downloads\Workspace\Automation-Scripts"
set "ARTIFACT_DIR=.\Artifacts"
set "YEAR=%datetime:~0,4%"
set "MONTH=%datetime:~4,2%"
set "DAY=%datetime:~6,2%"
set "HOUR=%datetime:~8,2%"
set "MINUTE=%datetime:~10,2%"
set "GIT_PAT_TOKEN=your-git-pat-token"

::Cloning the code from Github(master-branch):
echo.
echo ======================================================
echo Cloning the code from Github(master-branch)
echo ======================================================
echo.
git clone https://%GIT_PAT_TOKEN%@github.com/nageshkalan/HRM_V1.git


::Triggering Backend script in the background:
start "" "backend.bat"

::Building the frontned application:
echo.
echo ======================================================
echo Building the frontend application.
echo ======================================================
echo.
cd /d "%HOME_DIR%\HRM_V1\frontend\"
dir
call npm install --force
call npm run build:qa

::Copying the web.config to the server:
copy "%CONFIG_DIR%"\qa\web.config .\dist\

::Using R-Clone Sync to push all build files to remote server thorugh ftp profile. HRM-QA:/hrm_qa_frontend/  MQG0760:/frontend/
%HOME_DIR%\rclone\rclone.exe sync -vv --transfers 100 --buffer-size 1G --inplace .\dist\ MQG0760:/frontend/

::Taking artifact backup to a directory: 
if not exist ""%HOME_DIR%"\Artifacts" mkdir ""%HOME_DIR%"\Artifacts"
powershell.exe -Command "Compress-Archive -Path '.\dist\' -DestinationPath '%HOME_DIR%\Artifacts\frontend_qa_%DAY%-%MONTH%-%YEAR%_%HOUR%_%MINUTE%.zip'"
echo.
echo.
echo.
echo ======================================================
echo The frontend script has finished it's execution
echo by arround %DAY%-%MONTH%-%YEAR%__%HOUR%:%MINUTE%
echo ======================================================

endlocal