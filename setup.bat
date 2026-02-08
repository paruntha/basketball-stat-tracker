@echo off
echo Basketball Stat Tracker - Quick Setup
echo =====================================
echo.

REM Check Flutter installation
echo Checking Flutter installation...
where flutter >nul 2>nul
if %ERRORLEVEL% NEQ 0 (
    echo Flutter is not installed. Please install Flutter first:
    echo https://flutter.dev/docs/get-started/install
    exit /b 1
)

echo Flutter found
echo.

REM Get dependencies
echo Installing dependencies...
flutter pub get

if %ERRORLEVEL% NEQ 0 (
    echo Failed to get dependencies
    exit /b 1
)

echo Dependencies installed
echo.

REM Check for Firebase CLI
echo Checking Firebase CLI...
where flutterfire >nul 2>nul
if %ERRORLEVEL% EQU 0 (
    echo FlutterFire CLI found
    echo.
    set /p response="Do you want to configure Firebase now? (y/n): "
    if /i "%response%"=="y" (
        echo Running flutterfire configure...
        flutterfire configure
    ) else (
        echo Skipping Firebase setup (app will work with local storage only)
    )
) else (
    echo FlutterFire CLI not found
    echo App will work with local storage only
    echo To enable cloud sync later, run:
    echo   dart pub global activate flutterfire_cli
    echo   flutterfire configure
)

echo.
echo =====================================
echo Setup Complete!
echo.
echo To run the app:
echo   flutter run                 # Default device
echo   flutter run -d android      # Android
echo   flutter run -d chrome       # Web
echo   flutter run -d windows      # Windows
echo.
echo Happy tracking!
pause
