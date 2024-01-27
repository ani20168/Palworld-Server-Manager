@echo off

set "baseDir=H:\Steam game\steamapps\common\PalServer"
set "exeName=PalServer.exe"
set "source=%baseDir%\Pal\Saved\SaveGames\0\85FB8DD545DD599FDAA283AF2769AB1A"
set "dest=%baseDir%\data_backup"

REM RCON參數
set "rconIP=127.0.0.1"  REM 替換為您的伺服器IP
set "rconPort=25575"    REM 替換為您的RCON端口
set "rconPassword="  REM 替換為您的RCON密碼

set /a "counter=0"

:loop
REM 檢查伺服器是否在運行
tasklist | findstr /I "%exeName%" >nul
if errorlevel 1 (
    echo server is closed, backup service will close in 10s
    timeout /t 10
    exit
)


REM 執行備份操作
echo Performing backup operation...
REM 備份操作...

REM 檢查目標資料夾是否存在，如果不存在則創建
if not exist "%dest%" (
   mkdir "%dest%"
)

REM 獲取當前日期和時間作為新資料夾名稱
for /f "tokens=2 delims==" %%a in ('wmic os get localdatetime /value') do set datetime=%%a
set "year=%datetime:~0,4%"
set "month=%datetime:~4,2%"
set "day=%datetime:~6,2%"
set "hour=%datetime:~8,2%"
set "minute=%datetime:~10,2%"
set "newFolder=%year%-%month%-%day%_%hour%_%minute%"

REM 創建新資料夾
set "newDest=%dest%\%newFolder%"
mkdir "%newDest%"

REM 複製所需的文件和資料夾，隱藏詳細輸出
xcopy "%source%\Level.sav" "%newDest%" /I /Y /Q >nul
xcopy "%source%\LevelMeta.sav" "%newDest%" /I /Y /Q >nul
xcopy "%source%\Players" "%newDest%\Players\" /E /I /Y /Q >nul

REM 輸出當前時間
echo Backup started at %newFolder%

REM 檢查並刪除舊的備份資料夾（如果超過200個）
for /f "skip=200 eol=: delims=" %%i in ('dir "%dest%" /b /ad /o-d') do (
    rd /s /q "%dest%\%%i"
    echo Deleted oldest backup folder: %%i
)


REM 每隔30分鐘輸出一次記憶體使用情況
if %counter% equ 0 (
    for /f "tokens=5" %%a in ('tasklist /fi "imagename eq PalServer-Win64-Test-Cmd.exe" ^| findstr /i "PalServer-Win64-Test-Cmd"') do (
        echo Memory Usage: %%a K
        "%baseDir%\arrcon.exe" -H %rconIP% -P %rconPort% -p %rconPassword% "Broadcast PalServer_Memory_Usage:%%aK"
    )
)
REM 更新計數器
set /a counter+=1

REM 如果計數器達3則重置
if %counter% geq 3 set /a counter=0

REM 檢查記憶體高佔用
for /f "tokens=5" %%a in ('tasklist /fi "imagename eq PalServer-Win64-Test-Cmd.exe" ^| findstr /i "PalServer-Win64-Test-Cmd"') do (
    set "memUsage=%%a"
    setlocal enabledelayedexpansion
    set "memUsage=!memUsage:,=!"
    if !memUsage! geq 10000000 (
		echo Alart:Memory High Usage!
		"%baseDir%\arrcon.exe" -H %rconIP% -P %rconPort% -p %rconPassword% "Broadcast Alart:PalServer_Memory_High_Usage:%%aK...Server_will_restart_in_5_mins"
		timeout /t 120 /nobreak >nul
		"%baseDir%\arrcon.exe" -H %rconIP% -P %rconPort% -p %rconPassword% "Broadcast Alart:PalServer_Memory_High_Usage:%%aK...Server_will_restart_in_3_mins"
		timeout /t 120 /nobreak >nul
		"%baseDir%\arrcon.exe" -H %rconIP% -P %rconPort% -p %rconPassword% "Shutdown 60 Server_will_restart_in_1_min"
		
		REM 執行備份操作
		echo Performing backup operation...
		REM 備份操作...

		REM 檢查目標資料夾是否存在，如果不存在則創建
		if not exist "%dest%" (
		   mkdir "%dest%"
		)

		REM 獲取當前日期和時間作為新資料夾名稱
		for /f "tokens=2 delims==" %%a in ('wmic os get localdatetime /value') do set datetime=%%a
		set "year=%datetime:~0,4%"
		set "month=%datetime:~4,2%"
		set "day=%datetime:~6,2%"
		set "hour=%datetime:~8,2%"
		set "minute=%datetime:~10,2%"
		set "newFolder=%year%-%month%-%day%_%hour%_%minute%"

		REM 創建新資料夾
		set "newDest=%dest%\%newFolder%"
		mkdir "%newDest%"

		REM 複製所需的文件和資料夾，隱藏詳細輸出
		xcopy "%source%\Level.sav" "%newDest%" /I /Y /Q >nul
		xcopy "%source%\LevelMeta.sav" "%newDest%" /I /Y /Q >nul
		xcopy "%source%\Players" "%newDest%\Players\" /E /I /Y /Q >nul

		REM 輸出當前時間
		echo Backup started at %newFolder%
		
		REM 等待伺服器關閉完成
		timeout /t 120 /nobreak >nul
		
		REM 重新啟動伺服器
		echo Restarting PalServer...
		start "" "%baseDir%\PalServer.exe"
	)
	endlocal
)

REM 等待10分鐘後進行下一次循環
timeout /t 600 /nobreak >nul
goto loop