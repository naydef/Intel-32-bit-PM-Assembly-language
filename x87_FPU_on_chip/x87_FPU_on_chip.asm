;
;	x87_FPU_on_chip.asm
;
;   Demonstration the Usage of the x87 FPU on chip
;
;	 Begin:  20:00, July 26, 2015, by Mighten Dai<mighten.dai@gmail.com>
;	Latest:  21:25, July 26, 2015, by Mighten Dai<mighten.dai@gmail.com>
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
;  All of the following number were calculated by MSVS2010
f_pi			dd	?
f3_250			dd	40500000h   ; floating-point number 3.250, respect to IEEE 754

fadd_result		dd	?
fsub_result		dd	?
fmul_result		dd	?
fdiv_result		dd	?

szBuffer		db   64		dup(0)

;-----------------------------------------------------------------------------------
		.code
start:
	finit

	fld		dword ptr [f3_250]
	fldpi   ; push Pi
	fadd	ST, ST(1)       ;  Perform ST(0) = Pi + 3.250
	fstp	dword ptr [fadd_result]  ; Store the value on ST(0) => 6.391593
	fstp	dword ptr [szBuffer]   ; Balance the stack

	fld		dword ptr [f3_250]
	fldpi   ; push Pi
	fsub	ST(1), ST       ;  Perform ST(1) = 3.250 - Pi
	fstp	dword ptr [szBuffer]   ; Balance the stack
	fstp	dword ptr [fsub_result]  ; Store the value on ST(1)=> 0.1084073

	fld		dword ptr [f3_250]
	fldpi   ; push Pi
	fsub	ST, ST(1) ;  Perform ST(1) = PI - 3.250
	fstp	dword ptr [fsub_result]  ; Store the value on ST(1)=> -0.1084073
	fstp	dword ptr [szBuffer]   ; Balance the stack

	fld		dword ptr [f3_250]
	fldpi   ; push Pi
	fmul	ST, ST(1)       ;  Perform ST(0) = Pi * 3.250
	fstp	dword ptr [fmul_result]  ; Store the value on ST(0) => 10.21018
	fstp	dword ptr [szBuffer]   ; Balance the stack

	fld		dword ptr [f3_250]
	fldpi   ; push Pi
	fdiv	ST(1), ST       ;  Perform ST(0) = 3.250 / Pi
	fstp	dword ptr [szBuffer]     ; Balance the stack
	fstp	dword ptr [fdiv_result]  ; Store the value on ST(0) => 1.034507

	fld		dword ptr [f3_250]
	fldpi   ; push Pi
	fdiv	ST, ST(1)   ;  Perform ST(0) = Pi / 3.250
	fstp	dword ptr [fdiv_result]  ; Store the value on ST(0) => 0.9666439
	fstp	dword ptr [szBuffer]     ; Balance the stack

	invoke  ExitProcess, 0 ; == return 0;

end	start
;
; ------> Disassembled by OllyDebug V1.10
;
; 00401001  |. DBE3           FINIT
; 00401003  |. D905 04304000  FLD DWORD PTR DS:[403004]
; 00401009  |. D9EB           FLDPI
; 0040100B  |. D8C1           FADD ST,ST(1)
; 0040100D  |. D91D 08304000  FSTP DWORD PTR DS:[403008]
; 00401013  |. D91D 18304000  FSTP DWORD PTR DS:[403018]
; 00401019  |. D905 04304000  FLD DWORD PTR DS:[403004]
; 0040101F  |. D9EB           FLDPI
; 00401021  |. DCE9           FSUB ST(1),ST
; 00401023  |. D91D 18304000  FSTP DWORD PTR DS:[403018]
; 00401029  |. D91D 0C304000  FSTP DWORD PTR DS:[40300C]
; 0040102F  |. D905 04304000  FLD DWORD PTR DS:[403004]
; 00401035  |. D9EB           FLDPI
; 00401037  |. D8E1           FSUB ST,ST(1)
; 00401039  |. D91D 0C304000  FSTP DWORD PTR DS:[40300C]
; 0040103F  |. D91D 18304000  FSTP DWORD PTR DS:[403018]
; 00401045  |. D905 04304000  FLD DWORD PTR DS:[403004]
; 0040104B  |. D9EB           FLDPI
; 0040104D  |. D8C9           FMUL ST,ST(1)
; 0040104F  |. D91D 10304000  FSTP DWORD PTR DS:[403010]
; 00401055  |. D91D 18304000  FSTP DWORD PTR DS:[403018]
; 0040105B  |. D905 04304000  FLD DWORD PTR DS:[403004]
; 00401061  |. D9EB           FLDPI
; 00401063  |. DCF9           FDIV ST(1),ST
; 00401065  |. D91D 18304000  FSTP DWORD PTR DS:[403018]
; 0040106B  |. D91D 14304000  FSTP DWORD PTR DS:[403014]
; 00401071  |. D905 04304000  FLD DWORD PTR DS:[403004]
; 00401077  |. D9EB           FLDPI
; 00401079  |. D8F1           FDIV ST,ST(1)
; 0040107B  |. D91D 14304000  FSTP DWORD PTR DS:[403014]
; 00401081  |. D91D 18304000  FSTP DWORD PTR DS:[403018]
