; 	pm.asm
; 	    Protected-Mode.
;
; 	Aug 27th, 2014  08:22
;
; 	Mighten Dai
;

;			Segment Descriptor
;	usage:	Descriptor  Base, Limit, Attributes
;			Base		dd
;			Limit		dd ( Low 20 bits available)
;			Attributes	dw	( Low 4 bits of higher byte are always 0 )
%macro		Descriptor	3
	dw		%2 & 0ffffh
	dw		%1 & 0ffffh
	db		(%1 >> 16) & 0ffh
	dw		((%2>>8)&0f00h) | (%3 & 0f0ffh )
	db		(%1>>24) & 0ffh
%endmacro

org	0x7c00


jmp		___16_bit_entry

[section .gdt]
;	GDT
;							Base Address					Limit			Attributes
GDT_Begin:		Descriptor				0,							 0,			0x0000		; An Empty Descriptor
Code_Segment:	Descriptor				0,		Code_segment32_len - 1,			0x409a		; Present  Read  Execute 32-bit Code
Screen_Buffer:	Descriptor		  0xb8000,					    0xffff,			0x0092		; Present  Read  Write  Data
Flat_Memory:	Descriptor				0, 						0xffff,			0x4092		; Present  Read  Write  Data
Code16_Back:	Descriptor				0,						0xffff,			0x009a		; Present  Read  Execute 16-bit Code
; The GDT is End here.

; Now should prepare the Pseudo-GDT Descriptor used for GDTR.
GDT_length		equ		$ - GDT_Begin		; The length of GDT.

GDT_ptr			dw		GDT_length - 1		; GDT Limit
				dd		0					; GDT Base Address.
; How can I use the above segment in the 32-bit code segment?
; The following statement are used to prepare the Code Segment Selector.
;     2 * 2 * 2 = 8, so in hexadecimal, should align by referring the low 3 bit.
Code_Selector	equ		Code_Segment - GDT_Begin
Buffer_Selector	equ		Screen_Buffer - GDT_Begin
Flat_Selector	equ		Flat_Memory  - GDT_Begin
Code16_Selector	equ		Code16_Back - GDT_Begin

; Here is the End of [section .gdt]

[section .code_16]
[bits 16]			; the Tips to NASM Assembler that the following code should calculate by 16-bit.
___16_bit_entry:
	mov		ax, cs
	mov		ss, ax
	mov		sp, 0100h

	mov	[___Go_back_to_Real+3], ax

	mov		ds, ax
	mov		ax, 0xb800
	mov		es, ax
	mov		si, _bit16_string		 ; Don't worry, address calculated by NASM was denoted begin with 0000:7c00
	mov		di, ( 0 * 81 + 0 ) * 2   ; Line 0, Column 0.

	mov		cx, _config_code_segment_base_address - _bit16_string
	mov		ah, 0_000_0_010b   ; Colour Attributes.   Green Font on Black Background.

	_draw16:
		mov		al, [ds:si]
		inc		si
		mov		[es:di], ax
		add		di, 2
		loop	_draw16

	jmp		short _config_code_segment_base_address

_bit16_string:
	db   'CPU Now in Read-Address Mode, And Prepare to enter Protected-Mode...'

