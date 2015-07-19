;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
;
;	File   name: InitGenerateGDT_16bit_NASM.asm
;;	Description:  (call far ...)
;		1> Making GDT structure.
;			The NASM-syntax Assembly Routine
;		2> If you want to use this routine,
;			copy the code or simply: %include InitGenerateGDT_16bit_NASM.asm
;	Begin  with:  18:02, Feb 23, 2015   By Mighten Dai.
;	Last update:  21:25, Feb 24, 2015   By Mighten Dai.
;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

; Function      Name: _InitGenerateGDT_16bit
;
;	Caution: 1. This program can only run in 16-bit mode, or doesn't work.
;			2. Assume DS & SS have already configured.
;			3. Assume CS & DS of [main code] and [this procedure] is in the SAME Segment.
;
; Parameters   : <By stack> ( limit, base, ... ) From left to right as following...
; Calling Convention: __stdcall
;		[IN] Limit								<  32 bits in 4 Bytes >	( Limit )
;		[IN] Base								<  20 bits in 4 Bytes >	( Base  )
;		[IN] IsSegAccessed						<  1 bit in 2 Byte  >		( A )
;		[IN] IsCodeCanRead_IsDataCanWrite			<  1 bit in 2 Byte  >		( code:R, data:W )
;		[IN] IsDataExpandDown_IsCodeConforming		<  1 bit in 2 Byte  >		( code:E, data:E )
;		[IN] IsCodeSegment						<  1 bit in 2 Byte  >		( X )
;		[IN] IsNonSystemSegment					<  1 bit in 2 Byte  >		( S )
;		[IN] DscpPrivilegeLevel					<  2 bit in 2 Byte  >		( DPL )
;		[IN] IsPresent							<  1 bit in 2 Byte  >		( P )
;		[IN] Is_AVL_Set							<  1 bit in 2 Byte  >		( AVL )
;		[IN] IsCanRun64BitCode					<  1 bit in 2 Byte  >		( L )
;		[IN] Is_D_B_Set							<  1 bit in 2 Byte  >		( D/B )
;		[IN] Is_G_Set_or_Is_4KB_unites_available	<  1 bit in 2 Byte  >		( G )
;		[OUT] pointer to base address of Low-DWORD	<  32 bits in 4 Bytes, 2 Bytes in fact >
;		[OUT] pointer to base address of High-DWORD	<  32 bits in 4 Bytes, 2 Bytes in fact  >
_InitGenerateGDT16bit:
	push		bp
	mov			bp, sp
	sub			sp, 04h      ; Locate a DWORD memory space for storing data temporarily

	pushf
	push		ax
	push		cx
	push		di

	; Low-DWORD part of Descriptor dealing directly.
	mov			ax, [ bp + 04h ]   ; Get Limit 15:00
	mov			di, [ bp + 22h ]	; Get pointer of the head of GDT_Descriptor's Low DOWRD
	mov			[ di ], ax			; Point to the Low-DWORD Low  WORD, Save Limit 15:00
	mov			ax, [ bp + 08h ]   ; Get Base 15:00
	add			di, 02h				; Point to the Low-DWORD High WORD
	mov			[ di ], ax			; Save Base 15:00

	; High-DWORD part of Descriptor dealing, by using buffered variable in stack.
	mov			di,	[ bp + 24h ]	; Get pointer of the head of GDT_Descriptor's High-DOWRD Low WORD
	mov			ax,	[ bp + 0Ah ]	; Get Base 31:16, (al) Base23:16,  (ah)Base31:24
	mov			[ di + 3h ], ah		; Base 31:24
	mov			[ di ], al			; Base 23:16

	xor			cl, cl
	mov			al, [ bp + 1Ah ]	; AVL
	and			al, 1
	mov			ah, al
	
	inc			cl
	mov			al, [ bp + 1Ch ]	; L
	and			al, 1
	shl			al, cl
	or			ah, al

	inc			cl
	mov			al, [ bp + 1Eh ]	; D/B
	and			al, 1
	shl			al, cl
	or			ah, al

	inc			cl
	mov			al, [ bp + 20h ]	; G
	and			al, 1
	shl			al, cl
	or			ah, al

	inc			cl
	shl			ah, cl

	mov			al, [ bp + 06h ] ; Limit 19:16
	and			al, 0Fh	; 1111B
	or			ah, al
	mov			[ di + 2h ], ah

	mov			cl, 7
	mov			al, [ bp + 18h ]	; P
	and			al, 1
	shl			al, cl
	mov			ah, al

	dec			cl
	dec			cl
	mov			al, [ bp + 16h ]	; DPL
	and			al, 03h
	shl			al, cl
	or			ah, al

	dec			cl
	mov			al, [ bp + 14h ]	; S
	and			al, 1
	shl			al, cl
	or			ah, al

	dec			cl
	mov			al, [ bp + 12h ]	; X
	and			al, 1
	shl			al, cl
	or			ah, al
	
	dec			cl
	mov			al, [ bp + 10h ]	; data:E, code:C
	and			al, 1
	shl			al, cl
	or			ah, al

	dec			cl
	mov			al, [ bp + 0Eh ]	; data:W, code:R
	and			al, 1
	shl			al, cl
	or			ah, al

	dec			cl
	mov			al, [ bp + 0Ch ]	; A
	and			al, 1
	shl			al, cl
	or			ah, al

	mov			[ di + 1 ], ah

	pop			di
	pop			cx
	pop			ax
	popf

	mov			sp, bp
	pop			bp
	retf		22h
