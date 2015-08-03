
;THIS FILE IS UPDATED VERSION OF THE PREVIOUS POWER MANAGEMENT SOFTWARE
;THAT WAS PUT TOGETHER IN May 05 , 1991.
;FOLLOWING ARE THE CHANGES FROM THE PREVIOUS UPDATE...

;1. APM Initialization ( Intel Microsoft spec 0.9 ) support is added.

;2. The loader is capable of loading the file to BIOS area ( Shadow Memory )
;   and uses a standard AT technique to init the PM. Please refer to
;   the actual routine to study the technique.

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

;THIS PROGRAM IS A DOS EXECUTABLE FILE. IT SEARCHES THE CURRENT DIRECTORY
;AND IF IT FINDS A FILE BY NAME PMI.SYS (WHICH IS OUR POWER MANAGEMENT
;SOFTWARE MODULE) IT LOADS IT TO THE INTERNAL SM RAM ( D000:0 IS CHOSEN
;IN THIS EXAMPLE) AND THEN IT ENABLES THE POWER MANAGEMENT OF 386 SL
;SUPER SET. IT ALSO HAS AN INITIALISATION SEGMENT WHICH PROGRAMS THE
;82360SL POWER MANAGEMENT REGISTERS TO DESIRED INITIAL VALUES.
;IT THEN RETURNS CONTROL TO MS-DOS.

;If you specify  a switch onto the command line then the loader will
;allow you to load the PM module to EXTENSION SYSTEM EPROM area
;0E000h ( The shadow RAM at this area..) , then it will reboot the
;machine. During this reboot the shadow is enabled and hence the
;loader at the EPROM location 0E000h will gain control and so will
;allow you to  have your power management configured at boot time.
;This is necessary for APM POWER MANAGEMENT drivers to get access of
;power management when they get installed from CONFIG.SYS.

;Valid switches are /b and /h

;TO WRITE AND CHANGE SL SUPER SET REGISTERS , WE EXTENSIVELY MAKE USE OF
;MACROS  PRESENT IN PWRMN.MAC FILE.

;Include files REG_EQU.INC and PWRMN.MAC  before assembling.
;(c) Copyright 1990,1991 Intel Corp. 2625 Walsh Ave,Santa Clara, CA 95051.

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;UPDATE INFORMATION FOLLOWS..

;First Update   : Dec 26, 1990.
;Last Update    : May 05, 1991.
;Present Update : Sep 01, 1991.

;Intel Corp. 2625 Walsh Ave,Santa Clara, CA 95051.
;This is a SMD1 APPS product.
;------------------------------------------------------------
; Assembler Directives  Follow.
            .386C                       ; ENABLE 386 INSTRUCTION GENERATION.
             PAGE       22,80           ; THAT IS FOR MY TERMINAL.
             INCLUDE    REG_EQU.INC     ; EQUATES LIBRARY FOR PM.
             INCLUDE    PWRMN.MAC       ; MACRO LIBRARY FOR PM.
;-------------------------------------------------------------
;EQUATES  FOLLOW.THESE ARE LOCAL EQUATES NOT PRESENT IN OUR HOLY BOOK
;EQUATES...

PM_ENBL         EQU     96H     ;NO LSTDBY UNTILL WE DEBUG APM STUFF..
ENABLE_BYTE     EQU     05H     ;D000:0 TO D000:FFFFH
OPEN_FN         EQU     03DH    ;MS DOS FILE OPEN FUNCTION.
ACCESS_CODE     EQU     40H     ;MSDOS PARAMETER FOR FILE READING.
PM_SEG          EQU     3000H   ;THAT IS THE VECTOR FOR SM RAM.
ENTRY_POINT     EQU     8000H
DSP_CODE        EQU     09H     ;MSDOS STUFF AGAIN.
SYS_EVNT_MASK1  EQU     5AH     ;5AH =  SELECT KB,COM1 MOUSE,COM2 MOUSE,FDD
SYS_EVNT_MASK2  EQU     40H     ;40H =  SELECT HDD ..
STOP_BREAK_MASK1 EQU    1AH     ;SELECT KB,COM1 MOUSE,COM2 MOUSE.
STOP_BREAK_MASK2 EQU    01H     ;SELECT RTC ALARM.
;-------------------------------------------------------------
CODE    SEGMENT         PARA   USE16
ASSUME CS:CODE,DS:CODE,ES:CODE,SS:CODE

                ORG     0100H

