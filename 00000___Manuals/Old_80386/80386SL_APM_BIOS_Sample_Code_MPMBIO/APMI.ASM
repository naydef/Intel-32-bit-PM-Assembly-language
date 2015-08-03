
;THIS MODULE CONTAINS THE PM SW AND ITS SUB MODULES FOR INTEL'S EVALUATION

;IT HAS MODULES THAT SUPPORT SUSPEND / RESUME , GLOBAL

;STANDBY , LOCAL STANDBY AND TRAP MECHANISMS. ALSO IT HAS ROUTINES THAT

;SUPPORT A POWER MANAGEMENT INTERFACE THROUGH WHICH THE HIGHER LEVEL

;SOFTWARE APPLICATION CAN INTERFACE WITH POWER MANAGEMENT SOFTWARE.

;FOR DETAILS OF THIS INTERFACE PLEASE REFER TO DEVICE.DOC FILE.


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

;PRESENT UPDATE : SEP 01 , 1991.

;LAST UPDATE    : MAY 02 , 1991.

;THIS FILE IS UPDATED VERSION OF THE PREVIOUS POWER MANAGEMENT SOFTWARE
;THAT WAS PUT TOGETHER IN MAY 02 1990.

;FOLLOWING ARE THE CHANGES...


; 1 >The Intel - Microsoft spec 0.9 has been fully implemented. 
;    All the CALLS including Protected mode CONNECT CALLS are implemented.

; 2 >Critical SUSPEND-RESUME is also implemented.

; 3 >This code is for A-STEP..We will update it in near future for B-STEP.

; Note : Please read through APM code after you have read the APM
;        spec document 0.9 ( INTEL-MICROSOFT ).

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

;WHAT VERSION ?
                TRUE    EQU     00
                FALSE   EQU     0FFH

                CRT     EQU     TRUE            ;I HAVE A CRT SYSTEM.
;-----------------------------------------------------------
;FLAGS FOR DEBUG MESSAGES FOLLOW...IF YOU NEED DEBUG MESSAGES TO APPEAR
;AN THE SCREEN , YOU NEED TO ENABLE APPROPRIATE THE MESSAGE FLAGS..
;THE MODULE EXTENSIVELY MAKES USE OF DEBUG MESSAGES BECAUSE THEY HELP
;DEBUGGING THE ROUTINE WITH OUT ICE..

DISABLE                 EQU     TRUE
ENABLE                  EQU     FALSE

SW_SMI_MES_FLAG         EQU     DISABLE

APM_MES_FLAG		EQU	DISABLE

LSTDBY1_MES_FLAG        EQU     DISABLE
LSTDBY2_MES_FLAG        EQU     DISABLE
LSTDBY3_MES_FLAG        EQU     DISABLE

LTRP0_MES_FLAG          EQU     DISABLE
LTRP1_MES_FLAG          EQU     DISABLE
LTRP2_MES_FLAG          EQU     DISABLE
LTRP3_MES_FLAG          EQU     DISABLE
LTRP5_MES_FLAG          EQU     DISABLE

GSTDBY1_MES_FLAG        EQU     DISABLE
GSTDBY2_MES_FLAG        EQU     DISABLE

EXT_SMI_MES_FLAG        EQU     DISABLE

cpu_idle_mes_flag	equ	DISABLE
;----------------------------------------------------------

AUTO_OFF_FEATURE        EQU     ENABLE

;-----------------------------------------------------------
;THIS ROUTINE CONTAINS THE PM SW MAIN AND SUB MODULES.
;Include files PWRMN.MAC  before assembling.
;Intel Corp. 2625 Walsh Ave,Santa Clara, CA 95051.
;------------------------------------------------------------
; Assembler Directives  Follow.
             PAGE       22,80           ; THAT IS FOR MY TERMINAL.
             INCLUDE    REG_EQU.INC     ; MY HOLY BOOK OF EQUATES.
             INCLUDE    PWRMN.MAC       ; MY TOOL KIT , NEVER MEDDLE WITH IT.
            .386P                       ; ENABLE 386 INSTRUCTION GENERATION.
            .387                        ; ENABLE 387 INSTRUCTION GENERATION.
;-------------------------------------------------------------
;--EQUATES NOT IN REG_EQU.INC FILE ARE HERE.
ON              EQU     0FFH
OFF             EQU     00H
ENBL            EQU     0FFH
DISBL           EQU     00H
SYS_EVNT_MASK1  EQU     5AH     ;SELECT KB,COM1 MOUSE,COM2 MOUSE,FDD
SYS_EVNT_MASK2  EQU     40H     ;SELECT HDD...
STOP_BREAK_MASK1 EQU    1AH     ;SELECT KB,COM1 MOUSE,COM2 MOUSE
STOP_BREAK_MASK2 EQU    01H     ;SELECT RTC ALARM.

;-------------------------------------------------------------
CODE    SEGMENT         PARA   USE16
ASSUME CS:CODE,DS:CODE,ES:CODE,SS:CODE

               ORG     8000H		;That is where SMI entry point is..

START:

;ENTRY MODULE FOLLOWS.THIS CODE SEQUENCE IS EXECUTED EVERYTIME AN SMI OCCURS.
;------SEGMENT INIT FOLLOWS.(PM CODE AND DATA ARE WITHIN 64K)

                JMP     PM_MODULE

                DB      "INTEL PM",00   ;I ALWAYS SIGN IN.DON'T YOU ?

PM_MODULE :
		MOV     AX,CS			;GET THE VALUE OF CS.
		MOV     DS,AX                   ;INITIALISE DS.
		MOV	ES,AX			;INITIALISE ES
		MOV     SS,AX                   ;INITIALISE SS.
                NOP
		CLI                             ;NO INTERRUPTS..
                MOV     SP,STACK_TOP            ;INITIALISE STACK POINTER.
;----------------------------------------------------
; LOCK UP THE CPUPWRMODE REGISTER FIRST.
                CHANGE_REG  CPUPWRMODE,0BFFCH,0100H     ;LOCK CPUPWRMODE REG.
                OPEN_82360SL                            ;OPEN 360 SL SPACE..
;-----------------------------------------------------------
;It is necessary to process the CPU_IDLE calls of the APM interface
;first. This is because there are many idle calls per second and
;system will become sluggush if you have too much SMI over-head.
;Infact mouse movements may become sluggish if you have too much code
;being executed during CPU_IDLE calls.

;In A-STEP APM calls thro TRAP 5.

        READ_82360SL   SM_REQ_STS               ; READ SM_REQ_STS REGISTER.
        TEST    AL,LTRP_REQ		        ; IS IT LOCAL TRAP REQUEST ?
        JZ     GO_ON

YES_TRAP : 
;We use TRAP 5 for implementation of APM functions..In A-STEP 
;the control falls here whenever the APM driver makes an APM call.

                READ_82360SL    LTRP_STS
                TEST    AL,DEV5_TRPREQ
                JZ      GO_ON

;---THROW A MESSAGE IF DEBUG FLAG IS ENABLED...

	IF   LTRP5_MES_FLAG  EQ      ENABLE          ;IS DEBUG MESSAGE FLAG
	       	                                     ;ENABLED ???
	       MOV     SI,OFFSET LTRP_MES5
	       CALL NEAR PTR DEBUG_MES
	ENDIF

;We reset the trap request...

                WRITE_82360SL   LTRP_STS,1FH
		JMP	SW_APM_REQ	        ;Process APM Request

GO_ON :
;-----------------------------------------------------------
;As a next step we will be reading the CMOS shutdown byte..Before we do
;this we need to save the original INDEX register value of RTC chip..
;Why..??? Why ??? Because.........It is very much possible (and probable..)
;that CPU control was rudely pre-empted (snatched away..) in the midst
;of an RTC index and data write/read  cycle by an SMI..So for the security
;of the SYSTEM  it is necessary that we properly re-orient the CMOS INDEX
;register later on in our EXIT MODULE before we RESUME back to our
;application...This can be fortunately done in an SL system with relative
;ease because we do have a SHADOW register inside 82360SL , which
;continuously tracks the RTC index and NMI bit mask..This was safely
;saved by us during SUSPEND module..and we now give it back to RTC...

                READ_82360SL    SHNMIMASK

                MOV     BYTE PTR [OLD_RTC_INDEX],AL     ;INDEX and NMI
                                                        ;MASK SAVED...
;--------------------------------------------------------------------------
;OUR TASK IS TO DISPATCH THE CONTROL TO THE PROPER MODULE BASED ON THE
;STATUS BYTE AT THIS POINT.
;NOW WE TEST FOR A RESUME REQUEST BY LOOKING INTO SHUTDOWN BYTE.
;RESUME EVENT IS SIGNIFIED BY 0DH AT 0FH ADDRESS OF CMOS RAM.
;WE READ THE SUSPEND SHUTDOWN BYTE FROM CMOS RAM.

                MOV     AL,SHUTDOWN_SUS_ADD
                OR      AL,80H                  ;NO NMI.
                OUT     CMOSADD,AL

                JMP     $+2                     ;A RECOVERY DELAY FOR CMOS.
                JMP     $+2
                JMP     $+2

                IN      AL,CMOSDATA
                CMP     AL,SHUTDOWN_RESUME
                JNZ     NOT_RESUME
RESUME_EVENT :
                JMP     RESUME_PROCESS

NOT_RESUME :
;-----------------------------------------------------------------------
;IT HAS BEEN DETERMINED THAT THE SM RAM ENTRY WAS NOT DUE TO RESUME EVENT.
;SMI DISPATCHER FOLLOWS.IT ANALYSES THE STATUS FLAGS AND CALLS
;APPROPRIATE SERVICE MODULE. ANALYSIS OF STATUS REGISTERS BEGINS HERE.

        READ_82360SL   SM_REQ_STS               ; READ SM_REQ_STS REGISTER.

        MOV     BYTE PTR [SMI_REQ_STS_BYTE],AL

        TEST    AL,HW_SUSREQ            ; IS IT SUSPEND REQUEST ?
        JNZ     HW_SUSREQ_PROCESS
        TEST    AL,SW_REQ               ; IS IT SOFTWARE SMI REQUEST ?
        JNZ     SW_SMI_PROCESS
        TEST    AL,LSTDBY_REQ           ; IS IT LOCAL STANDBY REQUEST ?
        JNZ     LSTDBY_REQ_PROCESS
        TEST    AL,LTRP_REQ             ; IS IT LOCAL TRAP REQUEST ?
        JNZ     LTRP_REQ_PROCESS
        TEST    AL,EXT_SMI_REQ          ; IS IT EXTERNAL SMI REQUEST ?
        JNZ     EXT_SMI_PROCESS
        TEST    AL,GSTDBY_REQ           ; IS IT GLOBAL STANDBY REQUEST ?
        JNZ     GSTDBY_REQ_PROCESS

;---------------------------------------------------
;CONTROL FALLS HERE IF IT IS A FICTITIOUS REQUEST.REPORT THE ERROR.
                MOV     SI,OFFSET UNKNOWN_SMI_MES
                CALL NEAR PTR DEBUG_MES
;--------------------------------------------------
;CONTROL FALLS TO EXIT MODULE..WHICH LEGALLY EXITS SMI.EPILOGUE PROCEDURES
;FOLLOW FOR A GRACEFUL EXIT TO THE POINT WHERE SMI TOOK OVER CONTROL.

EXIT_SMI :

;This is the Last write to CMOS RAM index and DATA registers in the
;PM module before we RESUME back to the application..It is possible
;that CPU control was rudely pre-empted (snatched away..) in the midst
;of an RTC index and data write cycle..So for the security of the SYSTEM
;it is necessary that we properly re-orient the CMOS INDEX register..This
;can be fortunately done in an SL system with relative ease because we
;do have a SHADOW register inside 82360SL , which continuously tracks
;the RTC index and NMI bit mask..This was safely saved by us on our entry
;to PM module..and we now give it back to RTC...

                MOV     AL,BYTE PTR [OLD_RTC_INDEX]

                OUT     CMOSADD,AL              ;Application index restored.
;--------------------------------------------------------------------------
;FIND OUT IF CPU WAS IN HLT STATE PRIOR TO SMI OCCURANCE.IF TRUE
;DECREMENT THE EIP IMAGE TO ALLOW RE-ENTRY TO HALT STATE.
;REMEMBER CPUPWRMODE REGISTER IS ALWAYS READABLE.

        UNLOCK_CPUPWRMODE
        IN      AX,CPUPWRMODE
        TEST    AL,HALT_BIT
        JZ SHORT        NOT_A_HALT


RESTORE_HALT :

        MOV     BX,EIP_IMAGE_LOCN
        DEC     BYTE PTR [BX]

NOT_A_HALT :

        CHANGE_REG  CPUPWRMODE,0BFFCH,0100H     ;LOCK CPUPWRMODE REG.

;WE CLEAR THE STATUS REGISTER..BY DOING SO WE ARE GOING TO LOOSE THE
;SMI'S THAT OCCURED WHEN YOU WERE INSIDE SMI...BUT IN THIS EXAMPLE
;WE CHOOSE THIS SIMPLIFIED SOLUTION..

;        WRITE_82360SL   SM_REQ_STS,00		;important APM modification..
;-------------------------------------
;WE THROW A POST CODE ON TO PORT 80H TO SIGNIFY THAT WE ARE ABOUT TO
;EXIT THE SM RAM ...
                MOV     AL,8EH
                OUT     80H,AL
;--------------------------------------
;Enable SMI by writing to  SMI_CLR register.

        WRITE_82360SL    SMI_CLR,00     ; WRITE THE 82360SL REGISTER.
;--------------------------------------
;ENABLE CPU RESET BY 82360SL BY WRITING TO SMI_MARK REGISTER.

        WRITE_82360SL     SMI_MARK,00   ; WRITE THE 82360SL REGISTER.
;--------------------------------------
;CLOSE 82360SL SPACE..

        WRITE_82360SL   IDXLCK,01H
;-----------------------------------------------------------------
;EXECUTE RSM INSTRUCTION TO GET BACK TO THE APPLICATION.

        DB     0FH,0AAH                 ; NO ASSEMBLER KNOWS THIS YET.Ha.Ha..
;===========================================================================
;WHAT IF ??? RSM INSTRUCTION FAILS ...OK ATLEAST TELL ME SO...
;WE OUTPUT A POST CODE TO INDICATE RSM INSTRUCTION FAILURE..

        MOV     AL,RSM_FAIL
        OUT     80H,AL
        HLT                             ;WHAT ELSE ...?
;===========================================================================
SW_SMI_PROCESS :

;The control will be here if SW_SMI occured due to a SW_SMI_DELAY
;request by a module ( For ex: Critical SUSPEND in APM. )

		mov	byte ptr [SW_SMI_FLAG],TRUE

;TEST STUB FOLLOWS : A MESSAGE IS FLASHED ON THE SCREEN TO INDICATE
;PROPER DETECTION OF SW_SMI_REQ WAS MADE. IT IS ENABLED BY A PROPER
;ASSEMBLER DIRECTIVE AT THE TOP OF THIS FILE..
; WE CLEAR THE SCREEN AND PUT THE MESSAGE FOR 5 SEC APPROX.THEN WE EXIT
; TO APPLICATION.
;------------------------------------------------------------------
        IF      SW_SMI_MES_FLAG     EQ      ENABLE  ;IS DEBUG MESSAGE FLAG
                                                ;ENABLED ???
                MOV     SI,OFFSET SW_SMI_MES
                CALL NEAR PTR DEBUG_MES

        ENDIF
;--------------------------------------------------------------------
;Now we call the SW SMI counter program which counts the number of SMIs..

		call near ptr sw_smi_delay

;WE HAVE NOT USED THE SOFTWARE SMI ARCHITECTURE IN THIS EXAMPLE AND
;HENCE THERE IS NOTHING MORE TO BE PROCESSED HERE IN THE SOFTWARE OTHER
;THAN MAKING A GRACEFUL EXIT TO THE POINT WHERE SW SMI GAINED CONTROL.
;NOTE : FOR A SOFTWARE INTERFACE WITH APPLICATION SOFTWARE WE HAVE USED
;A TRAP RATHER THAN A SOFTWARE SMI IN THIS EXAMPLE..

;SO AT PRESENT NO PROCESSING NEEDS TO BE DONE HERE..

;RESET SOFTWARE SMI REQUEST BEFORE EXIT.


		WRITE_82360SL	SM_REQ_STS,7eh

                JMP     EXIT_SMI
;-------------------------------------------------------------------
;LOCAL STANDBY PROCESSING FOLLOWS.WE ONLY USE THE LOCAL STANDBY ARCHITECTURE
;OF THE SL SUPERSET TO PUT THE LOCAL DEVICES TO SOFTWARE STANDBY MODE.
;WE WILL NOT SWITCH OFF THE LOCAL DEVICES COMPLETELY .BECAUSE OF A  BUG
;IN SMLIL REGISTER , IT WILL NOT BE POSSIBLE FOR US TO RETRY AN IO
;INSTRUCTION..SO WE WILL NOT SWITCH OFF LOCAL DEVICES COMPLETELY...

LSTDBY_REQ_PROCESS :

                READ_82360SL    LSTDBY_STS

                CMP     AL,00H                  ;IS THERE A LOCAL STDBY REQ ?
                JNZ     LSTDBY_OK

;ALERT THE USER , THAT IT IS A PHONY REQUEST....

LSTDBY_STS_FAULTY :
                MOV     SI,OFFSET LSTDBY_FAULT_MES
                CALL NEAR PTR DEBUG_MES
                JMP     EXIT_SMI

;LOCAL STANDBY PROCESSING BEGINS HERE...

LSTDBY_OK :
                TEST    AL,DEV0_STDBYREQ        ;TEST FOR FIRST DEVICE..
                JZ      NEXT_LOCAL_1            ;IF NOT TRY NEXT.

;IN THE PRESENT VERSION , AS IT HAS BEEN OUTLINED IN THE LOAD.ASM FILE
;WE ARE USING TRAP 0 ARCHITECTURE TO PROVIDE A BUG FIX FOR SYTEM AND
;STOP BREAK EVENTS. THE EPSON 1040 TYPE FLOPPY DRIVE HAS INBUILT POWER
;MANAGEMENT..

                ALTER_82360SL   LSTDBY_STS,0FEH,00H
                JMP     LOCAL_STDBY_EXIT
;--------------------------------------------------------
NEXT_LOCAL_1 :
                TEST    AL,DEV1_STDBYREQ        ;TEST FOR SECOND DEVICE..
                JZ      NEXT_LOCAL_2            ;IF NOT TRY NEXT..

;---THROW A MESSAGE IF DEBUG FLAG IS ENABLED...

   IF   LSTDBY1_MES_FLAG        EQ      ENABLE  ;IS DEBUG MESSAGE FLAG
                                                ;ENABLED ???
                MOV     SI,OFFSET LSTDBY_MES1
                CALL NEAR PTR DEBUG_MES
        ENDIF

                MOV     AL,"L"                  ;AL = 4CH IS LSTDBY CODE.
                CALL NEAR PTR MANAGE_LOCAL_1    ;PUT THE DEVICE TO STANDBY.

;WE FLAG THE DEVICE AS OFF..

                MOV     BYTE PTR [DEV1_LSTDBY_STAT],OFF
                ALTER_82360SL   LSTDBY_STS,0FDH,00H
                JMP     LOCAL_STDBY_EXIT
;-------------------------------------------------------------------
NEXT_LOCAL_2 :
                TEST    AL,DEV2_STDBYREQ        ;TEST FOR THIRD DEVICE..
                JZ      NEXT_LOCAL_3            ;IF NOT TRY NEXT..

;---THROW A MESSAGE IF DEBUG FLAG IS ENABLED...

   IF   LSTDBY2_MES_FLAG        EQ      ENABLE  ;IS DEBUG MESSAGE FLAG
                                                ;ENABLED ???
                MOV     SI,OFFSET LSTDBY_MES2
                CALL NEAR PTR DEBUG_MES
        ENDIF
                MOV     AL,"L"                  ;AL = 4CH IS LSTDBY CODE.
                CALL NEAR PTR MANAGE_LOCAL_2    ;PUT THE DEVICE TO STANDBY.

;WE FLAG THE DEVICE OFF..

                MOV     BYTE PTR [DEV2_LSTDBY_STAT],OFF
                ALTER_82360SL   LSTDBY_STS,0FBH,00H

                JMP     LOCAL_STDBY_EXIT
;---------------------------------------------------------------------
NEXT_LOCAL_3 :
                TEST    AL,DEV3_STDBYREQ        ;TEST FOR FOURTH DEVICE..
                JZ      NEXT_LOCAL_4            ;IF NOT TRY NEXT.

;---THROW A MESSAGE IF DEBUG FLAG IS ENABLED...

   IF   LSTDBY3_MES_FLAG        EQ      ENABLE  ;IS DEBUG MESSAGE FLAG
                                                ;ENABLED ???
                MOV     SI,OFFSET LSTDBY_MES3
                CALL NEAR PTR DEBUG_MES
        ENDIF

                MOV     AL,"L"                  ;AL = 4CH IS LSTDBY CODE.
                CALL NEAR PTR MANAGE_LOCAL_3    ;PUT THE DEVICE TO STANDBY.

;WE FLAG THE DEVICE OFF..

                MOV     BYTE PTR [DEV3_LSTDBY_STAT],OFF
                ALTER_82360SL   LSTDBY_STS,0F7H,00H
                JMP     LOCAL_STDBY_EXIT
;----------------------------------------------------------------
;AS ALREADY STATED , IN OUR EXAMPLE TRAP_4 ARCHITECTURE IS USED TO CREATE
;A SOFTWARE INTERFACE BETWEEN POWER MANAGEMENT SOFTWARE AND HIGHER LEVEL
;SOFTWARE. HENCE IT IS OBVIOUS THAT DEV_4 REQUEST CAN NEVER OCCUR LEGALLY
;IN A DAVID BOARD HARDWARE. ANYWAY THE FOLLOWING LINES OF CODE ARE PROVIDED
;FOR COMPLETENESS..

NEXT_LOCAL_4 :
                TEST    AL,DEV4_STDBYREQ
                JZ      NEXT_LOCAL_5

                ALTER_82360SL   LSTDBY_STS,0EFH,00H

                JMP     LOCAL_STDBY_EXIT
;-------------------------------------------------------------------
;AT PRESENT LOCAL STANDBY TIMER 5 IS NOT USED...


NEXT_LOCAL_5 :
;Local Standby 5 is not used...


;                TEST    AL,DEV5_STDBYREQ
;                JZ      LOCAL_STDBY_EXIT
;
;                ALTER_82360SL   LSTDBY_STS,0DFH,00H
;-------------------------------------------------------------
;IN THIS EXAMPLE WE DO NOT SERVICE MULTIPLE LSTDBY REQUESTS..IF A LSTDBY
;REQUEST OCCURS WHEN ANOTHER ONE IS BEING SERVICED WE JUST DESTROY IT
;AND SERVICE IT WHEN IT OCCURS NEXT TIME...THIS IS JUST TO KEEP THE
;PROGRAM SIMPLE...

LOCAL_STDBY_EXIT :

        ALTER_82360SL   SM_REQ_STS,0F7H,00H

                JMP     EXIT_SMI

;-------------------------------------------------------------------
;LOCAL TRAP PROCESSING FOLLOWS.AS ALREADY OUTLINED TRAP NUMBER-4 IS USED
;TO INTERFACE WITH APPLICATION SOFTWARE.

