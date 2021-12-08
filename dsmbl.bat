@ECHO OFF

set TASM_DIR=c:\TASM

set BUILD_DIR=build
set SRC_DIR=src
set TEST_DIR=tests

if ["%1"]==[""] (
        echo No arg given. 
        goto :help
        exit 0
)
if ["%1"]==["run"] (
        if not exist "%BUILD_DIR%" mkdir "%BUILD_DIR%"
        dosbox -conf conf\dosbox.conf^
                -c "mount c '%TASM_DIR%'"^
                -c "set PATH=c:;d:\scripts"^
                -c "set BUILD_DIR=d:\%BUILD_DIR%"^
                -c "set SRC_DIR=d:\%SRC_DIR%"^
                -c "set TEST_DIR=d:\%TEST_DIR%"^
                -c "mount d '%cd%'"^
                -c "d:"^
                -c "build.bat"^
                -c "run.bat"
        exit 0
)
if ["%1"]==["build"] (
        if not exist "%BUILD_DIR%" mkdir "%BUILD_DIR%"
        dosbox  -conf conf\dosbox.conf^
                -c "mount c '%TASM_DIR%'"^
                -c "set PATH=c:;d:\scripts"^
                -c "set BUILD_DIR=d:\%BUILD_DIR%"^
                -c "set SRC_DIR=d:\%SRC_DIR%"^
                -c "set TEST_DIR=d:\%TEST_DIR%"^
                -c "mount d '%cd%'"^
                -c "d:"^
                -c "build.bat"
        exit 0
)
if ["%1"]==["dbuild"] (
        if not exist "%BUILD_DIR%" mkdir "%BUILD_DIR%"
        dosbox  -conf conf\dosbox.conf^
                -c "mount c '%TASM_DIR%'"^
                -c "set PATH=c:;d:\scripts"^
                -c "set BUILD_DIR=d:\%BUILD_DIR%"^
                -c "set SRC_DIR=d:\%SRC_DIR%"^
                -c "set TEST_DIR=d:\%TEST_DIR%"^
                -c "mount d '%cd%'"^
                -c "d:"^
                -c "dbuild.bat"
        exit 0
)
if ["%1"]==["debug"] (
        if not exist "%BUILD_DIR%" mkdir "%BUILD_DIR%"
        dosbox  -conf conf\dosbox.conf^
                -c "mount c '%TASM_DIR%'"^
                -c "set PATH=c:;d:\scripts"^
                -c "set BUILD_DIR=d:\%BUILD_DIR%"^
                -c "set SRC_DIR=d:\%SRC_DIR%"^
                -c "set TEST_DIR=d:\%TEST_DIR%"^
                -c "mount d '%cd%'"^
                -c "d:"^
                -c "dbuild.bat"^
                -c "dbg.bat"
        exit 0
)

echo Wrong arg.

:help
echo Possible args:
echo    build   - normal build;
echo    dbuild  - debug build;
echo    run     - normal build + run; - doesn't work yet
echo    debug   - debug build + run debugger; - doesn't work yet