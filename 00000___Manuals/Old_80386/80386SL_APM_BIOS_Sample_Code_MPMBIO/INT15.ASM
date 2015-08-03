
;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

;    INTEL CORPORATION  MAKES  NO WARRANTY  FOR THE  USE OF THIS

;    EXAMPLE  AND  ASSUMES  NO  RESPONSIBILITY  FOR  ANY  ERRORS

;    WHICH  MAY  APPEAR  IN  THIS  EXAMPLE  PROGRAM   NOR  DOES

;    IT MAKE  A  COMMITMENT  TO  UPDATE  THE  INFORMATION  THAT

;    ARE  CONTAINED  HEREIN.

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *


;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

;      < < < < < <  I M P O R T A N T    N O T I C E  > > > > > >      *

;THIS MODULE IS DESIGNED TO SERVE AS AN EXAMPLE FOR BIOS PROGRAMMERS   *

;WHO PROGRAM 386 SL BASED AT SYSTEM. IT MUST BE CONSIDERED AS AN       *

;EXAMPLE AND A PROGRAMMING IMPLEMENTATION RATHER THAN A LINE BY LINE   *

;CODE THAT HAS BEEN MAXIMISED FOR PROGRAMMING EFFICIENCY. THE PROGRAM  *

;HAS BEEN WRITTEN FOR CLARITY RATHER THAN PROGRAMMING ELEGANCE.        *

;THIS MODULE WAS DEVELOPED TO SERVE 386 SL PRODUCT INTRO , DEMO        *

;AND ENGINEERING NEEDS OF INTEL CORP. OF SANTA CLARA, CA.              *

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

;UPDATE INFORMATION FOLLOWS..

;PRESENT UPDATE : AUG 16 , 1991.

;This program is not a MSDOS executable file. This source file ultimately
;becomes a binary file which will be located by ROM LOADER onto 0E000:2000h.
;So it gains control whenever INT 15 occurs..
;It checks the passed on parameters for APM functions and provides support
;for Intel-Microsoft APM 0.9 calls..For non APM functions it
;hands-over the control back to the standard INT 15 handler..

;    PLEASE SEE LOADING INDTRUCTIONS IN LOADAPM.ASM file...

;TO WRITE AND CHANGE SL SUPER SET REGISTERS , WE EXTENSIVELY MAKE USE OF
;MACROS  PRESENT IN PWRMN.MAC FILE.

;Include files REG_EQU.INC and PWRMN.MAC  before assembling.
;(c) Copyright 1990,1991 Intel Corp. 2625 Walsh Ave,Santa Clara, CA 95051.

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;UPDATE INFORMATION FOLLOWS..

;First Update   : Aug 26, 1991.

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

;    INTEL CORPORATION  MAKES  NO WARRANTY  FOR THE  USE OF THIS

;    EXAMPLE  AND  ASSUMES  NO  RESPONSIBILITY  FOR  ANY  ERRORS

;    WHICH  MAY  APPEAR  IN  THIS  EXAMPLE  PROGRAM   NOR  DOES

;    IT MAKE  A  COMMITMENT  TO  UPDATE  THE  INFORMATION  THAT

;    ARE  CONTAINED  HEREIN.

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

;      < < < < < <  I M P O R T A N T    N O T I C E  > > > > > >      *

;THIS MODULE IS DESIGNED TO SERVE AS AN EXAMPLE FOR BIOS PROGRAMMERS   *
;WHO PROGRAM 386 SL BASED AT SYSTEM. IT MUST BE CONSIDERED AS AN       *
;EXAMPLE AND A PROGRAMMING IMPLEMENTATION RATHER THAN A LINE BY LINE   *
;CODE THAT HAS BEEN MAXIMISED FOR PROGRAMMING EFFICIENCY. THE PROGRAM  *
;HAS BEEN WRITTEN FOR CLARITY RATHER THAN PROGRAMMING ELEGANCE.        *

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;Intel Corp. 2625 Walsh Ave,Santa Clara, CA 95051.
;This is a BIOS ENGINEERING GROUP product.
;------------------------------------------------------------
; Assembler Directives  Follow.
            .386C                       ; ENABLE 386 INSTRUCTION GENERATION.
             PAGE       22,80           ; THAT IS FOR MY TERMINAL.
             INCLUDE    REG_EQU.INC     ; EQUATES LIBRARY FOR PM.
             INCLUDE    PWRMN.MAC       ; MACRO LIBRARY FOR PM.