LTRP_REQ_PROCESS :

                READ_82360SL    LTRP_STS

                CMP     AL,00H                  ;NO REQUEST BIT SET ?
                JNZ     LTRP_OK                 ;IF SET OK ELSE TRAP FAULTY.

;NO TRAP REQUEST BIT IS SET , SO REPORT THE ERROR AND EXIT.

LTRP_FAULTY :
                MOV     SI,OFFSET LTRP_FAULT_MES
                CALL NEAR PTR DEBUG_MES
                JMP     EXIT_SMI
LTRP_OK :

;NOW WE BEGIN TRAP PROCESSING...
;WE NEED TO CHECK WHETHER THIS IS A SW PMI REQUEST FIRST. A SOFTWARE PMI
;REQUEST IS SIGNALLED BY A TRAP_REQUEST NUMBER 4.THIS IS DONE FOR
;PERFORMANCE REASONS BECAUSE WE DO NOT WANT TO MAKE THE SYSTEM SLUGGISH
;WHENEVER THERE IS AN ENQUIRY FROM UPPER LEVEL SOFTWARE..
;The software interface that was provided for DEMO purposes still stays..

                MOV     BYTE PTR [LTRP_STS_BYTE],AL

                TEST    AL,DEV4_TRPREQ          ;TEST FOR TRAP - 4..
                JNZ     SW_PM_REQ
;-------------------------------------------------
;TRAP 0 PROCESSING FOLLOWS...TRAP 0 IS USED TO IMPLIMENT THE SYSTEM
;AND STOP BREAK EVENTS WORK-AROUND AS STATED EARLIER..PLEASE SEE
;ERRATA FOR DETAILS..

                TEST    AL,DEV0_TRPREQ          ;IS IT TRAP 0 ??
                JZ      NEXT_TRP_1              ;TRY NEXT...

;---THROW A MESSAGE IF DEBUG FLAG IS ENABLED...

   IF   LTRP0_MES_FLAG  EQ      ENABLE  ;IS DEBUG MESSAGE FLAG
                                                ;ENABLED ???
                MOV     SI,OFFSET LTRP_MES0
                CALL NEAR PTR DEBUG_MES
        ENDIF

                MOV     AL,"T"                  ;TRAP MANAGEMENT CODE = T
                CALL NEAR PTR MANAGE_LOCAL_0
                ALTER_82360SL   LTRP_STS,0FEH,00H  ;RESET TRAP REQUEST..
                JMP     EXIT_TRP
;---------------------------------------------------
NEXT_TRP_1 :
                TEST    AL,DEV1_TRPREQ
                JZ      NEXT_TRP_2

;---THROW A MESSAGE IF DEBUG FLAG IS ENABLED...

   IF   LTRP1_MES_FLAG  EQ      ENABLE  ;IS DEBUG MESSAGE FLAG
                                                ;ENABLED ???
                MOV     SI,OFFSET LTRP_MES1
                CALL NEAR PTR DEBUG_MES
        ENDIF
                MOV     AL,"T"
                CALL NEAR PTR MANAGE_LOCAL_1
                MOV     BYTE PTR [DEV1_LSTDBY_STAT],ON
                ALTER_82360SL   LTRP_STS,0FDH,00H
                JMP     EXIT_TRP
;-----------------------------------------------------
NEXT_TRP_2 :
                TEST    AL,DEV2_TRPREQ
                JZ      NEXT_TRP_3
;---THROW A MESSAGE IF DEBUG FLAG IS ENABLED...

   IF   LTRP2_MES_FLAG  EQ      ENABLE  ;IS DEBUG MESSAGE FLAG
                                                ;ENABLED ???
                MOV     SI,OFFSET LTRP_MES2
                CALL NEAR PTR DEBUG_MES
        ENDIF
                MOV     AL,"T"
                CALL NEAR PTR MANAGE_LOCAL_2
                MOV     BYTE PTR [DEV2_LSTDBY_STAT],ON
                ALTER_82360SL   LTRP_STS,0FBH,00H
                JMP     EXIT_TRP
;--------------------------------------------------------
NEXT_TRP_3 :
                TEST    AL,DEV3_TRPREQ
                JZ      EXIT_TRP

;---THROW A MESSAGE IF DEBUG FLAG IS ENABLED...

   IF   LTRP3_MES_FLAG  EQ      ENABLE  ;IS DEBUG MESSAGE FLAG
                                                ;ENABLED ???
                MOV     SI,OFFSET LTRP_MES3
                CALL NEAR PTR DEBUG_MES
        ENDIF
                MOV     AL,"T"
                CALL NEAR PTR MANAGE_LOCAL_3
                MOV     BYTE PTR [DEV3_LSTDBY_STAT],ON
                ALTER_82360SL   LTRP_STS,0F7H,00H
;-----------------------------------------------------------
EXIT_TRP :
;NOW WE RESET THE GROUP REQUEST BIT OF THE TRAP SYSTEM.
;Please note that the correct practise to manipulate the status bits
;is to write a 0 only to the bit we are re-setting and a 1 to all other bits.

                WRITE_82360SL   SM_REQ_STS,4FH
                JMP     EXIT_SMI
;--------------------------------------------------------------------------
;WE PROCESS THE SOFTWARE SMI REQUEST FROM UPPER LEVEL SOFTWARE HERE..
;THE SOFTWARE INTERFACE COMMUNICATES VIA TRAP 4. ALSO EXTENDED CMOS MEMORY
;LOCATIONS ARE USED TO PASS ON PARAMETERS..
;FOR A COMPLETE EXPLANATION OF THE INTERFACE AND THE DETAILED LISTING OF
;SYSTEM CALLS , PLEASE READ THE FILE DEVICE.DOC
;--------------------------------------------------------------------------
SW_PM_REQ :

;WE USE EXTENDED CMOS RAM TO PASS ON PARAMETERS.

                READ_XMOS       00
                MOV     BL,AL
                READ_XMOS       01
                MOV     BH,AL
                MOV     WORD PTR [AX_VALUE],BX
;--------------------------------------
                READ_XMOS       02
                MOV     BL,AL
                READ_XMOS       03
                MOV     BH,AL
                MOV     WORD PTR [BX_VALUE],BX
;--------------------------------------
                READ_XMOS       04
                MOV     BL,AL
                READ_XMOS       05
                MOV     BH,AL
                MOV     WORD PTR [CX_VALUE],BX
;----------------------------------------------------------
;A SW REQUEST DISPATCHER FOLLOWS..IT ANALYSES THE REQUEST FROM THE UPPER
;LEVEL SOFTWARE AND PROCESSES THEM..

                MOV     AX,WORD PTR [AX_VALUE]

                CMP     AH,SET_CPU_CLOCK        ;IS IT SET CPU CLOCK FN ?
                JNZ     NEXT_1                  ;TRY NEXT FUNCTION CODE.

;THE CPU CLOCK SPEED SETTING FUNCTION DETAILS ARE AS FOLLOWS..
;AH = 01H FUNCTION CODE FOR SET CPU CLOCK FUNCTION.
;BL = DIVISOR FACTOR FOR PROCESSOR CLOCK.
;THE ROUTINE RETURNS AX = 0 AND CY FLAG = 0 IN CASE OF NO ERRORS.

                CALL NEAR PTR SET_CLK

NEXT_1 :
                CMP     AH,GET_CPU_CLOCK        ;IS IT GET_CPU_CLOCK FN ?
                JNZ     NEXT_2                  ;TRY NEXT FUNCTION CODE.

;THE GET CPU CLOCK SPEED  FUNCTION DETAILS ARE AS FOLLOWS..
;AH = 81H FUNCTION CODE FOR GET CPU CLOCK FUNCTION.
;THE ROUTINE RETURNS AX = 0 AND CY FLAG = 0 IN CASE OF NO ERRORS.
;BL = DIVISOR FACTOR FOR PROCESSOR CLOCK (RETURN VALUE).

                CALL NEAR PTR GET_CLK
NEXT_2 :
                CMP     AH,SET_KB_CLK           ;IS IT SET KEY CLOCK ?
                JNZ     NEXT_3                  ;TRY NEXT..

;THE SET KEY CLOCK SPEED  FUNCTION DETAILS ARE AS FOLLOWS..
;AH = 02H FUNCTION CODE FOR SET KEY  CLOCK FUNCTION.
;BL = DIVISOR FACTOR FOR KEY BOARD CONTROLLER CLOCK.
;THE ROUTINE RETURNS AX = 0 AND CY FLAG = 0 IN CASE OF NO ERRORS.

                CALL NEAR PTR SET_KEY_CLK
NEXT_3 :

                CMP     AH,GET_KB_CLK           ;IS IT GET KEY CLOCK ?
                JNZ     NEXT_4                  ;TRY NEXT..

;THE GET KEY CLOCK SPEED  FUNCTION DETAILS ARE AS FOLLOWS..
;AH = 82H FUNCTION CODE FOR SET KEY  CLOCK FUNCTION.
;THE ROUTINE RETURNS AX = 0 AND CY FLAG = 0 IN CASE OF NO ERRORS.
;BL = DIVISOR FACTOR FOR KEY BOARD CONTROLLER CLOCK.(RETURN VALUE)

                CALL NEAR PTR GET_KEY_CLK
NEXT_4 :
                CMP     AH,LOAD_GST             ;IS IT LOAD GSTDBY TIMER ?
                JNZ     NEXT_5                  ;TRY NEXT FUNCTION..

;THE LOAD GSTDBY TIMER  FUNCTION DETAILS ARE AS FOLLOWS..
;AH = 03H FUNCTION CODE FOR LOAD_GS_TIMER  FUNCTION.
;CX = COUNT TO BE LOADED TO GLOBAL STANDBY TIMER.
;THE ROUTINE RETURNS AX = 0 AND CY FLAG = 0 IN CASE OF NO ERRORS.

                CALL NEAR PTR LOAD_GS_TMR
NEXT_5 :
                CMP     AH,GET_GST              ;IS IT GET GSTDBY TIMER ?
                JNZ     NEXT_6                  ;TRY NEXT..

;THE GET GSTDBY TIMER  FUNCTION DETAILS ARE AS FOLLOWS..
;AH = 83H FUNCTION CODE FOR GET_GS_TIMER  FUNCTION.
;THE ROUTINE RETURNS AX = 0 AND CY FLAG = 0 IN CASE OF NO ERRORS.
;CX = VALUE OF THE GSTDBY TIMER (RETURN VALUE..)

                CALL NEAR PTR GET_GS_TMR
NEXT_6 :
                CMP     AH,LOAD_APOT            ;IS IT LOAD AUTO POWER OFF ?
                JNZ     NEXT_7                  ;TRY NEXT..

;THE LOAD AUTO POWER OFF TIMER  FUNCTION DETAILS ARE AS FOLLOWS..
;AH = 04H FUNCTION CODE FOR LOAD_AP_TMR  FUNCTION.
;CX = COUNT TO BE LOADED TO AUTO POWER OFF TIMER.
;THE ROUTINE RETURNS AX = 0 AND CY FLAG = 0 IN CASE OF NO ERRORS.

                CALL NEAR PTR LOAD_AP_TMR
NEXT_7:
                CMP     AH,GET_APOT             ;IS IT GET AUTO POWER OFF ?
                JNZ     NEXT_8                  ;TRY NEXT FUNCTION..

;THE GET THE VALUE OF AUTO POWER OFF  TIMER  FUNCTION DETAILS ARE AS FOLLOWS..
;AH = 84H FUNCTION CODE FOR GET_AP_TMR  FUNCTION.
;THE ROUTINE RETURNS AX = 0 AND CY FLAG = 0 IN CASE OF NO ERRORS.
;CX = VALUE OF THE AUTO POWER OFF TIMER. (RETURN VALUE..)

                CALL NEAR PTR GET_AP_TMR
NEXT_8:
                CMP     AH,LOAD_APOW            ;IS IT LOAD AUTO PWR WARN TMR.
                JNZ     NEXT_9                  ;TRY NEXT FUNCTION..

;THE LOAD AUTO POWER OFF WARNING TIMER  FUNCTION DETAILS ARE AS FOLLOWS..
;AH = 05H FUNCTION CODE FOR LOAD_AP_TMR  FUNCTION.
;CX = COUNT TO BE LOADED TO AUTO POWER OFF WARNING TIMER.
;THE ROUTINE RETURNS AX = 0 AND CY FLAG = 0 IN CASE OF NO ERRORS.

                CALL NEAR PTR LOAD_APOW_TMR
NEXT_9 :
                CMP     AH,GET_APOW             ;IS IT GET APOFF WARN TIMER ?
                JNZ     NEXT_10                 ;TRY NEXT FUNCTION..

;GET THE VALUE OF AUTO POWER OFF WARNING  TIMER  DETAILS ARE AS FOLLOWS..
;AH = 84H FUNCTION CODE FOR GET_APOW_TMR  FUNCTION.
;THE ROUTINE RETURNS AX = 0 AND CY FLAG = 0 IN CASE OF NO ERRORS.
;CX = VALUE OF THE AUTO POWER OFF WARNING TIMER. (RETURN VALUE..)

                CALL NEAR PTR GET_APOW_TMR
NEXT_10 :
                CMP     AH,DISABLE_POFF         ;IS IT DISABLE AUTO PWR_OFF ?
                JNZ     NEXT_11                 ;TRY NEXT FUNCTION..

;THE DISABLE AUTO POWER OFF FEATURE FUNCTION  DETAILS ARE AS FOLLOWS..
;AH = 06H FUNCTION CODE FOR DISABLE_AUTO_OFF  FUNCTION.
;THE ROUTINE RETURNS AX = 0 AND CY FLAG = 0 IN CASE OF NO ERRORS.

                CALL NEAR PTR DISABLE_AUTO_OFF
NEXT_11 :
                CMP     AH,ENABLE_POFF          ;IS IT ENABLE AUTO PWR_OFF ?
                JNZ     NEXT_12                 ;TRY NEXT FUNCTION..

;THE ENABLE AUTO POWER OFF FEATURE FUNCTION  DETAILS ARE AS FOLLOWS..
;AH = 07H FUNCTION CODE FOR ENABLE_AUTO_OFF  FUNCTION.
;THE ROUTINE RETURNS AX = 0 AND CY FLAG = 0 IN CASE OF NO ERRORS.

                CALL NEAR PTR ENABLE_AUTO_OFF
NEXT_12 :
                CMP     AH,DISABLE_STANDBY      ;IS IT DUSABLE GSTDBY ?
                JNZ     NEXT_13                 ;TRY NEXT FUNCTION..

;THE DISABLE GLOBAL_STDBY FUNCTION  DETAILS ARE AS FOLLOWS..
;AH = 08H FUNCTION CODE FOR DISABLE_GSTDBY  FUNCTION.
;THE ROUTINE RETURNS AX = 0 AND CY FLAG = 0 IN CASE OF NO ERRORS.

                CALL NEAR PTR DISBL_GLOBAL_STDBY
NEXT_13 :
                CMP     AH,ENABLE_STANDBY       ;IS IT ENABLE GSTDBY ?
                JNZ     NEXT_15                 ;TRY NEXT FUNCTION..

;THE ENABLE GLOBAL_STDBY FUNCTION  DETAILS ARE AS FOLLOWS..
;AH = 09H FUNCTION CODE FOR ENABLE_GSTDBY  FUNCTION.
;THE ROUTINE RETURNS AX = 0 AND CY FLAG = 0 IN CASE OF NO ERRORS.

                CALL NEAR PTR ENBL_GLOBAL_STDBY

NEXT_15 :
                CMP     AH,READ_STEPDOWN        ;IS IT READ LSTDBY TMR ?
                JNZ     NEXT_16                 ;TRY NEXT FUNCTION..

;THE READ STEP DOWN FUNCTION READS THE TIMER VALUE (LOCAL STANDBY) OF
;THE APPROPRIATE DEVICE SPECIFIED IN BH REGISTER..
;AH = 11H FUNCTION CODE FOR READ_STEPDOWN  FUNCTION.
;BH = DEVICE CODE = 41H = "A" = FLOPPY , 42H = "B" = HDD
;BH = DEVICE CODE = 43H = "C" = BACKLIGHT , 44H = "D" = LCD
;IT MAY BE NOTED THAT IN OUR EXAMPLE OF DAVID BOARD MANAGEMENT THE
;DEVICES LCD AND BACKLIGHT ARE TREATED ALIKE.
;THE ROUTINE RETURNS AX = 0 AND CY FLAG = 0 IN CASE OF NO ERRORS.
;BL = RETURN VALUE = THE DEVICE PRESENT CODED POWER LEVEL , AS DEFINED BELOW.
;BL = 01 IF THE DEVICE IS OFF AND IT'S TIMER IS OFF.
;BL = 00 IF THE DEVICE IS ON AND IT'S TIMER IS OFF.
;BL = 03 IF THE DEVICE IS OFF AND IT'S TIMER IS ON.
;BL = 02 IF THE DEVICE IS ON AND IT'S TIMER IS ON.

                CALL NEAR PTR READ_LSTDBY_TMR
NEXT_16 :
                CMP     AH,LOAD_STEPDOWN        ;IS IT LOAD LSTDBY TIMER ?
                JNZ     NEXT_17                 ;TRY NEXT FUNCTION..

;THE LOAD STEP DOWN FUNCTION LOADS THE TIMER VALUE (LOCAL STANDBY) OF
;THE APPROPRIATE DEVICE SPECIFIED IN BH REGISTER..
;AH = 12H FUNCTION CODE FOR LOAD_STEPDOWN  FUNCTION.
;BH = DEVICE CODE = 41H = "A" = FLOPPY , 42H = "B" = HDD
;BH = DEVICE CODE = 43H = "C" = BACKLIGHT , 44H = "D" = LCD
;IT MAY BE NOTED THAT IN OUR EXAMPLE OF DAVID BOARD MANAGEMENT THE
;DEVICES LCD AND BACKLIGHT ARE TREATED ALIKE.
;THE ROUTINE RETURNS AX = 0 AND CY FLAG = 0 IN CASE OF NO ERRORS.

                CALL NEAR PTR LOAD_LSTDBY_TMR
NEXT_17 :
                CMP     AH,SET_DEV_PON          ;IS IT SET DEVICE POWER ?
                JNZ     NEXT_20                 ;ELSE TRY NEXT..

;THE SET_PWR_FN SETS POWER LEVEL OF THE DEVICES..
;THE APPROPRIATE DEVICE SPECIFIED IN BH REGISTER..
;AH = 13H FUNCTION CODE FOR SET POWER FUNCTION..
;BH = DEVICE CODE = 41H = "A" = FLOPPY , 42H = "B" = HDD
;BH = DEVICE CODE = 43H = "C" = BACKLIGHT , 44H = "D" = LCD
;IT MAY BE NOTED THAT IN OUR EXAMPLE OF DAVID BOARD MANAGEMENT THE
;DEVICES LCD AND BACKLIGHT ARE TREATED ALIKE.
;BL SPECIFIES THE POWER LEVEL..BL = 00 SWITCH OFF THE DEVICE..
;IF BL = 0FFH , THE ROUTINE SWITCHES ON THE DEVICE..
;THE ROUTINE RETURNS AX = 0 AND CY FLAG = 0 IN CASE OF NO ERRORS.

NEXT_20 :
                CMP     AH,ENABLE_STEP          ;IS IT ENABLE LSTDBY ?
                JNZ     NEXT_21                 ;TRY NEXT FUNCTION..

;THE ENABLE_STEP FUNCTION ENABLES THE LOCAL STANDBY FUNCTION FOR
;THE APPROPRIATE DEVICE SPECIFIED IN BH REGISTER..
;AH = 17H FUNCTION CODE FOR ENABLE LOCAL STANDBY  FUNCTION..
;BH = DEVICE CODE = 41H = "A" = FLOPPY , 42H = "B" = HDD
;BH = DEVICE CODE = 43H = "C" = BACKLIGHT , 44H = "D" = LCD
;THE ROUTINE RETURNS AX = 0 AND CY FLAG = 0 IN CASE OF NO ERRORS.

                CALL NEAR PTR ENABLE_LSTDBY
NEXT_21 :
                CMP     AH,DISABLE_STEP         ;IS IT DISABLE LSTDBY ?
                JNZ     NEXT_22                 ;THAT IS IT..EXIT NOW..

;THE DISABLE_STEP FUNCTION DISABLES THE LOCAL STANDBY FUNCTION FOR
;THE APPROPRIATE DEVICE SPECIFIED IN BH REGISTER..
;AH = 18H FUNCTION CODE FOR DISABLE LOCAL STANDBY  FUNCTION..
;BH = DEVICE CODE = 41H = "A" = FLOPPY , 42H = "B" = HDD
;BH = DEVICE CODE = 43H = "C" = BACKLIGHT , 44H = "D" = LCD
;THE ROUTINE RETURNS AX = 0 AND CY FLAG = 0 IN CASE OF NO ERRORS.

                CALL NEAR PTR DISABLE_LSTDBY
NEXT_22 :

;THIS FUNCTION IS NOT YET SUPPORTED FOR UPPER LEVEL SOFTWARE USE..

                CMP     AH,SET_MCP_CLOCK
                JNZ     NEXT_23

                CALL NEAR PTR SET_MCP_CLK
NEXT_23 :

;THIS FUNCTION IS NOT YET SUPPORTED FOR UPPER LEVEL SOFTWARE USE..

                CMP     AH,GET_MCP_CLOCK
                JNZ     NEXT_24

                CALL NEAR PTR GET_MCP_CLK
NEXT_24 :

;THIS FUNCTION IS NOT YET SUPPORTED FOR UPPER LEVEL SOFTWARE USE..

                CMP     AH,CTL_PWR_MGT
                JNZ     NEXT_25

                CALL NEAR PTR PM_ENBL_DISBL
NEXT_25 :

                ALTER_82360SL   LTRP_STS,0EFH,00H       ;SW SMI TRP RESET.
;------------------------------------------------------------------------
;WE SAVE ALL REGISTERS TO BE COMMUNICATED IN XCMOS...
;WE USE EXTENDED CMOS RAM TO PASS ON PARAMETERS.
                MOV     BX,WORD PTR [AX_VALUE]
                WRITE_XMOS      00,<BL>
                WRITE_XMOS      01,<BH>
;--------------------------------------
                MOV     BX,WORD PTR [BX_VALUE]
                WRITE_XMOS      02,<BL>
                WRITE_XMOS      03,<BH>
;--------------------------------------
                MOV     BX,WORD PTR [CX_VALUE]
                WRITE_XMOS      04,<BL>
                WRITE_XMOS      05,<BH>

                JMP     EXIT_TRP
;-----------------------------------------------------------------------
;The APM 0.9 version support module follows...The control falls here
;on an APM request from the Upper Level software..

SW_APM_REQ :

;Throw a DEBUG MESSAGE if the corresponding DEBUG flag is enabled..

   IF   APM_MES_FLAG        EQ      ENABLE	  ;IS DEBUG MESSAGE FLAG
                                                  ;ENABLED
                MOV     SI,OFFSET APM_REQ_MES
                CALL NEAR PTR DEBUG_MES
                JMP     EXIT_TRP

        ENDIF
;--------------------------------------------------------------
;First we make certain sanity checks..
;Sanity checks results will be as follows..
;No errors ..Perfectly sensible...CY = 0.
;If CY = 1 then AH will have the error code..See equate file for error 
;code values..
		call	near ptr sanity_check
		jc	no_cpu_idle_process

apm_call :
		mov	si,AX_CPU_DUMP+2
                Mov     ax,word ptr [si]
		cmp	al,CPU_IDLE_FN
		jnz	NO_CPU_IDLE_PROCESS

