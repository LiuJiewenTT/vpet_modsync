REM This is designed for the app: "https://store.steampowered.com/app/1920960/_/".
REM Script info: Written by LiuJiewenTT on 2023-09-08 21:43:00 +0800


@setlocal
@setlocal enabledelayedexpansion

@REM 设置代码页为UTF-8
@for /F "tokens=2 delims=:" %%i in ('chcp') do @( set /A codepage=%%i ) 
@call :func_ensureACP

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
		echo [VPet\mod\%%i]已存在。
	) else (
		mklink /J "..\..\common\VPet\mod\%%i" "1920960\%%i" 
	)
)
@EXIT /B 0

:func_ensureACP
    @if /I %codepage% NEQ 65001 ( 
        echo "[LOG]: Active code page is not 65001(UTF-8). [%codepage%]"
        chcp 65001
    )
@goto:eof
