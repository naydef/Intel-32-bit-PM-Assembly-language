@echo off
echo Compiling...
nasm -l MBR.lst -o MBR.bin MBR.asm
nasm -l kernel.lst -o kernel.bin kernel.asm
nasm -l sysinfo.lst -o sysinfo.bin sysinfo.asm

echo.  OK!
echo.
echo ==========================================================
echo Now writting to Floppy Image a.img....
echo.
echo.
echo.
echo  **********  writting MBR.bin ...
dd if=MBR.bin of="C:\Program Files\Bochs_2_6_7\a.img" seek=0 bs=512 count=1
echo.
echo.

echo  **********  writting kernel.bin ...
dd if=kernel.bin of="C:\Program Files\Bochs_2_6_7\a.img" seek=1 bs=512 count=2
echo.
echo.

echo  **********  writting SYSinfo.bin ...
dd if=sysinfo.bin of="C:\Program Files\Bochs_2_6_7\a.img" seek=3 bs=512 count=2
echo.
echo.

echo ==========================================================
echo Clean temporary file by pressing any key, otherwise please manually close the window.
echo.
echo.

echo.                      Press any key to continue...
pause>nul

del /q *.lst
del /q *.bin