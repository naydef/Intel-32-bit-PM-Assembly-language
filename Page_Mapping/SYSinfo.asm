;    SYSinfo.asm
;    System Information(Phy-Address == Vir-Address)
;			0x0003_0000 ~ 0x0003_FFFF
;		    LBA:3,4           = 2 Sectors
;    By using Library codes to fill this file.
;
;   Finally Modified by: ;	Mighten Dai<mighten.dai@gmail.com>
;                             15:32, July 22, 2015
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
	DQ		0x00008903_026E006E ; # 6  Task A TSS
GDT_Tail:

	times 0x200 - ( $ - GDT_Head ) db 0x00

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;  Kernel Task
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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;  Task A TSS: 
;            Base address: 0x0003_026E
;            Length:  104 Bytes 
Task_A_TSS_Head:
	Task_A_previous_TSS_Selector:  dw  0
	                               dw  0 ; Reserved.
	Task_A_ESP0:                   dd  0
	Task_A_SS0_selector:           dw  0
                                   dw  0 ; Reserved.
	Task_A_ESP1:                   dd  0
	Task_A_SS1_selector:           dw  0
                                   dw  0 ; Reserved.
	Task_A_ESP2:                   dd  0
	Task_A_SS2_selector:           dw  0
                                   dw  0 ; Reserved.
	Task_A_CR3_Reg:                dd  PDPTE
	Task_A_EIP_Reg:                dd  vir_address_Task_A_base
	Task_A_EFLAGS:                 dd  0
	Task_A_EAX_Reg:                dd  0
	Task_A_ECX_Reg:                dd  0
	Task_A_EDX_Reg:                dd  0
	Task_A_EBX_Reg:                dd  0
	Task_A_ESP_Reg:                dd  vir_address_Task_A_empty_stack_esp
	Task_A_EBP_Reg:                dd  0
	Task_A_ESI_Reg:                dd  0
	Task_A_EDI_Reg:                dd  vir_address_video_buffer_head
	Task_A_ES_selector:            dw  Ring0FlatCode
	                               dw  0 ; Reserved.
	Task_A_CS_selector:            dw  Ring0FlatCode
	                               dw  0 ; Reserved.
	Task_A_SS_selector:            dw  Ring0FlatData
	                               dw  0 ; Reserved.
	Task_A_DS_selector:            dw  0
	                               dw  0 ; Reserved.
	Task_A_FS_selector:            dw  0
	                               dw  0 ; Reserved.
	Task_A_GS_selector:            dw  0
	                               dw  0 ; Reserved.
	Task_A_LDT_selector:           dw  0
	                               dw  0 ; Reserved.
	Task_A_Trap_Flag__Bit0_Only:   dw  0 ; Only Bit0 Available.
	Task_A_IO_Map_Offset_Of_TSS:   dw  0
Task_A_TSS_Tail:
times  0x6E - ( $ - Task_A_TSS_Head ) db 0x00

; Here...
; 0x0000_02DC offset inside this file.
; 0x0003_02DC  absolute offset of the system.


times  0x400 - ( $ - $$ ) db 0xCC