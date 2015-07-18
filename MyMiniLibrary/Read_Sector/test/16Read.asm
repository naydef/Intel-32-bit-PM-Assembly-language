;	16Read.asm   -- MASM 5.00 Testing
;		Read Logical-Block-Address(LBA) Floppy-Disk-A Sector(s) in RM to memory location.
;
;	**** Merely test the first part: Conversion
;          In the absence of Floppy A:
;           Solution: Simulation of Bochs.
;
;	***** Debugging Guidance:
;	   By using "debug.exe", Step Over "call  RMRF", and check Head:Track:Sector = AX:BX:SI 
;
;	Mighten Dai, 21:42, July 18, 2015
;
assume cs:code, ss:stack

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
	mov		ax, code
	mov		ds, ax
	
	;  Other Parameters are all not to be tested, except AX = LBA Address
	;   At debug's Output, you can see:
	;   AX:BX:SI = Head:Track:Sector
	;
	;
	mov		ax, 0       ; 0, This ought to be: Head 0, Track 0, Sector 1
	call 	RMRF
	
	mov		ax, 05A0h   ; 1,440: This ought to be: Head 1, Track 0, Sector 1
	call 	RMRF

	mov		ax, 0027h   ; 39:    This ought to be: Head 0, Track 2, Sector 4
	call 	RMRF
	
	mov		ax, 4c00h
	int		21h

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;	Routine Name: _RM_read_floppy_data2memory
;	Description:	Read Floppy disk data to Memory
;	Parameters:
;	    {AX}    = LBA address of Floppy Disk
;	    {CX}    = Sector number to read
;	    {ES:BX} = Destination Memory Location.(RM only!!!)
;	Return 
;	    <On success> AH=0, AL = Sectors has read 
;	    <On failure> AH = error ID
;
;_RM_read_floppy_data2memory:
RMRF:    ; Real-Address Mode Reads Floppy(RMRF)
	push	cx  ; !!! CX is the sector number to read.!!! 
	push	dx
	push	bp
	mov		bp, sp

	;_@_internal_RM_LBA_to_Phy:
	;  1st, convert the address to LBA
	xor		cx, cx ; First version I uses 3 push 0 (Invalid seriously)
	push	cx     ;\  Because 8086 not support(while >=80286 can)
                   ; |   push  0000h into stack. 
	push	cx     ; | Is better than: ADD SP, 0006
	push	cx     ;/     due to initialization(is important for the following),
                   ; but bigger in instruction size 
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;;;  In case of stack error, refer to:        ;;;
	;;;      Stack Memory Arrangement.            ;;;
	;;;   WORD-size-memory                        ;;;
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;;;    ----------                             ;;;
	;;;   |   @Head  |<--- SS:[BP-6] ; Variable   ;;;
	;;;    ----------                             ;;;
	;;;   |  @Track  |<--- SS:[BP-4] ; Variable   ;;;
	;;;    ----------                             ;;;
	;;;   |  @Sector |<--- SS:[BP-2] ; Variable   ;;;
	;;;    ----------                             ;;;
	;;;   |  old BP  |<--- SS:[BP]  ;new BP,so on.;;;
	;;;    ----------                             ;;;
	;;;   |    DX    |<--- SS:[BP+2]              ;;;
	;;;    ----------                             ;;;
	;;;   |    CX    |<--- SS:[BP+4] !! Parameter ;;;
	;;; -------------------------------           ;;;
	;;;   |    IP    |  <This Routine is inside   ;;;
	;;;    ----------     the same code segment > ;;;	
	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	xor		dx, dx
	;mov		ax, ax                   ; DX:AX = LBA Sector ID
	mov		cx, 05A0h            ;(0,5A0)H = (1,440)D

	div		cx                   ; 16-bit Division
	mov		ss:[bp-6], ax        ; Head ID, AX = int(LBA/1,440)

	mov		ax, dx
	mov		cx, 0012h             ;(12)H = (18)D
	div		cl                     ; 8-bit Division
	mov		ss:[bp-4], al          ; Track  ID, AL = int( rem(LBA/1,440) / 18 )
	inc		ah                    ;  AH = Sector = rem( rem(LBA/1440) / 18 ) + 1
	mov		ss:[bp-2], ah         ; Sector ID, in AH

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	;  It is very hard to debug on Win7 without Hardware Floppy Disk A:
	;;******** Stack balance ONLY for Win7 Debugging Version.
	pop		ax		;Head
	pop		bx		;Track
	pop		si		;Sector
	
	
	
	;      Later I can Make it easier to debug next part in Bochs
	;
	;    So I just want to test the first part: Conversion
	;;_@_internal_RM_read_floppy:
	;;;  2nd, uses PARAM converted from LBA to INT 0x13 #2
	;;mov		ah, 02h         ; # AH, Function ID=2, Read Disk
	;;mov		al, ss:[bp+4]    ; # AL, Number of Sectors to read!!!!!!Routine Parameter!!!	
	;;pop		dx         ; Head ID, SS:[BP-6] ==>  DX
	;;mov		dh, dl          ; # DH, Head ID
	;;mov		dl, 0000h       ; # DL, Device ID: 0, --->Floppy A:!!! Caution !!!!
    ;;
	;;pop		cx         ; Track ID, SS:[BP-4] ==> CX
	;;mov		ch, cl          ; # CH, Track ID.
	;;mov		cl, ss:[bp-2]   ; Sector ID, SS:[BP-2] ==> CL
	;;
	;;;  ES:BX remain fixed.
	;;int		13h
    ;;
	;;add		sp, 2          ; clear @Sector, Keep Stack Balance.
	

	
	;_@_internal_RM_read_floppy_over_and_back:
	pop		bp             ; Resume BP
	pop		dx             ; Resume DX
	pop		cx             ; Resume CX
	ret                    ; Resume IP
	;
	;  Return 
	;   <On success> AH=0, AL = Sectors has read 
	;   <On failure> AH = error ID		
code		ends
;:::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

end			start