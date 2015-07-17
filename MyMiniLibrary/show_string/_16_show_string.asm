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
;			 | Bit7 | Bit6 | Bit5 | Bit4 |   Bit3 | Bit2  | Bit1 | Bit0 £ü
;			 | flash|   R      G      B  |  High  |    R     G     B    |
;			 |      |  Background Color  | light  |     Front  Color    |
;	           ----------------------------------------------------------
;         [CX] Length of the string.
;         [DH] Row ID [0,24]
;         [DL] Column ID [0,79]
;		 ES:BP --> &string[0];
[bits 16]
_16_show_string:
	mov		ax, 0x1301 ; int 0x10 #13, char only, cursor moving
	mov		bh, 0x00	; Page ID = 0
	int		0x10
	ret		;; Return
