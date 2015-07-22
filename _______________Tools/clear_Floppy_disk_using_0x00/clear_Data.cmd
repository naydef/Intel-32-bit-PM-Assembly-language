@echo off
echo. 
echo.
echo.
nasm -o clear_Floppy.bin clear_Floppy.asm
echo.  OK!
echo.
echo ==========================================================
echo.Clearing the Floppy A data on disk.
dd  if=clear_Floppy.bin  of="C:\Program Files\Bochs_2_6_7\a.img" seek=0 bs=1024 count=1440
echo.
echo.
del /q *.bin
echo ==========================================================
echo.                      Press any key to continue...
pause>nul