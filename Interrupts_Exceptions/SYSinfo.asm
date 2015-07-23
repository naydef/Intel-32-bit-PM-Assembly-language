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

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;  Global Descriptor Table
;    ----> Phy-Address Location = 0x0003_0000
GDT_Head:
	DQ		0x00000000_00000000	; # 0  NULL .
	DQ		0x00CF9A00_0000FFFF	; # 1  Ring0FlatCode.
	DQ		0x00CF9200_0000FFFF	; # 2  Ring0FlatData.
	DQ		0x00CFFA00_0000FFFF	; # 3  Ring3FlatCode.
	DQ		0x00CFF200_0000FFFF	; # 4  Ring3FlatData.
	DQ		0x00008903_0200006E ; # 5  Kernel Task TSS
	DQ		0x00008903_026E006E ; # 6  Task A TSS
GDT_Tail:
	times 0x100 - ( $ - GDT_Head ) db 0x00

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;    Interrupt Descriptor Table, 0x00 - 0x1F, No User Defined interruption taken into consideration.
;            ----> Phy-Address Location = 0x0003_0100
;  Reference Manual:
;     Intel(R) 64 And IA-32 Architectures Software Developer's Manual 
;      Volume 3, System Programming Guidance
;           Order number 325384, Order Number: 325384-055US, June 2015
IDT_Head:
	DQ		0x00078E00_00080000	; **# 00  #DE, Divide Error.
	DQ		0x00000000_00000000	; # 01  #DB, Debug exceptions(Under Construction)
	DQ		0x00000000_00000000	; # 02       Nonmaskable interrupt(Under Construction)
	DQ		0x00078F00_00080960	; **# 03  #BP, Breakpoint, or INT3 instruction (Under Construction)
	DQ		0x00000000_00000000	; # 04  #OF, Overflow, also INTO instruction (Under Construction)
	DQ		0x00000000_00000000	; # 05  #BR, Bounds Range Exceeded, BOUND instruction (Under Construction)
	DQ		0x00078E00_000812C0	; **# 06  #UD, Undefined/Invalid Opcode(Under Construction)
	DQ		0x00000000_00000000	; # 07  #NM, Device/Coprocessor not available(Under Construction)
	DQ		0x00000000_00000000	; # 08  #DF, Double fault(Under Construction)
	DQ		0x00000000_00000000	; # 09      ****(Reserved Officially)
	DQ		0x00000000_00000000	; # 0A  #TS, Invalid TSS(Under Construction)
	DQ		0x00000000_00000000	; # 0B  #NP, Segment Not Present(Under Construction)
	DQ		0x00000000_00000000	; # 0C  #SS, Stack exception(Under Construction)
	DQ		0x00078E00_000828A0	; **# 0D  #GP, General protection(Under Construction)
	DQ		0x00000000_00000000	; # 0E  #PF, Page Fault(Under Construction)
	DQ		0x00000000_00000000	; # 0F      ****(Reserved Officially)
	DQ		0x00000000_00000000	; # 10  #MF, Math Fault, Coprocessor/x87_FPU_Floating-Point Error(Under Construction)
	DQ		0x00000000_00000000	; # 11  #AC, Alignment Check(Under Construction)
	DQ		0x00000000_00000000	; # 12  #MC, Machine Check(Under Construction)
	DQ		0x00000000_00000000	; # 13  #XM, SIMD Floating-Point Exception(Under Construction)
	DQ		0x00000000_00000000	; # 14  #VE, Virtualization Exception
	DQ		0x00000000_00000000	; # 15  \    ****(Reserved Officially)
	DQ		0x00000000_00000000	; # 16  |    ****(Reserved Officially)
	DQ		0x00000000_00000000	; # 17  |    ****(Reserved Officially)
	DQ		0x00000000_00000000	; # 18  |    ****(Reserved Officially)
	DQ		0x00000000_00000000	; # 19  |    ****(Reserved Officially)
	DQ		0x00000000_00000000	; # 1A  |    ****(Reserved Officially)
	DQ		0x00000000_00000000	; # 1B  |    ****(Reserved Officially)
	DQ		0x00000000_00000000	; # 1C  |    ****(Reserved Officially)
	DQ		0x00000000_00000000	; # 1D  |    ****(Reserved Officially)
	DQ		0x00000000_00000000	; # 1E  |    ****(Reserved Officially)
	DQ		0x00000000_00000000	; # 1F  /    ****(Reserved Officially)
	; The 0x20-th is the user-defined interruption, but it is not taken in to my consideration.
IDT_Tail:
	times 0x100 - ( $ - IDT_Head ) db 0x00

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
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
	Kernel_EIP_Reg:                dd  phy_address_kernel_base
	Kernel_EFLAGS:                 dd  0
	Kernel_EAX_Reg:                dd  0
	Kernel_ECX_Reg:                dd  0
	Kernel_EDX_Reg:                dd  0
	Kernel_EBX_Reg:                dd  0
	Kernel_ESP_Reg:                dd  phy_address_kernel_empty_stack_esp
	Kernel_EBP_Reg:                dd  0
	Kernel_ESI_Reg:                dd  0
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
	Task_A_EDI_Reg:                dd  0
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