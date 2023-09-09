REM This is designed for the app: "https://store.steampowered.com/app/1920960/_/".
REM Script info: Written by LiuJiewenTT on 2023-09-08 21:42:00 +0800

@setlocal
@setlocal enabledelayedexpansion

@REM 设置代码页为UTF-8
@for /F "tokens=2 delims=:" %%i in ('chcp') do @( set /A codepage=%%i ) 
@call :func_ensureACP

REM 由于是删除连接，故设定更多检查等级（但可能会降低速度）。可用：0, 1
@if not defined check_level (
    set check_level=1
    echo [Default option]: check_level=1
) else (
    echo Defined check_level: %check_level%
)

@echo cd=%cd%
@REM 校验当前目录
@set "tmp="
@for /f "delims=" %%i in ('echo %cd%^|findstr /L "SteamLibrary\steamapps\workshop\content\1920960"') do @(set "tmp=%%i")
@if defined tmp @(
	:loop1
	REM 回显开启状态提示当前目录
	@set "tmp="
	@for /f "delims=" %%i in ('echo !cd!^|findstr /E "SteamLibrary\steamapps\workshop\content\1920960"') do @(set "tmp=%%i")
	@if not defined tmp @(
		cd ..
		@goto:loop1
	)
	@cd ..
	@echo cd^(changed^)=!cd!
) else (
	@set "tmp="
	@for /f "delims=" %%i in ('echo %cd%^|findstr /L "SteamLibrary\steamapps\common\VPet\mod"') do @(set "tmp=%%i")
	@if defined tmp @(
		:loop2
		REM 回显开启状态提示当前目录
		@set "tmp="
		@for /f "delims=" %%i in ('echo !cd!^|findstr /E "SteamLibrary\steamapps\common\VPet\mod"') do @(set "tmp=%%i")
		@if not defined tmp @(
			cd ..
			@goto:loop2
		)
		@cd ..\..\..\workshop\content
		@echo cd^(changed^)=!cd!
	)
)
@set "tmp="
@for /f "delims=" %%i in ('echo %cd%^|findstr /L "SteamLibrary\steamapps\workshop\content"') do @(set "tmp=%%i")
@if not defined tmp @(
	echo 未在当前目录的路径中查找到：SteamLibrary\steamapps\workshop\content
	@EXIT /B 1
)

@for /f "delims=" %%i in ('dir /b /A:D 1920960') do @(
	if exist "..\..\common\VPet\mod\%%i" ( 
        set ready_flag=false
		echo [VPet\mod\%%i]即将断开连接。
        if /I "%check_level%" GEQ "1" (
            set "tmp="
            for /f "delims=" %%j in ('dir /A:DL ..\..\common\VPet\mod^|findstr "%%i"^|findstr "JUNCTION"') do @(set "tmp=%%j")
            if defined tmp (
                set ready_flag=true
            )
        ) else (
            set ready_flag=true
        )
        if "!ready_flag!" == "true" (
            rmdir "..\..\common\VPet\mod\%%i"
            if not ERRORLEVEL 1 (
                set ready_flag=false
                if /I "%check_level%" GEQ "1" (
                    if not exist "..\..\common\VPet\mod\%%i" (
                        set ready_flag=true
                    )
                ) else (
                    set ready_flag=true
                )
                if /I "!ready_flag!" == "true" (
                    echo [VPet\mod\%%i]已断开连接。
                ) else (
                    echo [VPet\mod\%%i]已成功执行断开操作，但由于未知原因似乎未能成功。
                )
            )
        ) else (
            echo [VPet\mod\%%i]检查不通过，拒绝删除连接。
        )
	) else (
		echo [VPet\mod\%%i]连接不存在。
	)
)

@EXIT /B 0

:func_ensureACP
    @if /I %codepage% NEQ 65001 ( 
        echo "[LOG]: Active code page is not 65001(UTF-8). [%codepage%]"
        chcp 65001
    )
@goto:eof
