;File REG_EQU.INC has all the equates for PM routines.
;Include this file in the main before assembly.
;Intel Corp. 2625 Walsh Ave, Santa Clara,CA 95051.
;Date MAY 10,1990.


;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *

;    INTEL CORPORATION  MAKES  NO WARRANTY  FOR THE  USE OF THIS

;    EXAMPLE  AND  ASSUMES  NO  RESPONSIBILITY  FOR  ANY  ERRORS

;    WHICH  MAY  APPEAR  IN  THIS  EXAMPLE  PROGRAM   NOR  DOES

;    IT MAKE  A  COMMITMENT  TO  UPDATE  THE  INFORMATION  THAT

;    ARE  CONTAINED  HEREIN.

;* * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * * *
;Equates for PM registers follow..


CPUPWRMODE	EQU	22H

;82360SL Access Registers

CFGSTAT         EQU     023H    ;Configuration Space Status Register (I/O Adr)
CFGINDEX        EQU     024H    ;Configuration Space Index Register  (I/O Adr)
CFGDATA         EQU     025H    ;Configuration Space Data Register   (I/O Adr)
IDXLCK          EQU     0FAH    ;Configuration Space Lock Register   (Index)


;82360SL Power Management Register indexes

STP_BRK_CFG0       EQU  0B0H    ;Stop Break Register 0
STP_BRK_CFG1       EQU  0B1H    ;Stop Break Register 1
STP_BRK_CFG2       EQU  0B2H    ;Stop Break Register 2
SYS_EVNT_CFG0      EQU  0B3H    ;System Event Register 0
SYS_EVNT_CFG1      EQU  0B4H    ;System Event Register 1
SYS_EVNT_CFG2      EQU  0B5H    ;System Event Register 2
SM_REQ_CNTRL       EQU  0B6H    ;System Management Control
SM_REQ_STS         EQU  0B7H    ;Power Management REQUest
SPND_STS           EQU  0B8H    ;Suspend Status Register
STDBY_TMP_CNTRL    EQU  0B9H    ;Standby Timer Control
LSTDBY_STS         EQU  0BAH    ;Local Standby Idle Timer Count
LTRP_STS           EQU  0BBH    ;Local Trap Status
RESUME_MASK        EQU  0BCH    ;Resume Mask Register
SMI_CLR            EQU  0BDH    ;PMI Clear
SUS_WRN_TMR        EQU  0BEH    ;PMI Warning Timer Count
SUS_WRN_TMR_SRBTN	EQU	0F6H
TRP_ADRL_DEV0      EQU  0C0H    ;I/O Base Low Address Device 0
TRP_ADRH_DEV0      EQU  0C1H    ;I/O Base High Address Device 0
TRP_ADR_MSK_DEV0   EQU  0C2H    ;I/O Mask Device 0
LSTDBY_TMR_DEV0    EQU  0C3H    ;I/O Idle Timer Device 0
TRP_ADRL_DEV1      EQU  0C8H    ;I/O Base Low Address Device 1
TRP_ADRH_DEV1      EQU  0C9H    ;I/O Base High Address Device 1
TRP_ADR_MSK_DEV1   EQU  0CAH    ;I/O Mask Device 1
LSTDBY_TMR_DEV1    EQU  0CBH    ;I/O Idle Timer Device 1
TRP_ADRL_DEV2      EQU  0D0H    ;I/O Base Low Address Device 2
TRP_ADRH_DEV2      EQU  0D1H    ;I/O Base High Address Device 2
TRP_ADR_MSK_DEV2   EQU  0D2H    ;I/O Mask Device 2
LSTDBY_TMR_DEV2    EQU  0D3H    ;I/O Idle Timer Device 2
TRP_ADRL_DEV3      EQU  0D8H    ;I/O Base Low Address Device 3
TRP_ADRH_DEV3      EQU  0D9H    ;I/O Base High Address Device 3
TRP_ADR_MSK_DEV3   EQU  0DAH    ;I/O Mask Device 3
LSTDBY_TMR_DEV3    EQU  0DBH    ;I/O Idle Timer Device 3
TRP_ADRL_DEV4      EQU  0E0H    ;I/O Base Low Address Device 4
TRP_ADRH_DEV4      EQU  0E1H    ;I/O Base High Address Device 4
TRP_ADR_MSK_DEV4   EQU  0E2H    ;I/O Mask Device 4
LSTDBY_TMR_DEV4    EQU  0E3H    ;I/O Idle Timer Device 4
TRP_ADRL_DEV5      EQU  0E8H    ;I/O Base Low Address Device 5
TRP_ADRH_DEV5      EQU  0E9H    ;I/O Base High Address Device 5
TRP_ADR_MSK_DEV5   EQU  0EAH    ;I/O Mask Device 5
LSTDBY_TMR_DEV5    EQU  0EBH    ;I/O Idle Timer Device 5
APWR_TMRH          EQU  0F0H    ;Count High Auto Power Off Timer
APWR_TMRL          EQU  0F1H    ;Count Low  Auto Power Off Timer
GSTDBY_TMRH        EQU  0F2H    ;Count High Global Timer
GSTDBY_TMRL        EQU  0F3H    ;Count Low  Global Timer
SUS_WRN_TMR_APWR   EQU  0F4H    ;Auto Power Off Timer Count
SUS_WRN_TMR_BAT    EQU  0F5H    ;Battery Low Timer Count
SUS_WRN_TMR_SRBTN  EQU  0F6H    ;Button Timer Count
CRST_TMR           EQU  0F7H    ;CPU Reset Delay Timer Count
CRST_PULSE         EQU  0F8H    ;CPU Reset Pulse Timer Count
SMI_MARK           EQU  0F9H    ;PMI Mark
EXT_STS            EQU  0FBH    ;External Status
KC_CLK_CNTRL       EQU  0FCH    ;Keyboard Clock Control
STP_CLK            EQU  0FDH    ;Stop Clock Register
PWROFF_CNTL       EQU  0FEH    ;Device Power Control
PM_SUSREF          EQU  0FFH    ;82360SL Suspend Refresh
STDBY_TMR_CNTRL	   EQU	0B9H	;LOCAL STD BY TIMER ENABLE.
;---------------------------------------------------------------------------
;EQUATES FOR PM SOFTWARE FOLLOW........
KBC_CMD_REG	EQU	64H
KBC_DATA_REG	EQU	60H
READ_KBC_OP_PORT	EQU	0D0H
WRITE_KBC_OP_PORT	EQU	0D1H
STACK_TOP	EQU	0E000H
VIDEO_SEG	EQU	0B800H
UNLOCK_BIT	EQU	01H
LOCK_BIT	EQU	0100H
IOCFGOPN	EQU	80H
SW_REQ		EQU	01H
HW_SUSREQ	EQU	02H
GSTDBY_REQ	EQU	04H
LSTDBY_REQ	EQU	08H
LTRP_REQ	EQU	10H
EXT_SMI_REQ	EQU	40H
KEY_BIOS_STS_LOCN	EQU	0417H

