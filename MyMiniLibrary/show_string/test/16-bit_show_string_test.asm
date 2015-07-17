;
;			16-bit_show_string_test
;			Show "Hello, welcome!!!!!!" on screen.
;
;			Mighten Dai, 18:49, July 17, 2015
;
assume cs:code, ss:stack

;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
data			segment
	string_begin db 'Hello, welcome!!!!!!'
	string_end	db 0
data			ends

;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
stack			segment
	dw	100	dup( 0 )
stack			ends

;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
code			segment

start:
	mov		ax, stack
	mov		ss, ax
	mov		sp, 200
	mov		ax, data
	mov		ds, ax

	mov		ax, data
	mov		es, ax
	mov		bp, 0  ; ES:BP = string
	
	mov		cx, offset string_end
	sub		cx, offset string_begin ; Length
	mov		bl, 70h
	mov		dx, 0505h
	call 	_show
	
	mov		ax, 4c00h
	int		21h

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;   _16_show_string:  // By using BIOS int 0x10 #0x13
;		Display string and moving cursor.
;	Parameter: <By Register>
;         [BL] is following...
;	          ------------------------------------------------------------
;			 | Bit7 | Bit6 | Bit5 | Bit4 |   Bit3 | Bit2  | Bit1 | Bit0 ｜
;			 | flash|   R      G      B  |  High  |    R     G     B    |
;			 |      |  Background Color  | light  |     Front  Color    |
;	           ----------------------------------------------------------
;         [CX] Length of the string.
;         [DH] Row ID [0,24]
;         [DL] Column ID [0,79]
;		 ES:BP --> &string[0];
_show:
	mov		ax, 1301h 	; int 0x10 #13, char only, cursor moving
	mov		bh, 0000h	; Page ID = 0
	int		10h
	ret		;; Return
		
code		ends
;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

end			start