START:

;------SEGMENT INIT FOLLOWS.(THIS PROGRAM IS NOT LARGER THAN 64 K BYTES.)

                MOV     AX,CS           ;GET CODE SEG.
                MOV     DS,AX           ;INITIALISE DS.
                MOV     ES,AX           ;INITIALISE ES.
                MOV     SS,AX           ;INITIALISE SS.
                NOP
;----------------------------------------------------
;First we disable any power management due to previous runs..

		open_82360sl
		write_82360sl	sm_req_cntrl,00h
		write_82360sl	idxlck,01h

;Also we need to spoil XCMOS status byte ..

	write_xmos	XcmosInfoStart+23,00h	;Status setup.

;Now we disable the Shadow area...

 		UNLOCK_CPUPWRMODE
		CHANGE_REG  CPUPWRMODE, 0BFF3H,000AH
		CHANGE_REG  OMSCCR,0000H,0000H		;Disable E seg.Memory..
 		CHANGE_REG  CPUPWRMODE,0BFFCH,0100H     ;CLOSE SPACES.
;----------------------------------------------------
;PUT A SIGN ON MESSAGE...
                MOV     DX,OFFSET SIGN_ON_MES
                MOV     AH,DSP_CODE
                INT     OPSYS
;The loader's command line parser is here..Lemme analyze what is up there
;in command line at CS:80h

		call near ptr search_for_parm
		jnc	default_load_process
;----------------------------------------------------
		or	bl,20h			;convert to lower-case.
		mov	byte ptr [switch_byte],bl
		cmp	bl,"h"
		jnz	next_parm
help_menu :
		mov	dx,offset help_mes
		mov	ah,dsp_code
		int	opsys
		xor	ax,ax
		mov	ah,exit_code
		int	opsys
next_parm :
		cmp	bl,"b"
		jz	boot_load
next_parm1 :
		cmp	bl,"d"
		jz	default_load_process
no_more_parm :
		jmp	help_menu
boot_load :
		mov	dx,offset boot_load_mes
		mov	ah,dsp_code
		int	opsys
;--------------------------------------------------------
;Open up shadow ROM area...
 		UNLOCK_CPUPWRMODE
		CHANGE_REG  CPUPWRMODE, 0BFF3H,000AH
		CHANGE_REG  OMSCCR,0000H,0FFFFH		;Write and Read Only..
 		CHANGE_REG  CPUPWRMODE,0BFFCH,0100H     ;CLOSE SPACES.

;Segment init follows..
		mov	ax,SYS_ROM_SEGMENT
		mov	es,ax
		mov	ax,cs
		mov	ds,ax
		xor	di,di		;DI is my system ROM pointer.
		xor	si,si		;Si is my LOAD_DATA pointer.

;Step 1 : We write the signature first and then init the checksum.....

		mov	ax,ROM_SIGNATURE
		stosw
		mov	al,40h		;That is the length I use for CHK_SUM.
		stosb

;step 2 : Bring up the APM module from disk and load to 0E000:3000h.

		mov	dx,offset PMI_FILE
		call near ptr read_file
		jnc	pmi_load_continue
		jmp	out_of_here

pmi_load_continue :
		mov	di,Rom_PM_prog_start
		mov	si,offset file_buffer
		mov	cx,word ptr file_size
		CLD
		REPNZ MOVSB

;step 2 : Bring up the INT15 module from disk and load to 0E000:2000h.

		mov	dx,offset INT15_FILE
		call near ptr read_file
		jnc	int15_load_continue
		jmp	out_of_here

int15_load_continue :

		mov	di,Rom_INT15_prog_start
		mov	si,offset file_buffer
		mov	cx,word ptr file_size
		CLD
		REPNZ MOVSB

;step 3 : Bring up the INIT module from disk and load to 0E000:0003h

		mov	dx,offset INIT_FILE
		call near ptr read_file
		jnc	init_load_continue
		jmp	out_of_here

init_load_continue :
		mov	di,Rom_INIT_prog_start
		mov	si,offset file_buffer
		mov	cx,word ptr file_size
		CLD
		REPNZ MOVSB

