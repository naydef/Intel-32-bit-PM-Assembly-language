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
Task_A_Selector    		EQU	0x30 ; # 6


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;   GDT information:
;
GDT_Base:     EQU  0x0003_0000
GDT_Limit:    EQU  0x8 * 0x7    ; ( 0x8 * 0x7 ) Bytes Effective, 0x100 Bytes totally

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;   IDT information:
;
IDT_Base:     EQU  0x0003_0100   ; Arranged after GDT
IDT_Limit:    EQU  0x100         ; 0x100 Bytes Effective, 0x100 Bytes totally

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;      Page Directory Descriptor
;      Here is the value to be loaded into CR3
;    consist of base address, attributes.
;   0x10007 = ( 0000_0000_0000_0001_0000__000_00_0_0_00_1_1_1) in Binary
PDPTE    EQU           0x00001_0007 ; Base address: 0x0001_0000 (omit the lower 12 bits )
                                     ; Present
									 ; R/W = 1
									 ; U/S = 1
									 ; D = 0
									 ; A = 0
									 ; AVL Leave Blank

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

phy_address_kernel_base   EQU 0x0002_0000
phy_address_handler_base  EQU 0x0007_0000

phy_address_kernel_empty_stack_esp EQU 0x0005_0000

vir_address_Task_A_base 	EQU 0x0020_0000
phy_address_Task_A_base 	EQU 0x0005_0000

vir_address_Task_A_empty_stack_esp EQU 0x0007_0000
phy_address_Task_A_empty_stack_esp EQU 0x0007_0000

vir_address_video_buffer_head  EQU 0x000B_8000
phy_address_video_buffer_head  EQU 0x000B_8000