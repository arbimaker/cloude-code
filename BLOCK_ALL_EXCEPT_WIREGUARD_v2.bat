@echo off
REM БЛОКИРОВКА ВСЕХ СОЕДИНЕНИЙ КРОМЕ WIREGUARD И RDP ЧЕРЕЗ ТУННЕЛЬ
REM Этот скрипт запускать ВРУЧНУЮ после установки и активации WireGuard!
REM НЕ УСТАНАВЛИВАТЬ В АВТОЗАПУСК!

echo ========================================
echo БЛОКИРОВКА ФАЙРВОЛА - ВЕРСИЯ 2
echo ========================================
echo.
echo ВНИМАНИЕ! Этот скрипт:
echo 1. Заблокирует все соединения по умолчанию
echo 2. Разрешит только WireGuard и трафик через туннель
echo 3. Разрешит RDP ТОЛЬКО через туннель WireGuard
echo.
echo ВАЖНО: Запускайте ТОЛЬКО после того как:
echo - WireGuard установлен и туннель активен
echo - curl ifconfig.me показывает 194.31.72.192
echo.
echo Продолжить? (Ctrl+C для отмены)
pause

REM Включаем файрвол для всех профилей
netsh advfirewall set allprofiles state on

REM Устанавливаем политику: блокировать входящие и исходящие по умолчанию
netsh advfirewall set allprofiles firewallpolicy blockinbound,blockoutbound

echo [OK] Файрвол включен, все соединения заблокированы по умолчанию

REM ========================================
REM РАЗРЕШАЕМ WIREGUARD
REM ========================================

REM Разрешаем исходящие UDP на порт 51820 (WireGuard к 194.31.72.192)
netsh advfirewall firewall delete rule name="Allow_WG_Out" >nul 2>&1
netsh advfirewall firewall add rule name="Allow_WG_Out" dir=out action=allow protocol=UDP remoteip=194.31.72.192 remoteport=51820

echo [OK] Разрешен WireGuard: UDP к 194.31.72.192:51820

REM ========================================
REM РАЗРЕШАЕМ ТРАФИК ЧЕРЕЗ ТУННЕЛЬ
REM ========================================

REM Весь трафик через туннель WireGuard (10.0.0.0/24)
netsh advfirewall firewall delete rule name="Allow_Tunnel_Out" >nul 2>&1
netsh advfirewall firewall add rule name="Allow_Tunnel_Out" dir=out action=allow remoteip=10.0.0.0/24

netsh advfirewall firewall delete rule name="Allow_Tunnel_In" >nul 2>&1
netsh advfirewall firewall add rule name="Allow_Tunnel_In" dir=in action=allow remoteip=10.0.0.0/24

echo [OK] Разрешен трафик через туннель 10.0.0.0/24

REM ========================================
REM РАЗРЕШАЕМ RDP ТОЛЬКО ЧЕРЕЗ ТУННЕЛЬ
REM ========================================

REM RDP (порт 3389) только от клиентов в туннеле
netsh advfirewall firewall delete rule name="Allow_RDP_Tunnel" >nul 2>&1
netsh advfirewall firewall add rule name="Allow_RDP_Tunnel" dir=in action=allow protocol=TCP localport=3389 remoteip=10.0.0.0/24

echo [OK] Разрешен RDP только через туннель (10.0.0.0/24)

REM ========================================
REM РАЗРЕШАЕМ LOCALHOST
REM ========================================

netsh advfirewall firewall delete rule name="Allow_Loopback" >nul 2>&1
netsh advfirewall firewall add rule name="Allow_Loopback" dir=out action=allow remoteip=127.0.0.1

echo [OK] Разрешен localhost

echo.
echo ========================================
echo [OK] ФАЙРВОЛ НАСТРОЕН
echo ========================================
echo.
echo Разрешено:
echo [+] WireGuard к 194.31.72.192:51820
echo [+] Весь трафик через туннель 10.0.0.0/24
echo [+] RDP (3389) только через туннель
echo [+] Localhost
echo.
echo Заблокировано:
echo [-] Прямые соединения с/на 185.244.175.90
echo [-] RDP напрямую к физическому IP
echo.
echo ВАЖНО: Теперь для RDP нужно подключаться через эталон!
echo ========================================

REM Показываем правила
echo.
echo Проверка правил файрвола:
netsh advfirewall firewall show rule name=all | findstr "Allow_"

pause
