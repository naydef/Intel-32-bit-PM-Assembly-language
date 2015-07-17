; 	_32_show_string.asm
;	32-bit "show_string" routine  -- NASM-syntax
;
; Description:
;        Useful while displaying some essential info on screen
;
; Signed-off-by: Mighten Dai <mighten.dai@gmail.com>
;				22:29
;				July 16, 2015

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;		_32_show_string  : Display ASCII string on screen
;	Parameter:
;		DS:ESI:   *src  ;  DS is selector ID
;		ES:EDI:   *des  ;  ES is also Selector ID
;		[AH]:   Color Attributes
;	          ------------------------------------------------------------
;			 | Bit7 | Bit6 | Bit5 | Bit4 |   Bit3 | Bit2  | Bit1 | Bit0 £ü
;			 | flash|   R      G      B  |  High  |    R     G     B    |
;			 |      |  Background Color  | light  |     Front  Color    |
;	           ----------------------------------------------------------

;	Return:  EAX = String with color in AL have drawn.
[bits 32]
_32_show_string:
	push	ecx
	xor		ecx, ecx

	_@loop:
		mov		al, [esi]
		cmp		al, 0
		jz		_@loop_end
		mov		es:[edi], ax
		inc		esi
		inc		edi
		inc		edi
		inc		ecx
		
		jmp	short _@loop

	_@loop_end:
	mov		eax, ecx
	pop		ecx
	ret