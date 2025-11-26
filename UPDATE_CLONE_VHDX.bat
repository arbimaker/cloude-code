@echo off
REM Обновление существующей записи клона для использования clon192-4.vhdx
REM Выполнять на сервере 185.244.175.90

echo ========================================
echo ОБНОВЛЕНИЕ ЗАПИСИ КЛОНА НА clon192-4.vhdx
echo ========================================
echo.
echo Текущая конфигурация:
echo GUID клона: {830100c2-c752-11f0-88b8-d843ae6dfa0a}
echo Старый VHDX: clon192-3.vhdx
echo Новый VHDX: clon192-4.vhdx
echo.
echo GUID основной системы: {current}
echo.
pause

REM Обновляем пути к VHDX в записи клона
echo Обновляем device...
bcdedit /set {830100c2-c752-11f0-88b8-d843ae6dfa0a} device vhd=[C:]\VMClone\clon192-4.vhdx

echo Обновляем osdevice...
bcdedit /set {830100c2-c752-11f0-88b8-d843ae6dfa0a} osdevice vhd=[C:]\VMClone\clon192-4.vhdx

REM Проверяем что detecthal уже установлен (видим "Yes" в выводе)
echo detecthal уже установлен

REM Устанавливаем основную систему по умолчанию
echo Устанавливаем основную систему по умолчанию...
bcdedit /default {current}

REM Настраиваем безопасную загрузку
echo Настраиваем timeout и displaybootmenu...
bcdedit /timeout 0
bcdedit /set {bootmgr} displaybootmenu no

REM Настраиваем политику игнорирования ошибок
echo Настраиваем bootstatuspolicy...
bcdedit /set {current} bootstatuspolicy ignoreallfailures
bcdedit /set {830100c2-c752-11f0-88b8-d843ae6dfa0a} bootstatuspolicy ignoreallfailures

echo.
echo ========================================
echo ПРОВЕРКА РЕЗУЛЬТАТА
echo ========================================
bcdedit /enum

echo.
echo ========================================
echo [OK] ОБНОВЛЕНИЕ ЗАВЕРШЕНО
echo ========================================
echo.
pause