;Step 4 : We calculate the check_sum and write it.

		mov	bx,CHK_SUM_BYTE
		mov	byte ptr ES:[BX],00

		mov	cx,ROM_SIZE
		xor	si,si
		xor	al,al
chk_sum_it :
 		add	al,byte ptr ES:[SI]
		inc	si
		loop	chk_sum_it

;Now AL will have a value that shall be neutralized to get zero checksum..

		xor	ah,ah
		xchg	al,ah
		sub	al,ah
		mov	bx,CHK_SUM_BYTE
		mov	byte ptr ES:[BX],al	;Check sum written..
;--------------------------------------------------------
;Close shadow ROM area...

 		UNLOCK_CPUPWRMODE
		CHANGE_REG  CPUPWRMODE, 0BFF3H,000AH
		CHANGE_REG  OMSCCR,0000H,5555H		;Read Only...
 		CHANGE_REG  CPUPWRMODE,0BFFCH,0100H     ;CLOSE SPACES.
;----------------------------------------------------------
		mov	dx,offset rom_load_mes
		mov	ah,dsp_code
		int	opsys

;At this point the PM software with proper INIT routine is already loaded
;onto SYSTEM SHADOW RAM ( 0E000h ) area. But we need to soft boot the
;machine for the changes to take effect..We check for user response now...

		xor	ax,ax
		int	key_int		;Hang here for user response.

		or	al,20h		;I love small things..Do you ??
		cmp	al,"y"		;Not an YES is always NO to me.. 
		jz	ok_soft_boot

no_soft_boot :
		xor	ax,ax
		mov	ah,exit_code
		int	opsys
ok_soft_boot :
		db	0EAh,00h,00h,0ffh,0ffh	;Soft boot...
;----------------------------------------------------
default_load_process :

;--WE FIRST DESIGNATE PM RAM AREA....
;TO DESIGNATE PM RAM WE NEED TO WRITE 0002H TO MCPMRAM  AT 310H IN OMCS.
;FIRST UNLOCK CPU POWER MODE REGISTER.

        UNLOCK_CPUPWRMODE
        CHANGE_REG  CPUPWRMODE,0BFF3H,0002H
        CHANGE_REGB  MCPMRAM,00H,ENABLE_BYTE

;-----------------------------------------------------
;WE NEXT ENABLE SM RAM.
;TO ENABLE PM RAM WE NEED TO WRITE 0008H TO OMDCR  AT 302H IN IBU.
;FIRST UNLOCK CPU POWER MODE REGISTER.

        CHANGE_REG  CPUPWRMODE,0BFF3H,000AH
        CHANGE_REG  OMDCR,0FFF7H,0008H
        CHANGE_REG  CPUPWRMODE,0BFFCH,0100H     ;CLOSE SPACES BEFORE
                                                ;CALLING MSDOS.
;--------------------------------------------------------
;NOW READ THE POWER MANAGEMENT MODULE FROM DISK ..FILE APMI.SYS

		mov	dx,offset PMI_FILE
		call near ptr read_file
		jnc	load_continue_pmi
		jmp	out_of_here

;NOW COPY THE POWER MANAGEMENT MODULE INTO SM RAM.

load_continue_pmi :
	
                MOV     AX,PM_SEG
                MOV     ES,AX
                MOV     DI,ENTRY_POINT
                MOV     SI,OFFSET FILE_BUFFER
                MOV     CX,WORD PTR [FILE_SIZE]
                CLD
                REP     MOVSB
;-----------------------------------------------------------------
;WE NOW MAKE SURE OF THE INTEGRITY OF THE POWER MANAGEMENT MODULE LOADED.

                MOV     DI,ENTRY_POINT
                MOV     SI,OFFSET FILE_BUFFER
                MOV     CX,WORD PTR [FILE_SIZE]
                CLD
                REPZ    CMPSB
                JNZ     ERR                     ; DATA_NOT_OK
;------------------------------------------------------------------
;---DISABLE PM RAM AGAIN..RESET BIT 3 OF OMDCR REGISTER ...

                UNLOCK_CPUPWRMODE
                CHANGE_REG  CPUPWRMODE,0BFF3H,000AH
                CHANGE_REG  OMDCR,0FFF7H,0000H
                CHANGE_REG  CPUPWRMODE,0BFFCH,0100H     ;LOCK CPUPWRMODE REG.