cpu_idle_call :
		call near ptr cpu_idle_process
		jmp	exit_trp

no_cpu_idle_process :
		mov	si,ax_cpu_dump+2
		mov	ax,word ptr [si]

		mov	si,bx_cpu_dump
		mov	bx,word ptr [si]

		mov	si,cx_cpu_dump
		mov	cx,word ptr [si]

;Now we process the remaining APM functions..Retrieve all registers...
;First lemme check for invalid calls...

		cmp	ah,APM_FN
		jz	ok6
not_ok6 :
		stc			;Caller is guilty..
		mov	ax,invalid_call
		jmp	sw_apm_exit

ok6 :
		cmp	al,Installation_Check
		jnz	next_apm_fn1
instl_chk :
		call near ptr install_apm_check
		jmp	sw_apm_exit
next_apm_fn1 :
		cmp	al,Interface_Connect
		jnz	next_apm_fn2
connect_call :
		call near ptr apm_connect_call
		jmp	sw_apm_exit
next_apm_fn2 :
		cmp	al,Interface_Disconnect
		jnz	next_apm_fn5
disconnect_call:
		call near ptr apm_disconnect_call
		jmp	sw_apm_exit
next_apm_fn5 :
;Now check for interface connection..

		cmp	byte ptr [CONNECT_FLAG],TRUE
		jz	ok_all_set

connect_error :
		mov	ax,not_connect_err
		stc
		jmp	sw_apm_exit
ok_all_set :
		cmp	al,cpu_busy
		jnz	next_apm_fn6
busy_cpu :
		call near ptr apm_cpu_busy
		jmp	sw_apm_exit
next_apm_fn6 :
		cmp	al,set_power_state
		jnz	next_apm_fn7
set_power :
		call near ptr apm_set_power
		jmp	sw_apm_exit
next_apm_fn7 :
		cmp	al,apm_cntrl
		jnz	next_apm_fn8
control_apm :
		call near ptr pm_control
		jmp	sw_apm_exit
next_apm_fn8 :
		cmp	al,default_load
		jnz	next_apm_fn9
default_param :
		call near ptr load_default_parm
		jmp	sw_apm_exit
next_apm_fn9 :
		cmp	al,get_apm_sts
		jnz	next_apm_fn10
apm_sts :
		call near ptr get_apm_status
		jmp	sw_apm_exit
next_apm_fn10 :
		cmp	al,get_apm_evnt
		jnz	no_more_apm_fns
apm_event :
		call near ptr get_apm_event
		jmp	sw_apm_exit

no_more_apm_fns :
		stc
;--------------------------------------------------------------------
SW_APM_EXIT :
		pushf
		mov	si,flag_cpu_dump
		and	word ptr [si],CARRY_CLEAR_MASK

		popf
		jnc	get_regs
		or	word ptr [si],CARRY_SET_MASK
get_regs :
		mov	si,ax_cpu_dump
                mov	word ptr [si],ax
		mov	si,bx_cpu_dump
                Mov     word ptr [si],bx
		mov	si,cx_cpu_dump
                Mov     word ptr [si],cx

		jmp	exit_trp  
;------------------------------------------------------------
;GLOBAL STANDBY PROCESSING STARTS HERE..

GSTDBY_REQ_PROCESS :

;THE GLOBAL STANDBY STATE IS ENTERED WHEN A 386 SL MACHINE IS LEFT IDLE
;FOR A PERIOD OF TIME THAT IS SPECIFIED IN GSTDBY TIMER. IN OUR EXAMPLE
;FOR DAVID BOARD IN THIS EXAMPLE WE SWITCH OFF HDD AND BACK LIGHT AND
;THEN WE STOP THE CPU CLOCK.

;---THROW A MESSAGE IF DEBUG FLAG IS ENABLED...

   IF   GSTDBY1_MES_FLAG        EQ      ENABLE  ;IS DEBUG MESSAGE FLAG
                                                ;ENABLED
                MOV     SI,OFFSET GSTDBY_MESB
                CALL NEAR PTR DEBUG_MES
                JMP     SKIP_LCD2               ;ELSE YOU WILL NEVER SEE IT.
        ENDIF
;--------------------------------------------------------------
;APM Support is provided here...

		mov	al,StdbyRequest
		call near ptr apm_event_process
		jc	noapmGstdby
		jmp	EXIT_SMI

NOAPMGstdby:

;Now reset the global standby request..Write bits is the correct way
;to reset the status bits. Please see BIOS NEWS LETTER for details..

		write_82360sl	SM_REQ_STS,5bh

;NOW WE START PUTTING DEVICES TO STAND BY MODE....

;PUT THE HARD DISK TO STANDBY.

;FIND OUT IF HARD DISK IS ALREADY IN LOACL STAND BY...

;I am going to comment this portion for APM demo..But this costs us
;in system power..I guess the bug is in either in HDD or in our
;HDD driver..Well we'll see that later...


;               CMP     BYTE PTR [DEV3_LSTDBY_STAT],OFF
;               JZ      SKIP_HDD3
;---------------------------------------------------------------
;MASK OFF HDD AS AN INTERRUPT..
                IN      AL,21H

;SAVE IT FOR LATER USE..
                MOV     BYTE PTR [MASTER_OLD_MASK],AL

                OR      AL,04H          ;SLAVE I/P MASKED..
                JMP     $+2
                JMP     $+2
                OUT     21H,AL
;----------------------------------
                IN      AL,0A1H

;SAVE IT FOR LATER USE...
                MOV     BYTE PTR [SLAVE_OLD_MASK],AL

                OR      AL,40H          ;IRQ 14 MASKED..
                JMP     $+2
                JMP     $+2
                OUT     0A1H,AL
;--------------------------------------------------------------
;Note : There are some subtle points in putting HDD to standby because of the
;       A - STEP 82360 SL bug in stop break events..Please see ERRATA # 15
;       for a complete description.
;       But this is what happens when you try to put the HDD to software
;       commanded standby. The GO TO STANDBY command to HDD will generate
;       a task completion interrupt and this interrupt is blocked from
;       being serviced as we are in System Management Mode. So this pending
;       Hardware interrupt will render the STOP BREAK EVENTS to mis-behave as
;       described in the errata # 15.

;       So we avoid this situation as follows..We take out HDD as stop break
;       event before stopping the clock and we enable it just before exit.
;       Also before enabling it we service the HDD interrupt..This is
;       done by reading the status register at 1F7H.
;----------------------------------------------------------------
                READ_82360SL    STP_BRK_CFG1
                AND     AL,0BFH                 ;HDD SNATCHED AWAY..
                MOV     BL,AL
                WRITE_82360SL   STP_BRK_CFG1,<BL>

                READ_82360SL    SYS_EVNT_CFG1
                AND     AL,0BFH                 ;HDD SNATCHED AWAY..
                MOV     BL,AL
                WRITE_82360SL   SYS_EVNT_CFG1,<BL>
;----------------------------------------------------------------
;NOW WE MANAGE THE HARD DISK..

                MOV     AL,"L"
                CALL NEAR PTR MANAGE_LOCAL_3
                MOV     BYTE PTR [DEV3_LSTDBY_STAT],OFF

SKIP_HDD3 :

;PUT THE BACKLIGHT INTO STANDBY...

                CMP     BYTE PTR [DEV1_LSTDBY_STAT],OFF
                JZ      SKIP_BACKLIGHT1

                MOV     AL,"L"
                CALL NEAR PTR MANAGE_LOCAL_1
                MOV     BYTE PTR [DEV1_LSTDBY_STAT],OFF

SKIP_BACKLIGHT1 :
                CMP     BYTE PTR [DEV2_LSTDBY_STAT],OFF
                JZ      SKIP_LCD2

                MOV     AL,"L"
                CALL NEAR PTR MANAGE_LOCAL_2
                MOV     BYTE PTR [DEV2_LSTDBY_STAT],OFF
SKIP_LCD2 :

;-----------------------------------------------------
;WE SET THE SYSTEM IN STANDBY BIT TO INDICATE THE SYSTEM IS
;IN STAND BY.THIS ENABLES AUTO POWER OFF TIMER...
;This disables the SUSPEND-RESUME button but enables the AUTO_POWER_OFF
;timer in the A-STEP. This bug is only in A-STEP. The B -STEP silicon
;will not disable the button at any instant of time..So it is obvious
;that in A - STEP , when you are in GLOBAL STANDBY , you can either
;use AUTO POWER OFF feature or you can use the button to go to SUSPEND.
;But you can never use both together..THIS WILL BE FIXED IN B - STEP...


   IF   AUTO_OFF_FEATURE        EQ      ENABLE

;---------------------------------------------
;WE DISABLE SYSTEM EVENTS...This is very important ...because otherwise
;because of A-step bug the auto power off may fail to work otherwise..

		ALTER_82360SL	SYS_EVNT_CFG2,0FEH,00H
;------------------------------------------------
;If auto power off feature is enabled , then we will set the system
;in stand by bit so that auto power off timer can time out..

                ALTER_82360SL   APWR_TMRH,0FFH,80H
                ALTER_82360SL   SM_REQ_STS,0FFH,80H
		ALTER_82360SL	STP_BRK_CFG2,0FFH,80H

        ENDIF

;NOW ALL OF OUR DEVICES ARE IN STANDBY SO STOP THE CLOCK...
;WE THROW IN A POST CODE TO PORT 80H TO INDICATE THAT WE ARE
;GOING TO STOP THE CLOCK TO CPU CORE.IF EVERYTHING IS OK THEN SOFTWARE
;WILL FREEZE AT THIS POINT AND YOU WILL SEE 0aaH ON post card port. THE
;MACHINE WAITS FOR THE STOP BREAK EVENT TO CONTINUE PROCESSING.

                MOV     AL,0AAH
                OUT     80H,AL
;-----------------------------------------------
                DB      10H DUP (90H)           ;16 NO OPS...

                READ_82360SL     STP_CLK   ;STOP CLOCK..NEVER DID THAT BEFORE.
                                           ;IS NOT THAT FUNNY...

                DB      10H DUP (90H)           ;16 NO OPS...
;-------------------------------------------------------------
;RESET SYS_IN_STDBY BIT IF AUTOMATIC RESET IS NOT WORKING...

                ALTER_82360SL   SM_REQ_STS,07FH,00H
	
;---------------------------------------------------------------
;WE RE-ENABLE SYSTEM EVENTS...

		ALTER_82360SL	SYS_EVNT_CFG2,0FFH,01H

;------------------------------------------------
;This HDD wake up  is  for APM demo...I may remove it later...
;HDD wake up stuff...

;-----HDD WAKE UP STUFF HERE...
	MOV	AL,0E1H
	MOV	DX,1F7H
	OUT	DX,AL
;-------------------------------------------------------------
;THE SOFTWARE REACHES THIS POINT WHEN AN OCCURANCE OF STOP BREAK
;EVENTS BREAKS THE STOP CLOCK MODE AND RELEASES THE CPU TO TICK FURTHER..
;TO SIGNIFY THAT STOP BREAK EVENT OCCURED AND CPU HAS STARTED TICKING AGAIN
;WE THROW 55H AS THE POST CODE TO THE POST PORT..ALL THIS TO AID GUYS
;WHO ARE DEBUGGING THE SYSTEM MANAGEMENT MODE WITH OUT AN ICE..

                MOV     AL,55H
                OUT     80H,AL
;--------------------------------------------------------------
;It is now apparent that putting HDD to standby has caused an interrupt
;We need to service it first before we enable HDD as system events
;and stop break events otherwise the BUG will show up...
;Servicing the interrupt is done by reading the STATUS port of HDD..

                CALL NEAR PTR SMALL_DELAY
                MOV     DX,1F7H
                IN      AL,DX
                CALL NEAR PTR SMALL_DELAY
;--------------------------------------------------------------------
;---THROW A MESSAGE IF DEBUG FLAG IS ENABLED...

   IF   GSTDBY2_MES_FLAG        EQ      ENABLE  ;IS DEBUG MESSAGE FLAG
                                                ;ENABLED
                MOV     SI,OFFSET GSTDBY_MESE
                CALL NEAR PTR DEBUG_MES
        ENDIF
;-------------------------------------------------------------
;We now bring up HDD interrupt as a stop break event and system events..
;Ofcourse we have to consider , what user had chosen initially...

                READ_82360SL    STP_BRK_CFG1
                OR      AL,40H                  ;HDD AS STP_BRK ALIVE AGAIN..
                MOV     BL,AL
                AND     BL,STOP_BREAK_MASK2     ;DID USER REALLY WANT THIS ?
                WRITE_82360SL   STP_BRK_CFG1,<BL>

                READ_82360SL    SYS_EVNT_CFG1
                OR      AL,40H                  ;HDD AS SYS_EVNT ALIVE AGAIN..
                MOV     BL,AL
                AND     BL,SYS_EVNT_MASK2       ;DID USER REALLY WANT THIS ?
                WRITE_82360SL   SYS_EVNT_CFG1,<BL>
;-----------------------------------------------------------------
;PROGRAM THE MASTER WITH IT'S OLD MASK...

                MOV     AL,BYTE PTR [MASTER_OLD_MASK]
                OUT     21H,AL
;----------------------------------
;PROGRAM THE SLAVE WITH IT'S OLD MASK...

                MOV     AL,BYTE PTR [SLAVE_OLD_MASK]
                OUT     0A1H,AL
;-----------------------------------------------------------------
;WE RESET THE GLOBAL STANDBY REQUEST BIT AND ALSO SYS_IN_STDBY BIT....

                ALTER_82360SL   SM_REQ_STS,7BH,00
;------------------------------------------------------------------
; AUTO POWER OFF TIMER TIME OUT  IS A SUSPEND EVENT AND A SUSPEND EVENT IS
; CONFIGURED AS A STOP BREAK EVENT IN OUR EXAMPLE. AS A RESULT THERE ARE
; TWO WELL DEFINED LOGICAL PATHS THE PROGRAM CAN TAKE AT THIS POINT.

; < 1 > A STOP BREAK EVENT LIKE A KEY PRESS ETC..( ANY STOP BREAK EVENT
; OTHER THAN A SUSPEND EVENT) HAS STARTED THE CLOCK. IN THIS CASE THE SYSTEM
; HAS TO WAKE UP AND GO TO FULL ON STATE...SO IT MOVES UP IN POWER LEVEL.

; < 2 > A SUSPEND EVENT HAS CAUSED A STOP BREAK EVENT AND HENCE CLOCK
; IS RE-STARTED (LIKE AUTO POWER OFF TIMER). IN THIS CASE THE SYSTEM
; HAS TO SINK TO SUSPEND , WHICH A LOWER POWER STATE THAN GLOBAL STANDBY.
; SO , MACHINE MOVES (IN THIS CASE) TO A LOWER POWER STATE.

;WE CAN DECIDE THIS BY READING SM_REQ_STS REGISTER.

                READ_82360SL    SM_REQ_STS
                TEST            AL,HW_SUSREQ
                JZ              NO_AUTO_POWEROFF

AUTO_POWEROFF :

;SO WE JUMP TO THE SUSPEND MODULE WHICH PROCESSES IT..

                JMP             HW_SUSREQ_PROCESS
;------------------------------------------------------------
NO_AUTO_POWEROFF :

                JMP     EXIT_SMI
;-------------------------------------------------------------------
EXT_SMI_PROCESS :
;CONTROL FALLS HERE , WHEN AN EXTERNAL SMI SIGNAL IS ASSRTED. BUT THERE
;MUST BE EXTERNAL HARDWARE (LIKE A PUSH BUTTON MAY BE ) TO ASSERT THIS
;SIGNAL..THE PROCESSING TO BE DONE IN THIS MODULE DEPENDS ON WHO AND WHAT
;ASSERTS THIS SIGNAL..IN THE PRESENT EXAMPLE WE FLASH A MESSAGE IF THE
;CORRESPONDING MESSAGE FLAG IS ENABLED AND WE EXIT TO THE APPLICATION..
;------------------------------------------------------------------
;---THROW A MESSAGE IF DEBUG FLAG IS ENABLED...

   IF   EXT_SMI_MES_FLAG        EQ      ENABLE  ;IS DEBUG MESSAGE FLAG
                                                ;ENABLED
                MOV     SI,OFFSET EXT_SMI_MES
                CALL NEAR PTR DEBUG_MES
        ENDIF
;------------------------------------------------------------
;WE CLEAR THE EXT_SMI REQUEST AND EXIT ..

                ALTER_82360SL   SM_REQ_STS,0BFH,00
                JMP     EXIT_SMI
;--------------------------------------------------------
;SUSPEND PROCESSING MODULE FOLLOWS..WE PUT THE MACHINE TO LOWEST POWER
;SUSPEND MODE HERE...

HW_SUSREQ_PROCESS :
                                                                                               
;FIRST WE NEED TO SAVE THE REGISTERS THAT ARE NOT SAVED BY THE SMI MICRO-CODE
;AUTOMATICALLY..THE REASON FOR THIS IS THAT THE ONLY WAY TO GET OUT OF
;SUSPEND STATE IS THROUGH RESUME RESET AND  AND A RESET WILL CLEAR THESE
;REGISTERS..

                MOV     EAX,CR2
                MOV     DWORD PTR [CR2_VALUE],EAX
                MOV     EAX,DR0
                MOV     DWORD PTR [DR0_VALUE],EAX
                MOV     EAX,DR1
                MOV     DWORD PTR [DR1_VALUE],EAX
                MOV     EAX,DR2
                MOV     DWORD PTR [DR2_VALUE],EAX
                MOV     EAX,DR3
                MOV     DWORD PTR [DR3_VALUE],EAX
                MOV     EAX,TR6
                MOV     DWORD PTR [TR6_VALUE],EAX
                MOV     EAX,TR7
                MOV     DWORD PTR [TR7_VALUE],EAX
;--------------------------------------------------------------------
;--PROCESSING HW_SUS_REQ.WE FIRST NOTE DOWN THE SOURCE.

                READ_82360SL   SPND_STS         ; READ SUSPEND STATUS.

;IN OUR EXAMPLE THE AUTO POWER OFF REQUEST IS PROCESSED WITHIN THE
;GLOBAL STANDBY MODULE ..SO WE WILL NOT GET AN SMI FOR AN AUTO POWER OFF
;TIME OUT...BUT THE FOLLOWING CODE LINES ARE ADDED FOR COMPLETENESS..

                TEST    AL,APWR_OFF_SUSREQ      ;IS IT AUTO POWWER OFF ?
                JZ      NEXT_SUS_SOURCE1        ;TRY FOR NEXT SOURCE..

APWR_OFF :
                ALTER_82360SL   SPND_STS,0FEH,00H
                MOV     BYTE PTR [SUS_REQ_FLAG],APWR_OFF_SUSREQ

                mov     byte Ptr [APMEventSave],SUSPENDREQUEST

NEXT_SUS_SOURCE1 :

;IT MAY BE NOTED THAT PRESENT INTEL BOARDS DO NOT HAVE A BATT LOW DETECTION
;CIRCUIT. BUT THE CODE IS ADDED HERE FOR COMPLETENESS..

                TEST    AL,BATT_LOW_SUSREQ      ; IS BATTERY LOW ?
                JZ      NEXT_SUS_SOURCE2        ; TRY NEXT SOURCE..
BATT_LOW :

                ALTER_82360SL   SPND_STS,0FDH,00H
                MOV     BYTE PTR [SUS_REQ_FLAG],BATT_LOW_SUSREQ
;----------------------------------------------------------------------
;APM Modifications Spec Version 0.9

;APM modifications follow...If BATT_LOW gets asserted onto 360SL then 
;the control will come to this point and according to APM spec we do 
;have to post this SUSPEND EVENT to upper level and get it's consent .
;But if the upper level does not return concurrence with-in a preset
;time the APM spec allows us to put the SL to SUSPEND. But we will inform
;the upper level of a CRITICAL RESUME  when we bring up the SYSTEM on
;a resume event...

;We program the SW SMI timer to allow the user defined time interval..
;Since the resolution of 1 msec..We may have to reprogram it several
;times before we get the user defined time delay...

;First we check if we are connected yet with Operating System...

		mov	byte ptr [APMEventSave],batt_low_notify
		cmp	byte ptr [CONNECT_FLAG],TRUE
		jnz	dosuspend

		mov	byte ptr [critical_event_flag],FALSE
                mov     byte Ptr APMEventSave,BATT_LOW_NOTIFY

		alter_82360sl	RESUME_MASK,0FEh,01h	;Disable Batt_low.

;KILL HW REQUEST...SO THAT IT WOULD NOT HAUNT THE SYSTEM.
;CLEARING INDIVIDUAL AND GROUP REQ BITS WILL NOT CLEARING THE SUSPEND
;PMI REQ. IT HAUNTS YOUR SYSTEM.THE ONLY WAY  TO KILL IT IS TO
;REMOVE THE GROUP ENABLE AND RE-INSTATE IT..
;--------------------------------------------------------------
;SO WE RESET HW_SUS_ENABLE..

                ALTER_82360SL   SM_REQ_CNTRL,0FDH,00

                CALL NEAR PTR SMALL_DELAY
                CALL NEAR PTR SMALL_DELAY

;NOW WE RE-INSTATE THE  HW_SUS_ENABLE..

                ALTER_82360SL   SM_REQ_CNTRL,0FFH,02H
;---------------------------------------------------------------------

		mov	byte ptr [SW_SMI_FLAG],FALSE

		alter_82360sl	RESUME_MASK,0FEh,01h	;Disable Batt_low.

		mov	cx,Critical_Suspend_Delay
		call	near ptr SW_SMI_DELAY

;Control comes here after the Operating System is given the allowance
;pre-defined time. In case the OS authorizes  with in this time then
;the machine will go into SUSPEND and our RESUME routine will wash away
;all requests...

		mov	byte ptr [critical_event_flag],TRUE
		jmp	dosuspend

NEXT_SUS_SOURCE2 :
                TEST    AL,SRBTN_SUSREQ         ;IS IT S/R BUTTON ?
                JZ      NO_MORE_REQ             ;THIS IS THE LAST REQUEST.
SRBTN :

                ALTER_82360SL   SPND_STS,0FBH,00H
                MOV     BYTE PTR [SUS_REQ_FLAG],SRBTN_SUSREQ

NO_MORE_REQ :
                CMP     BYTE PTR [SUS_REQ_FLAG],00  ;IS IT A SPURIOUS REQ ?
                JNZ     SUSPEND_START

;PSEUDO REQUEST ...ALERT THE USER.
                MOV     SI,OFFSET UNKNOWN_SUS_MES
                CALL NEAR PTR DEBUG_MES
                JMP     EXIT_SMI
;------------------------------------------------------------
SUSPEND_START :
;APM Support must be provided here..We check for interface connection
;and if APM connection is established then we set the APMEvent save flag
;and wait for operating system authorization..

		mov	al,SuspendRequest
		call near ptr apm_event_process
		jc	dosuspend
		jmp	EXIT_SMI

DOSUSPEND:

; WE START THE SUSPEND PROCESSING..

                WRITE_82360SL   SPND_STS,00     ; CLEAR ALL SUSPEND STATUS.
                MOV     BYTE PTR [SUS_FLAG],YES

;We enable batt_low functions..
		alter_82360sl	RESUME_MASK,0FEh,00h	;Enable Batt_low.
