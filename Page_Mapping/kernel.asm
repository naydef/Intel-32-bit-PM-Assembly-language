;
;		kernel.asm
;		kernel
;
;	This file should be compiled into kernel.bin, then write to Sector 2 
;
;	Mighten Dai, 16:24, July 19, 2015
;   Finally Modified by: ;	Mighten Dai<mighten.dai@gmail.com>
;                             23:50, July 21, 2015
;
;       *****This is a configure-setter, its Vir-Address must remain equal to  Phy-Address!!!!!
;
;    Kernel, Base Physical Address 0x0002_0000, length = 65,536 Bytes
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
	
	; Filling the PTE items which is corresponding to PDE[0].
	call	___@@internal_routine_install_PTE_into_PDE_N0

	;;;;   Enable the Paging Memory Mechanism
	mov		eax, PDPTE         ; Me defined constant.
	mov		cr3, eax
	mov		eax, cr0
	or		eax, 0x8000_0000   ; Set the PG flag in CR0( PG flag is Bit 31 )
	mov		cr0, eax           ; Enable Paging memory mechanism from then on.

	; here is to solve the potential problem cause by Virtual Address.
	;     Normally now is the empty stack, and thus I will...
	mov		eax, Ring0FlatData
	mov		ss, eax
	mov		esp, vir_address_kernel_empty_stack_esp

	;;; Display some info on screen to celebrate this victory!!!!
	mov		esi, PM_String + phy_address_kernel_base
	mov		edi, vir_address_video_buffer_head    ; Video Buffer head.
	mov		ah, 0x07                              ; Color Attributes
	mov		dx, 0x0412
	call	_32_show_string

	jmp		dword Task_A_Selector:0xFFFF_FFFF

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
___@@internal_routine_install_PTE_into_PDE_N0:
pushad
pushf

mov		eax, 0x0000_0007
mov		ecx, 0x200
mov		edi, 0x0001_1000

_@_internal_filling_PTE_of_PDE:
; phy_address_Task_A_base    inside this portion, 
;   but it is better to omit by default .
	mov		[edi], eax
	inc		edi
	inc		edi
	inc		edi
	inc		edi
	add		eax, 0x0000_1000
	loop	_@_internal_filling_PTE_of_PDE

;    vir_address_Task_A_base = 0x0020_0000
;    phy_address_Task_A_base = 0x0005_0000
; turn to the corresponding Location to set   vir_address_Task_A_base,
;                   so that I can map it to   phy_address_Task_A_base
mov		eax, 0x0005_0007
mov		[edi], eax
inc		edi
inc		edi
inc		edi
inc		edi
add		eax, 0x0000_1000
mov		[edi], eax
popf
popad
ret

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
PM_String:  db '[Kernel]: Hello, I am a Kernel in Paging Memory Mode!', 0   ; Terminated mark.

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
%include "..\MyMiniLibrary\show_string\_32_show_string.asm"
;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::




times 512 * 2 - ($ -$$) db 0xCC