@echo off
call clean.cmd
nasm -o MBR.bin -l MBR.lst MBR.asm
nasm -o Kernel.bin -l Kernel.lst Kernel.asm
nasm -o SysInfo.bin -l SysInfo.lst SysInfo.asm

nasm -o task_A.bin -l task_A.lst task_A.asm
nasm -o task_B.bin -l task_B.lst task_B.asm
pause