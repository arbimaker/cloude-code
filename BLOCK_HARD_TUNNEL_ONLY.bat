@echo off
REM ЖЕСТКАЯ БЛОКИРОВКА - ТОЛЬКО ТУННЕЛЬ
REM Используйте ТОЛЬКО после настройки port forwarding на эталоне!
REM Прямой RDP к .90 будет заблокирован!

echo ========================================
echo ЖЕСТКАЯ БЛОКИРОВКА - ТОЛЬКО ТУННЕЛЬ
echo ========================================
echo.
echo ВНИМАНИЕ! После этого скрипта:
echo [-] Прямой RDP к 185.244.175.90 будет ЗАБЛОКИРОВАН
echo [+] RDP только через эталон с port forwarding
echo.
echo Убедитесь что на эталоне .192 настроен port forwarding:
echo   iptables -t nat -A PREROUTING -p tcp --dport 33389 -j DNAT --to-destination 10.0.0.2:3389
echo.
echo После этого подключайтесь: RDP к 194.31.72.192:33389
echo.
echo Продолжить? (Ctrl+C для отмены)
pause

REM Включаем файрвол
netsh advfirewall set allprofiles state on

REM Политика: блокировать ВСЁ по умолчанию
netsh advfirewall set allprofiles firewallpolicy blockinbound,blockoutbound

echo [OK] Файрвол включен, всё заблокировано

REM ========================================
REM РАЗРЕШАЕМ ТОЛЬКО WIREGUARD И ТУННЕЛЬ
REM ========================================

REM WireGuard исходящий
netsh advfirewall firewall delete rule name="Allow_WG_Out" >nul 2>&1
netsh advfirewall firewall add rule name="Allow_WG_Out" dir=out action=allow protocol=UDP remoteip=194.31.72.192 remoteport=51820

REM Весь трафик через туннель (входящий и исходящий)
netsh advfirewall firewall delete rule name="Allow_Tunnel_Out" >nul 2>&1
netsh advfirewall firewall add rule name="Allow_Tunnel_Out" dir=out action=allow remoteip=10.0.0.0/24

netsh advfirewall firewall delete rule name="Allow_Tunnel_In" >nul 2>&1
netsh advfirewall firewall add rule name="Allow_Tunnel_In" dir=in action=allow remoteip=10.0.0.0/24

REM Localhost
netsh advfirewall firewall delete rule name="Allow_Loopback" >nul 2>&1
netsh advfirewall firewall add rule name="Allow_Loopback" dir=out action=allow remoteip=127.0.0.1

echo [OK] Разрешено: WireGuard + туннель + localhost

REM ========================================
REM УДАЛЯЕМ ПРЯМОЙ RDP ЕСЛИ БЫЛ
REM ========================================

netsh advfirewall firewall delete rule name="Allow_RDP_In" >nul 2>&1
echo [OK] Прямой RDP заблокирован

echo.
echo ========================================
echo [OK] ЖЕСТКАЯ БЛОКИРОВКА НАСТРОЕНА
echo ========================================
echo.
echo Разрешено:
echo [+] WireGuard к 194.31.72.192:51820
echo [+] Весь трафик через туннель 10.0.0.0/24
echo [+] Localhost
echo.
echo Заблокировано:
echo [-] ВСЁ остальное, включая прямой RDP к .90
echo.
echo Для доступа используйте:
echo RDP к 194.31.72.192:33389 (через port forwarding на эталоне)
echo ========================================

pause