SYS_IN_STDBY	EQU	80H
HALT_BIT	EQU	40H
EIP_IMAGE_LOCN	EQU	0FFF0H
APWR_OFF_SUSREQ EQU	01H
BATT_LOW_SUSREQ	EQU	02H
SRBTN_SUSREQ	EQU	04H

EOR			EQU	0FFH
YES			EQU	0FFH
NO			EQU	00H
MORE			EQU	0FFH
NO_MORE			EQU	00H
SUS_NUMB_PTR		EQU	05H
RES_NUMB_PTR		EQU	04H
VALID_BIT		EQU	80H
VALID_BIT_PTR		EQU	07H
MESSAGE_BIT		EQU	80H
MESSAGE_BIT_PTR		EQU	06H
CMOSADD			EQU	70H
CMOSDATA		EQU	71H
SHUTDOWN_SUS_ADD	EQU	0FH
SHUTDOWN_RESUME		EQU	0DH
SMALL_DELAY_BYTE	EQU	8000H
MCRF			EQU	301H
PM_SUS_REF		EQU	0FFH
OMLCR			EQU	301H
MCBS			EQU	306H
EBC1CR			EQU	300H
NMI_OFF			EQU	80H
NMI_MASK		EQU	70H
;----------------------------------------------------
OMSECR		EQU	30CH
OMSFCR		EQU	30EH
OMSCCR		EQU	308H
OMSDCR		EQU	30AH
CCR		EQU	300H
MCDRAMMD	EQU	304H
MCMODE		EQU	300H
OMDCR           EQU     302H
OPEN_FILE       EQU     03DH
READ_ONLY       EQU     00H
SM_SEG          EQU     03000H
ENTRY_PT        EQU     08000H
CACHE_SHADOW_ENBL	EQU	03H
SYSTEM_STATUS_ADD	EQU	20H

XCMOS_INDEX     EQU     074H
XCMOS_DATA      EQU     076H

