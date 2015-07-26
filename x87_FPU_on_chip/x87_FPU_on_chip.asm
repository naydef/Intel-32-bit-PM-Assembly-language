;
;	x87_FPU_on_chip.asm
;
;   Demonstration the Usage of the x87 FPU on chip
;
;	 Begin:  15:43, July 26, 2015, by Mighten Dai<mighten.dai@gmail.com>
;	Latest:  19:59, July 26, 2015, by Mighten Dai<mighten.dai@gmail.com>
;
;	********The required the following support(s):
;      1> Win32-API  support
;      2> MASM32v11 compiling-environment
;==================================================================================
		.386p
		.model flat, stdcall
		option casemap :none

;-----------------------------------------------------------------------------------
include			windows.inc
include			user32.inc
includelib		user32.lib
include			kernel32.inc
includelib		kernel32.lib

;-----------------------------------------------------------------------------------
		.data
szBuffer		dd   0
szText			db   100	dup(0)
szCaption		db	"Demo: x87 FPU on chip", 0
szFormat		db	"Pi = 0x%X in Floating-point Number", 0dh, 0

;-----------------------------------------------------------------------------------
		.code
start:
	finit
	fldpi   ; push the PI's value into FPU-register Stack
	lea		eax, szBuffer
	fstp	dword ptr [eax]
	mov		ecx, [eax]

	; the prototype for wsprintfA
	;      int wsprintfA(  LPTSTR lpOut, LPCTSTR lpFmt, ... );
	push		ecx    ; The argument, only one
	push		offset szFormat	; LPCTSTR lpFmt
	push		offset szText	; LPTSTR lpOut
	call		wsprintfA
	add			esp, 000Ch    ; __cdecl Calling convention requires calling function clean the stack.

	;  Now display the target on screen by using MessageBox.
	; Prototype for MessageBox
	;    int MessageBox(  HWND hWnd, LPCTSTR lpText, LPCTSTR lpCaption, UINT uType );
	push	MB_OK
	push	offset szCaption
	push	offset szText
	push	NULL
	call	MessageBox        ; MessageBox shows that Pi = 0100 0000 0100 1001 0000 1111 1101 1011
                              ; Refer to as IEEE 754 Standard for Binary coded Floating-point
							  ; is  0_10000000_10010010000111111011011

	invoke  ExitProcess, 0 ; == return 0;

end	start	