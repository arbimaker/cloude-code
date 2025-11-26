@echo off
REM Скрипт настройки BCD для безопасной dual boot конфигурации
REM Выполнять на сервере 185.244.175.90

echo ========================================
echo Получаем текущую конфигурацию BCD...
echo ========================================
bcdedit /enum

echo.
echo ========================================
echo ВНИМАНИЕ! Сейчас нужно определить GUID записей:
echo 1. Запись основной системы (текущая Windows)
echo 2. Запись клона (только что добавленная)
echo ========================================
echo.
echo Выполните следующие команды вручную, подставив правильные GUID:
echo.
echo REM Установить основную систему по умолчанию:
echo bcdedit /default {GUID_ОСНОВНОЙ_СИСТЕМЫ}
echo.
echo REM Настроить запись клона:
echo bcdedit /set {GUID_КЛОНА} device vhd=[C:]\VMClone\clon192-4.vhdx
echo bcdedit /set {GUID_КЛОНА} osdevice vhd=[C:]\VMClone\clon192-4.vhdx
echo bcdedit /set {GUID_КЛОНА} description "Clone Server (IP 194.31.72.192)"
echo bcdedit /set {GUID_КЛОНА} detecthal yes
echo.
echo REM Настроить безопасную загрузку:
echo bcdedit /timeout 0
echo bcdedit /set {bootmgr} displaybootmenu no
echo bcdedit /set {default} bootstatuspolicy ignoreallfailures
echo bcdedit /set {GUID_КЛОНА} bootstatuspolicy ignoreallfailures
echo.
pause
