; 	_16_show_string.asm
;	16-bit "show_string" routine  -- NASM-syntax
;
; Description:
;        Useful while displaying some essential info on screen
;
; Signed-off-by: Mighten Dai <mighten.dai@gmail.com>
;				22:29
;				July 16, 2015

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;   _16_show_string:  // By using BIOS int 0x10 #0x13
;		Display string and moving cursor.
;	Parameter: <By Register>
;         [BL] is following...
;	          ------------------------------------------------------------
;			 | Bit7 | Bit6 | Bit5 | Bit4 |   Bit3 | Bit2  | Bit1 | Bit0 |
;			 | flash|   R      G      B  |  High  |    R     G     B    |
;			 |      |  Background Color  | light  |     Front  Color    |
;	           ----------------------------------------------------------
;         [DH] Row ID [0,24]
;         [DL] Column ID [0,79]
;		 ES:BP --> &string[0];
[bits 16]
_16_show_string:
	push	ax
	push	bx
	push	cx

	xor		cx, cx      ; Count from 0
	; Get string number
	push	bp
	_@_16show_internal_count:
		mov		al, [es:bp]
		cmp		al, 0
		je		_@_16show_internal_@@exit
		inc		cx
		inc		bp
		jmp 	_@_16show_internal_count
	_@_16show_internal_@@exit:
	pop		bp

	mov		ax, 0x1301 ; int 0x10 #13, char only, with cursor moving
	mov		bh, 0x00	; Page ID = 0
	int		0x10

	pop		cx
	pop		bx
	pop		ax
	ret		;; Return