;---------------------------------------------------------------------
;KILL HW REQUEST...SO THAT IT WOULD NOT HAUNT THE SYSTEM.
;CLEARING INDIVIDUAL AND GROUP REQ BITS WILL NOT CLEARING THE SUSPEND
;PMI REQ. IT HAUNTS YOUR SYSTEM.THE ONLY WAY  TO KILL IT IS TO
;REMOVE THE GROUP ENABLE AND RE-INSTATE IT..
;--------------------------------------------------------------
;SO WE RESET HW_SUS_ENABLE..

                ALTER_82360SL   SM_REQ_CNTRL,0FDH,00

                CALL NEAR PTR SMALL_DELAY
                CALL NEAR PTR SMALL_DELAY

;NOW WE RE-INSTATE THE  HW_SUS_ENABLE..

                ALTER_82360SL   SM_REQ_CNTRL,0FFH,02H
;---------------------------------------------------------------------
;WE WILL BE SAVING THE PERIPHERAL STATUS AND WILL BE WRITING TO PERIPHERAL
;IO ADDRESSES..SO IN ORDER TO AVOID PENDING SMI'S DUE TO TRAPS AND TIMER
;TIME OUTS WE DISABLE THEM IN SM_REQ_CNTRL REGISTER..

;STEP -1 : WE DISABLE ALL THE POWER MANAGEMENT BUT FOR SUS / RES.

                READ_82360SL    SM_REQ_CNTRL
                MOV     BYTE PTR [PM_ENABLE_BYTE],AL
                ALTER_82360SL   SM_REQ_CNTRL,00H,82H    ;ONLY SUS / RES..
NEXT_SUS_PROC :

;WE FIRST SAVE THE SHUTDOWN BYTE OF THE UPPER LEVEL SOFTWARE.
;WE READ THE SHUTDOWN BYTE FROM CMOS RAM.
;NOTE : READING CMOS RAM ACTUALLY DESTROYS THE INDEX THAT THE UPPER LEVEL
;       SOFTWARE HAD SETUP..IF IT HAS BEENINTERRUPTED FROM AN RTC CMOS RAM
;       WRITING CYCLE..SO WE DO RESTORE THE CMOS RAM INDEX BACK USING 360SL
;       SHADOW REGISTER IN THE RESUME MODULE.

                MOV     AL,SHUTDOWN_SUS_ADD
                OR      AL,80H                  ;NO NMI BIT.
                OUT     CMOSADD,AL

                JMP     $+2
                JMP     $+2
                JMP     $+2

                IN      AL,CMOSDATA             ;NEVER MESS WITH UPPER LEVEL
                                                ;SOFTWARE.
                MOV     BYTE PTR [OLD_CMOS_BYTE],AL
;--------------------------------------------------------
;WE MARK THE SUSPEND STATUS IN CMOS RAM , SO THAT BIOS ROUTINES CAN
;DETECT A RESUME RESET AND PROCESS A RESUME EVENT. WE USE THE SHUTDOWN
;BYTE FOR THIS PURPOSE AT CMOS RAM ADDRESS 0FH AND USE AN UNUSED AT CODE
;OF SHUT DOWN , WHICH FOR THIS EXAMPLE IS 0DH

                MOV     AL,SHUTDOWN_SUS_ADD
                OR      AL,80H
                OUT     CMOSADD,AL
                JMP     $+2
                JMP     $+2
                JMP     $+2
                MOV     AL,SHUTDOWN_RESUME
                OUT     CMOSDATA,AL
;----------------------------------------------------------------------
;DURING SUSPEND WE THE HARDWARE ON DAVID BOARD WILL SWITCH OFF EVERY
;PERIPHERAL USING A SIGNAL CALLED SUS_STAT. ALL WE NEED TO DO NOW IS TO
;SAVE THE STATUS OF THE DEVICE BEING SWITCHED OFF.

;DEVICE 1 : HARD DISK.
;HARD DISK : HDD WILL BE FULLY SWITCHED OFF .
;WE FIRST PUT HDD  STAND BY MODE , BEFORE WE SWITCH OFF HDD.
;THIS NOT ONLY REDUCES POWER SURGE , BUT ALSO HELPS US TO UPDATE DEVICE
;STATUS USING SAME STANDBY ROUTINES.

;PUTTING HDD TO STANDBY WILL GENERATE AN INTERRUPT 14 WHICH WE WILL
;SERVICE DURING RESUME.. THE FOLLOWING STEPS ARE INVOLVED IN BRINGING
;DOWN THE HARD DISK..
;STEP - 1 WE MASK OFF HDD INTERRUPT IN 8259 FIRST...

                IN      AL,21H
                MOV     BYTE PTR [MASTER_OLD_MASK],AL
                AND     AL,0FBH
                JMP     $+2
                JMP     $+2
;               OUT     21H,AL
;----------------------------------
                IN      AL,0A1H
                MOV     BYTE PTR [SLAVE_OLD_MASK],AL
                OR      AL,0BFH
                JMP     $+2
                JMP     $+2
;               OUT     0A1H,AL
;--------------------------------------------------------------
;NOW WE SNATCH AWAY HDD INTERRUPT AS SYSTEM AND STOP BREAK EVENTS..
;SEE GLOBAL STANDBY MODULE FOR A MORE DETAILED EXPLANATION...
;----------------------------------------------------------------
                READ_82360SL    STP_BRK_CFG1
                AND     AL,0BFH                 ;HDD SNATCHED AWAY..
                MOV     BL,AL
                WRITE_82360SL   STP_BRK_CFG1,<BL>

                READ_82360SL    SYS_EVNT_CFG1
                AND     AL,0BFH                 ;HDD SNATCHED AWAY..
                MOV     BL,AL
                WRITE_82360SL   SYS_EVNT_CFG1,<BL>

;----------------------------------------------------------------
;NOW WE MANAGE THE HARD DISK..THIS WILL GENERATE AN IRQ 14 FROM THE
;HARD DISK CONTROLLER BUT WE DON'T HAVE TO SERVICE THIS INTERRUPT
;BECAUSE WE WILL SWITCH OFF HDD ANYWAY AND THIS REQUEST WILL DIE..

                MOV     AL,"L"
                CALL NEAR PTR MANAGE_LOCAL_3
                MOV     BYTE PTR [DEV3_LSTDBY_STAT],OFF

SKIP_HDD3_S :

;VIDEO SYSTEM : THE DAVID BOARD USES A CIRRUS LOGIC - CHIPSET VIDEO CARD
;WHICH CAN NOT BE FULLY SWITCHED OFF , BECAUSE OF THE COMPLEXITY OF
;SHADOWING FULL VIDEO RAM AND VGA REGISTERS. INSTEAD WE USE THE POWER
;SAVE MODES AVAILABLE IN THE CIRRUS LOGIC CHIPSET. WE USE THE SAME STANDBY
;ROUTINES USED BY LOCAL STANDBY AND GLOBAL STANDBY PROCESS.

;DAVID VIDEO SYSTEM CAN OPERATE EITHER ON AN LCD OR ON A CRT. WE USE
;DIFFERENT ROUTINES  TO PUT THEM INTO STANDBY..

;ALSO REMEMBER THAT VGA SUBSYSTEM IS COMPOSED OFF 2 DIFFERENT DEVICES
;FOR OUR PURPOSE 1. LCD PANEL  , 2. BACK LIGHT.

                MOV     AL,"L"
                CALL NEAR PTR MANAGE_LOCAL_1
                MOV     BYTE PTR [DEV1_LSTDBY_STAT],OFF

                MOV     AL,"L"
                CALL NEAR PTR MANAGE_LOCAL_2
                MOV     BYTE PTR [DEV2_LSTDBY_STAT],OFF
;-------------------------------------------------------
                CALL NEAR PTR SMALL_DELAY
                MOV     DX,1F7H
                IN      AL,DX
                CALL NEAR PTR SMALL_DELAY
;---------------------------------------------------------------
;Key board controller will be switched off during SUSPEND. So the
;A20 gate status must be saved before we switch it off and shall be
;restored before we RESUME...This is because we may interrupt PROTECTED
;mode programs by an SMI and we have to be totally transparent to the
;the interrupted application...We do this by using the AT command set..

                IN      AL,KBC_CMD_REG

                TEST    AL,01H                  ;IS O/P BUFFER EMPTY ?
                JZ      OP_BUFF_EMPTY
;This means that something is something pending in the output buffer.
;Since we can not save it and restore it..we will destroy it..But it may be
;noted that usually the key board interface is interrupt driven..

OP_BUFF_FULL :
                IN      AL,KBC_DATA_REG

OP_BUFF_EMPTY :
                MOV     AL,READ_KBC_OP_PORT
                OUT     KBC_CMD_REG,AL

LAZY_8742 :
                JMP     $+2
                JMP     $+2
                IN      AL,KBC_CMD_REG
                JMP     $+2
                JMP     $+2
                TEST    AL,01H                  ;IS IP BUFFER FULL ?
                JNZ     LAZY_8742

                CALL    NEAR PTR SMALL_DELAY
                CALL    NEAR PTR SMALL_DELAY


KB_DATA_READY :
                IN      AL,KBC_DATA_REG
                MOV     BYTE PTR [A20_STATUS_BYTE],AL

                OUT     80H,AL

;---------------------------------------------------------------
;David board has a math co-processor which is switched off during SUSPEND
;So we need to save and restore it's contents..
;Saving 80387 status is done as follows..We wait until NPX is done..and
;then we save all it's state using FSAVE instruction..The save area
;requirement differs but can be as huge as 98 bytes..
;Note : Some assemblers insert automatic WAIT prefix unless you use "N"
;type of instruction like FNSAVE ..But for safety we insert it explicitly..

;First we check to find if MCP is present..We use equipment list byte
;present at 0:410H

                PUSH    ES
                XOR     AX,AX
                MOV     ES,AX
                TEST    BYTE PTR ES:[0410H],02H
                JZ      NO_387
PRESENT_387 :
                FWAIT
                MOV     BX,OFFSET NPX_SAVE_AREA         ;CAN BE 98 BYTES LONG.
                FSAVE   [BX]
                FWAIT
NO_387 :
                POP     ES
;---------------------------------------------------------------
;NOW HERE WE TAKE CARE OF SHADOWING..
;Note : There are some important points to be remembered when activating
;       Suspend / Resume in a system that has shadowing enabled .
;       Since we switch the SL memory controller to SUSPEND mode during
;       SUSPEND , it is obvious that memory can not be accessed until
;       you enable NORMAL_REFRESH in memory controller again. This means
;       that if the system tries to access SHADOW RAM on RESUME RESET because
;       SHADOW is enabled , the system will FAIL. So to circumvent the
;       situation we first disable EPROM SHADOW during SUSPEND and re-enable
;       it during the RESUME again...

;Step 1 : FInd out if shadow is enabled...This can be done by several ways
;        One way is to find out from SHADOW registers if they are configured
;        READ ONLY. But here in this example we do it by reading an
;        EXTENDED CMOS LOCATION = 20h.If shadow is enabled ,then bit 0
;        of this data byte is set to 1. Note : This is done by our BIOS.
;        Please see the listing of BIOS.ASM for more details..

                READ_XMOS       SYSTEM_STATUS_ADD
                TEST            AL,01H
                JZ              NO_SHADOW
SHADOW :
                UNLOCK_CPUPWRMODE

                CHANGE_REG      CPUPWRMODE,0BFF3H,000AH ;POINT TO IBU.

                CHANGE_REG      OMSECR,0000H,0000H      ;DISABLE F SEGMENT.
                CHANGE_REG      OMSFCR,0000H,0000H      ;DISABLE F SEGMENT.

                CHANGE_REG  CPUPWRMODE,0BFFCH,0100H     ;LOCK CPUPWRMODE REG.
NO_SHADOW :
;---------------------------------------------------------------
;NEXT DEVICE IS DRAM SUBSYSTEM..

;NOW WE HAVE TO PUT THE MACHINE TO SUSPEND REFRESH RATE.THE LOW REFRESH RATE
;TO WHICH WE CAN PUT THE DRAMS DEPENDS ON THE TYPE OF DRAM USED
;IN A PARTICULAR SYSTEM . FOR DAVID BOARD WE USE SUSPEND RATE = NORMAL
;RATE / 32.

;IT IS NOT NECESSARY TO PROGRAM THE SUSPEND REFRESH RATE EVERY TIME THE
;MACHINE GOES TO SUSPEND AS IT IS DONE HERE..IT CAN BE DONE IN BIOS
;DURING BOOT UP AND SL SUPERSET INITIALIZATION..

                UNLOCK_CPUPWRMODE

;FIRST WE SET THE SUSPEND REFRESH RATE BY PROGRAMMING MCRF REGISTER.

                CHANGE_REG  CPUPWRMODE,0BFF3H, 0002H    ;OPEN OMCU.

                MOV     AL,SUS_REF_FACTOR
                AND     AL,07H                  ;LAST 3 BITS VALID.
                MOV     CL,4
                SHL     AL,CL
                AND     AL,70H
                MOV     BL,AL
                CHANGE_REGB  MCRF,07H,<BL>
;---------------------------------------------------------------------
;PUT A POST CODE TO SIGNAL SUSPEND.POST CODE 94H = SYSTEM IN SUSPEND.
                MOV     AL,SUSPEND
                OUT     POST_PORT,AL
;----------------------------------------------------------------------
;THE MACHINE IS PUT TO SUSPEND BY SETTING 2 BITS SIMULTANEOUSLY IN CPU
;AND IO CHIP. THIS IS DONE BY WRITING 82H WITH 360 SL INDEX AND IBU
;SPACE OPEN TO ADDRESS 25H.
;THE STEPS TO BE FOLLOWED TO START SUSPEND STATE ARE AS FOLLOWS..
; 1. OPEN 82360 SL IF NOT ALREADY OPEN
; 2. POINT INDEX OF 82360SL TO SUS_REF = 0FFH
; 3. UNLOCK AND POINT CPUPWRMODE REGISTER TO IBU
; 4. WRITE 82H TO PORT ADDRESS 25H

;THIS WILL NOT ONLY PUT THE MEMORY CONTROLLER AND CPU TO SUSPEND REFRESH
;BUT WILL ALSO SET SUS_CMPLT BIT AUTOMATICALLY AND ENTER SUSPEND MODE.

                MOV     AL,PM_SUS_REF
                OUT     CFGINDEX,AL

                CHANGE_REG  CPUPWRMODE,0BFF3H, 000AH    ;ENABLE IBU.

                MOV     AL,82H
                OUT     SUS_REF_ENBL,AL
                HLT                             ;MEMORY CTLR OFF.
                                                ;NOTHING ELSE TO DO.
;---------------------------------------------------------------
RESUME_PROCESS :

;WE START THE RESUME EVENT  PROCESSING. CONTROL FALLS HERE AFTER AN
;INITIAL DETECTION AND PROCESSING AT THE ATPOST MODULE OF OUR INTEL
;BOARD BIOS. WE PUT A POST CODE TO SIGNAL START OF RESUME PROCESSING.
;RESUME  POST CODE 9AH = RESUME PROCESS IN SM RAM STARTED.

                MOV     AL,RESUME
                OUT     POST_PORT,AL

;These are APM modifications to allow critical RESUME EVENT notification..

		cmp	byte ptr [ critical_event_flag ], TRUE
		jnz	usual_resume

critical_resume :
		mov	byte ptr [critical_event_flag ],FALSE
                mov     al,resume_critical_notify
                mov     byte ptr [APMEventSave],al
                WRITE_XMOS 124D,1
		jmp	rsm_process_begin
usual_resume :
                mov     al,resume_normal_notify
                mov     byte ptr [APMEventSave],al
;---------------------------------------------------------------
rsm_process_begin :

;FIRST WE NEED TO REATORE THE ENHANCED REGISTER SET..THAT WAS CLEARED WHEN
;CPU GOT RESET..DURING RESUME PROCESS..

                MOV     EAX,DWORD PTR [CR2_VALUE]
                MOV     CR2,EAX
                MOV     EAX,DWORD PTR [DR0_VALUE]
                MOV     DR0,EAX
                MOV     EAX,DWORD PTR [DR1_VALUE]
                MOV     DR1,EAX
                MOV     EAX,DWORD PTR [DR2_VALUE]
                MOV     DR2,EAX
                MOV     EAX,DWORD PTR [DR3_VALUE]
                MOV     DR3,EAX
                MOV     EAX,DWORD PTR [TR6_VALUE]
                MOV     TR6,EAX
                MOV     EAX,DWORD PTR [TR7_VALUE]
                MOV     TR7,EAX
;------------------------------------------------------------------

NEXT_RES_PROC :

;RESUME ALWAYS TURNS ON THE SCREEN...BUT USING TRAP OFCOURSE..USING TRAP
;TO TURN OF A PARTICULAR PERIPHERAL IS ADVANTAGEOUS BECAUSE THE TRAP
;ROUTINES AUTOMATICALLY ENABLE LOCAL STANDBY ARCHITECTURE..
;SO FIRST UPDATE THE DEVICE STATUS..
;BUT OUR SCREEN OR VGA SUBSYSTEM HAS 2 COMPONENTS WHICH ARE BACK LIGHT
;AND LCD PANEL..

                MOV     BYTE PTR [DEV1_LSTDBY_STAT],ON
                MOV     BYTE PTR [DEV2_LSTDBY_STAT],ON

                MOV     AL,'T'
                CALL NEAR PTR MANAGE_LOCAL_1

                MOV     AL,'T'
                CALL NEAR PTR MANAGE_LOCAL_2
;--------------------------------------------------------------------
;NOW WE TAKE CARE OF HDD. HDD WOULD HAVE BEEN SWITCHED ON BY HARDWARE
;WHEN SUS_STAT GOES INACTIVE , BUT WE CAN LEAVE IT IN THE OFF MODE..
;BUT TO MAKE SURE THAT IT IS IN STANDBY MODE AFTER A TOTAL Vcc OFF AND
;Vcc ON ..WE WILL PUT IT TO STANDBY AGAIN...WE HAVE ALREADY DISABLED
;INTERRUPT 14..SO WE CAN JUST FLASH THE STANDBY COMMAND..

;               CMP     BYTE PTR [DEV3_LSTDBY_STAT],OFF
;               JZ      SKIP_DEV1_ON1

;               MOV     AL,"L"
;               CALL NEAR PTR MANAGE_LOCAL_3
;               MOV     BYTE PTR [DEV3_LSTDBY_STAT],OFF

;NOW WE HAVE TO CONSUME THE INTERRUPT OFCOURSE...
;--------------------------------------------------------------
;We need to service it first before we enable HDD as system events
;and stop break events otherwise the BUG will show up...
;Servicing the interrupt is done by reading the STATUS port of HDD..


                MOV     DX,01F7H
                MOV     AL,0E1H
                OUT     DX,AL


OK_HDD_GO :
;-------------------------------------------------------------
;We now bring up HDD interrupt as a stop break event and system events..
;Ofcourse we have to consider , what user had chosen initially...

                READ_82360SL    STP_BRK_CFG1
                OR      AL,40H                  ;HDD AS STP_BRK ALIVE AGAIN..
                MOV     BL,AL
                AND     BL,STOP_BREAK_MASK2     ;DID USER REALLY WANT THIS ?
                WRITE_82360SL   STP_BRK_CFG1,<BL>

                READ_82360SL    SYS_EVNT_CFG1
                OR      AL,40H                  ;HDD AS SYS_EVNT ALIVE AGAIN..
                MOV     BL,AL
                AND     BL,SYS_EVNT_MASK2       ;DID USER REALLY WANT THIS ?
                WRITE_82360SL   SYS_EVNT_CFG1,<BL>

;-----------------------------------------------------------------
;PROGRAM THE MASTER WITH IT'S OLD MASK...

                MOV     AL,BYTE PTR [MASTER_OLD_MASK]
;               OUT     21H,AL
;----------------------------------
;PROGRAM THE SLAVE WITH IT'S OLD MASK...

                MOV     AL,BYTE PTR [SLAVE_OLD_MASK]
;               OUT     0A1H,AL

SKIP_DEV1_ON1 :
;---------------------------------------------------------------
;David board has a math co-processor which is switched off during SUSPEND
;So we need to  restore it's contents..before we resume..
;We first do an FINIT , which is a like a HARDWARE reset to NPX and it
;brings it up to a known state and then we use the FRSTOR to restore the
;NPX back to it's original condition...
;The save area was dumped during SUSPEND by FSAVE instruction..Save area
;requirement differs but can be as huge as 98 bytes..
;Note : Some assemblers insert automatic WAIT prefix unless you use "N"
;type of instruction like FNSAVE ..But for safety we insert it explicitly..

;First we check to find if MCP is present..We use equipment list byte
;present at 0:410H
                PUSH    ES
                XOR     AX,AX
                MOV     ES,AX
                TEST    BYTE PTR ES:[0410H],02H
                JZ      NO_387_R
PRESENT_387_R :
                FINIT
                FWAIT                                   ;MAY BE REDUNDANT
                MOV     BX,OFFSET NPX_SAVE_AREA         ;CAN BE 98 BYTES LONG.
                FRSTOR  [BX]
                FWAIT
NO_387_R :
                POP     ES
;---------------------------------------------------------------
;Key board controller was switched off during SUSPEND. So the
;A20 gate status was saved before we switched it off and shall be now
;restored before we RESUME...This is because we may interrupt PROTECTED
;mode programs by an SMI and we have to be totally transparent to the
;the interrupted application...We do this by using the AT command set..

OP_BUFF_EMPTY_R :
                MOV     AL,WRITE_KBC_OP_PORT
                OUT     KBC_CMD_REG,AL

LAZY_8742_R :
                JMP     $+2
                JMP     $+2
                IN      AL,KBC_CMD_REG
                JMP     $+2
                JMP     $+2
                TEST    AL,01H                  ;WAS CMD ACCEPTED ???
                JNZ     LAZY_8742_R
KB_DATA_OP :
                MOV     AL,BYTE PTR [A20_STATUS_BYTE]
                OUT     KBC_DATA_REG,AL
;-------------------------------------------------------------------
;WE RESTORE THE OLD CMOS SHUT DOWN BYTE OF THE APPLICATION BACK TO CMOS RAM.

                MOV     AL,SHUTDOWN_SUS_ADD
                OR      AL,80H                  ;NO NMI PLEASE.
                OUT     CMOSADD,AL

                JMP     $+2
                JMP     $+2
                JMP     $+2

                MOV     AL,BYTE PTR [OLD_CMOS_BYTE]
                OUT     CMOSDATA,AL
;------------------------------------------------------------------
END_RES_PROCESS :
                MOV     BYTE PTR [SUS_FLAG],NO          ;CLEAR SUS_FLAG.
;------------------------------------------------------------------
;WE WILL HAVE TO CLEAR THE GROUP ENABLE  BIT TO CLEAR THE PRESENT
;HW_SUSPEND REQUEST..THIS WILL CLEAR ANY OTHER PENDING SUSPEND REQUESTS
;BUT SINCE WE DO NOT HAVE TO WORRY ABOUT BATT_LOW NOW , BECAUSE MACHINE
;WILL AGAIN SIGNAL SUSPEND AS SOON AS YOU RESUME..WE TOGGLE THE ENABLE
;ONCE TO CLEAR THE REQUEST..
;--------------------------------------------------------------

                MOV     BYTE PTR [SUS_FLAG],NO          ;CLEAR SUS_FLAG.

;------------------------------------------------------------
;KILL HW REQUEST...SO THAT IT WOULD NOT HAUNT THE SYSTEM.
;CLEARING INDIVIDUAL AND GROUP REQ BITS WILL NOT CLEARING THE SUSPEND
;PMI REQ. IT HAUNTS YOUR SYSTEM.THE ONLY WAY  TO KILL IT IS TO
;REMOVE THE GROUP ENABLE AND RE-INSTATE IT..

