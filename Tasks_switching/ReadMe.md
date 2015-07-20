##  Tasks

Description:
This program using NASM syntax mainly Control the i386 CPU to 
      in PM prepare two process and do switching stuff.

Simultaneously, create 2 kernel processes.

----------------------------
# Output on screen, more details  /Screen_Capture are described as PNG-photo file.
Bootstrap Print: 

	[Loader]: Now The kernel is loaded, and is executing...

Kernel    Print:

	[Kernel]: Hello, I am a regenerated Kernel, goto A, never wanna back...

Task  A   print:

	[Task A]: Hello, I am Task A, Now goto Task B.

Task  B   print:

	[Task B]: Hello, I am Task B, Demonstration Over !!!  :)

----------------------------
# File Usage

	Name              LBA-Address    Sector length   Description

	MBR.asm           0              1               System Bootstrap
	kernel.asm        1-2            2               System Kernel Codes
	SYSinfo.asm       3-4            2               System Information

	taskA.asm         5              1               Task A
	taskB.asm         6              1               Task B
	common_macroasm   0              0               Common Macro Reference

----------------------------
!!!Caution: Flat-model Memory Usage,
No stack-overflow checking mechanism!!!

----------------------------
# Memory Arrangement

	0x0000_0000 ~ 0x0000_7eff: <Undefined>          (512 Bytes)
	0x0000_7c00 ~ 0x0000_7dff: MBR                  (512 Bytes)
	0x0001_0000 ~ 0x0001_ffff: <Undefined>          (512 Bytes)
	   More details described in /Tasks/SYSinfo.asm
	0x0002_0000 ~ 0x0002_ffff: System Kernel Codes  (65,536 Bytes)
	0x0003_0000 ~ 0x0003_ffff: System Information   (65,536 Bytes)
	0x0004_0000 ~ 0x0004_ffff: System Stack         (65,536 Bytes)
	0x0005_0000 ~ 0x0005_ffff: Task A  Codes/ Data  (65,536 Bytes)
	0x0006_0000 ~ 0x0006_ffff: A 's  Stack          (65,536 Bytes)
	0x0007_0000 ~ 0x0007_ffff: Task B  Codes/Data   (65,536 Bytes)
	0x0008_0000 ~ 0x0008_ffff: B 's  Stack          (65,536 Bytes)

----------------------------
# Some Library Codes used, as shown in Linux-like notation:

		/32-bit-PM-Assembly-language/MyMiniLibrary/show_string/_16_show_string.asm
		/32-bit-PM-Assembly-language/MyMiniLibrary/show_string/_32_show_string.asm
		/32-bit-PM-Assembly-language/MyMiniLibrary/Read_Sector/_RM_read_floppy_data2memory.asm
		/32-bit-PM-Assembly-language/MyMiniLibrary/RM_clean_Screen/_RM_clean_screen.asm

----------------------------

	Signed-off-by:  Mighten Dai
				  23:30
                  July 14, 2015

	Finally Modified by: Mighten Dai<mighten.dai@gmail.com>
                             17:07, July 20, 2015