SHNMIMASK	EQU	2EH
CMOS_INDEX      EQU     070H
CMOS_DATA       EQU     071H

FULL            EQU     00H     ; full speed
HALF            EQU     10H     ; divide by 2
FOURTH          EQU     20H     ; divide by 4
EIGHTH          EQU     30H     ; divide by 8
KC_CLK_CNTRL    EQU     0FCH
BY_ONE          EQU     00H
BY_TWO          EQU     01H
BY_FOUR         EQU     02H
GSTDBY_TMRL     EQU     0F3H
GSTDBY_TMRH     EQU     0F2H
APWR_TMRL       EQU     0F1H
APWR_TMRH       EQU     0F0H
SUS_WRN_TMR_APWR EQU    0F4H
SM_REQ_CNTRL    EQU     0B6H
PM_REQ_STS	EQU	0B7H
LSTDBY_BASE     EQU     0C3H
SMOUT_CNTRL     EQU     0FEH
MCP_FULL        EQU     00H
MCP_HALF        EQU     08H
MCP_FOURTH      EQU     10H
MCP_EIGHTH      EQU     18H
SIXTEENTH       EQU     20H
PIN_ZERO        EQU     01H
PIN_ONE         EQU     02H
PIN_TWO         EQU     04H
PIN_THREE       EQU     08H
PIN_FOUR        EQU     10H
PIN_FIVE        EQU     20H
RES_ZERO        EQU     0FEH
RES_ONE         EQU     0FDH
RES_TWO         EQU     0FBH
RES_THREE       EQU     0F7H
RES_FOUR        EQU     0EFH
RES_FIVE        EQU     0BFH
SUS_REF_ENBL	EQU	25H
SUS_REF_FACTOR	EQU	05H
DEV0_TRPREQ	EQU	01H
DEV1_TRPREQ	EQU	02H
DEV2_TRPREQ	EQU	04H
DEV3_TRPREQ	EQU	08H
DEV4_TRPREQ	EQU	10H
DEV5_TRPREQ	EQU	20H
;--------------------------------------------------------
;SPECIFIC EQUATES FOR SW POWER MANAGEMENT INTERFACE.

SET_CPU_CLOCK		EQU	01H
GET_CPU_CLOCK		EQU	81H
SET_KB_CLK		EQU	02H
GET_KB_CLK		EQU	82H
LOAD_GST		EQU	03H
GET_GST			EQU	83H
LOAD_APOT		EQU	04H
GET_APOT		EQU	84H
LOAD_APOW		EQU	05H
GET_APOW		EQU	85H
DISABLE_POFF		EQU	06H
ENABLE_POFF		EQU	07H
DISABLE_STANDBY		EQU	08H
ENABLE_STANDBY		EQU	09H
SUSPEND_SYSTEM		EQU	10H
READ_STEPDOWN		EQU	11H
LOAD_STEPDOWN		EQU	12H
SET_DEV_PON		EQU	13H
SET_DEV_POFF		EQU	14H
READ_DEV_PWR		EQU	15H
ENABLE_STEP		EQU	17H
DISABLE_STEP		EQU	18H
SET_MCP_CLOCK		EQU	19H
GET_MCP_CLOCK		EQU	99H
CTL_PWR_MGT		EQU	20H
HDD_COMM_PORT		EQU	1F7H
HDD_PRAIRIETEK_PWRSAVE	EQU	0F8H
HDD_PRAIRIETEK_STDBY	EQU	0E0H
HDD_PRAIRIETEK_PWRMODE	EQU	0F8H
XMOS_ADD		EQU	74H
XMOS_DATA		EQU	76H
DEV0_STDBYREQ		EQU	01H
DEV1_STDBYREQ		EQU	02H
DEV2_STDBYREQ		EQU	04H
DEV3_STDBYREQ		EQU	08H
DEV4_STDBYREQ		EQU	10H
DEV5_STDBYREQ		EQU	20H

;--------------------------------------------------------
;POST CODES FOLLOW...
POST_PORT		EQU	80H
RSM_DETECT		EQU	97H
REF_NORMAL		EQU	98H
SMRAM_BAD		EQU	89H
SMRAM_OK		EQU	88H
RSM_FAIL		EQU	8FH
LSTDBY_PROC		EQU	4CH
TRAP_PROC		EQU	54H
STOP_CLK		EQU	0AAH
START_CLK		EQU	55H
SUSPEND			EQU	94H
RESUME			EQU	9AH
;---------------------------------------------------------

