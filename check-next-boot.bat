@echo off
REM Скрипт для проверки какая система загрузится следующей
REM Разместить в C:\BootManager\check-next-boot.bat

echo ========================================
echo Проверка конфигурации загрузки
echo ========================================
echo.

echo Система по умолчанию:
bcdedit /enum {default} | findstr "description device"

echo.
echo Последовательность загрузки (bootsequence):
bcdedit | findstr /C:"bootsequence"

echo.
echo Если bootsequence не установлена, загрузится система по умолчанию (основная)
echo Если bootsequence установлена, загрузится указанная система (один раз)
echo.

pause
