REM This is designed for the app: "https://store.steampowered.com/app/1920960/_/".
REM Script info: Written by LiuJiewenTT on 2024-05-25 11:01:00 +0800
REM Project Link: "https://github.com/LiuJiewenTT/vpet_modsync"


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
@if not defined reserve_myself (
    set reserve_myself=true
    echo [Default option]: reserve_myself=true
) else (
    echo Defined reserve_myself: %reserve_myself%
)
@if not defined excludes (
    set "excludes="
    if /I "%reserve_myself%" == "true" (
        set reserved_names_myself=3032653569,vpet_modsync
    )
    if not defined excludes (
        set "excludes=!reserved_names_myself!"
        if not defined excludes (
            echo [Default option]: excludes [None]
        ) else (
            echo [Default option]: excludes=!excludes!
        )
    ) else (
        set excludes=!excludes!,!reserved_names_myself!
        echo [Default option]: excludes=!excludes!
    )
) else (
    echo Defined excludes: %excludes%
)

@if ERRORLEVEL 1 (
    echo 发生未知错误，终止运行。可能是由于预定义选项语法错误。
    @EXIT /B 2
)

@echo cd=%cd%
@REM 校验当前目录
@set "tmp="
@set "tmp2="
@for /f "delims=" %%i in ('echo "%cd%\""^|findstr /L "SteamLibrary\steamapps\""') do @(set "tmp=%%i")
@for /f "delims=" %%i in ('echo "%cd%\""^|findstr /L "Steam\steamapps\""') do @(set "tmp2=%%i")
@if defined tmp @(
	set SteamLibraryName=SteamLibrary
) else if defined tmp2 @(
	set SteamLibraryName=Steam
) else (
	@echo 未在当前工资路径中找到Steam应用存储库SteamLibrary或Steam。
    @EXIT /B 3
)
@set "tmp="
@for /f "delims=" %%i in ('echo %cd%^|findstr /L "%SteamLibraryName%\steamapps\workshop\content\1920960"') do @(set "tmp=%%i")
@if defined tmp @(
	:loop1
	REM 回显开启状态提示当前目录
	@set "tmp="
	@for /f "delims=" %%i in ('echo !cd!^|findstr /E "%SteamLibraryName%\steamapps\workshop\content\1920960"') do @(set "tmp=%%i")
	@if not defined tmp @(
		cd ..
		@goto:loop1
	)
	@cd ..
	@echo cd^(changed^)=!cd!
) else (
	@set "tmp="
	@for /f "delims=" %%i in ('echo %cd%^|findstr /L "%SteamLibraryName%\steamapps\common\VPet\mod"') do @(set "tmp=%%i")
	@if defined tmp @(
		:loop2
		REM 回显开启状态提示当前目录
		@set "tmp="
		@for /f "delims=" %%i in ('echo !cd!^|findstr /E "%SteamLibraryName%\steamapps\common\VPet\mod"') do @(set "tmp=%%i")
		@if not defined tmp @(
			cd ..
			@goto:loop2
		)
		@cd ..\..\..\workshop\content
		@echo cd^(changed^)=!cd!
	)
)
@set "tmp="
@for /f "delims=" %%i in ('echo %cd%^|findstr /L "%SteamLibraryName%\steamapps\workshop\content"') do @(set "tmp=%%i")
@if not defined tmp @(
	echo 未在当前目录的路径中查找到：%SteamLibraryName%\steamapps\workshop\content
	@EXIT /B 1
)

@for /f "delims=" %%i in ('dir /b /A:D 1920960') do @(
	if exist "..\..\common\VPet\mod\%%i" ( 
        set ready_flag=NOT_SET
		echo [VPet\mod\%%i]即将断开连接。
        @set "tmp="
		@for /f "delims=" %%j in ('echo %excludes%^|findstr /L "%%i"') do @(set "tmp=%%j")
		@if defined tmp @(
            echo [VPet\mod\%%i]属于例外，跳过操作。
            set ready_flag=false
        )
        if /I "!ready_flag!" NEQ "false" if /I "%check_level%" GEQ "1" (
            set "tmp="
            for /f "delims=" %%j in ('dir /A:DL ..\..\common\VPet\mod^|findstr "%%i"^|findstr "JUNCTION"') do @(set "tmp=%%j")
            if defined tmp (
                set ready_flag=true
            )
        )
        if /I "!ready_flag!" == "NOT_SET" (
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
