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