;--------------------------------------------------------------
;SO WE RESET HW_SUS_ENABLE..

                ALTER_82360SL   SM_REQ_CNTRL,0FDH,00

                CALL NEAR PTR SMALL_DELAY
                CALL NEAR PTR SMALL_DELAY

;NOW WE RE-INSTATE THE  HW_SUS_ENABLE..

                ALTER_82360SL   SM_REQ_CNTRL,0FFH,02H

;------------------------------------------------------
;THROW A POST CODE TO SIGNIFY THE END OF RESUME PROCESS..

                MOV     AL,9CH
                OUT     80H,AL
;-------------------------------------------------------------

;STEP -2 : WE ENABLE ALL THE POWER MANAGEMENT ..

                XOR     BX,BX
                MOV     BL,BYTE PTR [PM_ENABLE_BYTE]

                ALTER_82360SL   SM_REQ_CNTRL,0FFH,<BL>

                JMP     EXIT_SMI
;-------------------------------------------------------------------

; + + + + + + + + + + + + + + + + + + + + + + + + + + + + + +

; SUBROUTINES FOR THE MODULES FOLLOW...

;---------------------------------------------------------------------
;ROUTINE CLEAR_SCREEN FOLLOWS...IT CLEARS THE SCREEN BY WRITING TO
;VIDEO MEMORY DIRECTLY.DESTROYS DX , SI,DI,AX.
;WORKS ONLY IN TEXT MODE. THE ROUTINE IS MAINLY USED FOR CLEARING THE
;SCREEN BEFORE WE PUT A DIAGNOSTIC MESSAGE.
;----------------------------------------------------------------------
CLEAR_SCREEN    PROC    NEAR

                PUSH    AX
                PUSH    BX
                PUSH    CX
                PUSH    DX
                PUSH    DS
;-------------------------------
                MOV     CX,2000         ;WRITE 80 x 25 CHARACTERS..
                XOR     DI,DI
                MOV     AX,VIDEO_SEG
                MOV     DS,AX
CLEAR_STILL :
                MOV     BYTE PTR [DI],20H
                INC     DI
                INC     DI
                DEC     CX
                JNZ SHORT       CLEAR_STILL
;----------------------------------
                POP     DS
                POP     DX
                POP     CX
                POP     BX
                POP     AX
                RET

CLEAR_SCREEN    ENDP
;-------------------------------------------------------
;WAIT_LOOP PROCEDURE FOLLOWS.SOFTWARE DRIVEN VERY LONG DELAY LOOP.
;WAITS FOR A WHILE , APPROX 5 SEC FOR A 20 MHZ DAVID ..
;SO THAT THE DAMMED PROGRAMMER CAN READ THE DEBUG MESSAGE..
;--------------------------------------------------------

WAIT_LOOP       PROC    NEAR
                PUSH    AX
                PUSH    CX

                MOV     AX,30
WAIT_STILL :
                MOV     CX,0FFFFH
NOT_YET :       DEC     CX
                JNZ SHORT       NOT_YET
                DEC     AX
                JNZ SHORT       WAIT_STILL
                POP     CX
                POP     AX
                RET
WAIT_LOOP       ENDP

;--------------------------------------------------------
;DEBUG_MES PROCEDURE FOLLOWS..THIS ROUTINE PUTS A MESSAGE ONTO SCREEN
;PAGE 0 WHOSE PTR IS PASSED ON IN SI.
;I/P = MESSAGE PTR IN DS:SI
;O/P = PUTS THE MESSAGE ON SCREEN AND WAITS FOR 5 SEC AND RETURNS NOTHING
;IT IS MAINLY USED BY TEST STUBS TO SHOW WHERE THE CONTROL IS.
;IT DESTROYS NONE. IT MAY BE NOTED THAT MESSAGE IS VISIBLE ONLY IN TEXT
;MODE AND ON PAGE 0. IT IS MAINLY USED WHILE DEBUGGING PM SOFTWARE.
;--------------------------------------------------------------------------
DEBUG_MES       PROC    NEAR
                PUSH    AX
                PUSH    SI
                PUSH    DI
                PUSH    ES
                CALL NEAR PTR CLEAR_SCREEN
;-------------------
                XOR     DI,DI
                MOV     AX,VIDEO_SEG
                MOV     ES,AX
VIDEO_WRITE :

                MOV     AL,BYTE PTR [SI]
                CMP     AL,00
                JZ SHORT        MESSAGE_OVER
                INC     SI
                MOV     BYTE PTR ES:[DI],AL
                ADD     DI,2
                JMP SHORT       VIDEO_WRITE

MESSAGE_OVER :

                CALL NEAR PTR WAIT_LOOP
                POP     ES
                POP     DI
                POP     SI
                POP     AX
                RET
DEBUG_MES       ENDP
;--------------------------------------------------------
;ROUTINE SMALL_DELAY FOLLOWS..
;PROVIDES A SMALL DELAY FOR SUCH THINGS AS BACK TO BACK IO READS OR
;SILICON RECOVERY TIMES...ETC
;---------------------------------------------------------
SMALL_DELAY     PROC    NEAR
                PUSH    CX
                MOV     CX,SMALL_DELAY_BYTE
KILL_TIME :
                DEC     CX
                JNZ     KILL_TIME
                POP     CX
                RET
SMALL_DELAY     ENDP
;---------------------------------------------------------------------
;PROCEDURE PANEL_ON_OFF FOLLOWS..
;PLAYS WITH LCD PANEL..THIS ROUTINE WAS SPECIFICALLY WRIITEN FOR INTEL
;DEMO SYSTEM WHICH USES A CIRRUS LCD VGA GRAPHICS CARD.USUALLY LCD CARDS
;USE FEATURE CONTROL BITS PROVIDED BY THE VGA INTERFACE TO CONTROL SOME
;SPECIAL FEATURES THAT ARE UNIQUE TO THE PARTICULAR CARD.HERE ON THIS
;CIRRUS CARD BY SETTING AND RESETTING THESE BITS WE CAN SWITCH ON AND
;SWITCH OFF BACK LIGHT AND THIS SAVES LOT OF POWER...

;I/P AX = 0 FOR SWITCHING OFF BACK LIGHT..
;I/P AX = 1 FOR SWITCHING ON BACK LIGHT..
;------------------------------------------------------------------
PANEL_ON_OFF PROC NEAR

        PUSH    AX
        PUSH    BX
        PUSH    CX
        PUSH    DX                      ;I SAVE , WHAT I DESTROY..
;-------------------------------
        MOV     CX,AX                   ;I NEED THE BITS IN AX..LATER..
        MOV     DX,3C4H
        MOV     AX,0084H                ;MAKE IT READABLE AND WRITABLE..
        MOV     BH,40H                  ;FEATURE CONTROL BITS 0 AND 1 ONLY..
        CALL    VGA_REG_WRITE           ;WRITE THE VGA REGISTER..
        MOV     DX,3CAH                 ;FCNTL RAD ADDRESS..
        IN      AL,DX
        AND     AL,0FCH                 ;I NEED ONLY THESE..
        MOV     BL,AL
        MOV     AX,CX                   ;THAT IS WHERE I HAD PUT THEM..
        AND     AL,03H
        OR      AL,BL                   ;NOW I GOT IT..
        MOV     DX, 3DAH
        OUT     DX,AL
        MOV     DX,3C4H
        MOV     AX,4084H                ;I NEED READ ONLY..
        MOV     BH,40H                  ;I CARE FOR 2 BITS..
        CALL    VGA_REG_WRITE
;--------------------------------------
        POP     DX
        POP     CX
        POP     BX
        POP     AX
        RET
PANEL_ON_OFF ENDP
;---------------------------------------------------------------------------
;LCD_STANDBY ROUTINE FOLLOWS..
;THIS ROUTINE PLAYS WITH CONTROL BITS  OF CIRRUS CARD TO SAVE POWER.
;IT IS HIGHLY DEPENDANT ON THE LCD DRIVER CARD THAT IS USED IN THE SYSTEM.
;THIS ROUTINE REDUCES THE POWER CONSUMPTION OF THE VGA CARD BY CUTTING
;OF MOST OF IT'S DATA PATHS AND BY PUTTING THE VIDEO RAM INTO
;SLOW REFRESH MODE.
;IT PLAYS WITH FCNTL BITS OF VGA REGISTER SET. THIS
;ROUTINE HENCE WOULD WORK ONLY ON A DAVID OR PROTO BOARD SYSTEM.
;---------------------------------------------------------------
LCD_STANDBY     PROC    NEAR
        MOV     DX, 3C4H
        MOV     BH,80H
        CALL    VGA_REG_WRITE
        RET
LCD_STANDBY     ENDP
;---------------------------------------------------------------
;PROCEDURE VGA_REG_WRITE FOLLOWS..
;I/P TO ROUTINE ARE : DX = REGISTER ADDRESS , AL = INDEX
;AH = DATA AND BH = MASK TO BE APPLIED TO BITS..
;----------------------------------------------------------
VGA_REG_WRITE PROC NEAR

        PUSH    AX
        PUSH    BX                      ;I SAVE , WHAT I DESTROY..
;-----------------------------------------------------------
        MOV     BL,AH
        AND     BL,BH
        CLI
;NOW WE HAVE REGISTER ADDRESS IN DX AND INDEX IN AL REGIUSTER..
;SO WE READ IT..
        OUT     DX,AL
        INC     DX
        MOV     AH,AL
        IN      AL,DX
        DEC     DX
        MOV     AH,AL
        NOT     BH
        AND     AL,BH
        OR      AL,BL
        INC     DX

        OUT     DX,AL                   ; THAT IS MY NEW DATA..
        DEC     DX
        POP     BX
        POP     AX
        RET
VGA_REG_WRITE ENDP
;----------------------------------------------------------
;ROUTINE SET_CLK FOLLOWS.
;I/P TO THIS ROUTINE IS BL REGISTER VALUE STORED BX_VALUE VARIABLE.
;SETS CPU CLOCK AND RETURNS AX = 0000 AND CY FLAG = 0 IF NO ERRORS.
;DESTROYS NONE OTHER THAN AX.
;---------------------------------------------------------------------------
SET_CLK         PROC    NEAR
                PUSH    BX
                PUSH    CX
                PUSH    DX
                PUSH    SI
;--------------------------------------
                UNLOCK_CPUPWRMODE               ;WE WRITE TO CLOCK
                MOV     BX,WORD PTR [BX_VALUE]  ;CONTROL FIELD OF
                MOV     BH,0                    ;CPUPWRMODE REGISTER
                XOR     AX,AX                   ;TO CONROL THE CPU
                MOV     CX,4                    ;CLOCK FIELD..
                MOV     AX,BX
                SHL     AL,CL
                MOV     BX,AX
                CHANGE_REG    CPUPWRMODE,0FFCFH,<BX>

;TELL THE CALLER THAT THERE WAS NO ERROR..

                CLC
                XOR     AX,AX
                MOV     WORD PTR [AX_VALUE],AX
                CHANGE_REG      CPUPWRMODE,0BFFCH,0100H
;---------------------------------------
                POP     SI
                POP     DX
                POP     CX
                POP     BX
                RET
SET_CLK         ENDP
;--------------------------------------------------------------
;ROUTINE GET_CLK FOLLOWS...
;GETS CPU CLOCK AND RETURNS AX = 0000 AND CY FLAG = 0 IF NO ERRORS.
;---------------------------------------------------------------
GET_CLK         PROC    NEAR
                PUSH    BX
                PUSH    CX
                PUSH    DX
                PUSH    SI
;--------------------------------------
                UNLOCK_CPUPWRMODE
                MOV     DX,CPUPWRMODE
                IN      AX,DX                   ;CLOCK INFO IN D4,D3 BITS.
                MOV     CX,4
                SHR     AL,CL
                AND     AX,0003H                ;INFO 2 LSB ONLY..
                MOV     BYTE PTR [BX_VALUE],AL

;TELL THE CALLER THAT THERE WAS NO ERROR..

                CLC
                XOR     AX,AX
                MOV     WORD PTR [AX_VALUE],AX
                CHANGE_REG      CPUPWRMODE,0BFFCH,0100H
;---------------------------------------
                POP     SI
                POP     DX
                POP     CX
                POP     BX
                RET
GET_CLK         ENDP
;----------------------------------------------------------------
;ROUTINE SET_KEY_CLK FOLLOWS...
;SETS KEY BOARD CTLR CLOCK AND RETURNS AX = 0000 AND CY FLAG = 0 IF NO ERRORS.
;DESTROYS NONE OTHER THAN AX.
;WE WRITE INTO KEY BOARD CLOCK CONTROL REGISTER..
;ROUTINE TAKES THE DEVISOR VALUE FROM BX_VALUE VARIABLE IN RAM.
;--------------------------------------------------------------------
SET_KEY_CLK     PROC    NEAR
                PUSH    BX
                PUSH    CX
                PUSH    DX
                PUSH    SI
;--------------------------------------
                MOV     BX,WORD PTR [BX_VALUE]
                AND     BL,03H                  ;INFO IS IN 2 LSB.
                ALTER_82360SL   KC_CLK_CNTRL,0FCH,<BL>
                CLC
                XOR     AX,AX
                MOV     WORD PTR [AX_VALUE],AX
;---------------------------------------
                POP     SI
                POP     DX
                POP     CX
                POP     BX
                RET
SET_KEY_CLK     ENDP
;----------------------------------------------------------------
;ROUTINE GET_KEY_CLK FOLLOWS...
;GETS KEY BOARD CTLR CLOCK AND RETURNS AX = 0000 AND CY FLAG = 0 IF NO ERRORS.
;UPDATES THE BX REGISTER AND MEMORY VARIABLE BX_VALUE..
;DESTROYS NONE OTHER THAN AX AND BX.
;-----------------------------------------------------------------
GET_KEY_CLK     PROC    NEAR
                PUSH    BX
                PUSH    CX
                PUSH    DX
                PUSH    SI
;--------------------------------------
                READ_82360SL    KC_CLK_CNTRL
                XOR     BX,BX
                MOV     BL,AL
                AND     BL,03H                          ;INFO IS IN 2 BITS.
                MOV     WORD PTR [BX_VALUE],BX
                CLC
                XOR     AX,AX
                MOV     WORD PTR [AX_VALUE],AX
;---------------------------------------
                POP     SI
                POP     DX
                POP     CX
                POP     BX
                RET
GET_KEY_CLK     ENDP
;----------------------------------------------------------------
;ROUTINE LOAD_GS_TMR FOLLOWS...
;IT LOADS THE GLOBAL STANDBY TIMER WITH THE BINARY VALUE SPECIFIED
;IN THE CX_VALUE  VARIABLE IN  RAM.
;IT IS USED BY UPPER LEVEL SOFTWARE TO CONFIGURE THE POWER MANAGEMENT..
;-------------------------------------------------------------------
LOAD_GS_TMR     PROC    NEAR
                PUSH    BX
                PUSH    CX
                PUSH    DX
                PUSH    SI
;--------------------------------------
                MOV     DX,WORD PTR [CX_VALUE]
                MOV     BX,DX
                PUSH    BX
                WRITE_82360SL   GSTDBY_TMRL,<BL>
                POP     BX
                XCHG    BH,BL
                WRITE_82360SL   GSTDBY_TMRH,<BL>
                CLC
                XOR     AX,AX
                MOV     WORD PTR [AX_VALUE],AX
;---------------------------------------
                POP     SI
                POP     DX
                POP     CX
                POP     BX
                RET
LOAD_GS_TMR     ENDP
;----------------------------------------------------------------
;ROUTINE GET_GS_TMR FOLLOWS...
;IT GETS THE GLOBAL STANDBY TIMER VALUE IN  BINARY .
;IT  UPDATES CX_VALUE VARIABLE IN RAM .
;IT ALSO PASSES ON 02H IN  BX_VALUE VARIABLE  IF GLOBAL STANDBY IS ENABLED.
;-----------------------------------------------------------------
GET_GS_TMR      PROC    NEAR
                PUSH    BX
                PUSH    CX
                PUSH    DX
                PUSH    SI
;--------------------------------------
;FIND OUT IF THE GLOBAL STANDBY FEATURE IS ENABLED BY READING SM_REQ_CNTRL
;REGISTER.
                XOR     BX,BX
                MOV     WORD PTR [BX_VALUE],BX
                READ_82360SL    SM_REQ_CNTRL
                TEST    AL,04H
                JZ      READ_GLBL_TMR
                MOV     BYTE PTR [BX_VALUE],02H
READ_GLBL_TMR :
                READ_82360SL    GSTDBY_TMRL
                MOV     DL,AL
                PUSH    DX
                READ_82360SL    GSTDBY_TMRH
                POP     DX
                MOV     DH,AL
                MOV     WORD PTR [CX_VALUE],DX
                CLC
                XOR     AX,AX
                MOV     WORD PTR [AX_VALUE],AX
;---------------------------------------
                POP     SI
                POP     DX
                POP     CX
                POP     BX
                RET
GET_GS_TMR      ENDP
;----------------------------------------------------------------
;ROUTINE LOAD_AP_TMR FOLLOWS...
;IT LOADS THE AUTO POWER OFF TIMER  WITH THE BINARY VALUE SPECIFIED
;IN THE VARIABLE AT CX_VALUE..
;-----------------------------------------------------------------
LOAD_AP_TMR     PROC    NEAR
                PUSH    BX
                PUSH    CX
                PUSH    DX
                PUSH    SI
;--------------------------------------
                MOV     DX,WORD PTR [CX_VALUE]
                MOV     BX,DX
                PUSH    BX
                WRITE_82360SL   APWR_TMRL,<BL>
                POP     BX
                XCHG    BH,BL
                AND     BL,7FH          ;REMEMBER ALL BITS ARE NOT SAME.
                WRITE_82360SL   APWR_TMRH,<BL>
                CLC
                XOR     AX,AX
                MOV     WORD PTR [AX_VALUE],AX
;---------------------------------------
                POP     SI
                POP     DX
                POP     CX
                POP     BX
                RET
LOAD_AP_TMR     ENDP
;----------------------------------------------------------------
;ROUTINE GET_AP_TMR FOLLOWS...
;IT GETS THE AUTO POWER OFF  TIMER VALUE IN  BINARY AND LOADS IT TO
;THE VARIABLE CX_VALUE..
;-----------------------------------------------------------------
GET_AP_TMR      PROC    NEAR
                PUSH    BX
                PUSH    CX
                PUSH    DX
                PUSH    SI
;--------------------------------------
                READ_82360SL    APWR_TMRL
                MOV     DL,AL
                PUSH    DX
                READ_82360SL    APWR_TMRH
                POP     DX
                MOV     DH,AL
                MOV     WORD PTR [CX_VALUE],DX
                CLC
                XOR     AX,AX
                MOV     WORD PTR [AX_VALUE],AX
;---------------------------------------
                POP     SI
                POP     DX
                POP     CX
                POP     BX
                RET
GET_AP_TMR      ENDP
;----------------------------------------------------------------
;ROUTINE LOAD_APOW_TMR FOLLOWS...
;IT LOADS THE AUTO POWER OFF SUSPEND TIMER  WITH THE BINARY VALUE SPECIFIED
;IN THE CX_VALUE VARIABLE..
;-----------------------------------------------------------------
LOAD_APOW_TMR   PROC    NEAR
                PUSH    BX
                PUSH    CX
                PUSH    DX
                PUSH    SI
;--------------------------------------
                MOV     DX,WORD PTR [CX_VALUE]
                MOV     BX,DX
                WRITE_82360SL   SUS_WRN_TMR_APWR,<BL>
                CLC
                XOR     AX,AX
                MOV     WORD PTR [AX_VALUE],AX
;---------------------------------------
                POP     SI
                POP     DX
                POP     CX
                POP     BX
                RET
LOAD_APOW_TMR   ENDP
;----------------------------------------------------------------
;ROUTINE GET_APOW_TMR FOLLOWS...
;IT GETS THE AUTO POWER OFF SUSPEND  TIMER VALUE IN  BINARY AND LOADS IT TO
;THE CX_VALUE VARIABLE..
;-------------------------------------------------------------------
GET_APOW_TMR    PROC    NEAR
                PUSH    BX
                PUSH    CX
                PUSH    DX
                PUSH    SI
;--------------------------------------
                READ_82360SL    SUS_WRN_TMR_APWR
                XOR     DX,DX
                MOV     DL,AL
                MOV     WORD PTR [CX_VALUE],DX
                CLC
                XOR     AX,AX
                MOV     WORD PTR [AX_VALUE],AX
;---------------------------------------
                POP     SI
                POP     DX
                POP     CX
                POP     BX
                RET
GET_APOW_TMR    ENDP
;----------------------------------------------------------------
;ROUTINE DISABLE_AUTO_OFF FOLLOWS...
;DISABLES AUTO POWER OFF FUNCTION OF THE POWER MANAGEMENT.
;RETURNS AX = 0 AND CY = 0 FOR NO ERRORS.
;-----------------------------------------------------------------
DISABLE_AUTO_OFF        PROC    NEAR
                PUSH    BX
                PUSH    CX
                PUSH    DX
                PUSH    SI
;--------------------------------------
                ALTER_82360SL   APWR_TMRH,7FH,00
                CLC
                XOR     AX,AX
                MOV     WORD PTR [AX_VALUE],AX
;---------------------------------------
                POP     SI
                POP     DX
                POP     CX
                POP     BX
                RET
DISABLE_AUTO_OFF        ENDP
;----------------------------------------------------------------
;ROUTINE ENABLE_AUTO_OFF FOLLOWS...
;ENABLES AUTO POWER OFF FUNCTION OF THE POWER MANAGEMENT.
;RETURNS AX = 0 AND CY = 0 FOR NO ERRORS.
;----------------------------------------------------------------
ENABLE_AUTO_OFF PROC    NEAR
                PUSH    BX
                PUSH    CX
                PUSH    DX
                PUSH    SI
;--------------------------------------
                ALTER_82360SL   APWR_TMRH,0FFH,80H
                CLC
                XOR     AX,AX
                MOV     WORD PTR [AX_VALUE],AX
;---------------------------------------
                POP     SI
                POP     DX
                POP     CX
                POP     BX
                RET
ENABLE_AUTO_OFF ENDP
;----------------------------------------------------------------
;ROUTINE DISBL_GLOBAL_STDBY FOLLOWS...
;DISABLES THE GLOBAL STANDBY FEATURE OF THE POWER MANAGEMENT.
;IT LEAVES THE GLOBAL PM ENABLE BIT UNDISTURBED.
;RETURNS AX = 0 AND CY = 0 FOR NO ERRORS.
;---------------------------------------------------------------
DISBL_GLOBAL_STDBY      PROC    NEAR
                PUSH    BX
                PUSH    CX
                PUSH    DX
                PUSH    SI
;--------------------------------------
                ALTER_82360SL   SM_REQ_CNTRL,0FBH,00H
                MOV     BYTE PTR [GSTDBY_ENBL_STAT],DISBL
                CLC
                XOR     AX,AX
                MOV     WORD PTR [AX_VALUE],AX
;---------------------------------------
                POP     SI
                POP     DX
                POP     CX
                POP     BX
                RET