;-------------------------------------------------------------
;EQUATES  FOLLOW.THESE ARE LOCAL EQUATES NOT PRESENT IN OUR HOLY BOOK
;EQUATES...

;-------------------------------------------------------------
CODE    SEGMENT         PARA   USE16

ASSUME CS:CODE,DS:CODE,ES:CODE,SS:CODE

int15		proc	far	

                ORG     2000H
START:

;The control falls here if the AH value is 53h which is designated as
;the INTEL - MICROSOFT APM extended BIOS service code. The routines
;here use a common data byte ( Which I intend to call APM_STATUS byte )
;That is located in Xcmos RAM.

;NOTE : This byte has been chosen by this programmer..OEMs finding
;difficulty with this location may allocate a different Xcmos RAM location.

;APM_STATUS byte is BIT coded as follows..

;	     ----------------------------- A connect call has been made (80h).
;	    |	 _________________________ A 16 bit connection is done  (40h). 
;	    |	|    _____________________ A 32 bit connection is done  (20h).
;	    |	|   |	 _________________ An SL-SMM connection	is done (10h).
;          _____________|_________________
;         | 7 | 6 | 5 | 4 | 3 | 2 | 1 | 0 |
;         |___|___|___|___|___|___|___|___|
;			    |	|   |	|
;			    |	|   |	|_ APM is supported (01h).
;			    |	|   |_____ PM has been enabled (02h).
;			    |	|_________ A 16 bit i/f is supported (04h).
;			    |_____________ A 32 bit i/f is supported (08h).
;
;--------------------------------------------------------------------------
;Note : This module assumes that you have implemented a small HOOK onto
;       standard BIOS INT15 driver..(It is also called casette driver
;       for historical reasons..). The standard INT15 driver supports
;       usually what are called BIOS EXTENSION SERVICES. Infact APM
;       is one of them. 

;       So you have to modify the INT15 driver of a standard BIOS 
;       to transfer the control to this code if it detects AH=53h
;       which is designated as APM FUNCTION CODE.

;---------------------------------------------------------------------------

Process_apm :
		cmp	al,Installation_Check
		jz	Installation_process
next_fn :
		cmp	al,Interface_16bit_connect
		jz	connect_16bit
next_fn1 :
		cmp	al,Interface_32bit_connect
		jz	connect_32bit

;If control comes here then it is an ordinary APM function..
;Also it is a normal INT 15 call ..not a 16 bit or 32 bit protected
;mode call..since these take the control to a different point..

;Standard INT 15 call processing...Note that this processing is very
;similar to 16 bit call processing BUT THE MAIN DIFFERENCE IS IN
;THE WAY OF RETURNING...YOU HAVE TO THROW AWAY FLAGS..THIS IS ACTUALLY
;A MODIFIED IRET INSTRUCTION. But in 16 bit protected mode call it
;is a standard FAR RETURN...

		push	edx
		push	esi
		push	ax
		mov	esi,eax
		and	esi,0ffff0000h
	read_xmos     XcmosInfoStart+31		;read  Port address LOW
		mov	dl,al
	read_xmos     XcmosInfoStart+30		;read  Port address High
		mov	dh,al
		pop	ax
		push	ax
		shl	eax,16d			;For A-STEP only..
		pop	ax
;Now we perform a read to invoke System Management Software..
		clc				;Not guilty until proven
		in	al,dx
		nop
		pushf				;Preserve Flags..
		and	eax,0000ffffh
		or	eax,esi
		popf
		pop	esi
		pop	edx
		retf	2		;Throw away flags..
;----------------------------------------------------------------
Installation_process :

;Install_apm_check procedure follows..

;This call is available only in Real Mode Int 15.

;This checks for APM version that is installed on the system..
;i/p = AH = 53h,AL= 00h,BX = 0000h - System BIOS.
;o/p = CY = 0 if function is successful and
;O/P -- AH = Major version number, AL = Minor version number
;O/P -- BH = ASCII "P" character,BL = ASCII "M" character.
;O/P -- CX = Flags.. Bit 0 = 1 if 16 bit protected mode i/f is supported.
;O/P -- CX = Flags.. Bit 1 = 1 if 32 bit protected mode i/f is supported.
;O/P -- CX = Flags.. Bit 2 = 1 if CPU_IDLE slows CPU clocks..
;O/P -- CX = Flags.. Bit 3 = 1 if BIOS PM is disabled..
;If CY = 1 then AH will have the standard APM error codes..
;------------------------------------------------------------------
		cmp	bx,BIOS_DEVICE
		jz	ok2