_config_code_segment_base_address:
	; Initializing 16-bit code segment Descriptor 
	xor		eax, eax
	mov		ax, cs
	shl		eax, 4						; 
	add		eax, returning_to_16_mode
	mov		word [Code16_Back + 2], ax
	shr		eax, 16
	mov		byte [Code16_Back + 4], al
	mov		byte [Code16_Back + 7], ah

	; Initializing 32-bit code segment Descriptor 
	xor		eax, eax
	mov		ax, cs
	shl		eax, 4
	add		eax, ___32_bit_entry   ; If not do that, the limit will be 0 to code32_length, cause fatal error!!

	mov		[Code_Segment + 2], ax	; Store bit-0 to bit-15    (Base Address)

	shr		eax, 16			; Move the High-Word of EAX to Low-Word of EAX.
	mov		[Code_Segment + 4], al	; Store bit-16 to bit-23    (Base Address)
	mov		[Code_Segment + 7], ah	; Store bit-25 to bit-31    (Base Address)

	; Prepare for Loading Pseudo-GDT descriptor to GDTR.
	xor		eax, eax
	mov		ax, ds
	mov		cl, 4
	shl		eax, cl						; The address Conversion from Real-Address Mode to Protected-Mode
	add		eax, GDT_Begin				;  Calculate the base address of GDT.
	mov		dword [GDT_ptr + 2], eax	; store GDT base into DS:[GDT_ptr + 2]  operand size = DWORD.
	
	lgdt	[GDT_ptr]					; Load Pseudo-GDT Descriptor into GDTR.
	
	; Clean the FLAG's field IF to disable Mask-able Interruption.
	cli
	
	; Configure A20 to enable whole 4 GB  Memory space.
	in		al, 0x92
	or		al, 0000_0010b
	out		0x92, al
	
	; Set CR0, to set field PE to 1.
	mov		eax, cr0
	or		eax, 1
	mov		cr0, eax		; Protection Enabled, 

	; Now into 32-bit Protection.
	;		Load CS with  Code_Selector
	;			 EIP with ___32_bit_entry
	jmp		dword	Code_Selector:0
;  End of [bits 16]

;    Jump into here from section .16_bit_back
;
___16_bit_return_back_entry:

_16_draw_and_exit:
	cli
	in		al, 0x92
	and		al, 1111_1101b
	out		0x92, al

	mov		ax, 0xb800
	mov		es, ax
	mov		di, ( 2 * 80 + 3 ) * 2	; Line 4, Column 0.

	mov		bh, 0_000_1_001b		; Colour Attributes,Blue font on Black background. 
	mov		al, 'O'
	mov		ah, bh
	mov		bl, 'K'
	
	; Print "OK"
	mov		word [es:di], ax
	add		di, 2
	mov		word [es:di], bx

; Nothing to do next, CPU Halt.
__halt:
	hlt
	jmp		short __halt


;   The following 32-bit code begin execution by JMP, instead of falling through.
[section .code_32]
[bits 32]
___32_bit_entry:
	mov		eax, Buffer_Selector	; In order not to generate 0x66 operand reversion mark.
	
	mov		es, eax
	mov		edi, (1 * 80 + 0) * 2	; Line 1, Column 0.

	mov		eax, cs
	mov		ds, eax
	mov		esi, _bit32_string - ___32_bit_entry          ; The 32-bit Code Segment's base address = ___32_bit_entry.

	mov		ecx, ( code_segment_end - _bit32_string ) / 2  ; Due to operand size is Double Word.

	mov		eax,  0x0c_00_0c_00				; Set colour attributes = blue font on black background

	; In the following block
	; ASCII Code Store in  EBX   byte 0, byte 2
	; Colour Attributes in EAX   byte 1, byte 3
	__draw32:
		and		eax, 0xff00_ff00		; Filter to mask byte 0, 2
		xor		ebx, ebx
		mov		bx, word [ds:esi]
		add		esi, 2
		shl		ebx, 8
		mov		bl, bh
		and		ebx, 0x00ff_00ff		; Filter to mask byte 1, 3
		or		eax, ebx				; Generate screen buffer information. count = 2
		mov		dword [es:edi], eax
		add		edi, 4
		loop	__draw32

		; Deal to back to 16-bit environment.
		jmp		Code16_Selector:0

_bit32_string:
	db   'CPU Now in Protected-Mode, Now I Wanna Back to RM...'

; End of [bits 32]
code_segment_end:
Code_segment32_len		equ			code_segment_end - ___32_bit_entry

;	Jump Into here from section .code_32.
;
[section  .16_bit_back]
[bits 16]
returning_to_16_mode:
	; Change the Machine code.
	mov		ax, 0
	mov		ds, ax

	mov		eax, cr0
	and		eax, 0xfffffffe
	mov		cr0, eax

	___Go_back_to_Real:
	jmp		0:_16_draw_and_exit