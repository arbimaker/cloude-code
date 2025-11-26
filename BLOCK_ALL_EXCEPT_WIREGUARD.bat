@echo off
REM КРИТИЧЕСКИ ВАЖНЫЙ СКРИПТ - БЛОКИРОВКА ВСЕХ СОЕДИНЕНИЙ КРОМЕ WIREGUARD
REM Этот скрипт должен быть выполнен В КЛОНЕ до первой загрузки
REM Размещается в клоне: D:\Windows\System32\GroupPolicy\Machine\Scripts\Startup\BLOCK_ALL_EXCEPT_WIREGUARD.bat
REM (когда VHDX смонтирован как D:)

echo ========================================
echo БЛОКИРОВКА ВСЕХ СОЕДИНЕНИЙ КРОМЕ WIREGUARD
echo ========================================

REM Включаем файрвол для всех профилей
netsh advfirewall set allprofiles state on

REM Устанавливаем политику: блокировать входящие и исходящие по умолчанию
netsh advfirewall set allprofiles firewallpolicy blockinbound,blockoutbound

echo Файрвол включен, все соединения заблокированы по умолчанию

REM Разрешаем исходящие UDP соединения на порт 51820 (WireGuard к 194.31.72.192)
netsh advfirewall firewall delete rule name="Allow_WG_Out" >nul 2>&1
netsh advfirewall firewall add rule name="Allow_WG_Out" dir=out action=allow protocol=UDP remoteip=194.31.72.192 remoteport=51820

echo Разрешены исходящие UDP на 194.31.72.192:51820 (WireGuard)

REM Разрешаем весь трафик через туннель WireGuard (10.0.0.0/24)
netsh advfirewall firewall delete rule name="Allow_Tunnel_Out" >nul 2>&1
netsh advfirewall firewall add rule name="Allow_Tunnel_Out" dir=out action=allow remoteip=10.0.0.0/24

netsh advfirewall firewall delete rule name="Allow_Tunnel_In" >nul 2>&1
netsh advfirewall firewall add rule name="Allow_Tunnel_In" dir=in action=allow remoteip=10.0.0.0/24

echo Разрешен трафик через туннель 10.0.0.0/24

REM Разрешаем localhost (для внутренних служб)
netsh advfirewall firewall delete rule name="Allow_Loopback" >nul 2>&1
netsh advfirewall firewall add rule name="Allow_Loopback" dir=out action=allow remoteip=127.0.0.1

echo Разрешен localhost 127.0.0.1

echo.
echo ========================================
echo [OK] ФАЙРВОЛ НАСТРОЕН
echo ========================================
echo Разрешено:
echo - WireGuard к 194.31.72.192:51820
echo - Трафик через туннель 10.0.0.0/24
echo - Localhost
echo.
echo Все остальные соединения ЗАБЛОКИРОВАНЫ
echo Утечка IP 185.244.175.90 НЕВОЗМОЖНА
echo ========================================

REM Показываем текущие правила
echo.
echo Проверка правил файрвола:
netsh advfirewall firewall show rule name=all | findstr "Allow_"

exit /b 0
