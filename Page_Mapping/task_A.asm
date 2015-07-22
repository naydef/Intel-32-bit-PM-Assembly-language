;
;		task_A.asm
;
;     Task A, Phy-Address: 0x0005_0000 - 0x0005_FFFF
;             Vir-Address: 0x0020_0000 - 0x0020_FFFF
;        This file's bin file ought to be written to LBA-Address 7, Length = 1
;
;	15:10
;	July 20, 2015
;
;   Signed-off-by: Mighten Dai<mighten.dai@gmail.com>
;   
;   Finally Modified by: ;	Mighten Dai<mighten.dai@gmail.com>
;                             15:32, July 22, 2015
;
[bits 32]
TaskA_32_bit_entry:
pushf
pushad
mov		eax, Ring0FlatData
mov		ds, eax
mov		es, eax
mov		esi, Task_A_MSG + vir_address_Task_A_base
mov		edi, vir_address_video_buffer_head
mov		edx, 0x0000_0512    ; Row, Column
mov		ah, 0x09            ; Color Attributes.
call	_32_show_string
popad
popf

jmp		short $

Task_A_MSG: db '[Task A]: Now I am in Paged memory.', 0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;     
%include "common_macro.asm"
%include "..\MyMiniLibrary\show_string\_32_show_string.asm"

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;  Alignment  0x200 Bytes in Hexadecimal =>  512 Bytes in Decimal
times 0x200 - ($ - $$) db 0xCC