not_ok2 :
		mov	ax,Unknown_device
		stc
		jmp	end_int15_process

ok2 :
		read_xmos     XcmosInfoStart+23		;APM_STATUS byte..

		test	al,APM_SUPPORT_BIT
		jnz	make_bx
		mov	ax,invalid_call
		stc
		jmp	end_int15_process

make_bx :
		mov	bx,"PM"

make_cx :
		read_xmos	XcmosInfoStart+24d
		xor	ah,ah
		xor	cx,cx
		xchg	ax,cx		;Flags in CX.

		push	cx		;Save cx..

make_ax :
		read_xmos	XcmosInfoStart+25d

		mov	ah,al
		and	al,0fh		;Minor version number.
		mov	cx,4
		shr	ah,cl
		and	ah,0fh
		clc

		pop	cx		;Get cx back..
end_int15_process :

		retf	2		;Throw away flags..
;---------------------------------------------
connect_16bit :

;We get control here if the OS requests Protected Mode 16 bit connect..
;The APM spec assures that we do get to use a modest amount of stack
;but please remember that we are not allowed to switch stacks since the
;caller can be in protected mode..

		cmp	bx,BIOS_DEVICE
		jnz	WrongDevice
ok_device1 :
		read_xmos     XcmosInfoStart+23		;APM_STATUS byte..
		test	al,04h
		jz	no_support_16bit
ok_next_chk1 :
		test	al,call16bit_done_bit
		jnz	already_16bit_connected
modify_stat :
		or	al,call16bit_done_bit
		or	al,connect_call_made
 		mov	bl,al
		write_xmos	XcmosInfoStart+23,<bl>

;Note : The file APMI.SYS uses an internal variable which shall be
;updated...Since it is a different data structure , we will update
;that variable by issuing a connect call thro' SL interface..

		push	dx
	read_xmos     XcmosInfoStart+31		;read  Port address LOW
		mov	dl,al
	read_xmos     XcmosInfoStart+30		;read  Port address High
		mov	dh,al
		mov	ah,APM_FN
		mov	al,Interface_Connect
		push	ax
		shl	eax,16d
		pop	ax
		xor	bx,bx
		clc
		in	al,dx			;Invoke SM SOFTWARE..
		nop
		pop	dx

make_cx_16bit :
;Please note that we have to tell the protected mode driver the data
;segment we are going to use so that it can release write permissions
;on it. IN 386SL THIS STUFF IS PRETTY SIMPLE. SINCE POWER MANAGEMENT
;OPERATES IN A SPECIAL MODE CALLED " SMM " , IT IS OK TO PASS ON
;CODE SEGMENT = DATA SEGMENT IN A 386SL.


		mov	cx,cs			;code seg = Data seg.		
make_bx_16bit :
		mov	bx,offset call_16bit
make_ax_16bit :
		mov	ax,cs			;code seg.						
		clc
		retf	2
already_16bit_connected :
		mov	ah,done_16bit
		stc
		retf	2

no_support_16bit :
		mov	ah,no_16bit_support
		stc
		retf	2	

WrongDevice :
		mov	ax,Unknown_device
		stc
		retf	2
;------------------------------------------------------------------------
;16 bit protected mode call is supported here. Any 16 bit protected mode
;call will land the control here..Please note that , it is very easy in
;an SL system to support this call since our system management mode
;is highly transparent.. Also note that , by the definition of APM
;we are supplied with modest amount of stack...
;------------------------------------------------------------------------
call_16bit :
		push	edx
		push	esi
		push	ax
		mov	esi,eax
		and	esi,0ffff0000h
	read_xmos     XcmosInfoStart+31		;read  Port address LOW
		mov	dl,al
	read_xmos     XcmosInfoStart+30		;read  Port address High
		mov	dh,al
		pop	ax
		push	ax
		shl	eax,16d
		pop	ax
;Now we perform a read to invoke System Management Software..
		clc
		in	al,dx
		nop
		pushf

		and	eax,0000ffffh
		or	eax,esi

		popf

		pop	esi
		pop	edx
		retf				;no flags here..Note..
