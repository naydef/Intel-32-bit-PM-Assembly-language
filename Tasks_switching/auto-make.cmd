@echo off
echo Compiling...
nasm -o MBR.bin     -l MBR.lst     MBR.asm
nasm -o Kernel.bin  -l Kernel.lst  Kernel.asm
nasm -o SysInfo.bin -l SysInfo.lst SysInfo.asm

nasm -o task_A.bin  -l task_A.lst  task_A.asm
nasm -o task_B.bin  -l task_B.lst  task_B.asm

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

echo  **********  writting task_A.bin ...
dd if=task_A.bin of="C:\Program Files\Bochs_2_6_7\a.img" seek=5 bs=512 count=1
echo.
echo.

echo  **********  writting task_B.bin ...
dd if=task_B.bin of="C:\Program Files\Bochs_2_6_7\a.img" seek=6 bs=512 count=1
echo.
echo.

echo.==========================================================
echo.  Clean temporary file by pressing any key, otherwise please manually close the window.
echo.
echo.

echo.                      Press any key to continue...
pause>nul

del /q *.lst
del /q *.bin