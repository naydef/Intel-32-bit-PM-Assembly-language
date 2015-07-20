@echo off
nasm -o MBR.bin MBR.asm
nasm -o SysInfo.bin SysInfo.asm
nasm -o Kernel.bin kernel.asm
pause