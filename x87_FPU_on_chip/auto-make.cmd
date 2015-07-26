@echo off

set target=x87_FPU_on_chip

REM    !!!!  DO NOT Delete the ^ mark, or will cause error

echo.     Compiling  %target%.asm ---^> %target%.exe  
echo.
echo.
echo.----------------------------------------------
ml /nologo /c /coff %target%.asm
echo.----------------------------------------------
link /nologo /subsystem:windows %target%.obj
echo.----------------------------------------------

del /q *.obj

echo.       Done.
echo.    
pause>nul