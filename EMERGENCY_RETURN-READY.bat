@echo off
REM ��������� ������� � �������� �������
REM ��� �ਯ� ࠧ��頥��� � ����� ��� ����७���� ������ � �᭮���� ��⥬�
REM ��������� � �����: D:\EMERGENCY_RETURN.bat (����� VHDX ᬮ��஢��)
REM ��᫥ ����㧪� ����� �㤥� ����㯥� ��� C:\EMERGENCY_RETURN.bat

echo ========================================
echo ��������� ������� � �������� �������
echo ========================================
echo.
echo ��� �ਯ� ��୥� ����㧪� � �᭮���� ��⥬�
echo � ���������� ��१������ �ࢥ�
echo.
echo ��������! ��१���� �१ 10 ᥪ㭤...
echo.

bcdedit /bootsequence {default}

if %errorlevel% equ 0 (
    echo [OK] ������ � �᭮���� ��⥬� ����஥�
    shutdown /r /t 10 /c "��������� ������� � �������� �������"
) else (
    echo [������] �� 㤠���� ����ந�� ������
    echo ���஡�� ������: bcdedit /bootsequence {default}
    pause
)