;------------------------------------------------------------------------
;INITIALISATION OF 360 SL FOLLOWS...

                OPEN_82360SL

                WRITE_82360SL    SM_REQ_STS,00
;-------------------------------------------------------------------
;WE PROGRAM WARNING TIMERS HERE...

                WRITE_82360SL     SUS_WRN_TMR_SRBTN,08H
                WRITE_82360SL     SUS_WRN_TMR_APWR,08H
                WRITE_82360SL     SUS_WRN_TMR,0F0H      ;1 msec/bit.
;----------------------------------------------------------------
;WE PROGRAM SYSTEM EVENTS HERE FOR A STEP , BECAUSE OF A 360SL BUG WE
;CAN  PROGRAM ONLY THE ACTIVE INTERRUPTS AS SYSTEM EVENTS.
;ALSO FROM THIS POINT ONWORDS WE DO TRACK THE 8259 MASK REGISTER MAKING IT
;A TRAP OF OUR SYSTEM...
;TO FIND ACTIVE INTERRUPTS WE READ THE INTERRUPT MASK REGISTER.

                XOR     AX,AX
                IN      AL,MASTER_PIC_MASK
                NOT     AL
                AND     AL,SYS_EVNT_MASK1
                MOV     BL,AL

                WRITE_82360SL     SYS_EVNT_CFG0,<BL>
;---------------------

                XOR     AX,AX
                IN      AL,SLAVE_PIC_MASK
                NOT     AL
                AND     AL,SYS_EVNT_MASK2
                MOV     BL,AL

                WRITE_82360SL     SYS_EVNT_CFG1,<BL>

;--------------------

                WRITE_82360SL     SYS_EVNT_CFG2,081H
;-------------------------------------------------------------
;DEV PWR 0 IS TIED TO FLOPPY , BUT SINCE FLOPPY NEEDS NO POWER MANAGEMENT
;WE DO NOT USE LSTDBY_TMR_DEV0 ANY MORE.

;--------------------------------------------------------------
;DEVICE 1 AND DEVICE 2 POINT TO ONLY ONE PHYSICAL DEVICE , WHICH IS BACKLIGHT
;AND LCD DISPLAY ...THEY ARE SPLIT LOGICALLY TO HAVE 2 TRAPS (MOUSE AND
;KEY BOARD)  WAKE UP THE DISPLAY.INITIALLY LET US SET IT FOR 60 SECONDS.

                WRITE_82360SL   LSTDBY_TMR_DEV1,0AH
;--------------------------------------------------------------
;DEVPWR 2 IS LCD...WE PROGRAM IT , INITIALLY TO 64 SECONDS.IT POINTS
;PHYSICALLY TO THE SAME DEVICE WHICH IS THE DISPLAY.

                WRITE_82360SL   LSTDBY_TMR_DEV2,11H
;---------------------------------------------------------------
;DEVPWR 3 IS HDD.WE PROGRAM THE TIMER FOR 80 SECS.

                WRITE_82360SL   LSTDBY_TMR_DEV3,14H

;---------------------------------------------------------------
;TIMER 4 AND 5 ARE NOT USED AT PRESENT...

;------------------------------------------------------------
;WE PROGRAM THE IO TRAPS FOR OUR DEVICES...
;FLOPPY POWER MANAGEMENT IS TAKEN OFF SINCE THE EPSON 1040 POWER MANAGES
;ITSELF.WE USE TRAP 0 FOR 8259 INTERRUPT CONTROLLER..
;THIS MEANS THAT A TRAP IS GENERATED WHENEVER AN ATTEMT  IS MADE BY ANY
;HIGH LEVEL SOFTWARE TO ALTER THE INTERRUPT MASK. SO THE POWER MANAGEMENT
;SOFTWARE THEN GAINS CONTROL AND USES THIS INFO TO ACTRIVELY ADJUST THE
;SYSTEM EVENTS AND STOP BREAK EVENNTS ...THUS CORRECTING THE 360SL'S
;BUG IN SYSTEM EVENTS.SEE CHIP ERRATA FOR MORE DETAILS..
;----------------------
                WRITE_82360SL   TRP_ADRL_DEV0,21H
                WRITE_82360SL   TRP_ADRH_DEV0,00H
                WRITE_82360SL   TRP_ADR_MSK_DEV0,80H    ;ENABLE TRAP.
