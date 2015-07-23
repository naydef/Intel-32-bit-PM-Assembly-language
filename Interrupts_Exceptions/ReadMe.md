#  Page Mapping the Memory

Description:
   Sometimes, especially, an unprocessed exception result in immediately crash
for lacking of Handlers, I hope it will work.

And Kernel crashes due to no Handlers will never bother me any longer.  

Apparently, these codes, which is familiar to us, is reused codes from Page_Mapping
It is really helpful and helped me save a lot of time.
Time has proved its efficiency.

-------------------------------
# Something need attention:
on Handlers of Exception as well as Interrupts....
1. Vir-Address == Phy-Address, due to the principle of simplification to demonstrate what is really needed to be done.
2. This portion merely demonstrate how a Handler works, NO User-Defined Interrupts AVAILABLE.
3. All the routines of Handlers are implemented and detailed in "handler.asm".

-------------------------------
# File Usage, where all the number are understood as Decimal.
	Name              LBA-Address      Sector length   Description
	common_macroasm   00                00               Common Macro Reference
	MBR.asm           00                01               System Bootstrap
	kernel.asm        01-02             02               System Kernel Codes
	SYSinfo.asm       03-04             02               System Information
	page.asm          05-06             02               System Page Map
	task_A.asm        07                01               Task A
	<Leave Blank>     08-09             02               <Leave Blank>
	handler.asm       10-59             50               Handlers for Interrupts & Exceptions
	<Leave Blank>     60                ??               <Leave Blank>

-------------------------------
# Memory Arrangement (Linear/Virtual Address) 
	0x0000_7C00 ~ 0x0000_7DFF: MBR                  (512 Bytes)
	0x0001_0000 ~ 0x0001_FFFF: Page Map             (512 Bytes)
	0x0002_0000 ~ 0x0002_0FFF: System Kernel Codes
	0x0003_0000 ~ 0x0003_FFFF: System Information   (65,536 Bytes)
	0x0004_0000 ~ 0x0004_FFFF: System Stack         (65,536 Bytes)
	0x0006_0000 ~ 0x0006_FFFF: Task A Stack
	0x0007_0000 ~ 0x0007_FFFF: *** Handlers for Interrupts & Exceptions
	0x0020_0000 ~ 0x0020_FFFF: Task A Codes

-------------------------------
# Memory Arrangement(Physical Address)

	0x0000_2000 ~ 0x0000_7EFF: <Undefined>        
	0x0000_7C00 ~ 0x0000_7DFF: MBR                
	0x0001_0000 ~ 0x0001_FFFF: Page Map           
	0x0002_0000 ~ 0x0002_0FFF: System Kernel Codes
	0x0003_0000 ~ 0x0003_0FFF: System Information 
	0x0004_0000 ~ 0x0004_0FFF: System Stack
	0x0005_0000 ~ 0x0005_FFFF: Task A Codes
	0x0006_0000 ~ 0x0006_FFFF: Task A Stack
	0x0007_0000 ~ 0x0007_FFFF: *** Handlers for Interrupts & Exceptions
	0x000B_8000 ~ 0x000B_FFFF: Video Buffer


	Signed-off-by:  Mighten Dai<mighten.dai@gmail.com>
				  23:48
                  July 21, 2015