DISBL_GLOBAL_STDBY      ENDP
;----------------------------------------------------------------
;ROUTINE ENBL_GLOBAL_STDBY FOLLOWS...
;IT ALSO SETS THE GLOBAL PM ENABLE IF IT IS NOT ALREADY SET.
;ENABLES THE GLOBAL STANDBY FEATURE OF THE POWER MANAGEMENT.
;-----------------------------------------------------------------
ENBL_GLOBAL_STDBY       PROC    NEAR
                PUSH    BX
                PUSH    CX
                PUSH    DX
                PUSH    SI
;--------------------------------------
                ALTER_82360SL   SM_REQ_CNTRL,0FFH,84H
                MOV     BYTE PTR [GSTDBY_ENBL_STAT],ENBL
                CLC
                XOR     AX,AX
                MOV     WORD PTR [AX_VALUE],AX
;---------------------------------------
                POP     SI
                POP     DX
                POP     CX
                POP     BX
                RET
ENBL_GLOBAL_STDBY       ENDP
;----------------------------------------------------------------
;ROUTINE READ_LSTDBY_TMR FOLLOWS...
;FIRST BX IS LOADED WITH THE VARIABLE AT BX_VALUE...THEN ...
;IF BH=41H THEN ROUTINE WILL RETURN  LSTDBY TIMER 0 IN CX_VALUE VARIABLE.
;IF BH=42H THEN ROUTINE WILL RETURN  LSTDBY TIMER 3 IN CX_VALUE VARIABLE.
;IF BH=43H THEN ROUTINE WILL RETURN  LSTDBY TIMER 1 IN CX_VALUE VARIABLE.
;IF BH=44H THEN ROUTINE WILL RETURN  LSTDBY TIMER 2 IN CX_VALUE VARIABLE.
;IF BH=45H THEN ROUTINE WILL RETURN  LSTDBY TIMER 5 IN CX_VALUE VARIABLE.

;ALSO IT RETURNS DEVICE'S PRESENT POWER LEVEL OF THE DEVICE AS FOLLOWS..
;BL IN BX_VALUE = 01 IF THE DEVICE IS OFF AND IT'S LSTDBY TIMER IS OFF.
;BL IN BX_VALUE = 00 IF THE DEVICE IS ON AND IT'S LSTDBY TIMER IS OFF.
;BL IN BX_VALUE = 03 IF THE DEVICE IS OFF AND IT'S LSTDBY TIMER IS ON.
;BL IN BX_VALUE = 02 IF THE DEVICE IS ON AND IT'S LSTDBY TIMER IS ON.
;THE STATE OF THE DEVICE AND IT'S ENABLE STATUS CAN BE FOUND OUT READING
;APPROPRIATE VARIABLES .
;THIS ROUTINE IS THE MOST IMPORTANT ROUTINE THAT IS CALLED BY THE WINDOWS
;DEMO PROGRAM TO UPDATE IT'S STATUS...
;------------------------------------------------------------
READ_LSTDBY_TMR PROC    NEAR
                PUSH    BX
                PUSH    CX
                PUSH    DX
                PUSH    SI
;--------------------------------------
                MOV     BX,WORD PTR [BX_VALUE]
                XOR     BL,BL
                MOV     WORD PTR [BX_VALUE],BX
                CMP     BH,"A"
                JNZ     NEXT_A

READ_FLOP_DEVPWR0_TMR :

                CMP     BYTE PTR [DEV0_LSTDBY_FEATURE],DISBL
                JNZ     TIMER0_ENABLED
TIMER_DISABLED :
                CMP     BYTE PTR [DEV0_LSTDBY_STAT],OFF
                JNZ     TIMER0_OFF_DEV0_ON

TIMER0_OFF_DEV0_OFF :

                MOV     BYTE PTR [BX_VALUE],01H
                JMP     READ_TMR_0

TIMER0_OFF_DEV0_ON :
                MOV     BYTE PTR [BX_VALUE],00H
                JMP     READ_TMR_0
TIMER0_ENABLED :
                CMP     BYTE PTR [DEV0_LSTDBY_STAT],OFF
                JNZ     TIMER0_ON_DEV0_ON
TIMER0_ON_DEV0_OFF :
                MOV     BYTE PTR [BX_VALUE],03H
                JMP     READ_TMR_0
TIMER0_ON_DEV0_ON :

                MOV     BYTE PTR [BX_VALUE],02H

READ_TMR_0 :
                READ_82360SL    LSTDBY_TMR_DEV0
                JMP     GET_OUT

;------------------------------------------------------------

NEXT_A :
                CMP     BH,"B"
                JNZ     NEXT_B

;---------------------------------------------------------------
READ_HDD_DEVPWR3_TMR :

                CMP     BYTE PTR [DEV3_LSTDBY_FEATURE],DISBL
                JNZ     TIMER3_ENABLED
TIMER_3_DISABLED :
                CMP     BYTE PTR [DEV3_LSTDBY_STAT],OFF
                JNZ     TIMER3_OFF_DEV3_ON

TIMER3_OFF_DEV3_OFF :

                MOV     BYTE PTR [BX_VALUE],01H
                JMP     READ_TMR_3

TIMER3_OFF_DEV3_ON :
                MOV     BYTE PTR [BX_VALUE],00H
                JMP     READ_TMR_3
TIMER3_ENABLED :
                CMP     BYTE PTR [DEV3_LSTDBY_STAT],OFF
                JNZ     TIMER3_ON_DEV3_ON
TIMER3_ON_DEV3_OFF :
                MOV     BYTE PTR [BX_VALUE],03H
                JMP     READ_TMR_3
TIMER3_ON_DEV3_ON :

                MOV     BYTE PTR [BX_VALUE],02H

READ_TMR_3 :
                READ_82360SL    LSTDBY_TMR_DEV3
                JMP     GET_OUT
;------------------------------------------------------------------

NEXT_B :
                CMP     BH,"C"
                JNZ     NEXT_C

READ_BACKLIGHT_DEVPWR1_TMR :
;------------------------------------------------------------------
                CMP     BYTE PTR [DEV1_LSTDBY_FEATURE],DISBL
                JNZ     TIMER1_ENABLED
TIMER_1_DISABLED :
                CMP     BYTE PTR [DEV1_LSTDBY_STAT],OFF
                JNZ     TIMER1_OFF_DEV1_ON

TIMER1_OFF_DEV1_OFF :

                MOV     BYTE PTR [BX_VALUE],01H
                JMP     READ_TMR_1

TIMER1_OFF_DEV1_ON :
                MOV     BYTE PTR [BX_VALUE],00H
                JMP     READ_TMR_1
TIMER1_ENABLED :
                CMP     BYTE PTR [DEV1_LSTDBY_STAT],OFF
                JNZ     TIMER1_ON_DEV1_ON
TIMER1_ON_DEV1_OFF :
                MOV     BYTE PTR [BX_VALUE],03H
                JMP     READ_TMR_1
TIMER1_ON_DEV1_ON :

                MOV     BYTE PTR [BX_VALUE],02H

READ_TMR_1 :
                READ_82360SL    LSTDBY_TMR_DEV1
                JMP     GET_OUT

;------------------------------------------------------------
NEXT_C :
                CMP     BH,"D"
                JNZ     NEXT_D

READ_LCD_DEVPWR2_TMR :
;-------------------------------------------------------------
                CMP     BYTE PTR [DEV2_LSTDBY_FEATURE],DISBL
                JNZ     TIMER2_ENABLED
TIMER_2_DISABLED :
                CMP     BYTE PTR [DEV2_LSTDBY_STAT],OFF
                JNZ     TIMER2_OFF_DEV2_ON

TIMER2_OFF_DEV2_OFF :

                MOV     BYTE PTR [BX_VALUE],01H
                JMP     READ_TMR_2

TIMER2_OFF_DEV2_ON :
                MOV     BYTE PTR [BX_VALUE],00H
                JMP     READ_TMR_2
TIMER2_ENABLED :
                CMP     BYTE PTR [DEV2_LSTDBY_STAT],OFF
                JNZ     TIMER2_ON_DEV2_ON
TIMER2_ON_DEV2_OFF :
                MOV     BYTE PTR [BX_VALUE],03H
                JMP     READ_TMR_2
TIMER2_ON_DEV2_ON :

                MOV     BYTE PTR [BX_VALUE],02H

READ_TMR_2 :
                READ_82360SL    LSTDBY_TMR_DEV2
                JMP     GET_OUT

;------------------------------------------------------------
NEXT_D :
                CMP     BH,"Z"          ;UNKNOWN NOW...
                JNZ     R_EXIT

READ_UNRESERVED_TMR :
;-------------------------------------------------------------------
                CMP     BYTE PTR [DEV5_LSTDBY_FEATURE],DISBL
                JNZ     TIMER5_ENABLED
TIMER_5_DISABLED :
                CMP     BYTE PTR [DEV5_LSTDBY_STAT],OFF
                JNZ     TIMER5_OFF_DEV5_ON

TIMER5_OFF_DEV5_OFF :

                MOV     BYTE PTR [BX_VALUE],01H
                JMP     READ_TMR_5

TIMER5_OFF_DEV5_ON :
                MOV     BYTE PTR [BX_VALUE],00H
                JMP     READ_TMR_5
TIMER5_ENABLED :
                CMP     BYTE PTR [DEV5_LSTDBY_STAT],OFF
                JNZ     TIMER5_ON_DEV5_ON
TIMER5_ON_DEV5_OFF :
                MOV     BYTE PTR [BX_VALUE],03H
                JMP     READ_TMR_5
TIMER5_ON_DEV5_ON :

                MOV     BYTE PTR [BX_VALUE],02H

READ_TMR_5 :
                READ_82360SL    LSTDBY_TMR_DEV5

;------------------------------------------------------------
GET_OUT :
                XOR     DX,DX
                MOV     DL,AL
                MOV     WORD PTR [CX_VALUE],DX
                CLC
                XOR     AX,AX
                MOV     WORD PTR [AX_VALUE],AX
;---------------------------------------
R_EXIT :
                POP     SI
                POP     DX
                POP     CX
                POP     BX
                RET
READ_LSTDBY_TMR ENDP
;----------------------------------------------------------------
;ROUTINE LOAD_LSTDBY_TMR FOLLOWS...
;FIRST BX IS LOADED WITH THE VARIABLE AT BX_VALUE...THEN ...
;IF BH=41H THEN ROUTINE WILL LOAD  LSTDBY TIMER 0 WITH CX_VALUE VARIABLE.
;IF BH=42H THEN ROUTINE WILL LOAD  LSTDBY TIMER 3 WITH CX_VALUE VARIABLE.
;IF BH=43H THEN ROUTINE WILL LOAD  LSTDBY TIMER 1 WITH CX_VALUE VARIABLE.
;IF BH=44H THEN ROUTINE WILL LOAD  LSTDBY TIMER 2 WITH CX_VALUE VARIABLE.
;IF BH=45H THEN ROUTINE WILL LOAD  LSTDBY TIMER 5 WITH CX_VALUE VARIABLE.
;----------------------------------------------------------------
LOAD_LSTDBY_TMR PROC    NEAR
                PUSH    BX
                PUSH    CX
                PUSH    DX
                PUSH    SI
;--------------------------------------
                MOV     BX,WORD PTR [BX_VALUE]
                MOV     DX,WORD PTR [CX_VALUE]
                AND     DH,00H                  ;8 BIT GUYS..

                CMP     BH,"A"
                JNZ     NEXT_A1

LOAD_FLOP_DEVPWR0_TMR :

                WRITE_82360SL   LSTDBY_TMR_DEV0,<DL>
                JMP     GET_OUT1
NEXT_A1 :
                CMP     BH,"B"
                JNZ     NEXT_B1

LOAD_HDD_DEVPWR3_TMR :

                WRITE_82360SL   LSTDBY_TMR_DEV3,<DL>
                JMP     GET_OUT1
NEXT_B1 :
                CMP     BH,"C"
                JNZ     NEXT_C1

LOAD_BACKLIGHT_DEVPWR1_TMR :

                WRITE_82360SL   LSTDBY_TMR_DEV1,<DL>
                JMP     GET_OUT1
NEXT_C1 :
                CMP     BH,"D"
                JNZ     NEXT_D1

LOAD_LCD_DEVPWR2_TMR :

                WRITE_82360SL   LSTDBY_TMR_DEV2,<DL>
                JMP     GET_OUT1
NEXT_D1 :
                CMP     BH,"Z"          ;UNKNOWN NOW...
                JNZ     R_EXIT1

LOAD_UNRESERVED_TMR_Z :

;                WRITE_82360SL   LSTDBY_TMR_DEV5,<DL>


GET_OUT1 :
                XOR     DX,DX
                MOV     DL,AL
                MOV     WORD PTR [CX_VALUE],DX
                CLC
                XOR     AX,AX
                MOV     WORD PTR [AX_VALUE],AX
;---------------------------------------
R_EXIT1 :
                POP     SI
                POP     DX
                POP     CX
                POP     BX
                RET
LOAD_LSTDBY_TMR ENDP
;----------------------------------------------------------------
;ROUTINE SET_PWR_FN FOLLOWS...
;PUTS THE DESIGNATED DEVICE TO DESIRED  POWER LEVEL.IN THIS VERSION
;WE SUPPORT ONLY TWO POWER LEVELS (MAX AND MIN) FOR DEVICES.
;FIRST BX IS LOADED WITH THE VARIABLE AT BX_VALUE...THEN ...
;IF BH=41H THEN ROUTINE WILL OPERATE ON FLOPPY.
;IF BH=42H THEN ROUTINE WILL OPERATE ON HDD.
;IF BH=43H THEN ROUTINE WILL OPERATE ON BACK LIGHT.
;IF BH=44H THEN ROUTINE WILL OPERATE ON LCD.
;BL WILL HAVE POWER LEVEL...00 = PUT OFF DEVICE. 0FFH = PUT ON DEVICE.
;---------------------------------------------------------------------
SET_PWR_FN      PROC    NEAR
                PUSH    BX
                PUSH    CX
                PUSH    DX
                PUSH    SI
;--------------------------------------
                MOV     BX,WORD PTR [BX_VALUE]
                CMP     BH,"A"                          ;IS IT FLOPPY ?
                JNZ     NEXT_DEV1
;               CALL NEAR PTR FLOPPY_CNTRL
                JMP     DEV_OUT
NEXT_DEV1:
                CMP     BH,"B"                          ;IS IT HDD ?
                JNZ     NEXT_DEV2
                CALL NEAR PTR HDD_CNTRL
                JMP     DEV_OUT
NEXT_DEV2 :
                CMP     BH,"C"         ;IS IT BACK LIGHT ?
                JNZ     NEXT_DEV3
                CALL NEAR PTR BACKLIGHT_CNTRL
                JMP     DEV_OUT
NEXT_DEV3 :
                CMP     BH,"D"          ;IS IT LCD PANEL ?
                JNZ     NEXT_DEV4
                CALL NEAR PTR LCD_PANEL_CNTRL
                JMP     DEV_OUT
NEXT_DEV4 :
                CMP     BH,"Z"          ;IS IT UNKNOWN ?
                JNZ     NEXT_DEV5
                CALL NEAR PTR UNKNOWN_CNTRL

DEV_OUT :
                CLC
                XOR     AX,AX
                MOV     WORD PTR [AX_VALUE],AX

NEXT_DEV5 :
;---------------------------------------
                POP     SI
                POP     DX
                POP     CX
                POP     BX
                RET
SET_PWR_FN      ENDP
;-------------------------------------------------------------------------
;ROUTINE ENABLE_LSTDBY FOLLOWS...
;ENABLES THE LOCAL STAND BY FEATURE OF THE DEVICE..BUT DOES NOT
;CHANGE THE TRAP ENABLE BIT OR DEVICE ACTIVE BIT..
;FIRST BX IS LOADED WITH THE VARIABLE AT BX_VALUE...THEN ...
;IF BH=41H THEN ROUTINE WILL ENABLE  LSTDBY OF DEVICE 0.
;IF BH=42H THEN ROUTINE WILL ENABLE  LSTDBY OF DEVICE 3.
;IF BH=43H THEN ROUTINE WILL ENABLE  LSTDBY OF DEVICE 1.
;IF BH=44H THEN ROUTINE WILL ENABLE  LSTDBY OF DEVICE 2.
;IF BH=45H THEN ROUTINE WILL ENABLE  LSTDBY OF DEVICE 5.
;-------------------------------------------------------------------------
ENABLE_LSTDBY   PROC    NEAR
                PUSH    BX
                PUSH    CX
                PUSH    DX
                PUSH    SI
;--------------------------------------
                MOV     BX,WORD PTR [BX_VALUE]
                CMP     BH,"A"          ;IS IT FLOPPY ?
                JNZ     NEXT_DEVL1
                ALTER_82360SL   STDBY_TMR_CNTRL,0FFH,01H
                MOV     BYTE PTR [DEV0_LSTDBY_FEATURE],ENBL
                JMP     DEVL_OUT
NEXT_DEVL1:
                CMP     BH,"B"          ;IS IT HDD ?
                JNZ     NEXT_DEVL2
                ALTER_82360SL   STDBY_TMR_CNTRL,0FFH,08H
                MOV     BYTE PTR [DEV3_LSTDBY_FEATURE],ENBL
                JMP     DEVL_OUT
NEXT_DEVL2 :
                CMP     BH,"C"         ;IS IT BACK LIGHT ?
                JNZ     NEXT_DEVL3
                ALTER_82360SL   STDBY_TMR_CNTRL,0FFH,02H
                MOV     BYTE PTR [DEV1_LSTDBY_FEATURE],ENBL
                JMP     DEVL_OUT
NEXT_DEVL3 :
                CMP     BH,"D"          ;IS IT LCD PANEL ?
                JNZ     NEXT_DEVL4
                ALTER_82360SL   STDBY_TMR_CNTRL,0FFH,04H
                MOV     BYTE PTR [DEV2_LSTDBY_FEATURE],ENBL
                JMP     DEVL_OUT
NEXT_DEVL4 :
                CMP     BH,"Z"          ;IS IT UNKNOWN ?
                JNZ     NEXT_DEVL5
                CALL NEAR PTR UNKNOWN_CNTRL

DEVL_OUT :
                CLC
                XOR     AX,AX
                MOV     WORD PTR [AX_VALUE],AX

NEXT_DEVL5 :
;---------------------------------------
                POP     SI
                POP     DX
                POP     CX
                POP     BX
                RET
ENABLE_LSTDBY   ENDP
;----------------------------------------------------------------
;ROUTINE DISABLE_LSTDBY FOLLOWS...
;DISABLES THE LOCAL STAND BY FEATURE OF THE DEVICE..BUT DOES NOT
;CHANGE THE TRAP ENABLE BIT OR DEVICE ACTIVE BIT..
;FIRST BX IS LOADED WITH THE VARIABLE AT BX_VALUE...THEN ...
;IF BH=41H THEN ROUTINE WILL DISABLE  LSTDBY OF DEVICE 0.
;IF BH=42H THEN ROUTINE WILL DISABLE  LSTDBY OF DEVICE 3.
;IF BH=43H THEN ROUTINE WILL DISABLE  LSTDBY OF DEVICE 1.
;IF BH=44H THEN ROUTINE WILL DISABLE  LSTDBY OF DEVICE 2.
;IF BH=45H THEN ROUTINE WILL DISABLE  LSTDBY OF DEVICE 5.
;----------------------------------------------------------------
DISABLE_LSTDBY  PROC    NEAR
                PUSH    BX
                PUSH    CX
                PUSH    DX
                PUSH    SI
;--------------------------------------
                MOV     BX,WORD PTR [BX_VALUE]
                CMP     BH,"A"          ;IS IT FLOPPY ?
                JNZ     NEXT_DEVM1
                ALTER_82360SL   STDBY_TMR_CNTRL,0FEH,00H
                MOV     BYTE PTR [DEV0_LSTDBY_FEATURE],DISBL
                JMP     DEVM_OUT
NEXT_DEVM1:
                CMP     BH,"B"          ;IS IT HDD ?
                JNZ     NEXT_DEVM2
                ALTER_82360SL   STDBY_TMR_CNTRL,0F7H,00H
                MOV     BYTE PTR [DEV3_LSTDBY_FEATURE],DISBL
                JMP     DEVM_OUT
NEXT_DEVM2 :
                CMP     BH,"C"         ;IS IT BACK LIGHT ?
                JNZ     NEXT_DEVM3
                ALTER_82360SL   STDBY_TMR_CNTRL,0FDH,00H
                MOV     BYTE PTR [DEV1_LSTDBY_FEATURE],DISBL

                JMP     DEVM_OUT
NEXT_DEVM3 :
                CMP     BH,"D"          ;IS IT LCD PANEL ?
                JNZ     NEXT_DEVM4
                ALTER_82360SL   STDBY_TMR_CNTRL,0FBH,00H
                MOV     BYTE PTR [DEV2_LSTDBY_FEATURE],DISBL
                JMP     DEVM_OUT
NEXT_DEVM4 :
                CMP     BH,"Z"          ;IS IT UNKNOWN ?
                JNZ     NEXT_DEVM5
                CALL NEAR PTR UNKNOWN_CNTRL

DEVM_OUT :
                CLC
                XOR     AX,AX
                MOV     WORD PTR [AX_VALUE],AX

NEXT_DEVM5 :
;---------------------------------------
                POP     SI
                POP     DX
                POP     CX
                POP     BX
                RET
DISABLE_LSTDBY  ENDP
;----------------------------------------------------------------
;ROUTINE HDD_CNTRL IS AS FOLLOWS....
;HDD DRIVER FOR PRAIRIETEK HARD DISK....FLASHES PM COMMANDS TO HDD.
;NOTE WE CAN NOT TURN OFF HDD FULLY EXCEPT IN SUSPEND BECAUSE
;DAVID DOES NOT HAVE A ISOLATION BUFFER.
;BL = 0 ..HDD WILL BE TURNED OFF..(OR PUT TO LOWEST POWER MODE) ELSE ON.
;--------------------------------------------------------------------
HDD_CNTRL       PROC    NEAR
                PUSH    AX
                PUSH    BX
                PUSH    CX
                PUSH    DX
;--------------------------------------
                MOV     AL,66H
                OUT     80H,AL
;---------------------------------------
                CMP     BL,0
                JNZ     SWITCH_ON_HDD

SWITCH_OFF_HDD :

                MOV     DX,HDD_COMM_PORT
                MOV     AL,HDD_PRAIRIETEK_STDBY
                OUT     DX,AL
                MOV     BYTE PTR [HDD_STAT],OFF
                MOV     BYTE PTR [DEV3_LSTDBY_STAT],OFF

                CALL    NEAR PTR SMALL_DELAY
                CALL    NEAR PTR SMALL_DELAY

                JMP     EXIT_HDD
;--------------------------------------
SWITCH_ON_HDD :
;TAKE CARE OF HDD

                MOV     DX,HDD_COMM_PORT
                MOV     AL,0E1H
                OUT     DX,AL

                MOV     DX,HDD_COMM_PORT
                MOV     AL,0F9H
                OUT     DX,AL
                CALL    NEAR PTR SMALL_DELAY
                CALL    NEAR PTR SMALL_DELAY
;-------------------------------
                MOV     BYTE PTR [HDD_STAT],ON
                MOV     BYTE PTR [DEV3_LSTDBY_STAT],ON
;---------------------------------------
                MOV     AL,48H
                OUT     80H,AL
;---------------------------------------
EXIT_HDD :
                POP     DX
                POP     CX
                POP     BX
                POP     AX
                RET