;----------------------
;BACK LIGHT TRAPS... ARE MOUSE TRAPS 3F8H TO 3FEH..TRAP REMAINS
;DISABLED BECAUSE IT IS THE RESPONSIBILITY OF THE LOCAL STANDBY
;ROUTINE TO ENABLE IT...

                WRITE_82360SL   TRP_ADRL_DEV1,0F8H
                WRITE_82360SL   TRP_ADRH_DEV1,03H
                WRITE_82360SL   TRP_ADR_MSK_DEV1,07H    ;DISABLE TRAP.
;----------------------
;LCD TRAPS... ARE KEY BOARD  TRAPS 060H TO 064H

                WRITE_82360SL   TRP_ADRL_DEV2,60H
                WRITE_82360SL   TRP_ADRH_DEV2,00H
                WRITE_82360SL   TRP_ADR_MSK_DEV2,04H
;----------------------
;HDD  TRAPS... 1F0H TO 1F7H..

                WRITE_82360SL   TRP_ADRL_DEV3,0F0H
                WRITE_82360SL   TRP_ADRH_DEV3,01H
                WRITE_82360SL   TRP_ADR_MSK_DEV3,07H
;----------------------
;SOFTWARE INTERFACE IS VIA TRAP 4 AND A DUMMY ADDRESS OF 26H..

                WRITE_82360SL   TRP_ADRL_DEV4,26H
                WRITE_82360SL   TRP_ADRH_DEV4,00H       ;0026H IS MY DUMMY
                                                        ;DEVICE.
                WRITE_82360SL   TRP_ADR_MSK_DEV4,80H
;----------------------
;APM SOFTWARE INTERFACE IS VIA TRAP 5 AND A DUMMY ADDRESS OF B0H..

                WRITE_82360SL   TRP_ADRL_DEV5,0B0H
                WRITE_82360SL   TRP_ADRH_DEV5,00H       ;00B0H IS PORT
                                                        ;ADDRESS.
                WRITE_82360SL   TRP_ADR_MSK_DEV5,80H
;----------------------
;ENABLE LSTD BY TIMERS.TIMER 0 IS NOT ENABLED BECAUSE TRAP 0 IS USED FOR
;SYSTEM EVENTS WORK-AROUND.TIMER 4 IS NOT ENABLED BECAUSE TRAP 4 IS USED FOR
;SOFTWARE INTERFACE BETWEEN HIGH LEVEL SOFTWARE AND OUR POWER MANAGEMENT
;CODE.TIMER 5 IS NOT PROGRAMMED BECAUSE IT IS NOT YET USED.
;SO WE ONLY ENABLE HDD,MOUSE AND KEYBOARD TIMERS.

                WRITE_82360SL   STDBY_TMR_CNTRL,0EH
;----------------------
;PROGRAMMING GLOBAL STAND BY TIMER.4 SEC /BIT AND 16 BIT TIMER..
;WE PROGRAM IT TO 1 MIN 20 SECONDS..
                WRITE_82360SL   GSTDBY_TMRL,0EH		;0EH
                WRITE_82360SL   GSTDBY_TMRH,00H
;-------------------------------------------------------------
;WE PROGRAM AUTO-POWER OFF TIMER HERE.THIS IS THE TIME DELAY BEFORE YOU
;GOTO SUSPEND FROM GLOBAL STANDBY.

                WRITE_82360SL   APWR_TMRL,08H
                WRITE_82360SL   APWR_TMRH,80H
                WRITE_82360SL   SUS_WRN_TMR_APWR,08H
;-------------------------------------------------------------
;WE PROGRAM THE STOP BREAK EVENTS NOW.THEY ALSO WILL BE PROGRAMMED JUST LIKE
;SYSTEM EVENTS IN  A-STEP CPU AND IO CHIP.

;TO FIND ACTIVE INTERRUPTS WE READ THE INTERRUPT MASK REGISTER.

                XOR     AX,AX
                IN      AL,MASTER_PIC_MASK
                NOT     AL
                AND     AL,STOP_BREAK_MASK1
                MOV     BL,AL

                WRITE_82360SL     STP_BRK_CFG0,<BL>
;---------------------

                XOR     AX,AX
                IN      AL,SLAVE_PIC_MASK
                NOT     AL
                AND     AL,STOP_BREAK_MASK2
                MOV     BL,AL

                WRITE_82360SL     STP_BRK_CFG1,<BL>
