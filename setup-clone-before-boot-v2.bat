@echo off
REM НАСТРОЙКА КЛОНА ПЕРЕД ПЕРВОЙ ЗАГРУЗКОЙ - ВЕРСИЯ 2
REM Выполнять на хосте .90 когда VHDX смонтирован как D:
REM ВАЖНО: НЕ копирует файрвол в автозапуск! Вы включите его вручную после установки WireGuard.

echo ========================================
echo НАСТРОЙКА КЛОНА ПЕРЕД ПЕРВОЙ ЗАГРУЗКОЙ
echo ВЕРСИЯ 2 (БЕЗ АВТОБЛОКИРОВКИ)
echo ========================================
echo.
echo VHDX должен быть смонтирован как D:
echo Если не смонтирован, выполните:
echo   diskpart
echo   select vdisk file="C:\VMClone\clon192-4.vhdx"
echo   attach vdisk
echo   list volume
echo   exit
echo.
pause

REM Проверяем доступность D:\Windows
if not exist D:\Windows (
    echo [ОШИБКА] D:\Windows не найден!
    echo Смонтируйте VHDX сначала
    pause
    exit /b 1
)

echo [OK] D:\Windows найден
echo.

REM ========================================
REM ШАГ 1: Создаем директорию для файлов
REM ========================================
echo ШАГ 1: Создание директории D:\Setup...
mkdir "D:\Setup" 2>nul

if exist "D:\Setup" (
    echo [OK] Директория D:\Setup создана
) else (
    echo [ОШИБКА] Не удалось создать директорию
    pause
    exit /b 1
)

REM ========================================
REM ШАГ 2: Копируем установщик WireGuard
REM ========================================
echo.
echo ШАГ 2: Копирование установщика WireGuard...
echo ВНИМАНИЕ: Убедитесь что wireguard-installer.exe находится в текущей директории!
echo Скачать: https://download.wireguard.com/windows-client/wireguard-installer.exe
echo.

if exist "wireguard-installer.exe" (
    copy "wireguard-installer.exe" "D:\Setup\" /Y
    echo [OK] WireGuard installer скопирован
) else (
    echo [ПРЕДУПРЕЖДЕНИЕ] wireguard-installer.exe не найден
    echo Вы можете скопировать его позже вручную
    pause
)

REM ========================================
REM ШАГ 3: Копируем конфигурацию WireGuard
REM ========================================
echo.
echo ШАГ 3: Копирование конфигурации WireGuard...

if exist "wg-clone.conf" (
    copy "wg-clone.conf" "D:\Setup\" /Y
    echo [OK] wg-clone.conf скопирован
) else (
    echo [ПРЕДУПРЕЖДЕНИЕ] wg-clone.conf не найден
    pause
)

REM ========================================
REM ШАГ 4: Копируем скрипты блокировки (для ручного запуска)
REM ========================================
echo.
echo ШАГ 4: Копирование скриптов блокировки файрвола...
echo ВАЖНО: Эти скрипты НЕ в автозапуске! Запускать ВРУЧНУЮ!

if exist "BLOCK_SOFT_ALLOW_RDP.bat" (
    copy "BLOCK_SOFT_ALLOW_RDP.bat" "D:\Setup\" /Y
    echo [OK] BLOCK_SOFT_ALLOW_RDP.bat скопирован
) else (
    echo [ПРЕДУПРЕЖДЕНИЕ] BLOCK_SOFT_ALLOW_RDP.bat не найден
)

if exist "BLOCK_HARD_TUNNEL_ONLY.bat" (
    copy "BLOCK_HARD_TUNNEL_ONLY.bat" "D:\Setup\" /Y
    echo [OK] BLOCK_HARD_TUNNEL_ONLY.bat скопирован
) else (
    echo [ПРЕДУПРЕЖДЕНИЕ] BLOCK_HARD_TUNNEL_ONLY.bat не найден
)

REM ========================================
REM ШАГ 5: Копируем аварийный скрипт возврата
REM ========================================
echo.
echo ШАГ 5: Копирование аварийного скрипта возврата...

if exist "EMERGENCY_RETURN-READY.bat" (
    copy "EMERGENCY_RETURN-READY.bat" "D:\EMERGENCY_RETURN.bat" /Y
    echo [OK] EMERGENCY_RETURN.bat скопирован в D:\
) else (
    echo [ПРЕДУПРЕЖДЕНИЕ] EMERGENCY_RETURN-READY.bat не найден
    pause
)

REM ========================================
REM ЗАВЕРШЕНИЕ
REM ========================================
echo.
echo ========================================
echo НАСТРОЙКА КЛОНА ЗАВЕРШЕНА
echo ========================================
echo.
echo Что было сделано:
echo [+] Создана директория D:\Setup
echo [+] Скопирован WireGuard installer (если был найден)
echo [+] Скопирована конфигурация WireGuard
echo [+] Скопированы скрипты блокировки (для ручного запуска!)
echo [+] Скопирован аварийный скрипт возврата
echo.
echo СЛЕДУЮЩИЕ ШАГИ:
echo 1. Размонтировать VHDX
echo 2. Настроить WireGuard ключи в wg-clone.conf
echo 3. Смонтировать снова и скопировать обновленный конфиг
echo 4. Размонтировать
echo 5. Загрузить клон
echo 6. После загрузки:
echo    a) Установить WireGuard из D:\Setup\wireguard-installer.exe
echo    b) Импортировать D:\Setup\wg-clone.conf
echo    c) Активировать туннель
echo    d) Проверить: curl ifconfig.me (должно быть 194.31.72.192)
echo    e) Запустить D:\Setup\BLOCK_SOFT_ALLOW_RDP.bat
echo.
echo ВАЖНО: Файрвол НЕ включается автоматически!
echo Вы включите его вручную после установки WireGuard.
echo ========================================
echo.
pause
