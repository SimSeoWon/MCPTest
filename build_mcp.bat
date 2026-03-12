@echo off
echo ===================================
echo Installing PyInstaller...
echo ===================================
pip install pyinstaller

echo.
echo ===================================
echo Generating Executable for UE Crash Analyzer...
echo ===================================
pyinstaller -y --onefile --name "UE_Crash_Analyzer" uelog_analyzer.py

echo.
echo ===================================
echo Build Complete! The executable is located in the 'dist' folder.
echo ===================================
pause
