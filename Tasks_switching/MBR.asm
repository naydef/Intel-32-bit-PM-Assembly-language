;
;	MBR.asm
;	Kernel Loader
;
;	Mighten Dai, 14:25, Feb 28, 2015
;   Finally Modified by: Mighten Dai<mighten.dai@gmail.com>
;                             16:56, July 20, 2015
;
;##############################################
;#   Descriptor  located in LBA-address 1
;#   Kernel Code located in LBA-address 2 to 5  
;#

%include "common_macro.asm"


org		0x7c00

;::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
cli
mov		ax, cs
mov		ss, ax
mov		sp, 0x7c00

; Clean screen of Bochs.
call	_RM_clean_screen

;   SYS INFO Loading... at Floppy A:  LBA-address 3~4    Size = 0x400 Bytes = 1,024 Bytes
;					   To Memory     0x0003_0000 ~ 0x0003_03FF
;   Load GDT stored in Floppy A:
mov		ax, 0x3000
mov		es, ax
xor		bx, bx    ; ES:BX = Linear 3000:0000 => Physical 0x0003_0000
mov		ax, 3     ; LBA-Address 3~4
mov		cx, 2     ; Number of sectors to read.
call	_RM_read_floppy_data2memory

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;   Kernel Loading... at Floppy A:  LBA-address 1~2    Size = 0x400 Bytes = 1,024 Bytes
;						To Memory     0x0002_0000 ~ 0x0002_03FF
;   Load kernel stored in Floppy A:
mov		ax, 0x2000
mov		es, ax
xor		bx, bx    ; ES:BX = Linear 2000:0000 => Physical 0x0002_0000
mov		ax, 1     ; LBA-Address 1~2
mov		cx, 2     ; Number of sectors to read.
call	_RM_read_floppy_data2memory

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;   Task A Codes Loading... at Floppy A:  LBA-address 5       Size = 0x200 Bytes = 512 Bytes
;						To Memory     0x0005_0000 ~ 0x0005_01FF
;   Load Task A Codes stored in Floppy A:
mov		ax, 0x5000
mov		es, ax
xor		bx, bx    ; ES:BX = Linear 5000:0000 => Physical 0x0005_0000
mov		ax, 5     ; LBA-Address 5
mov		cx, 1     ; Number of sectors to read.
call	_RM_read_floppy_data2memory

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;   Task B Codes Loading... at Floppy A:  LBA-address 6       Size = 0x200 Bytes = 512 Bytes
;						To Memory     0x0007_0000 ~ 0x0007_01FF
;   Load Task B Codes stored in Floppy A:
mov		ax, 0x7000
mov		es, ax
xor		bx, bx    ; ES:BX = Linear 7000:0000 => Physical 0x0007_0000
mov		ax, 6     ; LBA-Address 6
mov		cx, 1     ; Number of sectors to read.
call	_RM_read_floppy_data2memory

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;   String showing...
mov		ax, cs
mov		es, ax									; ES Point to the address of string.
mov		ax, LoaderMessage
mov		bp, ax									; BP Point to the address of string.
mov		bl, 0x0C								; Attributes = (BL)
mov		dx, 0x0000								; Line ID = (DH), Column ID = (DL)
call	_16_show_string

lgdt	[ PseudoGDT_Head ]

cli

; Configure A20 to enable whole 4 GB  Memory space.
in		al, 0x92
or		al, 0000_0010B
out		0x92, al

; Set CR0, to set field PE to 1.
mov		eax, cr0
or		eax, 1
mov		cr0, eax		; Protection Enabled, 

; Goto Kernel
jmp		dword	Ring0FlatCode:phy_address_kernel_base

LoaderMessage:			db '[Loader]: Now The kernel is loaded, and is executing...', 0
LoaderMessageTail:

;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
PseudoGDT_Head:
		dw		GDT_Limit
		dd		GDT_Base
PseduoGDT_Tail:

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Windows7 Platform-Specific Path notation.
%include "..\MyMiniLibrary\RM_clean_Screen\_RM_clean_screen.asm"
%include "..\MyMiniLibrary\Read_Sector\_RM_read_floppy_data2memory.asm"
%include "..\MyMiniLibrary\show_string\_16_show_string.asm"


times 0x1FE - ( $ -$$ ) db 0xCC
dw 0xaa55