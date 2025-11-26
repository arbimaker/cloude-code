@echo off
REM НАСТРОЙКА КЛОНА ПЕРЕД ПЕРВОЙ ЗАГРУЗКОЙ
REM Выполнять на хосте .90 когда VHDX смонтирован как D:
REM КРИТИЧЕСКИ ВАЖНО: эти настройки предотвращают утечку IP

echo ========================================
echo НАСТРОЙКА КЛОНА ПЕРЕД ПЕРВОЙ ЗАГРУЗКОЙ
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
REM ШАГ 1: Создаем директорию для startup скриптов
REM ========================================
echo ШАГ 1: Создание директорий для скриптов...
mkdir "D:\Windows\System32\GroupPolicy\Machine\Scripts\Startup" 2>nul
mkdir "D:\BootManager" 2>nul

if exist "D:\Windows\System32\GroupPolicy\Machine\Scripts\Startup" (
    echo [OK] Директория Startup создана
) else (
    echo [ОШИБКА] Не удалось создать директорию
    pause
    exit /b 1
)

REM ========================================
REM ШАГ 2: Копируем скрипт блокировки файрвола
REM ========================================
echo.
echo ШАГ 2: Копирование скрипта блокировки файрвола...
echo ВНИМАНИЕ: Убедитесь что файл BLOCK_ALL_EXCEPT_WIREGUARD.bat находится в текущей директории!
echo.

if exist "BLOCK_ALL_EXCEPT_WIREGUARD.bat" (
    copy "BLOCK_ALL_EXCEPT_WIREGUARD.bat" "D:\Windows\System32\GroupPolicy\Machine\Scripts\Startup\" /Y
    echo [OK] Скрипт блокировки скопирован
) else (
    echo [ПРЕДУПРЕЖДЕНИЕ] BLOCK_ALL_EXCEPT_WIREGUARD.bat не найден в текущей директории
    echo Скопируйте его вручную в D:\Windows\System32\GroupPolicy\Machine\Scripts\Startup\
    pause
)

REM ========================================
REM ШАГ 3: Копируем аварийный скрипт возврата
REM ========================================
echo.
echo ШАГ 3: Копирование аварийного скрипта возврата...

if exist "EMERGENCY_RETURN.bat" (
    copy "EMERGENCY_RETURN.bat" "D:\" /Y
    echo [OK] EMERGENCY_RETURN.bat скопирован в D:\
) else (
    echo [ПРЕДУПРЕЖДЕНИЕ] EMERGENCY_RETURN.bat не найден
    pause
)

REM ========================================
REM ШАГ 4: Настройка автозапуска скрипта блокировки
REM ========================================
echo.
echo ШАГ 4: Настройка автозапуска блокировки файрвола...
echo Создаем файл scripts.ini для Group Policy...

echo [Startup] > "D:\Windows\System32\GroupPolicy\Machine\Scripts\scripts.ini"
echo 0CmdLine=BLOCK_ALL_EXCEPT_WIREGUARD.bat >> "D:\Windows\System32\GroupPolicy\Machine\Scripts\scripts.ini"
echo 0Parameters= >> "D:\Windows\System32\GroupPolicy\Machine\Scripts\scripts.ini"

if exist "D:\Windows\System32\GroupPolicy\Machine\Scripts\scripts.ini" (
    echo [OK] scripts.ini создан
) else (
    echo [ОШИБКА] Не удалось создать scripts.ini
    pause
)

REM ========================================
REM ШАГ 5: Копируем установщик WireGuard (если есть)
REM ========================================
echo.
echo ШАГ 5: Копирование установщика WireGuard...
echo ВНИМАНИЕ: Скачайте WireGuard installer для Windows с https://www.wireguard.com/install/
echo Поместите wireguard-installer.exe в текущую директорию
echo.

if exist "wireguard-installer.exe" (
    mkdir "D:\Install" 2>nul
    copy "wireguard-installer.exe" "D:\Install\" /Y
    echo [OK] WireGuard installer скопирован в D:\Install\
) else (
    echo [ПРЕДУПРЕЖДЕНИЕ] wireguard-installer.exe не найден
    echo Вам нужно будет установить WireGuard после первой загрузки клона
    pause
)

REM ========================================
REM ШАГ 6: Копируем конфигурацию WireGuard
REM ========================================
echo.
echo ШАГ 6: Копирование конфигурации WireGuard...

if exist "wg-clone.conf" (
    mkdir "D:\Install\WireGuard" 2>nul
    copy "wg-clone.conf" "D:\Install\WireGuard\" /Y
    echo [OK] wg-clone.conf скопирован в D:\Install\WireGuard\
) else (
    echo [ПРЕДУПРЕЖДЕНИЕ] wg-clone.conf не найден
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
echo [+] Создана директория для startup скриптов
echo [+] Скопирован скрипт блокировки файрвола
echo [+] Настроен автозапуск блокировки при загрузке
echo [+] Скопирован аварийный скрипт возврата
echo [+] Подготовлен WireGuard (если файлы были найдены)
echo.
echo СЛЕДУЮЩИЕ ШАГИ:
echo 1. Размонтировать VHDX: diskpart -^> detach vdisk
echo 2. Настроить BCD (используйте configure-bcd.bat)
echo 3. Загрузить клон (используйте boot-to-clone.bat)
echo 4. После загрузки клона:
echo    - Установить WireGuard из D:\Install\wireguard-installer.exe
echo    - Скопировать D:\Install\WireGuard\wg-clone.conf в C:\Program Files\WireGuard\Data\Configurations\
echo    - Активировать туннель wg-clone
echo    - Проверить IP: curl ifconfig.me
echo.
pause