;--------------------

                WRITE_82360SL     STP_BRK_CFG2,81H

;We initialize the XCMOS RAM for APM support.
;For details of the XCMOS map please see APM BIOS reference document.

	WRITE_XMOS     XcmosInfoStart+31,0b0h	;Setup Port address LOW
	WRITE_XMOS     XcmosInfoStart+30,000h	;Set Port address High
	WRITE_XMOS     XcmosInfoStart+29,005h	;Set for A2 and APM
	WRITE_XMOS     XcmosInfoStart+28,00h	;PM_EVENT flag.
	WRITE_XMOS     XcmosInfoStart+27,'L'	;SL signature.
	WRITE_XMOS     XcmosInfoStart+26,'S'	;SL signature.
	WRITE_XMOS     XcmosInfoStart+25,09h	;APM version 0.9
	WRITE_XMOS     XcmosInfoStart+24,07h	;Support flags..

;We write APM_STATUS BYTE here..

	write_xmos	XcmosInfoStart+23,1fh	;Status setup.

;-----------------------------------------------------------
;Testing BATT_LOW portions of APM driver..

	write_82360sl	SUS_WRN_TMR_BAT,04h	;Program Batt_low timer.
	alter_82360sl	RESUME_MASK,0FEh,00h	;Enable  Batt_low functions.
;-----------------------------------------------------------
;Program the SW_SMI timer for 255 msec.

		write_82360sl	SW_SMI_TMR,0FEh
;------------------------------------------------------------
;NOW WE ENABLE THE FULL POWER MANAGEMENT STATE MACHINE...

                WRITE_82360SL   SM_REQ_CNTRL,PM_ENBL
;------------------------------------------------------------------
;WE ARE DONE WITH INITIALIZATION..LOCK UP THE 360SL INDEX SPACE...
                WRITE_82360SL    IDXLCK,01
;-------------------------------------------------------------------
                MOV     DX,OFFSET SUCCESS_MES
                MOV     AH,09H
                INT     OPSYS
;--------------------------------------------------------------------
OUT_OF_HERE :
                MOV     AH,EXIT_CODE
                INT     OPSYS
                INT     PROC_TERM

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;Subroutines for the load module are as follows...

;------------------------------------------------------------------
;Routine Search_for_parm follows...It searches the command line for valid
;switches and if found it return them to caller..
;I/P DS:80h Command line parameter string passed by MSDOS.

;O/P = CY = 0 if no parameters are specified..DEFAULT LOAD CONDITION..
;O/P = CY = 1 if there are parameters on command line..and then...
;O/P   BL = 0ffh if the switch is invalid or not supported..
;      BL = parameter if supported..

;Warning : "This guy is a Bad Boy.." ..Destroys registers..
;------------------------------------------------------------------     
search_for_parm		proc		near

;First we search for the switch delimeter "/"
		xor	ch,ch
		mov	si,80h		;Command parameter start.
		mov	cl,byte ptr [si] ;Number of chars..
		cmp	cl,0h		; Zero Parameters...May be ?
		jnz	yes_parm	;Yes ..user did key in something..
		inc	cl		;Else  force CL = 1 ...
yes_parm :
		inc	si
search_slash :
		cmp	byte ptr [si],"/"
		jz	slash_found
		inc	si
		loop	search_slash
		clc
		jmp	end_search
slash_found :
		mov	cx,20d
spaces :
		inc	si
		cmp	byte ptr [si],20h
		jnz	parm_compare
		loop	spaces
invalid_parm :
		mov	bl,0ffh
		stc
		jmp	end_search

Parm_compare :
		mov	bl,byte ptr [si]
		stc
;------------------------------
end_search :

		ret	
search_for_parm		endp
;---------------------------------------------------------------------
;Procedure to read a file from diskette to file_buffer follows...
;The offset of the name of the file is passed in DS:DX
;output CY = 0 No error. CY = 1 Error..Error message has been displayed.
;If successful the data will be in FILE_BUFFER.
;----------------------------------------------------------------------
read_file	proc	near
		push	ax
		push	bx
		push	cx
		push	dx
		push	bp
		mov	bp,sp
