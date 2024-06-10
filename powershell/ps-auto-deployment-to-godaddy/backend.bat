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

::Building the backend application:
echo.
echo ======================================================
echo Building the backend application.
echo ======================================================
cd /d "%HOME_DIR%\HRM_V1\backend\"
dir
::Updating the crendentials for the application:
del .\HRM.API\appsettings.json
copy "%CONFIG_DIR%"\qa\be\appsettings.json .\HRM.API\
::Building the artifacts in local for backend: 
dotnet restore .\HRM.API\HRM.API.csproj
dotnet build .\HRM.API\HRM.API.csproj -c release -o .\app\build\
dotnet publish .\HRM.API\HRM.API.csproj -c release -o .\app\publish\

::Updating the web-config for the application:
del .\app\publish\web.config
copy "%CONFIG_DIR%"\qa\be\web.config .\app\publish\

::Using R-Clone Sync to push all build files to remote server thorugh ftp profile. HRM-QA:/hrm_qa_backend/  MQG0760:/backend/
::"%HOME_DIR%"\rclone\rclone.exe sync --transfers=100 --checkers=100 .\app\publish\ HRM-QA:/hrm_qa_backend/
%HOME_DIR%\rclone\rclone.exe sync -vv --transfers 100 --buffer-size 1G --inplace .\app\publish\ MQG0760:/backend/

::Taking artifact backup to a directory: 
if not exist ""%HOME_DIR%"\Artifacts" mkdir ""%HOME_DIR%"\Artifacts"
powershell.exe -Command "Compress-Archive -Path '.\app\publish\' -DestinationPath '%HOME_DIR%\Artifacts\backend_qa_%DAY%-%MONTH%-%YEAR%_%HOUR%_%MINUTE%.zip'"
echo.
echo.
echo.
echo ======================================================
echo The backend script has finished it's execution
echo by arround %DAY%-%MONTH%-%YEAR%__%HOUR%:%MINUTE%
echo ======================================================
endlocal