@echo off
REM �������᪨� ������� � �᭮���� ��⥬� �१ 15 �����
REM ��� �ਯ� ������ ����᪠���� �� ����㧪� ����� � 䮭� (Startup)
REM �������� � �����: D:\Windows\System32\GroupPolicy\Machine\Scripts\Startup\AUTO_RETURN_15MIN.bat

echo ========================================
echo �������᪨� ������� - 15 �����
echo ========================================
echo.
echo ��� �ਯ� ����᪠���� � 䮭� � ��१���㧨� ��⥬� � �᭮���� �१ 15 �����
echo ���� ������ �⬥���� ����㧪� - �믮���� C:\CANCEL_AUTO_RETURN.bat
echo.

REM �������� 䠩� �⬥�� (㤠�塞 �᫨ ���⥫)
if exist "C:\CANCEL_AUTO_RETURN" (
    echo [��������������] ���������� 䠩� �⬥��, ���������᪨� ������� �⬥���
    del C:\CANCEL_AUTO_RETURN
    exit /b 0
)

REM ������� 䠩� �⬥��
echo. > C:\CANCEL_AUTO_RETURN

REM ����㧪� �१ 15 ����� (900 ᥪ㭤)
echo [OK] ���������᪨� ������� � �᭮���� ��⥬� ����⥫�� �१ 15 �����
echo ��� �⬥��: del C:\CANCEL_AUTO_RETURN

REM ����ন���� ��१���᪠ � 䮭�
start /min powershell -WindowStyle Hidden -Command "Start-Sleep -Seconds 900; if (Test-Path 'C:\CANCEL_AUTO_RETURN') { Remove-Item 'C:\CANCEL_AUTO_RETURN'; bcdedit /bootsequence '{default}'; shutdown /r /t 30 /c '���������᪨� ������� � �᭮���� ��⥬� �१ 15 �����' }"

exit /b 0