HDD_CNTRL       ENDP
;-------------------------------------------------------------------
;ROUTINE BACKLIGHT_CNTRL IS AS FOLLOWS....
;IT MAY BE NOTED THAT IN OUR PRESENT EXAMPLE , FROM THE ON/OFF VIEW POINT
;WE REGARD BACK LIGHT AND LCD AS THE SAME DEVICE. THE REASON FOR THIS
;IS THAT WHEN WE SWITCH OFF LCD OR BACK LIGHT , THERE IS NO POINT IN KEEPING
;THE OTHER ON.BUT FROM THE POWER MANAGEMENT ARCHITECTURE VIEW POINT , THEY
;ARE CONSIDERED AS TWO SEPERATE DEVICES. THIS ALLOWS US TO HAVE TWO TRAP
;MECHANISMS TO BRING THE VIDEO SYSTEM UP . ONE IS MOUSE MOVEMENT AND OTHER
;IS ANY KEY BOARD ACTIVITY..
;BL = 0 BACK LIGHT WILL BE TURNED OFF ELSE TURNED ON..
;---------------------------------------------------------------------
;BL = 0 BACK LIGHT WILL BE TURNED OFF ELSE TURNED ON..
BACKLIGHT_CNTRL PROC    NEAR
                PUSH    AX
                PUSH    BX
                PUSH    CX
                PUSH    DX
;--------------------------------------
                CMP     BL,0
                JNZ     SWITCH_ON_BACKLIGHT
SWITCH_OFF_BACKLIGHT :

                MOV     BYTE PTR [BACKLIGHT_STAT],OFF
                MOV     BYTE PTR [LCDPANEL_STAT],OFF
                MOV     BYTE PTR [DEV1_LSTDBY_STAT],OFF
                MOV     BYTE PTR [DEV2_LSTDBY_STAT],OFF

;IF IT IS A CRT , THEN THERE IS NOT MUCH POWER MANAGEMENT , THAT CAN BE
;DONE WITH THOSE BIG GUYS,SINCE THEY ARE SUPPLIED FROM 110 VOLTS AC .
;SO WE CUT THE VIDEO BY FOLLOWING THE VGA WRITE SEQUENCE..

        IF      CRT   EQ        TRUE                    ;IS IT A CRT ?

                MOV     DX,3DAH
                IN      AL,DX
                MOV     DX,3C0H
                MOV     AL,0
                OUT     DX,AL
        ELSE                            ;IT IS A LCD.

;IF IT IS AN LCD SYSTEM THEN WE USE THE CIRRUS LOGIC CARD FEATURE CONTROL
;BITS TO DO REAL POWER MANAGEMENT. THIS REDUCES POWER CONSUMPTION VERY
;DRASTICALLY...

        MOV     AX, 0808AH
        CALL    LCD_STANDBY
        CALL NEAR PTR SMALL_DELAY
        CALL NEAR PTR SMALL_DELAY
        XOR     AX,AX
        CALL NEAR PTR PANEL_ON_OFF

        ENDIF

        CALL NEAR PTR SMALL_DELAY
        JMP     EXIT_BACKLIGHT
;--------------------------------------------------------------
SWITCH_ON_BACKLIGHT :

                MOV     BYTE PTR [BACKLIGHT_STAT],ON
                MOV     BYTE PTR [LCDPANEL_STAT],ON

                MOV     BYTE PTR [DEV1_LSTDBY_STAT],ON
                MOV     BYTE PTR [DEV2_LSTDBY_STAT],ON

                CALL NEAR PTR SMALL_DELAY
                CALL NEAR PTR SMALL_DELAY

        IF      CRT     EQ      TRUE

                MOV     DX,3DAH
                IN      AL,DX
                MOV     DX,3C0H
                MOV     AL,20H
                OUT     DX,AL

        ELSE

;IF IT IS A LCD SUBSYSTEM WE USE THE SAME CALLS TO BRING THEM UP..

               MOV      AX, 0008AH
               CALL     LCD_STANDBY
                CALL NEAR PTR SMALL_DELAY
                CALL NEAR PTR SMALL_DELAY

                MOV     AX,1
                CALL NEAR PTR PANEL_ON_OFF

        ENDIF
;-------------------------------------------------
                CALL NEAR PTR SMALL_DELAY
                CALL NEAR PTR SMALL_DELAY

EXIT_BACKLIGHT :

                POP     DX
                POP     CX
                POP     BX
                POP     AX
                RET
BACKLIGHT_CNTRL ENDP
;-------------------------------------------------------------------
;LCD_PANEL_CNTRL ROUTINE FOLLOWS...
;BL = 0 LCD PANEL IS TURNED OFF ..ELSE TURNED ON..
;IT MAY BE NOTED THAT IN OUR PRESENT EXAMPLE , FROM THE ON/OFF VIEW POINT
;WE REGARD BACK LIGHT AND LCD AS THE SAME DEVICE. THE REASON FOR THIS
;IS THAT WHEN WE SWITCH OFF LCD OR BACK LIGHT , THERE IS NO POINT IN KEEPING
;THE OTHER ON.BUT FROM THE POWER MANAGEMENT ARCHITECTURE VIEW POINT , THEY
;ARE CONSIDERED AS TWO SEPERATE DEVICES. THIS ALLOWS US TO HAVE TWO TRAP
;MECHANISMS TO BRING THE VIDEO SYSTEM UP . ONE IS MOUSE MOVEMENT AND OTHER
;IS ANY KEY BOARD ACTIVITY..
;-----------------------------------------------------------------
LCD_PANEL_CNTRL PROC    NEAR
                PUSH    AX
                PUSH    BX
                PUSH    CX
                PUSH    DX
;--------------------------------------
                CMP     BL,0
                JNZ     SWITCH_ON_LCDPANEL

SWITCH_OFF_LCDPANEL:

                MOV     BYTE PTR [BACKLIGHT_STAT],OFF
                MOV     BYTE PTR [LCDPANEL_STAT],OFF

                MOV     BYTE PTR [DEV1_LSTDBY_STAT],OFF
                MOV     BYTE PTR [DEV2_LSTDBY_STAT],OFF

;IF IT IS A CRT , THEN THERE IS NOT MUCH POWER MANAGEMENT , THAT CAN BE
;DONE WITH THOSE BIG GUYS,SINCE THEY ARE SUPPLIED FROM 110 VOLTS AC .
;SO WE CUT THE VIDEO BY FOLLOWING THE VGA WRITE SEQUENCE..

        IF      CRT   EQ        TRUE                    ;IS IT A CRT ?

                MOV     DX,3DAH
                IN      AL,DX
                MOV     DX,3C0H
                MOV     AL,0
                OUT     DX,AL
        ELSE                            ;IT IS A LCD.

;IF IT IS AN LCD SYSTEM THEN WE USE THE CIRRUS LOGIC CARD FEATURE CONTROL
;BITS TO DO REAL POWER MANAGEMENT. THIS REDUCES POWER CONSUMPTION VERY
;DRASTICALLY...

        MOV     AX, 0808AH
        CALL    LCD_STANDBY
        CALL NEAR PTR SMALL_DELAY
        CALL NEAR PTR SMALL_DELAY
        XOR     AX,AX
        CALL NEAR PTR PANEL_ON_OFF

        ENDIF

;------------------
                CALL NEAR PTR SMALL_DELAY
                JMP     EXIT_LCDPANEL

SWITCH_ON_LCDPANEL :

                MOV     BYTE PTR [BACKLIGHT_STAT],ON
                MOV     BYTE PTR [LCDPANEL_STAT],ON

                MOV     BYTE PTR [DEV1_LSTDBY_STAT],ON
                MOV     BYTE PTR [DEV2_LSTDBY_STAT],ON

                CALL NEAR PTR SMALL_DELAY
                CALL NEAR PTR SMALL_DELAY

;IF IT IS CRT WE JUST BRING UP THE VIDEO..

        IF      CRT     EQ      TRUE

                MOV     DX,3DAH
                IN      AL,DX
                MOV     DX,3C0H
                MOV     AL,20H
                OUT     DX,AL

        ELSE
;IF IT IS A LCD SUBSYSTEM WE USE THE SAME CALLS TO BRING THEM UP..

               MOV      AX, 0008AH
               CALL     LCD_STANDBY
                CALL NEAR PTR SMALL_DELAY
                CALL NEAR PTR SMALL_DELAY

                MOV     AX,1
                CALL NEAR PTR PANEL_ON_OFF

        ENDIF
;-------------------------------------------------

EXIT_LCDPANEL :

                CALL NEAR PTR SMALL_DELAY
;--------------------------------------
                POP     DX
                POP     CX
                POP     BX
                POP     AX
                RET
LCD_PANEL_CNTRL ENDP
;-------------------------------------------------------------------
;UNKNOWN_CNTRL ROUTINE FOLLOWS...
;THE FIFTH DEVICE DOES NOT EXIST IN DAVID SYSTEM. IT IS FOR FUTURE
;EXPANSION OF SYSTEM MANAGEMENT...
;------------------------------------------------------------------
UNKNOWN_CNTRL   PROC    NEAR
                PUSH    AX
                PUSH    BX
                PUSH    CX
                PUSH    DX
;--------------------------------------
;THERE IS NOTHING YOU CAN DO WITH AN UNKNOWN DEVICE NOW.
;--------------------------------------
                POP     DX
                POP     CX
                POP     BX
                POP     AX
                RET
UNKNOWN_CNTRL   ENDP
;-------------------------------------------------------------------
;FLOPPY POWER MANAGEMENT IS TAKEN OFF SINCE THE EPSON 1040 POWER MANAGES
;ITSELF.TRAP 0 IS USED TO TRACK THE ACTIVE INTERRUPTS MAINTAINED BY 8259
;PIC AND WE USE THIS TO CONTINUOUSLY TRACK AND ADJUST SYSTEM EVENTS.ANY TIME
;CONTROL FALLS HERE IT IS OBVIOUS THAT THE HIGHER LEVEL SOFTWARE
;TRIED TO ALTER THE ACTIVE INTERRUPT STRUCTURE .

MANAGE_LOCAL_0          PROC    NEAR
                PUSH    BX
                PUSH    CX
                PUSH    DX
;--------------------------------------
;WE NEED TO DISABLE THE TRAP FIRST BEFORE WE READ THE PIC STUFF..ELSE
;WE GET INTO A ENDLESS SMI QUEUE MODE , BECAUSE THIS READ GENERATES
;AND ADDS A PENDING TRAP SMI TO 360SL AND SO ON...

                ALTER_82360SL   SM_REQ_CNTRL,0EFH,00H
                ALTER_82360SL   TRP_ADR_MSK_DEV0,7FH,00H

                XOR     AX,AX
                IN      AL,MASTER_PIC_MASK
                NOT     AL
                AND     AL,SYS_EVNT_MASK1
;-------------------------------------------------
;               PUSH    AX
                OUT     80H,AL
;               MOV     SI,OFFSET BUG_MES
;               CALL NEAR PTR DEBUG_MES
;               POP     AX
;----------------------------------------
                MOV     BL,AL

                WRITE_82360SL     SYS_EVNT_CFG0,<BL>

;---------------------

                XOR     AX,AX
                IN      AL,SLAVE_PIC_MASK
                NOT     AL
                AND     AL,SYS_EVNT_MASK2
                MOV     BL,AL

                WRITE_82360SL     SYS_EVNT_CFG1,<BL>
;--------------------------------------
;WE ALSO MANAGE STOP BREAK EVENTS HERE IN THE SAME WAY..

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
;---------------------------------------
;WE ARE DONE..NO MORE PIC READS..SO LET US ENABLE THE TRAP MECHANISM
;AGAIN...
                ALTER_82360SL   TRP_ADR_MSK_DEV0,0FFH,80H
                ALTER_82360SL   SM_REQ_CNTRL,0EFH,10H
                ALTER_82360SL   LTRP_STS,0FEH,00
;-------------------------------------
EXIT_MANAGE :
                XOR     AX,AX
                POP     DX
                POP     CX
                POP     BX
                RET
MANAGE_LOCAL_0  ENDP
;-------------------------------------------------------------------
;MANAGES THE DEVICE FOR LOCAL STDBY.MANAGING BACKLIGHT.
MANAGE_LOCAL_1          PROC    NEAR
                PUSH    BX
                PUSH    CX
                PUSH    DX
;--------------------------------------
                CMP     AL,"L"
                JZ      LSTDBY_SUPPORT_1
TRAP_SUPPORT_1 :

;WHEN WE SWITCH ON A DEVICE WE NEED TO DISABLE THE CORRESPONDING
;TRAP MECHANISM FOR THAT PARTICULAR DEVICE...

                MOV     BL,0FFH
                CALL NEAR PTR BACKLIGHT_CNTRL
                ALTER_82360SL   TRP_ADR_MSK_DEV1,3FH,00H
                ALTER_82360SL   TRP_ADR_MSK_DEV2,3FH,00H
                CMP     BYTE PTR [DEV1_LSTDBY_FEATURE],DISBL
                JZ      EXIT_MANAGE_1

;TRAP IS DISABLED ..BUT WE NEED TO ENABLE THE LSTDBY TIMER SO THAT THE
;PARTICULAR DEVICE CAN GO TO STAND BY AGAIN IN CASE OF A PROLONGED INACTIVITY.

                ALTER_82360SL   STDBY_TMR_CNTRL,0FFH,02H
                JMP     EXIT_MANAGE_1

LSTDBY_SUPPORT_1 :

;WHEN WE SWITCH OFF THE DEVICE , DURING LOCAL STANDBY , WE NEED TO ENABLE THE
;CORRESPONDING TRAP MECHANISM , SO THAT THE DEVICE CAN BE SWITCHED ON AGAIN
;WHEN IT'S SERVICES ARE NEEDED BY THE UPPER LEVEL SOFTWARE.ALSO WE NEED TO
;DISABLE THE CORRESPONDING LSTDBY TIMER.IN CASE OF DEVICE 1 , WHICH IS
;VIDEO SUBSYSTEM WE ENABLE BOTH TRAPS BECAUSE WE CONSIDER THEM AS THE SAME
;DEVICE. THIS GIVES US THE OPPORTUNITY TO BRING UP THE VIDEO SYSTEM EITHER
;BY TRAP -1 , WHICH IS MOUSE MOVEMENT OR BY KEY BOARD ACTIVITY , WHICH ARE
;OUR TRAP-2.
                MOV     BL,0
                CALL NEAR PTR BACKLIGHT_CNTRL
                ALTER_82360SL   TRP_ADR_MSK_DEV1,3FH,80H  ;ENBL TRP0.
                ALTER_82360SL   TRP_ADR_MSK_DEV2,3FH,80H  ;ENBL TRP0.

;DISABLE LCD AND BACK LIGHT TIMERS.

                ALTER_82360SL   STDBY_TMR_CNTRL,0F9H,00H

;--------------------------------------
                XOR     AX,AX
EXIT_MANAGE_1 :
                POP     DX
                POP     CX
                POP     BX
                RET
MANAGE_LOCAL_1  ENDP
;-------------------------------------------------------------------
;MANAGES THE DEVICE FOR LOCAL STDBY.MANAGING LCD.
MANAGE_LOCAL_2          PROC    NEAR
                PUSH    BX
                PUSH    CX
                PUSH    DX
;--------------------------------------
                CMP     AL,"L"
                JZ      LSTDBY_SUPPORT_2
TRAP_SUPPORT_2 :

;WHEN WE SWITCH ON A DEVICE WE NEED TO DISABLE THE CORRESPONDING
;TRAP MECHANISM FOR THAT PARTICULAR DEVICE...

                MOV     BL,0FFH
                CALL NEAR PTR LCD_PANEL_CNTRL
                ALTER_82360SL   TRP_ADR_MSK_DEV2,03FH,00H
                ALTER_82360SL   TRP_ADR_MSK_DEV1,3FH,00H
                CMP     BYTE PTR [DEV2_LSTDBY_FEATURE],DISBL
                JZ      EXIT_MANAGE_2

;TRAP IS DISABLED ..BUT WE NEED TO ENABLE THE LSTDBY TIMER SO THAT THE
;PARTICULAR DEVICE CAN GO TO STAND BY AGAIN IN CASE OF A PROLONGED INACTIVITY.

                ALTER_82360SL   STDBY_TMR_CNTRL,0FFH,04H

                JMP     EXIT_MANAGE_2

LSTDBY_SUPPORT_2 :

;WHEN WE SWITCH OFF THE DEVICE , DURING LOCAL STANDBY , WE NEED TO ENABLE THE
;CORRESPONDING TRAP MECHANISM , SO THAT THE DEVICE CAN BE SWITCHED ON AGAIN
;WHEN IT'S SERVICES ARE NEEDED BY THE UPPER LEVEL SOFTWARE.ALSO WE NEED TO
;DISABLE THE CORRESPONDING LSTDBY TIMER.IN CASE OF DEVICE 1 , WHICH IS
;VIDEO SUBSYSTEM WE ENABLE BOTH TRAPS BECAUSE WE CONSIDER THEM AS THE SAME
;DEVICE. THIS GIVES US THE OPPORTUNITY TO BRING UP THE VIDEO SYSTEM EITHER
;BY TRAP -1 , WHICH IS MOUSE MOVEMENT OR BY KEY BOARD ACTIVITY , WHICH ARE
;OUR TRAP-2.
                MOV     BL,0
                CALL NEAR PTR LCD_PANEL_CNTRL
                ALTER_82360SL   TRP_ADR_MSK_DEV2,3FH,80H  ;ENBL TRP0.
                ALTER_82360SL   TRP_ADR_MSK_DEV1,3FH,80H

;DISABLE LCD AND BACK LIGHT TIMERS.

                ALTER_82360SL   STDBY_TMR_CNTRL,0F9H,00H

;--------------------------------------
                XOR     AX,AX
EXIT_MANAGE_2 :
                POP     DX
                POP     CX
                POP     BX
                RET
MANAGE_LOCAL_2  ENDP
;-------------------------------------------------------------------
;MANAGES THE DEVICE FOR LOCAL STDBY.MANAGING HARD DISK.
MANAGE_LOCAL_3          PROC    NEAR
                PUSH    BX
                PUSH    CX
                PUSH    DX
;--------------------------------------
                CMP     AL,"L"
                JZ      LSTDBY_SUPPORT_3
TRAP_SUPPORT_3 :

;WHEN WE SWITCH ON A DEVICE WE NEED TO DISABLE THE CORRESPONDING
;TRAP MECHANISM FOR THAT PARTICULAR DEVICE...
                MOV     BL,0FFH
                CALL NEAR PTR HDD_CNTRL
                ALTER_82360SL   TRP_ADR_MSK_DEV3,03FH,00H
                CMP     BYTE PTR [DEV3_LSTDBY_FEATURE],DISBL
                JZ      EXIT_MANAGE_3
                ALTER_82360SL   STDBY_TMR_CNTRL,0FFH,08H
                JMP     EXIT_MANAGE_3

;TRAP IS DISABLED ..BUT WE NEED TO ENABLE THE LSTDBY TIMER SO THAT THE
;PARTICULAR DEVICE CAN GO TO STAND BY AGAIN IN CASE OF A PROLONGED INACTIVITY.

LSTDBY_SUPPORT_3 :
;WHEN WE SWITCH OFF THE DEVICE , DURING LOCAL STANDBY , WE NEED TO ENABLE THE
;CORRESPONDING TRAP MECHANISM , SO THAT THE DEVICE CAN BE SWITCHED ON AGAIN
;WHEN IT'S SERVICES ARE NEEDED BY THE UPPER LEVEL SOFTWARE.ALSO WE NEED TO
;DISABLE THE CORRESPONDING LSTDBY TIMER.

                MOV     BL,0
                CALL NEAR PTR HDD_CNTRL
                ALTER_82360SL   TRP_ADR_MSK_DEV3,3FH,80H  ;ENBL TRP0.

                ALTER_82360SL   STDBY_TMR_CNTRL,0F7H,00H

;--------------------------------------
                XOR     AX,AX
EXIT_MANAGE_3 :
                POP     DX
                POP     CX
                POP     BX
                RET
MANAGE_LOCAL_3  ENDP
;-------------------------------------------------------------------
;Routine SW_SMI_DELAY follows... It allows the application to proceed 
;to work for this pre-defined amount of time..and when it lapses it
;return the control to the caller. During this interval it does not allow
;any other SMI requests other than SW SMI.
;i/p = CX register contains the delay allowed in seconds..
;If the SW delay is done then the control will go back to the routine
;that requested the SW_SMI delay...
;If SW DELAY is not done then the control will always go to EXIT_MODULE
;so that the control goes to application.
;i/p = SW_SMI_FLAG = TRUE if this routine is called by SMI dispatcher
;SW_SMI_FLAG  = FALSE if this routine is called by any other source.
;Note that if this flag is false then the routine is invoked by a SM
;process that has decided to wait like BATT_LOW suspend..But if this
;flag = TRUE then this routine is called by dispatcher and is due to the
;generation of a SW_SMI.
;o/p = none..
;--------------------------------------------------------------------
sw_smi_delay	proc	near

		push	ax
		push	bx
		push	cx
		push	dx
		mov	bp,sp		;get stack top.
;---------------------------------
;First check if SW_SMI_FLAG is true.

		cmp	byte ptr [ SW_SMI_FLAG ],TRUE
		jz	skip_loop_init

loop_init :

;First save the return address of the routine requesting the DELAY.

		mov	bx,word ptr [bp+08h]
		mov	word ptr [sw_smi_return_add],bx

;save PM_REQ_CNTRL..Then enable only SW_SMI and TRAP.

		read_82360sl	SM_REQ_CNTRL
		mov	byte ptr [pm_enable_byte],al

		mov	bl,91h
		write_82360sl	SM_REQ_CNTRL, <bl>

;Calculate SW_SMI_COUNTER value...

		mov	ax,cx
		mov	bx,4
		mul	bx
		mov	word ptr [SW_SMI_COUNTER],ax

skip_loop_init :

;First check if  enough time is granted...

		dec	word ptr [SW_SMI_COUNTER]
		jnz	one_more_time
no_more_time :
		write_82360sl	SM_REQ_CNTRL,80h
		mov	bl,byte ptr [pm_enable_byte]
		and	bl,0feh
		write_82360sl	SM_REQ_CNTRL,<bl>

;Delay is done ..so we return to the routine that requested the delay..
;We acheive this by modifying the image of IP on the stack.

		mov	bx,word ptr [sw_smi_return_add]
		mov	word ptr [bp+08h],bx
		jmp	end_sw_smi_time

one_more_time:

;^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^
;Note : The Only way to clear the SW_SMI is to toggle the enable bit
;in SM_REQ_CNTRL..Please See BIOS NEWS LETTER..

		alter_82360sl	sm_req_cntrl,0feh,00h

		mov	cx,50
waity :		loop	waity

		alter_82360sl	sm_req_cntrl,0ffh,01h

;^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

;You can only write a 0 into status bit but never a 1.This allows us not to
;destroy the bits that are in the process of being set.
;Reset the SW_SMI_STS bit..

		write_82360sl	sm_req_sts,7eh

;Now we will have to give the control to EXIT module so that it makes
;an exit to the application...

		mov	bx,offset EXIT_SMI
		mov	word ptr [bp+08h],bx

end_sw_smi_time	:
		
		pop	dx
		pop	cx
		pop	bx
		pop	ax
		ret
sw_smi_delay	endp
;--------------------------------------------------------------------
;ROUTINE SET_MCP_CLK FOLLOWS...
;TO BE COMPLETED FOR UPPER LAYER SOFTWARE USE..
;------------------------------------------------------------------
SET_MCP_CLK     PROC    NEAR

                RET
