@ECHO OFF

cd %BUILD_DIR%
tasm /zi %SRC_DIR%\dis.asm /i%SRC_DIR%
tlink %BUILD_DIR%\dis.obj