@ECHO OFF

set TEST_FILE=%1
if ["%1"]==[""] set TEST_FILE=test1

td %BUILD_DIR%\dis%BUILD_DIR%\%TEST_FILE%.com %TEST_FILE%.txt