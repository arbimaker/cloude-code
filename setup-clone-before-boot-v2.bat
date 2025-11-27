@echo off
REM ��������� ����� ����� ������ ��������� - ������ 2
REM �믮����� �� ��� .90 ����� VHDX ᬮ��஢�� ��� D:
REM �����: �� ������� 䠩ࢮ� � ��⮧����! �� ������ ��� ������ ��᫥ ��⠭���� WireGuard.

echo ========================================
echo ��������� ����� ����� ������ ���������
echo ������ 2 (��� ��������������)
echo ========================================
echo.
echo VHDX ������ ���� ᬮ��஢�� ��� D:
echo �᫨ �� ᬮ��஢��, �믮����:
echo   diskpart
echo   select vdisk file="C:\VMClone\clon192-3.vhdx"
echo   attach vdisk
echo   list volume
echo   exit
echo.
pause

REM �஢��塞 ����㯭���� D:\Windows
if not exist D:\Windows (
    echo [������] D:\Windows �� ������!
    echo �������� VHDX ᭠砫�
    pause
    exit /b 1
)

echo [OK] D:\Windows ������
echo.

REM ========================================
REM ��� 1: ������� ��४��� ��� 䠩���
REM ========================================
echo ��� 1: �������� ��४�ਨ D:\Setup...
mkdir "D:\Setup" 2>nul

if exist "D:\Setup" (
    echo [OK] ��४��� D:\Setup ᮧ����
) else (
    echo [������] �� 㤠���� ᮧ���� ��४���
    pause
    exit /b 1
)

REM ========================================
REM ��� 2: �����㥬 ��⠭��騪 WireGuard
REM ========================================
echo.
echo ��� 2: ����஢���� ��⠭��騪� WireGuard...
echo ��������: �������� �� wireguard-installer.exe ��室���� � ⥪�饩 ��४�ਨ!
echo ������: https://download.wireguard.com/windows-client/wireguard-installer.exe
echo.

if exist "wireguard-installer.exe" (
    copy "wireguard-installer.exe" "D:\Setup\" /Y
    echo [OK] WireGuard installer ᪮��஢��
) else (
    echo [��������������] wireguard-installer.exe �� ������
    echo �� ����� ᪮��஢��� ��� ����� ������
    pause
)

REM ========================================
REM ��� 3: �����㥬 ���䨣���� WireGuard
REM ========================================
echo.
echo ��� 3: ����஢���� ���䨣��樨 WireGuard...

if exist "wg-clone.conf" (
    copy "wg-clone.conf" "D:\Setup\" /Y
    echo [OK] wg-clone.conf ᪮��஢��
) else (
    echo [��������������] wg-clone.conf �� ������
    pause
)

REM ========================================
REM ��� 4: �����㥬 �ਯ�� �����஢�� (��� ��筮�� ����᪠)
REM ========================================
echo.
echo ��� 4: ����஢���� �ਯ⮢ �����஢�� 䠩ࢮ��...
echo �����: �� �ਯ�� �� � ��⮧���᪥! ����᪠�� �������!

if exist "BLOCK_SOFT_ALLOW_RDP.bat" (
    copy "BLOCK_SOFT_ALLOW_RDP.bat" "D:\Setup\" /Y
    echo [OK] BLOCK_SOFT_ALLOW_RDP.bat ᪮��஢��
) else (
    echo [��������������] BLOCK_SOFT_ALLOW_RDP.bat �� ������
)

if exist "BLOCK_HARD_TUNNEL_ONLY.bat" (
    copy "BLOCK_HARD_TUNNEL_ONLY.bat" "D:\Setup\" /Y
    echo [OK] BLOCK_HARD_TUNNEL_ONLY.bat ᪮��஢��
) else (
    echo [��������������] BLOCK_HARD_TUNNEL_ONLY.bat �� ������
)

REM ========================================
REM ��� 5: �����㥬 ���਩�� �ਯ� ������
REM ========================================
echo.
echo ��� 5: ����஢���� ���਩���� �ਯ� ������...

if exist "EMERGENCY_RETURN-READY.bat" (
    copy "EMERGENCY_RETURN-READY.bat" "D:\EMERGENCY_RETURN.bat" /Y
    echo [OK] EMERGENCY_RETURN.bat ᪮��஢�� � D:\
) else (
    echo [��������������] EMERGENCY_RETURN-READY.bat �� ������
    pause
)

REM ========================================
REM ����������
REM ========================================
echo.
echo ========================================
echo ��������� ����� ���������
echo ========================================
echo.
echo �� �뫮 ᤥ����:
echo [+] ������� ��४��� D:\Setup
echo [+] �����஢�� WireGuard installer (�᫨ �� ������)
echo [+] �����஢��� ���䨣���� WireGuard
echo [+] �����஢��� �ਯ�� �����஢�� (��� ��筮�� ����᪠!)
echo [+] �����஢�� ���਩�� �ਯ� ������
echo.
echo ��������� ����:
echo 1. �������஢��� VHDX
echo 2. ����ந�� WireGuard ���� � wg-clone.conf
echo 3. �����஢��� ᭮�� � ᪮��஢��� ���������� ���䨣
echo 4. �������஢���
echo 5. ����㧨�� ����
echo 6. ��᫥ ����㧪�:
echo    a) ��⠭����� WireGuard �� D:\Setup\wireguard-installer.exe
echo    b) ������஢��� D:\Setup\wg-clone.conf
echo    c) ��⨢�஢��� �㭭���
echo    d) �஢����: curl ifconfig.me (������ ���� 194.31.72.192)
echo    e) �������� D:\Setup\BLOCK_SOFT_ALLOW_RDP.bat
echo.
echo �����: ���ࢮ� �� ����砥��� ��⮬���᪨!
echo �� ������ ��� ������ ��᫥ ��⠭���� WireGuard.
echo ========================================
echo.
pause