;-------------------------------------
;Check if the file exists..

                CLC                             ;INIT ERRORS.
                MOV     AH,OPEN_FN              ;OPEN FILE FN.
                MOV     AL,ACCESS_CODE          ;ACCESS CODE.
                INT     OPSYS                   ;CALLING MS-DOS.
                JNC     NOERR
ERR:
;-----PRINT AN ERROR MESSAGE AND EXIT TO DOS.
                MOV     DX,OFFSET ERR_MES
                MOV     AH,09H          ;DISPLAY CODE.
                INT     OPSYS           ;CALLING MS-DOS TO PRINT IT.
                JMP     OUT_OF_READ_FILE

NOERR:
;-----TO DETERMIN THE FILE SIZE...

                MOV     WORD PTR [FILE_HANDLE],AX
                MOV     BX,AX           ;FILE HANDLE IN BX REG.
                XOR     CX,CX           ;CLEAR CX REG.
                XOR     DX,DX           ;CLEAR DX REG.
                MOV     AL,02H          ;METHOD CODE.
                MOV     AH,42H          ;FILE PTR MOVING CODE.
                INT     OPSYS           ;CALLING MS-DOS.
                JC      ERR
                MOV     WORD PTR [FILE_SIZE],AX

;----WE NOW MOVE THE FILE PTR BACK TO START BY SAME FUNCTION.

                MOV     BX,WORD PTR [FILE_HANDLE]
                MOV     AL,0            ;METHOD CODE.
                MOV     AH,42H          ;FILE PTR MOVING CODE.
                XOR     CX,CX           ;CLEAR CX REG.
                XOR     DX,DX           ;CLEAR DX REG.
                INT     OPSYS           ;CALLING MSDOS.
                JC      ERR

;------READING THE FILE INTO SYSTEM MEMORY.

                MOV     BX,WORD PTR [FILE_HANDLE]
                MOV     AX,3F00H        ;FILE READ CODE=3FH.
                MOV     CX,WORD PTR [FILE_SIZE]
                MOV     DX,OFFSET File_Buffer
                INT     OPSYS           ;CALLING MSDOS.
                JC      ERR
                CMP     AX,CX           ;ALL READ=?
                JNZ     ERR
;------------------------------------------------------
		clc
		jmp	end_read_file

Out_of_read_file :
		stc
end_read_file :
;--------------------------------------
		pop	bp
		pop	dx
		pop	cx
		pop	bx
		pop	ax
		ret
read_file	endp
;----------------------------------------------------------------------
;DATA AREA FOR THE PROGRAM...
PMI_FILE        DB      'APMI.SYS',00
INT15_FILE	DB	'INT15.SYS',00
INIT_FILE	DB	'INIT.SYS',00
ERR_MES         DB      0DH,0AH,0AH,'Can not load PM  Software.. $'
SUCCESS_MES     DB      0DH,0AH,0AH,'LOADAPM :  PM SW successfully loaded '
                DB      'into SM RAM and enabled.',0DH,0AH,0AH,24H
SIGN_ON_MES     DB      0DH,0AH,"Intel's  PM SW  LOADER  V 2.0 ( Sep 06,91 )."
		DB      0DH,0AH,'APM Version 0.9 Supported.$'
help_mes	db	0dh,0ah,0ah,' Valid switches are as follows...'
		db	0dh,0ah,0ah,' /h          = Output this help menu..'
		db	0dh,0ah,0ah,' /b          = Load PM program to SYSTEM ROM area for later boot-time loading.'
		db	0dh,0ah,0ah,' /d          = Load Now...!!..( Default Option ) .'
		db	0dh,0ah,0ah,' No Switches = Load Now...!!..'
		db	0dh,0ah,0ah,' LOADAPM     : Power Management  Not  Loaded..',0dh,0ah,24h
boot_load_mes 	db	0dh,0ah,0ah,'Loading PM program to SYSTEM ROM area.',0dh,0ah,0ah,24h
rom_load_mes	db	0dh,0ah,'All Programs were  successfully loaded to System ROM area..'
		db	0dh,0ah,0ah,'You will have to soft-boot your System for PM to take control ..'
		db	0dh,0ah,0ah,'Shall I Soft-boot the  machine for you now ( y / n ) ?  ',24h

switch_byte	db	00h
FILE_HANDLE     DW      ?
FILE_SIZE       DW      ?
FILE_BUFFER     DB      30000 DUP (00)
;--------------------------------------------------------
CODE            ENDS
END     START
