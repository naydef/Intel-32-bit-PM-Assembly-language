;
;	MBR.asm
;	Kernel Loader
;
;	Mighten Dai, 14:25, Feb 28, 2015
;   Finally Modified by: Mighten Dai<mighten.dai@gmail.com>
;                             17:34, July 20, 2015
;

%include "common_macro.asm"


org		0x7c00

;::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
cli
mov		ax, cs
mov		ss, ax
mov		sp, 0x7c00

; Clean screen of Bochs.
call	_RM_clean_screen

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;   Page Map Loading... at Floppy A:  LBA-address 5~6    Size = 0x400 Bytes = 1,024 Bytes
;					    To Memory     0x0001_0000 ~ 0x0001_03FF
;   Load kernel stored in Floppy A:
mov		ax, 0x1000
mov		es, ax
xor		bx, bx    ; ES:BX = Linear 1000:0000 => Physical 0x0001_0000
mov		ax, 5     ; LBA-Address 5~6
mov		cx, 2     ; Number of sectors to read.
call	_RM_read_floppy_data2memory

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
;   Page Map Loading... at Floppy A:  LBA-address 7    Size = 0x200 Bytes = 512 Bytes
;					    To Memory     0x0005_0000 ~ 0x0005_03FF
;   Load kernel stored in Floppy A:
mov		ax, 0x5000
mov		es, ax
xor		bx, bx    ; ES:BX = Linear 5000:0000 => Physical 0x0005_0000
mov		ax, 7     ; LBA-Address 7
mov		cx, 1     ; Number of sectors to read.
call	_RM_read_floppy_data2memory

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;   Handler Codes Loading... at Floppy A:  LBA-address 10    Size = 0x6400 Bytes = 25,600 Bytes
;					         To Memory   0x0007_0000 ~ 0x0007_03FF
;   Load kernel stored in Floppy A:
mov		ax, 0x7000
mov		es, ax
xor		bx, bx       ; ES:BX = Linear 7000:0000 => Physical 0x0007_0000
mov		ax, 0x0A     ; LBA-Address 0xA = 10 decimally
mov		cx, 0x32     ; Number of sectors to read. 0x32 = 50 decimally
call	_RM_read_floppy_data2memory

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
lgdt	[ PseudoGDT_Head ]
lidt	[ PseudoIDT_Head]

;    the Interrupt Flag in FLAGS Register is cleared
;
; Configure A20 to enable whole 4 GB  Memory space.
in		al, 0x92
or		al, 0000_0010B
out		0x92, al

; Set CR0, to set field PE to 1.
mov		eax, cr0
or		eax, 1
mov		cr0, eax		; Protection Enabled

; Goto Kernel, and flush the CPU Instruction-Prefetching sequence.
; MUST use Phy-Address because Paged-Memory Mode now is Disabled due to CR0.PG = 0 initially.
jmp		dword	Ring0FlatCode:phy_address_kernel_base

;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
PseudoGDT_Head:
		dw		GDT_Limit
		dd		GDT_Base
PseduoGDT_Tail:

;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
PseudoIDT_Head:
		dw		IDT_Limit
		dd		IDT_Base
PseduoIDT_Tail:

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Windows7 Platform-Specific Path notation.
%include "..\..\MyMiniLibrary\RM_clean_Screen\_RM_clean_screen.asm"
%include "..\..\MyMiniLibrary\Read_Sector\_RM_read_floppy_data2memory.asm"

times 0x1FE - ( $ -$$ ) db 0xCC
dw 0xaa55