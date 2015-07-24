;
;		common_macro.asm
;
;     Standard Macro Reference.

NULL_Selector           EQU 0x00 ; # 0 
Ring0FlatCode           EQU	0x08 ; # 1
Ring0FlatData           EQU	0x10 ; # 2
Ring3FlatCode           EQU	0x18 ; # 3
Ring3FlatData           EQU	0x20 ; # 4
Kernel_Task_Selector    EQU	0x28 ; # 5

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;   GDT information:
;
GDT_Limit:    EQU  0x8 * 0x6    ; ( 0x8 * 0x6 ) Bytes Effective, 0x100 Bytes totally
GDT_Base:     EQU  0x0003_0000

;
;
;
phy_address_kernel_base   EQU 0x0002_0000
phy_address_kernel_empty_stack_esp EQU 0x0005_0000
phy_address_Task_A_empty_stack_esp EQU 0x0007_0000

phy_address_video_buffer_head  EQU 0x000B_8000