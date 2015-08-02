;
;		handler.asm
;
;		Interrupts as well as Exceptions Handlers
;   
;  ------>Storage
;   Floppy  LBA-Address: 10-14 ( in Decimal notation )
;   Runtime Vir-Address: 0x0007_0000(Hexadecimally)
;   Runtime Phy-Address: 0x0007_0000
;
;  ------->NOTE THAT!!!
;      Interrupts and Exception Identifiers ranged
;                     from 0x00 to 0x1F, or from 0 to 31( Decimal )  
;      NO USER-DEFINED IDENTIFERS' STORAGE LOCATION AVAILABLE.
;
;   Apparently, it is not enough for further extension,
;                but it could save plenty of time to do what is in need.
;
;  -------> Updates:
;         Begin: 13:46, July 23, 2015, Mighten Dai <mighten.dai@gmail.com>
; Latest Update:
;
[bits 32]   ; 
%include "common_macro.asm"

;==========================================================
; #00,  Fault, Error Code = No, source: DIV and IDIV instructions
; Runtime Phy-Address = 0x0007_0000
;        #DE, Divide Error
handler_DE_:
	pushad
	pushf
	mov		eax, Ring0FlatData
	mov		ds, eax
	mov		es, eax
	mov		esi, handler_DE_MSG_ + phy_address_handler_base
	mov		edi, vir_address_video_buffer_head
	mov		ah, 0x07                              ; Color Attributes
	mov		edx, ( 0xA * 81 + 0x2 ) * 2               ; Line 0, Column 0.
	call	_32_show_string
	popf
	popad
	iret

handler_DE_MSG_ db '[#DE Handler]: Divide Error', 0	

times   0x320 - ($ - handler_DE_ ) db 0xCC

;==========================================================
; #01  
; Runtime Phy-Address = 0x0007_0320
;        #DB, Debug exceptions
handler_DB_:
times   0x320 - ($ - handler_DB_ ) db 0xCC

;==========================================================
; #02
; Runtime Phy-Address = 0x0007_0640
;             Nonmaskable interrupt
handler_NMI_:
times   0x320 - ($ - handler_NMI_ ) db 0xCC

;==========================================================
; #03
; Runtime Phy-Address = 0x007_0960
;       #BP, Breakpoint, or INT3 instruction
handler_BP_:
	pushad
	pushf
	mov		eax, Ring0FlatData
	mov		ds, eax
	mov		es, eax
	mov		esi, handler_BP_MSG_ + phy_address_handler_base
	mov		edi, vir_address_video_buffer_head
	mov		ah, 0x07                              ; Color Attributes
	mov		edx, ( 0xB * 81 ) * 2               ; Line 0, Column 0.
	call	_32_show_string
	popf
	popad
	iret
handler_BP_MSG_ db '[#BP Handler]: An Breakpoint disturbed the execution, but continue.', 0	
times   0x320 - ($ - handler_BP_ ) db 0xCC

;==========================================================
; #04
; Runtime Phy-Address = 0x0007_0C80
;       #OF, Overflow, also INTO instruction
handler_OF_:
times   0x320 - ($ - handler_OF_ ) db 0xCC

;==========================================================
; #05
; Runtime Phy-Address = 0x0007_0FA0
;       #BR, Bounds Range Exceeded, BOUND instruction 
handler_BR_:
times   0x320 - ($ - handler_BR_ ) db 0xCC

;==========================================================
; #06
; Runtime Phy-Address = 0x0007_12C0
;       #UD, Undefined/Invalid Opcode
handler_UD_:
	pushad
	pushf
	mov		eax, Ring0FlatData
	mov		ds, eax
	mov		es, eax
	mov		esi, handler_UD_MSG_ + phy_address_handler_base
	mov		edi, vir_address_video_buffer_head
	mov		ah, 0x07                              ; Color Attributes
	mov		edx, ( 0xC * 81 ) * 2               ; Line 0, Column 0.
	call	_32_show_string
	popf
	popad
	iret
handler_UD_MSG_ db '[#UD Handler]: Invalid Instruction.', 0	

times   0x320 - ($ - handler_UD_ ) db 0xCC

;==========================================================
; #07
; Runtime Phy-Address = 0x0007_15E0
;       #NM, Device/Coprocessor not available
handler_NM_:
times   0x320 - ($ - handler_NM_ ) db 0xCC

;==========================================================
; #08
; Runtime Phy-Address = 0x0007_1900
;       #DF, Double fault
handler_DF_:
times   0x320 - ($ - handler_DF_ ) db 0xCC

;==========================================================
; #09
; Runtime Phy-Address = 0x0007_1C20
;      ****(Reserved Officially)
times   0x320   db 0xCC

;==========================================================
; #0A
; Runtime Phy-Address = 0x0007_1F40
;       #TS, Invalid TSS
handler_TS:
times   0x320 - ($ - handler_TS ) db 0xCC

;==========================================================
; #0B
; Runtime Phy-Address = 0x0007_2260
;        #NP, Segment Not Present
handler_NP_:
times   0x320 - ($ - handler_NP_ ) db 0xCC

;==========================================================
; #0C
; Runtime Phy-Address = 0x0007_2580
;       #SS, Stack exception
handler_SS_:
times   0x320 - ($ - handler_SS_ ) db 0xCC

;==========================================================
; #0D
; Runtime Phy-Address = 0x0007_28A0
;       #GP, General protection
handler_GP:
	push	eax
	mov		eax, [esp - 0x8] ; Get Error Code
	pushad
	pushf
	mov		eax, Ring0FlatData
	mov		ds, eax
	mov		es, eax
	mov		esi, handler_GP_MSG_ + phy_address_handler_base
	mov		edi, vir_address_video_buffer_head
	mov		ah, 0x07                              ; Color Attributes
	mov		edx, ( 0xD * 81 ) * 2               ; Line 0, Column 0.
	call	_32_show_string
	popf
	popad
	pop		eax
	sub		esp, 4
;	iret
jmp		$
handler_GP_MSG_: db '[#GP Handler]: Access Violation.', 0
times   0x320 - ($ - handler_GP ) db 0xCC

;==========================================================
; #0E
; Runtime Phy-Address = 0x0007_2BC0
;       #PF, Page Fault
handler_PF_:
times   0x320 - ($ - handler_PF_ ) db 0xCC

;==========================================================
; #0F
; Runtime Phy-Address = 0x0007_2EE0
;        ****(Reserved Officially)
times   0x320   db 0xCC

;==========================================================
; #10
; Runtime Phy-Address = 0x0007_3200
;       #MF, Math Fault, Coprocessor/x87_FPU_Floating-Point Error
handler_MF:
times   0x320 - ($ - handler_MF ) db 0xCC

;==========================================================
; #11
; Runtime Phy-Address = 
;       #AC, Alignment Check
handler_AC:
times   0x320 - ($ - handler_AC ) db 0xCC

;==========================================================
; #12
; Runtime Phy-Address = 0x0007_3520
;       #MC, Machine Check
handler_MC:
times   0x320 - ($ - handler_MC ) db 0xCC

;==========================================================
; #13
; Runtime Phy-Address = 0x0007_3840
;       #XM, SIMD Floating-Point Exception
handler_XM_:
times   0x320 - ($ - handler_XM_ ) db 0xCC

;==========================================================
; #14
; Runtime Phy-Address = 0x0007_3B60
;      #VE, Virtualization Exception
handler_VE_:
times   0x320 - ($ - handler_VE_ ) db 0xCC

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
%include "..\..\MyMiniLibrary\show_string\_32_show_string.asm"