;
;	make_descriptor.asm
;
;		Make up descriptor for storage-segment and system-segment descriptor
;
;		**********************************
;		* Copyright(C) 2011, Lee Chung   *
;		* All Rights Reserved.           *
;		**********************************
;
;	Original: 18:37, Nov 06, 2011, By Lee Chung <leechung@126.com>
;	Modified: 20:27, Jul 19, 2015, By Mighten Dai<mighten.dai@gmail.com>
;
;
%include "..\MyMiniLibrary\attributes.inc.asm"
;
;	************************* !!! Caution !!!! **********************
;	*       This routine can ONLY used for 80486 and later CPU      *
;	*****************************************************************
;
;	# Routine:  _make_descriptor
;	# Parameter
;		{EAX} = Base Linear-Address
;		{EBX} = Limit
;		{ECX} = Attributes, in high DWORD, all of the irrelevant bits are cleared( =0 )
;	# Return
;		{EDX:EAX} = Corresponding Segment Descriptor
_make_descriptor:
mov		edx,eax
shl		eax,16
or		ax,bx           ; the 32-bit Beginning of Descriptor in EAX, done.

and		edx,0xffff0000  ; Clear the irrelevant bit of Base Address
rol		edx,8
bswap	edx   ; Make Base address 31 to 24, and 23 to 16 (80486+)

xor		bx,bx
or		edx,ebx         ; Set up 4 High-bit field of Limit

or		edx,ecx         ; Set up Attributes Field

ret