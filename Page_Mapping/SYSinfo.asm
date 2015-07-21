;    SYSinfo.asm
;    System Information
;			0x0003_0000 ~ 0x0003_FFFF
;		    LBA:3,4           = 2 Sectors
;    By using Library codes to fill this file.
;
;   Finally Modified by: ;	Mighten Dai<mighten.dai@gmail.com>
;                             16:56, July 20, 2015
;
;##############################################

%include "common_macro.asm"


GDT_Head:
	DQ		0x00000000_00000000	; # 0  NULL .
	DQ		0x00CF9A00_0000FFFF	; # 1  Ring0FlatCode.
	DQ		0x00CF9200_0000FFFF	; # 2  Ring0FlatData.
	DQ		0x00CFFA00_0000FFFF	; # 3  Ring3FlatCode.
	DQ		0x00CFF200_0000FFFF	; # 4  Ring3FlatData.
	DQ		0x00008903_0200006E ; # 5  Kernel Task TSS

GDT_Tail:

	times 0x200 - ( $ - GDT_Head ) db 0x00

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;  Task A
;      Base address: 0x0003_0200
;            Length:  104 Bytes 

Kernel_Task_head:
	Kernel_previous_TSS_Selector:  dw  0
	                               dw  0 ; Reserved.
	Kernel_ESP0:                   dd  0
	Kernel_SS0_selector:           dw  0
                                   dw  0 ; Reserved.
	Kernel_ESP1:                   dd  0
	Kernel_SS1_selector:           dw  0
                                   dw  0 ; Reserved.
	Kernel_ESP2:                   dd  0
	Kernel_SS2_selector:           dw  0
                                   dw  0 ; Reserved.
	Kernel_CR3_Reg:                dd  PDPTE
	Kernel_EIP_Reg:                dd  0x0002_0000
	Kernel_EFLAGS:                 dd  0
	Kernel_EAX_Reg:                dd  0
	Kernel_ECX_Reg:                dd  0
	Kernel_EDX_Reg:                dd  0       ; ??????????????????????????????
	Kernel_EBX_Reg:                dd  0       ; Why there uses the Virtual Address instead of Physical Address
	Kernel_ESP_Reg:                dd  vir_address_kernel_empty_stack_esp ; Empty Stack, Range:0x0004_0000 ~ 0x0004_FFFF
	Kernel_EBP_Reg:                dd  0       ; Because according to the experiment, 
	Kernel_ESI_Reg:                dd  0       ;   which shows that load TSS Selector into TR does not modify the ESP.
	Kernel_EDI_Reg:                dd  0
	Kernel_ES_selector:            dw  0
	                               dw  0 ; Reserved.
	Kernel_CS_selector:            dw  Ring0FlatCode
	                               dw  0 ; Reserved.
	Kernel_SS_selector:            dw  Ring0FlatData
	                               dw  0 ; Reserved.
	Kernel_DS_selector:            dw  0
	                               dw  0 ; Reserved.
	Kernel_FS_selector:            dw  0
	                               dw  0 ; Reserved.
	Kernel_GS_selector:            dw  0
	                               dw  0 ; Reserved.
	Kernel_LDT_selector:           dw  0
	                               dw  0 ; Reserved.
	Kernel_Trap_Flag__Bit0_Only:   dw  0 ; Only Bit0 Available.
	Kernel_IO_Map_Offset_Of_TSS:   dw  0
Kernel_Task_tail:
times  0x6E - ( $ - Kernel_Task_head ) db 0x00

; Here...
; 0x0000_034A offset inside this file.
; 0x0003_034A  absolute offset of the system.

times  0x400 - ( $ - $$ ) db 0xCC