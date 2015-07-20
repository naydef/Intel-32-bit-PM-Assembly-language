;
;			Test in Real Mode.
;
;			Mighten Dai, 18:23, July 20, 2015
;
assume cs:code, ss:stack

;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
data			segment
	Message_Head db  'Hello MASM 5.00 ! '
	Message_Tail db  0
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
	mov		bp, 0
	mov		cx, offset Message_Tail - offset Message_Head
	mov		ax, 1301h ; int 0x10 #13, char only, with cursor moving
	mov		bx, 000Ch	; Page ID = 0
	mov		dx, 0304h
	int		10h
	
	mov		ax, 4c00h
	int		21h		
code		ends
;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

end			start