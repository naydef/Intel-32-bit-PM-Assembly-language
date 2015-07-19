;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
;
;	File   name: _RM_clean_screen.asm
;;	Description:  (call far ...)
;			clean the screen by calling BIOS int 0x10 #6
;
;	Last update:  09:25, Jul 19, 2015   By Mighten Dai.
;
;
; First of all, I will clear the screen by using BIOS INT #0x10
_RM_clean_screen:
push	ax
push	bx
push	cx
push	dx

mov     ax, 0600h				; AH = Function ID = 06, Upward the screen (BIOS INT 10h #06h Definition)
								; AL = 0, clear the screen.
mov		bx, 0700h				; BH = Gray on Black screen
mov		cx, 0000h				; Location: at the begin of the screen.
mov		dx, 184fh				; Location: Line = 18h, Column = 4fh
int		10h

pop		dx
pop		cx
pop		bx
pop		ax
ret