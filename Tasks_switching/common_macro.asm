;
;		common_macro.asm
;
;     Standard Macro Reference.

NULL                    EQU 0x00 ; # 0 
Ring0FlatCode           EQU	0x08 ; # 1
Ring0FlatData           EQU	0x10 ; # 2
Ring3FlatCode           EQU	0x18 ; # 3
Ring3FlatData           EQU	0x20 ; # 4
Task_A_Selector         EQU	0x28 ; # 5
Task_B_Selector         EQU	0x30 ; # 6
Kernel_Task_Selector    EQU	0x38 ; # 7



phy_address_kernel_data_base          EQU 0x0003_0000
phy_address_kernel_base               EQU 0x0002_0000
phy_address_kernel_empty_stack_esp    EQU 0x0005_0000

phy_address_Task_A_base 	          EQU 0x0005_0000
phy_address_Task_A_empty_stack_esp    EQU 0x0007_0000

phy_address_Task_B_base 	          EQU 0x0007_0000
phy_address_Task_B_empty_stack_esp    EQU 0x0009_0000

phy_address_video_buffer_head         EQU 0x000B_8000

GDT_Limit       EQU     0x8 * 8
GDT_Base        EQU     phy_address_kernel_data_base
