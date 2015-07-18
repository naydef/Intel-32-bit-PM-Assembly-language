;	_RM_read_floppy_data2memory.asm
;
;	Read Logical-Block-Address(LBA) Floppy-Disk-A Sector(s) in RM to memory location.
;
;		18:44, July 18, 2015
;		Signed-off-by: Mighten Dai<mighten.dai@gmail.com>
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;         !!! Caution !!!
;    This routine can ONLY be used in Bootstrap(of RM),
;	DO NOT USE in Protected Mode(PM), or results in #GP
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;  Note:
;    For Floppy Disk A:
; 	  LBA = ( Head * 80 + Track ) * 18 + Sector - 1
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;	---->Algorithm:
;	   LBA Sector => Physical Sector
;	# Physical Address: (Head/Track/Sector)
;	# 		  int() get quotient, while  rem() get remainder.
;	# Head   = int( LBA / 1440 )
;	# Track  = int( rem(LBA/1440) / 18 )
;	# Sector = rem( rem(LBA/1440) / 18 ) + 1
;
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
_RM_read_floppy_data2memory:
	push	cx  ; !!! CX is the sector number to read.!!! 
	push	dx
	push	bp
	mov		bp, sp

	_@_internal_RM_LBA_to_Phy:
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
	mov		[bp-6], ax        ; Head ID, AX = int(LBA/1,440)

	mov		ax, dx
	mov		cx, 0012h             ;(12)H = (18)D
	div		cl                     ; 8-bit Division
	mov		[bp-4], al          ; Track  ID, AL = int( rem(LBA/1,440) / 18 )
	inc		ah                    ;  AH = Sector = rem( rem(LBA/1440) / 18 ) + 1
	mov		[bp-2], ah         ; Sector ID, in AH

	_@_internal_RM_read_floppy:
	;  2nd, uses PARAM converted from LBA to INT 0x13 #2
	mov		ah, 02h         ; # AH, Function ID=2, Read Disk
	mov		al, [bp+4]      ; # AL, Number of Sectors to read!!!!!!Routine Parameter!!!	
	pop		dx         ; Head ID, SS:[BP-6] ==>  DX
	mov		dh, dl          ; # DH, Head ID
	mov		dl, 0000h       ; # DL, Device ID: 0, --->Floppy A:!!! Caution !!!!

	pop		cx         ; Track ID, SS:[BP-4] ==> CX
	mov		ch, cl          ; # CH, Track ID.
	mov		cl, [bp-2]      ; Sector ID, SS:[BP-2] ==> CL
	
	;  ES:BX remain fixed.
	int		13h

	add		sp, 2          ; clear @Sector, Keep Stack Balance.
	
	_@_internal_RM_read_floppy_over_and_back:
	pop		bp             ; Resume BP
	pop		dx             ; Resume DX
	pop		cx             ; Resume CX
	ret                    ; Resume IP
	;
	;  Return 
	;   <On success> AH=0, AL = Sectors has read 
	;   <On failure> AH = error ID