;------------------------------------------------------------------------			
connect_32bit :

;We get control here if the OS requests Protected Mode 32 bit connect..
;The APM spec assures that we do get to use a modest amount of stack
;but please remember that we are not allowed to switch stacks since the
;caller can be in protected mode..This call is invoked in real mode 
;with an interrupt 15 call..

		cmp	bx,BIOS_DEVICE
		jnz	WrongDevice_32bit
ok_device1_32bit :
		read_xmos     XcmosInfoStart+23		;APM_STATUS byte..
		test	al,08h
		jz	no_support_32bit
ok_next_chk1_32 :
		test	al,call32bit_done_bit
		jnz	already_32bit_connected
modify_stat_32 :
		or	al,call32bit_done_bit
		or	al,connect_call_made
		mov	bl,al
		write_xmos	XcmosInfoStart+23,<bl>

;Note : The file APMI.SYS uses an internal variable which shall be
;updated...Since it is a different data structure , we will update
;that variable by issuing a connect call thro' SL interface..
;Note : We must allow a 32 bit connect call even if a 16 bit connect call
;has already been made. So we need to check that..else SM SW gives
;an error code already connected..

		push	dx
	read_xmos     XcmosInfoStart+31		;read  Port address LOW
		mov	dl,al
	read_xmos     XcmosInfoStart+30		;read  Port address High
		mov	dh,al
		mov	ah,APM_FN
		mov	al,Interface_Connect
		push	ax
		shl	eax,16d
		pop	ax
		xor	bx,bx
		clc
		in	al,dx			;Invoke SM SOFTWARE..
		nop
		pop	dx

make_cx_32bit :
		mov	cx,cs			;code seg = Data seg.		

make_bx_32bit :
		mov	bx,offset call_32bit
		and	ebx,0000ffffh
make_ax_32bit :
		mov	ax,cs			;code seg.						
		and	eax,0000ffffh
make_dx_32bit :
		mov	dx,cs
		clc
		retf	2
already_32bit_connected :
		mov	ah,done_32bit
		stc
		retf	2

no_support_32bit :
		mov	ah,no_32bit_support
		stc
		retf	2	

WrongDevice_32bit :
		mov	ax,Unknown_device
		stc
		retf	2
;------------------------------------------------------------------------
;32 bit protected mode call is supported here. Any 32 bit protected mode
;call will land the control here..Please note that , it is very easy in
;an SL system to support this call since our system management mode
;is highly transparent.. Also note that , by the definition of APM
;we are supplied with modest amount of stack...

;Note : This full routine will have to be coded using DB directive
;       since it is a code operating in 32 bit mode...

;Attention fellow programmers..! All this because of OPERAND OVERRIDE
;byte of 386 architecture...Forgot about it..? So soon ??? Read about
;it in Intel 386SX programmers ref. manual...

;------------------------------------------------------------------------
call_32bit :
		db	52h		;push	edx  in 32 bit mode.
		db	56h		;push	esi  in 32 bit mode.
		db	66h,50h		;push	ax   in 32 bit mode.
		db	8bh,0f0h	;mov	esi,eax	in 32 bit mode.
		db	81h,0e6h	;and    esi,0ffff0000h
		dw	0000h,0ffffh
	read_xmos     XcmosInfoStart+31,0b0h	;Setup Port address LOW
		mov	dl,al
	read_xmos     XcmosInfoStart+30,000h	;Set Port address High
		mov	dh,al
		db	66h,58h		;pop	ax in 32 bit mode.
		db	66h,50h		;push	ax in 32 bit mode.
		db	0c1h,0e0h,10h	;shl	eax,16d in 32 bit mode.
		db	66h,58h		;pop	ax in 32 bit mode.
;Now we perform a read to invoke System Management Software..
		clc
		in	al,dx
		nop

		pushf

		db	25h		;and	eax,0000ffffh in 32 bit mode.
		dw	0h,0ffffh
		db	0bh,0c6h	;or	eax,esi in 32 bit mode.

		popf

		db	5eh		;pop	esi in 32 bit mode.
		db	5ah		;pop	edx in 32 bit mode.
		retf				;no flags here..Note..
;------------------------------------------------------------------------			

int15		endp
;--------------------------------------------------------
CODE            ENDS
END     START
