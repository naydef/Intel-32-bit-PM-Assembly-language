;
;		kernel.asm
;		kernel
;
;	This file should be compiled into kernel.bin, then write to Sector 2 
;
;	Mighten Dai, 16:24, July 19, 2015
;   Finally Modified by: ;	Mighten Dai<mighten.dai@gmail.com>
;                             16:56, July 20, 2015
;
;
;    Kernel, Base Address 0x0002_0000, length = 65,536 Bytes
;			!!!!!! Caution: Offset address was counted from 0x00000000 !!!!!!!
;			But Kernel codes uses Flat model Physical Address 
;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

%include "common_macro.asm"

;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
;			Kernel Code.   
[bits 32]
kernel_32_bit_entry:
	mov		eax, Ring0FlatData
	mov		es, eax
	mov		ds, eax
	mov		ss, eax
	mov		esp, phy_address_kernel_empty_stack_esp
	
	mov		eax, Kernel_Task_Selector
	ltr		ax

	mov		esi, PM_String + phy_address_kernel_base
	mov		edi, phy_address_video_buffer_head
	mov		ah, 0x07             ; Color Attributes
	mov		dx, 0x0412
	call	_32_show_string

	jmp		Task_A_Selector:0

;  Kernel Paused infinitely.
	cli
	jmp		short $

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
PM_String:  db '[Kernel]: Hello, I am a regenerated Kernel, goto A, never wanna back...', 0
            db 0    ; Terminated mark.

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
%include "..\MyMiniLibrary\show_string\_32_show_string.asm"
%include "..\MyMiniLibrary\32Descriptor\make_descriptor.asm"
;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::




times 512 * 2 - ($ -$$) db 0xCC