SET_MCP_CLK     ENDP
;----------------------------------------------------------------
;ROUTINE GET_MCP_CLK FOLLOWS...
;TO BE COMPLETED FOR UPPER LAYER SOFTWARE USE..
;----------------------------------------------------------------
GET_MCP_CLK     PROC    NEAR

                RET
GET_MCP_CLK     ENDP
;----------------------------------------------------------------
;ROUTINE PM_ENBL_DISBL FOLLOWS...
;TO BE COMPLETED FOR UPPER LAYER SOFTWARE USE..
;----------------------------------------------------------------
PM_ENBL_DISBL   PROC    NEAR

                RET
PM_ENBL_DISBL   ENDP
;----------------------------------------------------------------
;Procedure for making certain APM sanity checks follows...
;Sanity check  results will be as follows..
;No errors ..Perfectly sensible...CY = 0.
;If CY = 1 then AH will have the error code..See equated file for error 
;code values..
;----------------------------------------------------------------
sanity_check	proc	near

		clc		;You are not bad until proven guilty.

;First we check if the connect call has been made..

		cmp	byte ptr [CONNECT_FLAG],TRUE
		jz	ok_connected

not_connected :
		mov	ax,not_connect_err
		stc
		jmp	sanity_check_end

;--------------------------------------------------------------
ok_connected :

;First we get the registers of the caller since APM is a register
;driven interface..
;Note : In A-STEP we use the IN instruction to generate a trap and this
;destroys the AL value. To circumvent this problem we duplicate the AX
;value in the upper half of 32 bit EAX register. And here we retrieve
;this duplicated upper half value..

		mov	si,AX_CPU_DUMP+2
                Mov     ax,word ptr [si]

;Check for a valid APM call first...

		cmp	ah,APM_FN
		jnz	not_an_apm_call
		xor	ax,ax
		clc
		jmp	sanity_check_end
not_an_apm_call :
		stc
		mov	ax,invalid_call

sanity_check_end :
		mov	word ptr [AX_VALUE],ax		
		ret
sanity_check	endp
;----------------------------------------------------------------
;The procedure for processing CPU_IDLE process follows..
;i/p = none...and o/p = none. It wakes up on any interrupt from the hardware.
;The upper level OS issues a CPU_IDLE call whenever it finds that all the
;invoked applications are waiting for some kind of input and are idling..
;There can be several CPU_IDLE calls per second. The number of such calls
;depends on how much the CPU is loaded by the operating system and invoked
;applications..The APM spec tells us that we can reduce consumption of
;the system during these brief intervals ..which we do by stopping the
;CPU clock. But note that we are supposed to keep up the Operating system
;time . So we enable the AT herat beat as a STOP BREAK event. Essentially
;we wake up 18 times a second and update the clock. Once the clock is 
;updated the OS again issues a CPU_IDLE call if applications are still idling.
;------------------------------------------------------------------
cpu_idle_process	proc	near

;Test stub follows..A message is flashed onto the screen to indicate
;that proper detection of CPU_IDLE was made.It is enabled by a proper
;assembler directive at the top of this file.

        if      cpu_idle_mes_flag     eq      enable

		mov	al,22h
		out	80h,al

                mov	si,offset CPU_IDLE_MES
                call near ptr debug_mes

        endif
;--------------------------------------------------------------
;Now if you enable IRQ0 as timer event things don't work so easily
;Please see NEWS LETTER for details..We enable the INTR output from 
;the 8259 PIC as STOP BREAK event. This will allow us to wakeup and service
;timer ticks and any other pending hardware interrupt like mouse.

                ALTER_82360SL   STP_BRK_CFG2,0FFH,08H

;NOW WE STOP THE CLOCK..BUT AT EVERY TIMER TICK OR ANY OTHER HARDWARE
;INTERRUPT WE WAKE UP AND RESUME THE SYSTEM..

                DB      2	DUP (90H)   

                READ_82360SL    STP_CLK    ;stop clock..never did that before.
                                           ;is not that funny...???
                DB      2	DUP (90H)   
;-------------------------------------------------------------
;We disable the INTR output from 8259 as a STOP BREAK EVENT.

                ALTER_82360SL   STP_BRK_CFG2,0F7H,00H
		xor	ax,ax
		mov	si,ax_cpu_dump
                Mov     word ptr [si],ax
		ret
cpu_idle_process	endp
;----------------------------------------------------------------
;Install_apm_check procedure follows..
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
install_apm_check	proc	near

		push	ax
		push	bx
		push	cx
		push	dx
		push	bp
		mov	bp,sp		;Get stack top.
;--------------------------------------------
		cmp	bx,BIOS_DEVICE
		jz	ok2
not_ok2 :
		stc
		mov	word ptr [BP+8],Unknown_device
		jmp	end_install_call
ok2 :
		mov	bx,"PM"
		mov	word ptr [BP+6],bx
		read_xmos	XcmosInfoStart+25d
		mov	ah,al
		and	al,0fh		;Minor version number.
		mov	cx,4
		shr	ah,cl
		and	ah,0fh
		mov	word ptr [BP+8],AX

		read_xmos	XcmosInfoStart+24d
		xor	ah,ah
		mov	word ptr [BP+4],ax	;interface flags..				
		clc
;---------------------------------------------
end_install_call :
		pop	bp
		pop	dx
		pop	cx
		pop	bx
		pop	ax
		ret
install_apm_check	endp
;------------------------------------------------------------------
;apm_connect_call procedure follows..
;i/p = AH = 53h,AL= 01h,BX = 0000h - System BIOS.
;o/p = CY = 0 if function is successful.

;If CY = 1 then AX = 02 if already connected..
;If CY = 1 then AX = 09 if Unrecognised device ID.
;------------------------------------------------------------------
apm_connect_call	proc	near

		push	ax
		push	bx
		push	cx
		push	dx
		push	bp
		mov	bp,sp		;Get stack top.
;---------------------------------------------
		cmp	bx,BIOS_DEVICE
		jz	ok4
not_ok4 :
		stc
		mov	word ptr [BP+8],Unknown_device
		jmp	end_connect_call
ok4 :
		cmp	byte ptr [CONNECT_FLAG],TRUE
		jz	connect_true

not_yet_connected :
		mov	byte ptr [CONNECT_FLAG],TRUE
		mov	byte ptr [APMEventSave],NO_EVENTS	;Clear Junk.
		clc
		xor	ax,ax
		mov	word ptr [bp+8],ax
		jmp	end_connect_call
connect_true :
		stc
		mov	word ptr [bp+8],alreadyConnected
;---------------------------------------------
end_connect_call :
		pop	bp
		pop	dx
		pop	cx
		pop	bx
		pop	ax
		ret
apm_connect_call	endp
;------------------------------------------------------------------
;apm_disconnect_call procedure follows..
;Breaks the co-operative interaction between the System BIOS and
;the caller...
;i/p = AH = 53h,AL= 04h,BX = 0000h - System BIOS.
;o/p = CY = 0 if function is successful.

;If CY = 1 then AX = 03 if interface not connected..
;If CY = 1 then AX = 09 if Unrecognised device ID.
;------------------------------------------------------------------
apm_disconnect_call	proc	near

		push	ax
		push	bx
		push	cx
		push	dx
		push	bp
		mov	bp,sp		;Get stack top.
;---------------------------------------------
		cmp	bx,BIOS_DEVICE
		jz	ok7
not_ok7 :
		stc
		mov	word ptr [BP+8],Unknown_device
		jmp	end_disconnect_call
ok7 :
		cmp	byte ptr [CONNECT_FLAG],FALSE
		jz	connect_false
diconnect_it :
		mov	byte ptr [CONNECT_FLAG],FALSE
;We need to update the global connection flag here so that INT 15 routines 
;can figure out the connection status..

		read_xmos	XcmosInfoStart+23
		and	al,0fh
 		mov	bl,al
		write_xmos	XcmosInfoStart+23,<bl>

		clc
		xor	ax,ax
		mov	word ptr [bp+8],ax
		jmp	end_disconnect_call
connect_false :
		stc
		mov	word ptr [bp+8],alreadyDisconnected
;---------------------------------------------
end_disconnect_call :
		pop	bp
		pop	dx
		pop	cx
		pop	bx
		pop	ax
		ret
apm_disconnect_call	endp
;------------------------------------------------------------------
;apm_cpu_busy procedure follows..
;------------------------------------------------------------------
apm_cpu_busy	proc	near

		stc
	     	ret
apm_cpu_busy	endp
;------------------------------------------------------------------
;apm_set_power procedure follows..
;This call will place the system or the device specified into the 
;requested state by the caller...
;------------------------------------------------------------------
apm_set_power	proc	near

		push	ax
		push	bx
		push	cx
		push	dx
		push	bp
		mov	bp,sp		;Get stack top.
;---------------------------------------------
		cmp	bx,ALL_DEVICES
		jz	no_err1
err1 :
		mov	word ptr [BP+8],Unknown_device
		stc	
		jmp	set_power_call_end
no_err1 :
		read_82360sl	sm_req_cntrl
		test	al,80h
		jnz	no_err2
err2 :
		mov	word ptr [BP+8],Pm_disabled
		stc
		jmp	set_power_call_end
no_err2 :
		cmp	cx,Ready_req
		jz	set_power_call_end
chk_next :
		cmp	cx,standby_req
		jnz	chk_next1
yes_stdby_req :
		cmp	byte ptr [chip_req],StdbyRequest
		jz	strt_stdby				
no_req_stdby :
		mov	word ptr [BP+8],NO_STATE_REQUEST
		stc	
		jmp	set_power_call_end
strt_stdby :
		mov	si,flag_cpu_dump
		and	word ptr [si],CARRY_CLEAR_MASK
		mov	byte ptr [Chip_req],00h
		jmp	noapmgstdby		;jmp to gstdby module..
chk_next1 :
		cmp	cx,suspend_req
		jnz	chk_next2

yes_suspend_req :
		cmp	byte ptr [chip_req],SuspendRequest
		jz	strt_suspend
no_req_suspend :
		mov	word ptr [BP+8],NO_STATE_REQUEST
		stc	
		jmp	set_power_call_end
strt_suspend :
		mov	si,flag_cpu_dump
		and	word ptr [si],CARRY_CLEAR_MASK
		mov	byte ptr [Chip_req],00h
		jmp	dosuspend		;Jump to suspend module..

chk_next2 :
		mov	word ptr [BP+8],invalid_call
		stc
;--------------------------------------------
set_power_call_end :

		pop	bp
		pop	dx
		pop	cx
		pop	bx
		pop	ax
		ret
apm_set_power	endp
;------------------------------------------------------------------
;pm_control procedure follows..
;This function allows the caller to enable or disable all APM
;functions..
;-------------------------------------------------------------------
pm_control	proc	near

		push	ax
		push	bx
		push	cx
		push	dx
		push	bp
		mov	bp,sp		;Get stack top.
;---------------------------------------------
		cmp	bx,pm_device
		jz	try_pm_fn
illegal_dev1 :
		mov	word ptr [BP+8],Unknown_device
		stc	
		jmp	pm_control_end

try_pm_fn :
		cmp	cx,disable_pm
		jz	disable_it
enable_it :
		mov	bl,byte ptr [old_apm_enable]
		alter_82360sl	sm_req_cntrl,0ffh,<bl>
		read_xmos	XcmosInfoStart+24
		and	al,0f7h
		mov	bl,al
		write_xmos	XcmosInfoStart+24,<bl>
		jmp	did_it
disable_it :
		read_82360sl	sm_req_cntrl
		mov	byte ptr [old_apm_enable],al
		alter_82360sl	sm_req_cntrl,91h,00h	;Trap and sw SMI.

		read_xmos	XcmosInfoStart+24
		or	al,08h
		mov	bl,al
		write_xmos	XcmosInfoStart+24,<bl>
did_it :
		clc	
;---------------------------------------------
pm_control_end :
		pop	bp
		pop	dx
		pop	cx
		pop	bx
		pop	ax
		ret
pm_control	endp
;------------------------------------------------------------------
;load_default_parm procedure follows..

load_default_parm	proc	near

		stc
		ret
load_default_parm	endp
;------------------------------------------------------------------
;get_apm_status procedure follows..
;Gets the status of Power supply and stuff..A totally hardware dependant
;call...We just return whatever we know from EVAL board hardware..
;------------------------------------------------------------------
get_apm_status		proc	near

		push	ax
		push	bx
		push	cx
		push	dx
		push	bp
		mov	bp,sp		;Get stack top.
;---------------------------------------------
		cmp	bx,all_devices
		jz	try_apm_status
stat_illegal_dev1 :
		mov	word ptr [BP+8],Unknown_device
		stc
		jmp	apm_status_end
try_apm_status :
		xor	ax,ax
		mov	word ptr [BP+8],ax	;No errors..
stat_make_bx :
		mov	bh,AC_ON_LINE
		mov	bl,UNKNOWN
		mov	word ptr [BP+6],bx
stat_make_cx :
		xor	cx,cx
		mov	cl,UNKNOWN
		mov	word ptr [BP+4],cx
		clc	
;---------------------------------------------
apm_status_end :
		pop	bp
		pop	dx
		pop	cx
		pop	bx
		pop	ax
		ret
get_apm_status		endp
;------------------------------------------------------------------
;get_apm_event procedure follows..
;Returns next pending PM event..or indicates if no PM events are pending..
;------------------------------------------------------------------
get_apm_event		proc	near

		push	ax
		push	bx
		push	cx
		push	dx
		push	bp
		mov	bp,sp		;Get stack top.
;---------------------------------------------
		cmp	byte ptr [APMEventsave],NO_EVENTS
		jnz	pm_event
no_pm_event :
		mov	word ptr [BP+8],NO_EVENTS
		stc	
		jmp	pm_event_end
pm_event :
		xor	bx,bx
		mov	bl,byte ptr [APMEventsave]
		mov	word ptr [BP+6],bx
		mov	word ptr [BP+8],0h	;No errors..
		mov	byte ptr [APMEventsave],NO_EVENTS
		clc
;---------------------------------------------
pm_event_end :
		pop	bp
		pop	dx
		pop	cx
		pop	bx
		pop	ax
		ret
get_apm_event		endp
;------------------------------------------------------------------
;The routine apm_event_process follows...This routine is called
;after a PM_EVENT is detected at the CHIP LEVEL. We process the 
;request here from the APM VIEW POINT here and return the control.
;i/p = AL contains what request brought it here..
;o/p = CY = 1 if we OK the request...and allow the event to happen.
;o/p = CY = 0 if we document and block the chip request and allow
;the SL to function further..
;------------------------------------------------------------------
apm_event_process	proc	near
		push	ax
		push	bx
		push	cx
		push	dx
;----------------------------------
;We check for interface connection

		cmp	byte ptr [CONNECT_FLAG],TRUE
		jz	APM_STUFF
NO_APM_STUFF :
		stc
		jmp	apm_process_end
APM_STUFF :
		cmp	al,StdbyRequest
		jz	stdby_apm_process

no_stdby_apm_process :
		cmp	al,SuspendRequest
		jz	Suspend_apm_process

no_suspend_apm_process :			
		stc
		jmp	apm_process_end		;I dont know this guy..

stdby_apm_process :
		cmp	byte ptr [APMEventSave],SuspendRequest
		jz	PendingSuspendRequest

                mov     byte ptr [APMEventSave],al
                WRITE_XMOS APM_STS_PORT,Event_flag
		mov	byte ptr [Chip_req],Stdbyrequest
PendingSuspendRequest :

		write_82360sl	SM_REQ_STS,5bh
		clc
		jmp	apm_process_end

Suspend_apm_process :
                mov     byte Ptr [APMEventSave],al
                WRITE_XMOS APM_STS_PORT,Event_flag
		mov	byte ptr [Chip_req],SuspendRequest
                WRITE_82360SL   SPND_STS,00     ; CLEAR ALL SUSPEND STATUS.
;---------------------------------------------------------------------
;KILL HW REQUEST...SO THAT IT WOULD NOT HAUNT THE SYSTEM.
;CLEARING INDIVIDUAL AND GROUP REQ BITS WILL NOT CLEARING THE SUSPEND
;PMI REQ. IT HAUNTS YOUR SYSTEM.THE ONLY WAY  TO KILL IT IS TO
;REMOVE THE GROUP ENABLE AND RE-INSTATE IT..
;--------------------------------------------------------------
;SO WE RESET HW_SUS_ENABLE..

                ALTER_82360SL   SM_REQ_CNTRL,0FDH,00

                CALL NEAR PTR SMALL_DELAY
                CALL NEAR PTR SMALL_DELAY

;NOW WE RE-INSTATE THE  HW_SUS_ENABLE..

                ALTER_82360SL   SM_REQ_CNTRL,0FFH,02H
		CLC
;---------------------------------------------------------------------
apm_process_end :
		pop	dx
		pop	cx
		pop	bx
		pop	ax
		ret
apm_event_process	endp
;-------------------------------------------------------------------

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;DATA AREA FOR PM SOFTWARE FOLLOWS.

;APM Data area follows...

critical_event_flag	db	FALSE
SW_SMI_COUNTER		DW	0000h
SW_SMI_FLAG		DW	FALSE
sw_smi_return_add	dw	0000h
connect_flag		db	FALSE
APMEventsave		db	NO_EVENTS
chip_req		db	00h
old_apm_enable		db	00h
;-----------------------------------------------------------------
CR2_VALUE               DB      4 DUP (00)
DR0_VALUE               DB      4 DUP (00)
DR1_VALUE               DB      4 DUP (00)
DR2_VALUE               DB      4 DUP (00)
DR3_VALUE               DB      4 DUP (00)
TR6_VALUE               DB      4 DUP (00)
TR7_VALUE               DB      4 DUP (00)
AX_VALUE                DW      0
BX_VALUE                DW      0
CX_VALUE                DW      0
DX_VALUE                DW      0
KB_STS_LOCN             DW      00
FLOPPY_STAT             DB      ON
HDD_STAT                DB      ON
BACKLIGHT_STAT          DB      ON
LCDPANEL_STAT           DB      ON
DEV0_LSTDBY_STAT        DB      ON
DEV1_LSTDBY_STAT        DB      ON
DEV2_LSTDBY_STAT        DB      ON
DEV3_LSTDBY_STAT        DB      ON

DEV5_LSTDBY_STAT        DB      ON

STP_BRK0_BYTE		DB	00H
STP_BRK1_BYTE		DB	00H
STP_BRK2_BYTE		DB	00H

GSTDBY_ENBL_STAT        DB      ENBL
LSTDBY_ENBL_DEV0        DB      ENBL
LSTDBY_ENBL_DEV1        DB      ENBL
LSTDBY_ENBL_DEV2        DB      ENBL
LSTDBY_ENBL_DEV3        DB      ENBL

;LSTDBY_ENBL_DEV5        DB      ENBL

DEV0_LSTDBY_FEATURE     DB      ENBL
DEV1_LSTDBY_FEATURE     DB      ENBL
DEV2_LSTDBY_FEATURE     DB      ENBL
DEV3_LSTDBY_FEATURE     DB      ENBL
DEV4_LSTDBY_FEATURE     DB      ENBL
DEV5_LSTDBY_FEATURE     DB      ENBL
;-----------------------------------------------------
NPX_SAVE_AREA           DB      80H     DUP (00)        ;RESERVE 120 BYTES..
A20_STATUS_BYTE         DB      00H
MY_LOCN                 DB      00H
OLD_RTC_INDEX           DB      00H
MASTER_OLD_MASK         DB      00H
SLAVE_OLD_MASK          DB      00H
PM_ENABLE_BYTE          DB      00H
LTRP_STS_BYTE           DB      00H
BITMASK                 DB      ?
A20_STATUS              DB      00
INT10_OFFSET            DW      00
INT10_SEG               DW      00
OLD_CMOS_BYTE           DB      00
SMI_REQ_STS_BYTE        DB      00
SUS_REQ_FLAG            DB      00
SUS_FLAG                DB      NO
UNKNOWN_SMI_MES         DB      "DISPATCH : Unknown request or 82360SL read "
                        DB      "error..",00
UNKNOWN_SUS_MES         DB      "SUSPEND : Unknown suspend request OR "
                        DB      "82360SL read error..",00
;####################################################################
;MESSAGES AND DATA FOR TEST STUBS.
EXT_SMI_MES             DB      "EXT_SMI  OCCURED.That is all I know..",00
HW_SMI_MES              DB      "HW_SUS_REQ has occured...",00
DEV_DRVR_MES            DB      "SUSPEND : Calling Device driver...",00
DEV_DRVR_MES_RES        DB      "RESUME  : Calling Device driver...",00
DEV_DRVR_ERR_MES        DB      "SUSPEND : Device driver failed...",00
DEV_DRVR_ERR_MES_RES    DB      "RESUME  : Device driver failed...",00
RES_EVENT_MES           DB      "RESUME  : RESUME PROCESSING STARTED..",00
SW_SMI_MES              DB      "DISPATCH : Software SMI Occured...",00
SW_PM_REQ_MES           DB      "DISPATCH : Bob is calling me..",00
LCD_MES                 DB      "LSTDBY : I AM HERE AT LCD..",00
LSTDBY_MES0             DB      'LSTDBY : LOCAL STANDBY REQ -- 0 OCCURED..,',00
LSTDBY_MES1             DB      'LSTDBY : LOCAL STANDBY REQ -- 1 OCCURED..,',00
LSTDBY_MES2             DB      'LSTDBY : LOCAL STANDBY REQ -- 2 OCCURED..,',00
LSTDBY_MES3             DB      'LSTDBY : LOCAL STANDBY REQ -- 3 OCCURED..,',00
LSTDBY_MES4             DB      'LSTDBY : LOCAL STANDBY REQ -- 4 OCCURED..,',00
LSTDBY_MES5             DB      'LSTDBY : LOCAL STANDBY REQ -- 5 OCCURED..,',00
LSTDBY_FAULT_MES        DB      'LSTDBY STS REGISTER IS 00 H ',00

LTRP_MES0               DB      'LTRP : LOCAL TRAP REQUEST -- 0 OCCURED..,',00
LTRP_MES1               DB      'LTRP : LOCAL TRAP REQUEST -- 1 OCCURED..,',00
LTRP_MES2               DB      'LTRP : LOCAL TRAP REQUEST -- 2 OCCURED..,',00
LTRP_MES3               DB      'LTRP : LOCAL TRAP REQUEST -- 3 OCCURED..,',00
LTRP_MES4               DB      'LTRP : LOCAL TRAP REQUEST -- 4 OCCURED..,',00
LTRP_MES5               DB      'LTRP : LOCAL TRAP REQUEST -- 5 OCCURED..,',00
LTRP_FAULT_MES          DB      'TRAP STATUS REGISTER IS 00 H ',00

GSTDBY_MESB             DB      'GSTDBY : (BEFORE ) GLOBAL STDBY REQ OCCURED..',00
GSTDBY_MESE             DB      'GSTDBY : (AFTER ) CLOCK TURNED ON NOW..',00
BUG_MES                 DB      'BUG...BUG....READ THE POST PORT NOW...',00
I_AM_HERE_MES           DB      'CONTROL: I AM HERE..I AM HERE..',00
I_AM_HERE_MES1          DB      'CONTROL1: I AM HERE..WATCH POST CODE .',00

cpu_idle_mes		db	'CPU_IDLE : CPU_IDLE call detected..',00
APM_REQ_MES		DB	'SW_APM : APM request detected...',00
;#####################################################################


;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

CODE            ENDS
END     START
