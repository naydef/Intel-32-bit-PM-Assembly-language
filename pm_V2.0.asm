; 	pm.asm
; 	    Protected-Mode Tutorial.
;
; 	Mighten Dai, Feb 27, 2015  17:45
;
org	0x7c00
Program_Entry:
jmp		___16_bit_entry

[section .gdt]
;	GDT
GDT_Begin:		dd		0x00000000, 0x00000000		; An Empty Descriptor
Code_Segment:	dd		0x00000082, 0x00409A00		; Present  Read  Execute 32-bit Code
Screen_Buffer:	dd		0x8000FFFF, 0x0000920B		; Present  Read  Write  Data
Flat_Memory:	dd		0x0000FFFF, 0x00409200		; Present  Read  Write  Data
Code16_Back:	dd		0x0000FFFF, 0x00009A00		; Present  Read  Execute 16-bit Code
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
	; First of all, I will clear the screen bu using BIOS INT #0x10
	mov     ax, 0600h				; AH = Function ID = 06, Upward the screen (BIOS INT 10h #06h Definition)
									; AL = 0, clear the screen.
	mov		bx, 0700h				; BH = Gray on Black screen
	mov		cx, 0000h				; Location: at the begin of the screen.
	mov		dx, 184fh				; Location: Line = 18h, Column = 4fh
	int		10h

	mov		ax, cs
	mov		ds, ax
	mov		ss, ax
	mov		sp, 0100h

	mov	[___Go_back_to_Real+3], ax

	mov		eax, 0xB800
	mov		es, ax
	mov		edi, ( 0 * 81 + 0 ) * 2   ; Line 0, Column 0.
	mov		ax, 0x07
	mov		byte [es:di], 'R'
	inc		di
	inc		di
	mov		byte [es:di], 'M'
	
	; configure code-segment's base address:
	; Initializing 16-bit code segment Descriptor 
	xor		eax, eax
	mov		ax, cs
	shl		eax, 4
	add		eax, returning_to_16_mode
	mov		word [Code16_Back + 2], ax
	shr		eax, 16
	mov		byte [Code16_Back + 4], al
	mov		byte [Code16_Back + 7], ah

	; Initializing 32-bit code segment Descriptor 
	xor		eax, eax
	mov		ax, cs
	shl		eax, 4
	add		eax, ___32_bit_entry	; If not do that, the limit will be 0 to code32_length, cause fatal error!!

	mov		[Code_Segment + 2], ax	; Store bit-0 to bit-15    (Base Address)

	shr		eax, 16					; Move the High-Word of EAX to Low-Word of EAX.
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
	mov		di, ( 4 * 80 + 0 )		; Line 4.

	; Print Strings.
	mov		byte [es:di], 'R'
	inc		di
	inc		di
	mov		byte [es:di], 'M'

; Nothing to do next, CPU Halt.
__halt:
	hlt
	jmp		short __halt

;   The following 32-bit code begin execution by JMP, instead of falling through.
[section .code_32]
[bits 32]
___32_bit_entry:
	mov		eax, Buffer_Selector	; Using EAX, in order not to generate 0x66 operand reversion mark.
	mov		es, eax
	mov		edi, (1 * 80 + 0) * 2	; Line 1, Column 0.

	mov		byte [es:di], 'P'
	inc		di
	inc		di
	mov		byte [es:di], 'M'

	; Deal to back to 16-bit environment.
	jmp		Code16_Selector:0

; End of [bits 32]
code_segment_end:
Code_segment32_len		equ			code_segment_end - ___32_bit_entry

;	Jump Into here from section .code_32.
;
[section  .16_bit_back]
[bits 16]
returning_to_16_mode:
	; Now still in Protected Mode.
	; Change the Machine code.
	xor		ax, ax
	mov		ds, ax

	mov		eax, cr0
	and		eax, 0xFFFFFFFE
	mov		cr0, eax

	___Go_back_to_Real:
	jmp		0:_16_draw_and_exit
	
; Due to the compiler's special mechanism, this method is invalid, so I have to add the 0xaa55 to the MBR	
; times 510 - ( $ - $$ ) db 0xcc
; dw 0xaa55