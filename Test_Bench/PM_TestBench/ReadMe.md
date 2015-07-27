#  Flat-Model Memory PM Testing Bench

Description:
  Sometimes we need to test the special function in PM
Most commonly, there is not a suitable test bench whatsoever.

All the patterns will be settled from then on...

-------------------------------
# File Usage

	Name              LBA-Address    Sector length   Description
	
	MBR.asm           0              1               System Bootstrap
	kernel.asm        1-2            2               System Kernel Codes
	SYSinfo.asm       3-4            2               System Information
	
	Kernel.asm        5              1               Task A
	common_macroasm   0              0               Common Macro Reference
	
-------------------------------
# Memory Arrangement

	0x0000_0000 ~ 0x0000_7EFF: <Undefined>          (512 Bytes)
	0x0000_7C00 ~ 0x0000_7DFF: MBR                  (512 Bytes)
	0x0001_0000 ~ 0x0001_FFFF: <Undefined>          (512 Bytes)
	0x0002_0000 ~ 0x0002_FFFF: System Kernel Codes  (65,536 Bytes)
	0x0003_0000 ~ 0x0003_FFFF: System Information   (65,536 Bytes)
	0x0004_0000 ~ 0x0004_FFFF: System Stack         (65,536 Bytes)

-------------------------------
	Signed-off-by:  Mighten Dai<mighten.dai@gmail.com>
				  17:38
                  July 20, 2015