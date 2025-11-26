@echo off
REM МЯГКАЯ БЛОКИРОВКА - РАЗРЕШАЕТ ПРЯМОЙ RDP
REM Используйте этот вариант пока не настроите port forwarding на эталоне
REM ЗАПУСКАТЬ ВРУЧНУЮ после установки WireGuard!

echo ========================================
echo МЯГКАЯ БЛОКИРОВКА ФАЙРВОЛА
echo ========================================
echo.
echo Этот скрипт:
echo [+] Блокирует все исходящие соединения кроме WireGuard
echo [+] РАЗРЕШАЕТ входящий RDP напрямую (для удобства доступа)
echo [+] Весь исходящий трафик ТОЛЬКО через туннель
echo.
echo Утечка IP невозможна, но RDP доступен напрямую к .90
echo.
echo ВАЖНО: Запускайте ТОЛЬКО после активации WireGuard туннеля!
echo.
pause

REM Включаем файрвол
netsh advfirewall set allprofiles state on

REM Политика: блокировать исходящие, разрешить входящие
netsh advfirewall set allprofiles firewallpolicy blockoutbound,allowinbound

echo [OK] Файрвол включен

REM ========================================
REM ИСХОДЯЩИЕ - ТОЛЬКО WIREGUARD И ТУННЕЛЬ
REM ========================================

REM Разрешаем исходящие WireGuard
netsh advfirewall firewall delete rule name="Allow_WG_Out" >nul 2>&1
netsh advfirewall firewall add rule name="Allow_WG_Out" dir=out action=allow protocol=UDP remoteip=194.31.72.192 remoteport=51820

REM Разрешаем исходящие через туннель
netsh advfirewall firewall delete rule name="Allow_Tunnel_Out" >nul 2>&1
netsh advfirewall firewall add rule name="Allow_Tunnel_Out" dir=out action=allow remoteip=10.0.0.0/24

REM Разрешаем localhost
netsh advfirewall firewall delete rule name="Allow_Loopback" >nul 2>&1
netsh advfirewall firewall add rule name="Allow_Loopback" dir=out action=allow remoteip=127.0.0.1

echo [OK] Исходящие: только WireGuard и туннель

REM ========================================
REM ВХОДЯЩИЕ - RDP РАЗРЕШЕН
REM ========================================

REM Явно разрешаем входящий RDP (по умолчанию уже разрешен, но на всякий случай)
netsh advfirewall firewall delete rule name="Allow_RDP_In" >nul 2>&1
netsh advfirewall firewall add rule name="Allow_RDP_In" dir=in action=allow protocol=TCP localport=3389

echo [OK] Входящий RDP разрешен

echo.
echo ========================================
echo [OK] МЯГКАЯ БЛОКИРОВКА НАСТРОЕНА
echo ========================================
echo.
echo Что разрешено:
echo [+] ИСХОДЯЩИЕ: Только WireGuard и туннель (НЕТ УТЕЧКИ IP!)
echo [+] ВХОДЯЩИЕ: RDP к 185.244.175.90:3389 работает
echo.
echo Проверьте:
echo 1. curl ifconfig.me - должен показать 194.31.72.192
echo 2. RDP к 185.244.175.90 - должен работать
echo.
echo Когда настроите port forwarding на эталоне, используйте
echo BLOCK_HARD_TUNNEL_ONLY.bat для полной блокировки
echo ========================================

pause
