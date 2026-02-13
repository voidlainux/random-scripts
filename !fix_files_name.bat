@echo off
setlocal disabledelayedexpansion

set "target=."
cd /d "%target%"

echo scanning for files...

for /r %%a in ("*Addon* v.pkg") do (
    set "fpath=%%~dpa"
    set "fname=%%~na"
    set "fext=%%~xa"

    setlocal enabledelayedexpansion
    set "newname=!fname:~0,-2!"

    echo processing: "!fname!!fext!"

    pushd "!fpath!"
    ren "!fname!!fext!" "!newname!!fext!"
    popd

    endlocal
)

echo done.
pause
