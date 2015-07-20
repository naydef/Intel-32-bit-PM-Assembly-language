;
;		task_A.asm
;
;     Task A, memory space : 0x0005_0000 ~ 0x0005_ffff
;        This file's bin file ought to be written to LBA-Address 5, Length = 1
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
TaskA_32_bit_entry:
pushf
pushad

mov		eax, Ring0FlatData
mov		ds, eax
mov		es, eax
mov		esi, Task_A_MSG + 0x0005_0000 ; True Address = Base + Offset
mov		edi, 0x000B_8000
mov		edx, 0x0000_0512
mov		ah, 0x09
call	_32_show_string

popad
popf

jmp		Task_B_Selector:0   ; Goto Task B

Task_A_MSG: db '[Task A]: Hello, I am Task A, Now goto Task B.', 0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;     
%include "common_macro.asm"
%include "..\MyMiniLibrary\show_string\_32_show_string.asm"

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;  Alignment  0x200 Bytes in Hexadecimal =>  512 Bytes in Decimal
times 0x200 - ($ - $$) db 0xCC
