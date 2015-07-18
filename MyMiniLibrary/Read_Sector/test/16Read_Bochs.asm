;	16Read_Bochs.asm   -- NASM 2.07 Testing & Bochs 2.6.7
;		Read Logical-Block-Address(LBA) Floppy-Disk-A Sector(s) in RM to memory location.
;
;								Mighten Dai, 22:39, July 18, 2015
;
;	**** Compilation:
;		# nasm -o test16.bin 16Read_Bochs.asm
;
;	**** Preparation of Bochs for its Simulation
;		# Configure the *.bxrc file with its *.IMG file which represent the "Floppy Disk A:"
;		# By using Binary-writing tool such as "WinHex"
;			1> Write test16.bin, or rather, the newly compiled binary file, 
;				to 1st Sector
;			2> Write 0xAA manually to the whole the second sector.
;			3> Write 0x55 manually to the whole the third  sector, save it.
;
;	**** Debugging Guidance:
;       1> Fill LBA Sector 1 to 2 (0x200 to 0x5FF) with 0xAA and 0x55 separately.
;	   2> By using "bochsdbg.exe", Step Over "call  _RM_read_floppy_data2memory"
;       3> Check Memory 0200:0000 to 0200:03FF
;
;
org		0x7c00

__@@@_program_entry:
cli
xor		ax, ax
mov		ax, cs
mov		ss, ax
mov		sp, 0x7c00
mov		ds, ax

mov		ax, 0x0200
mov		es, ax  ; ES:BX ---> Begin address.
xor		bx, bx  ; ES:BX = 0200:0000
mov		ax, 1   ; # AX = from LBA sector # 1
mov		cx, 2   ; # CX = read 2 sectors

call	_RM_read_floppy_data2memory

xor		ax, ax
xor		ax, ax
hlt             ; With CLI, halting


; ## Special Mark of  "..\" means goto the last-level directory or folder,
;               where the target ASM source file is located.
%include "..\_RM_read_floppy_data2memory.asm"

;;;;;;;
; Filling the sectors remained, generate the effective MBR's mark 0xaa55 
times 510 - ( $- $$ ) db 0
dw		0xaa55				; Caution: Byte order Little-endian order:  0x1FE is 0x55, while 0x1FF is 0xAA