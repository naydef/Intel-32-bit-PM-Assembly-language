;
;		task_B.asm
;
;     Task A, memory space : 0x0007_0000 ~ 0x0007_ffff
;        This file's bin file ought to be written to LBA-Address 6, Length = 1
;
;	15:10
;	July 20, 2015
;
;   Signed-off-by: Mighten Dai<mighten.dai@gmail.com>
;   
;   Finally Modified by: ;	Mighten Dai<mighten.dai@gmail.com>
;                             16:56, July 20, 2015
;
[bits 32]
TaskB_32_bit_entry:
pushf
pushad

mov		eax, Ring0FlatData
mov		ds, eax
mov		es, eax
mov		esi, Task_B_MSG + 0x0007_0000 ; True Address = Base + Offset
mov		edi, 0x000B_8000
mov		edx, 0x0000_0612
mov		ah, 0x0D
call	_32_show_string

popad
popf

cli
hlt
jmp short $ - 1

Task_B_MSG: db '[Task B]: Hello, I am Task B, Demonstration Over !!!  :)', 0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;     
%include "common_macro.asm"
%include "..\MyMiniLibrary\show_string\_32_show_string.asm"

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;  Alignment  0x200 Bytes in Hexadecimal =>  512 Bytes in Decimal
times 0x200 - ($ - $$) db 0x90