
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
;becomes a binary file which will be located by ROM LOADER onto 0E000:3h.
;So it gains control through OPTIONAL ROM SEARCH utilities that  are 
;invoked by ROM_SEARCH routine of any standard ATPOST during both
;cold and warm boot processes. THE LOADING FROM ROM ONTO SM RAM IS 
;ACCOMPLISHED AS DESCRIBED BELOW...

;As described above init.asm which is located at 0E000:0003h in the
;Shadow RAM with shadow enabled gains control during both cold and
;warm boot processes. Once invoked the INIT program has all the code
;necessary to do following things..

;1 > It disables the Global Power Management first and loads the PM code
;    that is located at 0E000:3000h to the SM RAM and then enables it.

;2 > It then runs through INITIALIZATION of 360SL. The Power Management
;    registers are initialized. ALSO THERE IS A HOOK PROVIDED HERE
;    for CONFIGURATION utility but this particular version of software
;    does not support it.

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
;This is an SMD1 APPS product.
;------------------------------------------------------------
; Assembler Directives  Follow.
            .386C                       ; ENABLE 386 INSTRUCTION GENERATION.
             PAGE       22,80           ; THAT IS FOR MY TERMINAL.
             INCLUDE    REG_EQU.INC     ; EQUATES LIBRARY FOR PM.
             INCLUDE    PWRMN.MAC       ; MACRO LIBRARY FOR PM.
;-------------------------------------------------------------
;EQUATES  FOLLOW.THESE ARE LOCAL EQUATES NOT PRESENT IN OUR HOLY BOOK
;EQUATES...
END_OF_MES	EQU	00H
WriteTeleType   EQU	0EH
Video		EQU	10H
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

Init		proc	far

                ORG     0003H 			;That is the origin.

START:
		jmp	init_start

;Data area for INIT routine...

chksum_byte	dw	0000h
Intel_sign	db	0dh,0ah,"Intel Corp. Power Management Initialization",00
Date_code	db	"Dated Aug 26,1991."
SignOnMessage	db	"Intel's  Power Management initializer Version 0.4 ( Aug 26,1991 )"
		db	0Dh,0Ah,"Intel-Microsoft APM version 0.9 Supported. ",0dh,0ah,00h

init_start :

;------SEGMENT INIT FOLLOWS.(THIS PROGRAM IS NOT LARGER THAN 64 K BYTES.)

		pushf
		cli

                MOV     AX,CS           ;GET CODE SEG.
                MOV     DS,AX           ;INITIALISE DS.

		MOV	AX,3000h	;SM RAM seg.
                MOV     ES,AX           ;INITIALISE ES.

;----------------------------------------------------
;Put a sign on message at the cursor location...We use video interrupt 10h
;with following parameters..Ah= 0Eh, AL = ASCII code, BH = Page,Bl =0.
;Note : This function increments the cursor position...

		mov	si,offset SignOnMessage
Try_more :
		cmp	byte ptr [si],END_OF_MES
		jz	sign_on_done
write_one_chr :
		mov	al,byte ptr [si]	;Get Character.
		mov	ah,WriteTeleType
		xor	bx,bx
		int	Video
		inc	si
		jmp	try_more
;-------------------------------------------------------------------
sign_on_done :
;Now we disable Power Management...

		open_82360SL
		Write_82360sl	SM_REQ_CNTRL,00h
		Write_82360sl	IDXLCK,01h
;-------------------------------------------------------------------
;Now we load the Power Management routines into SM RAM.They are located
;at 0E000:3000h.
;Step 1 : We first allocate the internal SM RAM area..

;TO DESIGNATE PM RAM WE NEED TO WRITE 0002H TO MCPMRAM  AT 310H IN OMCS.
;FIRST UNLOCK CPU POWER MODE REGISTER.

        UNLOCK_CPUPWRMODE
        CHANGE_REG  CPUPWRMODE,0BFF3H,0002H
        CHANGE_REGB  MCPMRAM,00H,ENABLE_BYTE
;-----------------------------------------------------
;Step 2 : We next enable the SM RAM..
;TO ENABLE PM RAM WE NEED TO WRITE 0008H TO OMDCR  AT 302H IN IBU.
;FIRST UNLOCK CPU POWER MODE REGISTER.

        CHANGE_REG  CPUPWRMODE,0BFF3H,000AH
        CHANGE_REG  OMDCR,0FFF7H,0008H
        CHANGE_REG  CPUPWRMODE,0BFFCH,0100H     ;CLOSE SPACES BEFORE
                                                ;CALLING MSDOS.
;--------------------------------------------------------
;Step 3 : We load the Power Management code into SM RAM now..

		mov	di,Entry_pt
		mov	si,Rom_PM_prog_start
		mov	cx,8000h
		CLD
		REPNZ MOVSB
;------------------------------------------------------------------
;Step 4 : DISABLE PM RAM AGAIN..RESET BIT 3 OF OMDCR REGISTER ...

                UNLOCK_CPUPWRMODE
                CHANGE_REG  CPUPWRMODE,0BFF3H,000AH
                CHANGE_REG  OMDCR,0FFF7H,0000H
                CHANGE_REG  CPUPWRMODE,0BFFCH,0100H     ;LOCK CPUPWRMODE REG.
;------------------------------------------------------------------------
;2 > We now  run through INITIALIZATION of 360SL. The Power Management
;    registers are initialized.

;Step 1 : Initialize 360SL. No user CONFIG UTILITY in this VERSION.

                OPEN_82360SL

                WRITE_82360SL    SM_REQ_STS,00
;-------------------------------------------------------------------
;WE PROGRAM WARNING TIMERS HERE...

                WRITE_82360SL     SUS_WRN_TMR_SRBTN,08H
                WRITE_82360SL     SUS_WRN_TMR_APWR,08H
                WRITE_82360SL     SUS_WRN_TMR,30H      ;1 msec/bit.
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

;We initialize the XCMOS RAM for Intel-Microsoft APM support 0.9
;For details of the XCMOS map please see APM BIOS reference document.

	WRITE_XMOS     XcmosInfoStart+31,0b0h	;Setup Port address LOW
	WRITE_XMOS     XcmosInfoStart+30,000h	;Set Port address High
	WRITE_XMOS     XcmosInfoStart+29,005h	;Set for A2 and APM
	WRITE_XMOS     XcmosInfoStart+28,00h	;PM_EVENT flag.
	WRITE_XMOS     XcmosInfoStart+27,'L'	;SL signature.
	WRITE_XMOS     XcmosInfoStart+26,'S'	;SL signature.
	WRITE_XMOS     XcmosInfoStart+25,09h	;APM version 0.9
	WRITE_XMOS     XcmosInfoStart+24,07h	;Support flags..
;-----------------------------------------------------------
;Initialize BATT_LOW portions of 360SL.

	write_82360sl	SUS_WRN_TMR_BAT,04h	;Program Batt_low timer.
	alter_82360sl	RESUME_MASK,0FEh,00h	;Enable  Batt_low functions.
;-----------------------------------------------------------
;Program the SW_SMI timer for 255 msec.

		write_82360sl	SW_SMI_TMR,0FFh
;------------------------------------------------------------
;Step 2 : We enable PM.

                WRITE_82360SL   SM_REQ_CNTRL,PM_ENBL
;------------------------------------------------------------------
;WE ARE DONE WITH INITIALIZATION..LOCK UP THE 360SL INDEX SPACE...
                WRITE_82360SL    IDXLCK,01
;-------------------------------------------------------------------
;That is it ...Return to Booting ritual...
		popf
		retf
init		endp
;--------------------------------------------------------
CODE            ENDS
END     START
