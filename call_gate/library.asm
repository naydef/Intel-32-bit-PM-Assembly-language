;   Library.asm
;
;    Frequently used library code reflected by Call Gate.
;
;   Begin:  20:42, Aug 02, 2015, by Mighten Dai<mighten.dai@gmail.com>
;  Latest:  21:36, Aug 02, 2015, by Mighten Dai<mighten.dai@gmail.com>
;
;
%include "common_macro.asm"
[bits 32]

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;    Here Vir-Address: 0x0005_0000
;
;		show_string  : Display ASCII string on screen
;	Parameter:       DS ES Selector
;		DS:ESI:   *source        ;  DS is selector ID
;		ES:EDI    *dest_head     ; the head of the Buffer.
;		[AH]:   Color Attributes
;         [DH] Row/Line ID [0,24] \ Temporary, Video_Buffer_Head + EDX
;         [DL] Column ID [0,79]   / 
;	            -----------------------------------------------------------
;			 | Bit7 | Bit6 | Bit5 | Bit4 |   Bit3 | Bit2  | Bit1 | Bit0 |
;			 | flash|   R      G      B  |  High  |    R     G     B    |
;			 |      |  Background Color  | light  |     Front  Color    |
;	           ------------------------------------------------------------
;	Return:  EAX = String with color in AH have drawn.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
_show_string___call_gate_entry:
push		ecx
push		eax
push		ebx
xor		eax, eax

add		edi, edx

pop		ebx
pop		eax

xor		ecx, ecx
_@_internal_loop:
	mov		al, [esi]
	cmp		al, 0
	je		_@_internal_loop_end
	mov		[es:edi], ax
	inc		esi
	inc		edi
	inc		edi
	inc		ecx

	jmp	short _@_internal_loop

_@_internal_loop_end:
mov		eax, ecx
pop		ecx
retf

times 0x100 - ( $ - _show_string___call_gate_entry ) db 0x00

;    Here Vir-Address: 0x0005_0100
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
