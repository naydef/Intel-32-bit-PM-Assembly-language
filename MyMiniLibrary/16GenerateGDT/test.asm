;
;			Test Generating GDT_Descriptor in Real Mode.
;
;			Mighten Dai, 18:26, Feb 24, 2015
;
assume cs:code, ss:stack, es:buffer

;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
data			segment
	outL	dd	0
	outH	dd	0

	Base 	dd	7c00h
	Limit	dd	1ffh
data			ends

;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
buffer			segment
	Quadword dw	0, 0, 0, 0
buffer			ends

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

	mov		bx, 1
	mov		cx, 0
	
	mov		ax, offset outH
	push	ax				; HighWordAddress_offset
	mov		ax, offset outL
	push	ax				; LowWordAddress_offset
	push	cx				; G = 0
	push	bx				; B = 1
	push	cx				; L = 0
	push	cx				; AVL = 0
	push	bx				; P = 1
	push	cx				; DPL = 0
	push	bx				; S
	push	bx				; X
	push	cx				; E C
	push	cx				; W R
	push	cx				; A
	
	lea		si, Base

	mov		ax, [si + 2]
	push	ax		; Base H
	push	[si]		; Base L
	
	lea		di, Limit
	mov		ax, [ di + 2 ]
	push	ax		; Limit H
	push	[di]		; Limit L
	
	call 	_Gene
	
	mov		ax, 4c00h
	int		21h

	_Gene:
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
		ret			22h
		
code		ends
;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

end			start