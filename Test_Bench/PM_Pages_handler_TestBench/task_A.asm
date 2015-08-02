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
%include "common_macro.asm"
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
[bits 32]
TaskA_32_bit_entry:
mov		eax, Ring0FlatData
mov		ds, eax
mov		es, eax
mov		edi, vir_address_video_buffer_head
mov		ah, 0x09            	; Color Attributes.

;
;     Task A say Hello.
; 
mov		ah, 0x09            	; Color Attributes.
mov		esi, Task_A_MSG + vir_address_Task_A_base
mov		edx, ( 160 + 0 )        ; Line 1, Column 0.    ; Row, Column
call	_32_show_string

;
;     Test the #BP Exception Handler
;         "Trap", fall through...
mov		ah, 0x09            	; Color Attributes.
mov		esi, Task_A_BP + vir_address_Task_A_base
mov		edx, 58 ; 218 - 160, Decimally.
call	_32_show_string
int		0x3
db		0xCC

;
;     Test the #UD Exception Handler
;
mov		ah, 0x09            	; Color Attributes.
mov		esi, Task_A_UD + vir_address_Task_A_base
mov		edx, 80  ; 218 - 120
call	_32_show_string
mov		eax, Ring0FlatData
or		eax, 0x3
mov		ds, eax
;mov		eax, [0000]

;
;     Test the #UD Exception Handler
;
mov		ah, 0x09            	; Color Attributes.
mov		esi, Task_A_UD + vir_address_Task_A_base
mov		edx, 80  ; 218 - 120
call	_32_show_string
db		0xFF, 0xFF, 0xA6

;
;     Test the #DE Exception Handler
;         -- Why I don't write code involves displaying string on screen?
;            The "Fault", or rather, Re-execute the code that caused the Fault will be restarted.
mov		eax, 0x0000_FFFF
xor		ebx, ebx
div		ebx               ; Generate the #DE, the Divide Error.

Task_A_MSG:db '[Task A]: Hello, my name is Trouble Maker !!   ^_^ ', 0
Task_A_BP: db '[Task A]: I want to Generate a #BP @.@~ ', 0
Task_A_UD: db '[Task A]: Invalid instruction are coming, so it is with #UD. ^_^ ', 0
Task_A_GP: db '[Task A]: I want to Generate a #GP  ^_^' , 0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
%include "..\..\MyMiniLibrary\show_string\_32_show_string.asm"

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;  Alignment  0x200 Bytes in Hexadecimal =>  512 Bytes in Decimal
times 0x200 - ($ - $$) db 0xCC
