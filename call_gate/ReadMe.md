#  Call Gate Test.

Description:
  Always, I wanna use the include LIB Code file for later use.
But in fact, it is a waste of Memory and some Global resources are therefore hard to manipulate.

  An idea come into my mind,
		--- Using Call Gate installed in GDT for further support.

-------------------------------
# File Usage

	Name              LBA-Address    Sector length   Description
	
	MBR.asm           0              1               System Bootstrap
	kernel.asm        1-2            2               System Kernel Codes
	SYSinfo.asm       3-4            2               System Information

	Library.asm       6              2               Frequently used library code reflected by Call Gate.
	
	common_macroasm   0              0               Common Macro Reference
	
-------------------------------
# Memory Arrangement

	0x0000_0000 ~ 0x0000_7EFF: <Undefined>          (512 Bytes)
	0x0000_7C00 ~ 0x0000_7DFF: MBR                  (512 Bytes)
	0x0001_0000 ~ 0x0001_FFFF: <Undefined>          (512 Bytes)
	0x0002_0000 ~ 0x0002_FFFF: System Kernel Codes  (65,536 Bytes)
	0x0003_0000 ~ 0x0003_FFFF: System Information   (65,536 Bytes)
	0x0004_0000 ~ 0x0004_FFFF: System Stack         (65,536 Bytes)

	0x0005_0000 ~ 0x0005_FFFF: System Library

-------------------------------
	Signed-off-by:  Mighten Dai<mighten.dai@gmail.com>
				  21:34
                  Aug 02, 2015