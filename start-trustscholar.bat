@echo off
setlocal enabledelayedexpansion
title TrustScholar - Web ^& Backend Registry Server

echo ===============================================================================
echo                TRUSTSCHOLAR -- BO KHOI DONG MAY CHU DU AN
echo ===============================================================================
echo.

:: 1. Kiem tra thu muc lam viec
if not exist "web\index.html" (
    echo [LOI] Khong tim thay thu muc 'web\index.html'!
    echo Vui long chay file .bat nay tu thu muc goc cua du an TrustScholar.
    echo Thu muc hien tai: %CD%
    echo.
    pause
    exit /b 1
)

:: 2. Kiem tra xem may chu da chay tren cong 3000 chua
echo [1/3] Kiem tra trang thai cong 3000...
powershell -NoProfile -Command "try { $res = Invoke-RestMethod -Uri 'http://127.0.0.1:3000/api/health' -TimeoutSec 2; if ($res.status -eq 'ok') { exit 0 } else { exit 2 } } catch { exit 1 }"
set HEALTH_STATUS=%ERRORLEVEL%

if %HEALTH_STATUS% EQU 0 (
    echo.
    echo ===============================================================================
    echo [THONG BAO] May chu TrustScholar DANG HOAT DONG SAN SANG tren cong 3000
    echo URL Giao dien Web: http://localhost:3000
    echo URL Health-Check:  http://localhost:3000/api/health
    echo URL Students API:  http://localhost:3000/api/students
    echo ===============================================================================
    echo.
    echo Ban co the mo trinh duyet va su dung ngay.
    echo.
    pause
    exit /b 0
)

:: Neu cong 3000 bi chiem boi tien trinh khac khong phai TrustScholar
powershell -NoProfile -Command "$conn = Get-NetTCPConnection -LocalPort 3000 -State Listen -ErrorAction SilentlyContinue; if ($conn) { exit 1 } else { exit 0 }"
if %ERRORLEVEL% EQU 1 (
    echo.
    echo [CANH BAO] Cong 3000 dang bi chiem boi mot ung dung khac khong phai TrustScholar!
    echo Vui long kiem tra hoac tat ung dung dang chiem cong 3000 truoc khi khoi dong.
    echo.
    pause
    exit /b 1
)
echo     - Cong 3000 san sang.

:: 3. Kiem tra moi truong Node.js / Python
echo [2/3] Kiem tra moi truong thuc thi...
set SERVER_EXEC=

where node >nul 2>&1
if %ERRORLEVEL% EQU 0 (
    if exist "scripts\server.mjs" (
        set SERVER_EXEC=node scripts\server.mjs
        echo     - Tim thay Node.js. Chon: node scripts\server.mjs
    )
)

if "%SERVER_EXEC%"=="" (
    where python >nul 2>&1
    if %ERRORLEVEL% EQU 0 (
        if exist "scripts\server.py" (
            set SERVER_EXEC=python scripts\server.py 3000
            echo     - Tim thay Python. Chon: python scripts\server.py 3000
        )
    )
)

if "%SERVER_EXEC%"=="" (
    echo.
    echo [LOI] Khong tim thay Node.js hoac Python tren may tinh!
    echo Vui long cai dat Node.js ban 20 tro len hoac Python 3.
    echo.
    pause
    exit /b 1
)

:: 4. Khoi chay may chu backend
echo [3/3] Khoi chay may chu: %SERVER_EXEC%
echo.
echo ===============================================================================
echo Giao dien DApp: http://localhost:3000
echo Health-check:   http://localhost:3000/api/health
echo Students API:   http://localhost:3000/api/students
echo.
echo [Luu y] Giu cua so nay de duy tri ket noi Backend. Nhan Ctrl+C de dung.
echo ===============================================================================
echo.

%SERVER_EXEC%
