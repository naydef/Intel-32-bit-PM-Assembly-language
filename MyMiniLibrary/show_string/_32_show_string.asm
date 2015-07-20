; 	_32_show_string.asm
;	32-bit "show_string" routine  -- NASM-syntax
;
; Description:
;        Useful while displaying some essential info on screen
;
; Signed-off-by: Mighten Dai <mighten.dai@gmail.com>
;				22:29
;				July 16, 2015
;
; Latest Update: 18:17, July 19, 2015
;
;
;    ******** During programming, this module proves ineffective when print the screen on a specific location on screen.
;             Need REPAIRING !!!!! 
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;		_32_show_string  : Display ASCII string on screen
;	Parameter:       DS ES Selector
;		DS:ESI:   *source        ;  DS is selector ID
;		ES:EDI    *dest_head     ; the head of the Buffer.
;		[AH]:   Color Attributes
;         [DH] Row/Line ID [0,24]
;         [DL] Column ID [0,79]
;	            -----------------------------------------------------------
;			 | Bit7 | Bit6 | Bit5 | Bit4 |   Bit3 | Bit2  | Bit1 | Bit0 |
;			 | flash|   R      G      B  |  High  |    R     G     B    |
;			 |      |  Background Color  | light  |     Front  Color    |
;	           ------------------------------------------------------------
;	Return:  EAX = String with color in AH have drawn.
_32_show_string:
push		ecx
push		eax
push		ebx
xor		eax, eax

mov		al,  0x50  ; 80 in decimal
mul		dh         ; AX = DH * 80
movzx		bx, dl
add		ax, bx
and		eax, 0x0000_FFFF
mov		cl, 2
mul		cl         ; AX = (DH * 80 + DL) * 2
add		edi, eax   ; Point to a specific address.

pop		ebx
pop		eax

xor		ecx, ecx
_@_internal_loop:
	mov		al, [esi]
	cmp		al, 0
	je		_@_internal_loop_end ;_@_internal_loop_end:
	mov		[es:edi], ax
	inc		esi
	inc		edi
	inc		edi
	inc		ecx

	jmp	short _@_internal_loop

_@_internal_loop_end:
mov		eax, ecx
pop		ecx
ret
