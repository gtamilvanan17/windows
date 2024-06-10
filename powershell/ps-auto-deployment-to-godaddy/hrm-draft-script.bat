@echo off
setlocal

:: Declaring variables
set "CONFIG_DIR=C:\Users\tgowran\OneDrive - quadgen.com\Workitems\HRMS\Godaddy\Configurations"
set "HOME_DIR=C:\Users\tgowran\Downloads\Workspace\Automation-Scripts"
set "ARTIFACT_DIR=.\Artifacts"

::Cloning the code from Github(master-branch)
echo.
echo ======================================================
echo Cloning the code from Github(master-branch)
echo ======================================================
echo.
git clone https://your-git-pat-token@github.com/nageshkalan/HRM_V1.git

::Building the frontned application
echo.
echo ======================================================
echo Building the frontend application.
echo ======================================================
echo.
echo.

dir
cd /d "%HOME_DIR%\HRM_V1\frontend\" && (
    npm run deploy:qa
    copy "%CONFIG_DIR%"\qa\web.config .\dist\
    ..\..\rclone\rclone.exe sync --transfers=40 --checkers=40 .\dist\ HRM-QA:/frontend/
    powershell.exe -Command "Compress-Archive -Path '.\dist\*' -DestinationPath '%HOME_DIR%\Artifacts\frontend_%DATE:~10,4%%DATE:~4,2%%DATE:~7,2%.zip'"
)
powershell.exe -Command "Compress-Archive -Path '.\demo\*' -DestinationPath '%HOME_DIR%\artfact\frontend_%DATE:~10,4%%DATE:~4,2%%DATE:~7,2%.zip'"


::Building the backend application
echo.
echo ======================================================
echo Building the backend application.
echo ======================================================
echo.
echo.

dir
cd /d "%HOME_DIR%\HRM_V1\backend\"
dir
del .\HRM.API\appsettings.json
copy "%CONFIG_DIR%"\qa\be\appsettings.json .\HRM.API\
dotnet restore .\HRM.API\HRM.API.csproj
dotnet build .\HRM.API\HRM.API.csproj -c release -o .\app\build\
dotnet publish .\HRM.API\HRM.API.csproj -c release -o .\app\publish\
del .\app\publish\web.config
copy "%CONFIG_DIR%"\qa\be\web.config .\app\publish\
..\..\rclone\rclone.exe sync --transfers=40 --checkers=40 .\dist\ HRM-QA:/backend/
if not exist "artfact" mkdir "artfact"
powershell.exe -Command "Compress-Archive -Path '.\app\publish\*' -DestinationPath '%HOME_DIR%\Artifacts\backend_%DATE:~10,4%%DATE:~4,2%%DATE:~7,2%.zip'"


echo Displaying date and time...
date /t
time /t

echo All commands have been executed.
endlocal


======================================================


for /f "tokens=2 delims==" %i in ('"wmic os get localdatetime /value"') do set datetime=%i
set year=%datetime:~0,4%
set month=%datetime:~4,2%
set day=%datetime:~6,2%
set hour=%datetime:~8,2%
set minute=%datetime:~10,2%
set name=project
set zipname=%name%_%day%_%month%_%year%_%hour%%minute%.zip

rem Create the zip file
powershell Compress-Archive -Path project_directory -DestinationPath %zipname%



frontend_qa_%datetime:~0,4%_%datetime:~4,2%_%datetime:~6,2%__%datetime:~8,2%:%datetime:~10,2%.zip

frontend_%DEPLOY_ENV%_%datetime:~0,4%_%datetime:~4,2%_%datetime:~6,2%__%datetime:~8,2%:%datetime:~10,2%.zip

backend_%DEPLOY_ENV%_%datetime:~0,4%_%datetime:~4,2%_%datetime:~6,2%__%datetime:~8,2%:%datetime:~10,2%.zip
powershell.exe -Command "Compress-Archive -Path '.\app\publish\*' -DestinationPath '%HOME_DIR%\Artifacts\backend_%DATE:~10,4%%DATE:~4,2%%DATE:~7,2%.zip'"




start "" "frontend.bat"
echo Test
timeout /T 30 /NOBREAK
start "" "test.bat"


powershell.exe -Command "Compress-Archive -Path '.\Artifacts\' -DestinationPath '%HOME_DIR%\Art\backend_%datetime:~0,4%_%datetime:~4,2%_%datetime:~6,2%__%datetime:~8,2%:%datetime:~10,2%.zip'"


.\rclone\rclone.exe sync -vv --transfers 100 --buffer-size 1G --inplace .\HRM_V1\frontend\dist\ MQG0760:/frontend12




@echo off
setlocal

:: Get the current date and time
for /f "tokens=2 delims==" %%i in ('"wmic os get localdatetime /value"') do set datetime=%%i

:: Extract date and time components
set year=%datetime:~0,4%
set month=%datetime:~4,2%
set day=%datetime:~6,2%
set hour=%datetime:~8,2%
set minute=%datetime:~10,2%

:: Print the formatted date and time
echo %day%-%month%-%year%_%hour%:%minute%

endlocal


START /WAIT npm install
echo hello