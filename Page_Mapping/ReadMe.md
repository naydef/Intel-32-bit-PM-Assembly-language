#  Page Mapping the Memory

Description:
   Sometimes I would prefer a Virtual-Address Memory,
For Example, the kernel is needed less care, 
and thus I can move it to upper memory Address(0x9000_0000),
But simply move to it may result in #GP for lacking of sufficient
   physical memory space.

So, a idea comes to my mind by mapping.

And all the patterns will be settled from then on...

But the map to 0x9000_0000 means that I have to maintain a huge Structure 

-------------------------------
# File Usage

	Name              LBA-Address    Sector length   Description
	
	MBR.asm           0              1               System Bootstrap
	kernel.asm        1-2            2               System Kernel Codes
	SYSinfo.asm       3-4            2               System Information
	page.asm          5-6            2               System Page Map
	task_A.asm        7              1               Task A
	common_macroasm   0              0               Common Macro Reference
	
-------------------------------
# Memory Arrangement(Linear/Virtual Address = Physical Address)
	0x0000_7C00 ~ 0x0000_7DFF: MBR                  (512 Bytes)
	0x0001_0000 ~ 0x0001_FFFF: Page Map             (512 Bytes)
	0x0002_0000 ~ 0x0002_0FFF: System Kernel Codes
	0x0003_0000 ~ 0x0003_FFFF: System Information   (65,536 Bytes)
	0x0004_0000 ~ 0x0004_FFFF: System Stack         (65,536 Bytes)
	0x0006_0000 ~ 0x0006_FFFF: Task A Stack
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
	0x000B_8000 ~ 0x000B_FFFF: Video Buffer


	Signed-off-by:  Mighten Dai<mighten.dai@gmail.com>
				  23:48
                  July 21, 2015