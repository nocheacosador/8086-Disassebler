@ECHO OFF

cd %BUILD_DIR%
tasm /m2 %TEST_DIR%\%1.asm
tlink /t %1.obj