;THESE EQUATES WERE EXTRACTED BY LOAD1.ASM ...MAY BE REPEATED...CLEAN IT.
EXIT_CODE	EQU	4CH
OPSYS		EQU	21H
PROC_TERM	EQU	20H
OMDCR		EQU	302H
MCPMRAM		EQU	310H
OMSBCR		EQU	306H
OMLCR		EQU	301H
TRUE		EQU	00H
FALSE		EQU	0FFH
ON		EQU	0FFH
OFF		EQU	00H
ENBL		EQU	0FFH
DISBL		EQU	00H
SMI_DATA_SEGMENT  EQU	37F0H
MASTER_PIC_MASK	EQU	21H
SLAVE_PIC_MASK	EQU	0A1H
;-------------------------------------------------------------
;APM equates follow...

XcmosInfoStart  	equ     96d	;That is where APM info starts.
Critical_Suspend_Delay	EQU	30d	;30 Sec Wait for OS authorization.
SW_SMI_TMR		EQU	0BEh	;That is the register.
AX_CPU_DUMP		EQU	0FFD0h	;SMI microcode dumps AX there..
BX_CPU_DUMP		EQU	0FFDCh	;SMI microcode dumps BX there..
CX_CPU_DUMP		EQU	0FFD4h	;SMI microcode dumps CX there..
FLAG_CPU_DUMP		EQU	0FFF4h	;SMI microcode dumps flags there..
CARRY_CLEAR_MASK	EQU	0FFFEh	;AND this to clear carry flag.
CARRY_SET_MASK		EQU	0001h	;OR this to set carry flag.
;---------------------------------------------------------------
;APM Error codes follow...
pm_disabled		equ	01h
not_connect_err		equ	03h
alreadyConnected	equ	02h
alreadyDisconnected	equ	03h
invalid_call		equ	1fh
Unknown_device		equ	09h
NO_STATE_REQUEST	EQU	60h
NO_EVENTS		equ	80h
EVENT_FLAG		equ	1
APM_STS_PORT		equ	124d
disable_pm		equ	0h
no_16bit_support	equ	06h
done_16bit		equ	05h
no_32bit_support	equ	08h
done_32bit		equ	07h
;---------------------------------------------------------------
;Device ID for APM follows..
BIOS_DEVICE	equ	0000h
ALL_DEVICES	equ	0001h
pm_device	equ	0ffffh
;---------------------------------------------------------------
;OS APM requests to our PM BIOS are as follows...

Ready_req		equ	0000h
standby_req		equ	0001h
suspend_req		equ	0002h
off_req			equ	0003h
;---------------------------------------------------------------
;APM function list follows..

APM_FN			equ	53h
BATT_LOW_REQUEST	equ	05h
CPU_IDLE_FN		equ	05h
Installation_Check	equ	00h
Interface_Connect	equ	01h
Interface_16bit_connect equ	02h
Interface_32bit_connect equ	03h
Interface_Disconnect	equ	04h
cpu_busy		equ	06h
set_power_state		equ	07h
apm_cntrl		equ	08h
default_load		equ	09h
get_apm_sts		equ	0ah
get_apm_evnt		equ	0bh
connect_call_made	equ	80h
;--------------------------------------------------------------
;PM EVENTS ARE AS FOLLOWS...
StdbyRequest		equ	01h
suspendrequest		equ	02h
resume_normal_notify	equ	03h
resume_critical_notify	equ	04h
batt_low_notify		equ	05h
;---------------------------------------------------------------
SYS_ROM_SEGMENT		equ	0E000h
ROM_SIGNATURE		equ	0AA55h
rom_pm_prog_start	equ	3000h
rom_INT15_prog_start	equ	2000h
rom_INIT_prog_start	equ	0003h
rom_size		equ	8000h
Int15_position		equ	0054h
BiosRamInt15_Offset	equ	04B5h
chk_sum_byte		equ	0006h
key_int			equ	16h
;---------------------------------------------------------------
;APM Status Byte definitions are here..
APM_SUPPORT_BIT		equ	00000001b
PROT16_SUPPORT_BIT	equ	00000100b
CALL16BIT_DONE_BIT	equ	01000000b
CALL32BIT_DONE_BIT	EQU	00100000b
;---------------------------------------------------------------
;APM Power Status events..
AC_ON_LINE	equ	01h
AC_OFF_LINE	equ	00h
UNKNOWN		equ	0ffh
;----------------------------------------------------------------
