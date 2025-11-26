@echo off
REM Генерация ключей WireGuard
REM Требуется установленный WireGuard

echo ========================================
echo ГЕНЕРАЦИЯ КЛЮЧЕЙ WIREGUARD
echo ========================================
echo.

REM Проверяем наличие wg.exe
where wg.exe >nul 2>&1
if %errorlevel% neq 0 (
    echo [ОШИБКА] wg.exe не найден!
    echo Установите WireGuard сначала: https://www.wireguard.com/install/
    pause
    exit /b 1
)

echo Генерируем ключи для КЛОНА...
echo.

REM Генерируем приватный ключ клона
wg genkey > clone-private.key
if %errorlevel% neq 0 (
    echo [ОШИБКА] Не удалось сгенерировать приватный ключ
    pause
    exit /b 1
)

REM Генерируем публичный ключ клона из приватного
type clone-private.key | wg pubkey > clone-public.key

echo [OK] Ключи сгенерированы:
echo.
echo ПРИВАТНЫЙ КЛЮЧ КЛОНА (для wg-clone.conf):
type clone-private.key
echo.
echo.
echo ПУБЛИЧНЫЙ КЛЮЧ КЛОНА (для конфигурации эталона .192):
type clone-public.key
echo.
echo.
echo ========================================
echo ИНСТРУКЦИИ:
echo ========================================
echo 1. Скопируйте ПРИВАТНЫЙ ключ в wg-clone.conf (строка PrivateKey)
echo 2. Скопируйте ПУБЛИЧНЫЙ ключ в конфигурацию WireGuard на эталоне .192
echo 3. На эталоне .192 получите публичный ключ командой:
echo    wg show ^| findstr "public key"
echo 4. Вставьте публичный ключ эталона в wg-clone.conf (строка PublicKey в секции [Peer])
echo.
echo ВАЖНО: Храните приватные ключи в безопасности!
echo.
pause

echo.
echo Сохраняем ключи в файлы:
echo   clone-private.key - ПРИВАТНЫЙ ключ клона
echo   clone-public.key  - ПУБЛИЧНЫЙ ключ клона
echo.
echo Используйте их для настройки WireGuard конфигураций
echo.
pause
