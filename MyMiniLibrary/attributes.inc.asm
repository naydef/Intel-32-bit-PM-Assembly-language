;
;	attributes.inc.asm
;
;		All kinds of attributes defined in this library.
;
;		**********************************
;		* Copyright(C) 2011, Yu Yuan     *
;		* All Rights Reserved.           *
;		**********************************
;
;	Original: 18:37, Nov 06, 2011, By Lee Chung <leechung@126.com>
;	Modified: 20:27, Jul 19, 2015, By Mighten Dai<mighten.dai@gmail.com>
;
;
;  For Data Segment
;       -----------------------------------------------
;		Type ID     Description
;			0		Execute/Read-only
;			1		Execute/Read-only, Accessed
;			2		Execute/Read/Write
;			3		Execute/Read/Write, Accessed 
;			4		Execute/Read-only, Expand-down
;			4		Execute/Read-only, Expand-down
;			5		Execute/Read-only, Expand-down, Accessed
;			6		Execute/Read/Write, Expand-down
;			7		Execute/Read/Write, Expand-down, Accessed
;		
;  For Code Segment
;       -----------------------------------------------
;		Type ID     Description
;			8		Execute-only
;			9		Execute-only, Accessed
;			A		Execute/Read
;			B		Execute/Read, Accessed
;			C		Execute-only, Conforming
;			D		Execute-only, Conforming, Accessed
;			E		Execute/Read, Conforming
;			F		Execute/Read, Conforming, Accessed
;
;		
;  For System Segment
;       -----------------------------------------------
;			0		<Undefined>
;			1		286 TSS(Available) 
;			2		LDT
;			3		286 TSS(Busy)
;			4		286 Call Gate
;			5		Task Gate
;			6		286 Interrupt Gate
;			7		286 Trap Gate
;			8		<Undefined>
;			9		386 TSS(Available) 
;			A		<Undefined>
;			B		386 TSS(Busy)
;			C		386 Call Gate
;			D		<Undefined>
;			E		386 Interrupt Gate
;			F		386 Trap Gate
;
;----------------------------------------------------------------------------
; ����������ֵ�����У�
;       DA_  : Descriptor Attribute
;       D    : ���ݶ�
;       C    : �����
;       S    : ϵͳ��
;       R    : ֻ��
;       RW   : ��д
;       A    : �ѷ���
;       ���� : �ɰ���������˼���
;----------------------------------------------------------------------------

; ����������
DA_32		EQU	4000h	; 32 λ��

DA_DPL0		EQU	  00h	; DPL = 0
DA_DPL1		EQU	  20h	; DPL = 1
DA_DPL2		EQU	  40h	; DPL = 2
DA_DPL3		EQU	  60h	; DPL = 3

; �洢������������
DA_DR		EQU	90h	; ���ڵ�ֻ�����ݶ�����ֵ
DA_DRW		EQU	92h	; ���ڵĿɶ�д���ݶ�����ֵ
DA_DRWA		EQU	93h	; ���ڵ��ѷ��ʿɶ�д���ݶ�����ֵ
DA_C		EQU	98h	; ���ڵ�ִֻ�д��������ֵ
DA_CR		EQU	9Ah	; ���ڵĿ�ִ�пɶ����������ֵ
DA_CCO		EQU	9Ch	; ���ڵ�ִֻ��һ�´��������ֵ
DA_CCOR		EQU	9Eh	; ���ڵĿ�ִ�пɶ�һ�´��������ֵ

; ϵͳ������������
DA_LDT		EQU	  82h	; �ֲ��������������ֵ
DA_TaskGate	EQU	  85h	; ����������ֵ
DA_386TSS	EQU	  89h	; ���� 386 ����״̬������ֵ
DA_386CGate	EQU	  8Ch	; 386 ����������ֵ
DA_386IGate	EQU	  8Eh	; 386 �ж�������ֵ
DA_386TGate	EQU	  8Fh	; 386 ����������ֵ

; RPL(Requested Privilege Level)
;
; TI(Table Indicator)
;	TI=0 GDT
;	TI=1 LDT

;----------------------------------------------------------------------------
;       SA_  : Selector Attribute

SA_RPL0		EQU	0	; \   RPL
SA_RPL1		EQU	1	; |     With Privilege
SA_RPL2		EQU	2	; |
SA_RPL3		EQU	3	; /

SA_TIG		EQU	0	; \  TI
SA_TIL		EQU	4	; /
;----------------------------------------------------------------------------
