/*
	Copyright(C) 2015, Mighten Dai
	All Rights Reserved.

	File   name: InitGenerateGDT_C.h
	Description:
		1> Making GDT structure.
			The C/C++ syntax
		2> If you want to use this routine,
			copy the code or simply: #include InitGenerateGDT_C.h
		3> Calling Convention: __stdcall

	Begin  with:  18:12, Feb 23, 2015   by Mighten Dai.
	Last update:  22:21, Feb 23, 2015   by Mighten Dai.
						See how to use it by seeing the test_generator.c and its output.
*/
#ifndef						INCLUDE_MAKE_GDT_ROUTINE_C_H_
#define						INCLUDE_MAKE_GDT_ROUTINE_C_H_

typedef		unsigned int 	DWORD;
typedef		unsigned char	BYTE;

////////////////////////////////////////////////////////////////////////////
//
// Function Name: InitGenerateGDT
//					Used to generate the 64-bit descriptor in GDT.
//
// Parameters   : <By stack>
//		[IN]  < 18 bytes >
//		[OUT] < 8  bytes >
//
void			InitGenerateGDT(
	// # Bit00 - Bit15, Bit48 - Bit51
	// Segment Limit field.
	DWORD		Limit,	// Segment's Limit, 20 bits make sense.

	// # Bit16 - Bit39
	// Base address field.
	DWORD		Base,	// Segment's Base address, 32 bits make sense.
	
	// # Bit40 - Bit43
	// TYPE, Type Field, one-byte-available for each.  
	BYTE		IsSegAccessed,	// Code/Data: A						
	BYTE		IsCodeCanRead_IsDataCanWrite,		// Code: R, Data: W		
	BYTE		IsDataExpandDown_IsCodeConforming,	// Data: Expand, Code:Conforming
	BYTE		IsCodeSegment,						// Data: 0, Code: 1 ( IsSegmentExecutable)

	// # Bit44
	// S, Descriptor Type flag, one-byte-available for each.
	BYTE		IsNonSystemSegment,		// 1=Code/Data, 0=System segment

	// # Bit45 - Bit46
	// DPL, Descriptor Privilege Level field, 2 bits available.
	BYTE		DscpPrivilegeLevel,		// Ring0, Ring1, Ring2, Ring3
	
	// # Bit47
	// P, segment Present flag, indicate whether segment is present in memory.
	BYTE		IsPresent,
	
	// # Bit52
	// AVL, always AVaiLable for system program
	BYTE		Is_AVL_Set,
	
	// # Bit53
	// L, In IA-32e Mode,1= 64-bit code-running method.
	BYTE		IsCanRun64BitCode,

	// # Bit54.
	// D_B, Default operation size, default stack pointer size
	//			and/or upper boundary( used for expand-down or stack segment )
	//			Recommended: 1 = 32-bit code/data, 0 = 16-bit ...
	BYTE		Is_D_B_Set,
	
	// # Bit55.
	// G, Granularity
	BYTE		Is_G_Set_or_Is_4KB_unites_available,
	
	//  ======> Return Value: Low  DOWRD
	DWORD		*pLowDoubleWord,
	
	//  ======> Return Value: High DOWRD
	DWORD		*pHighDoubleWord
)
{
	*pLowDoubleWord  = 0;
	*pHighDoubleWord = 0;

	// The Low-DWORD Descriptor settling to dword ptr [pLowDoubleWord] 
	*pLowDoubleWord  = Limit & 0xFFFF;
	*pLowDoubleWord |=  ( Base & 0xFFFF ) << 16;

	__asm
	{
		push	ebx
		xor		ebx, ebx

		// High-DWORD Bit 0 - 7,  Base address 23:16 Settling to EBX.
		mov		eax, Base
		shr		eax, 16
		and		eax, 0xFF
		or		ebx, eax

		// High-DWORD Bit 8 - 11, TYPE field settling to EBX.
		mov		al, IsSegAccessed
		and		eax, 1
		shl		eax, 8
		or		ebx, eax

		mov		al, IsCodeCanRead_IsDataCanWrite
		and		eax, 1
		shl		eax, 9
		or		ebx, eax

		mov		al, IsDataExpandDown_IsCodeConforming
		and		eax, 1
		shl		eax, 10
		or		ebx, eax


		mov		al, IsCodeSegment
		and		eax, 1
		shl		eax, 11
		or		ebx, eax

		// High-DWORD Bit 12: S, settling to ebx
		mov		al, IsNonSystemSegment
		and		eax, 1
		shl		eax, 12
		or		ebx, eax
		
		// High-DWORD Bit 13 - 14, settling to ebx
		mov		al, DscpPrivilegeLevel
		and		eax, 0x3
		shl		eax, 13
		or		ebx, eax
		
		// High-DWORD Bit 15, settling to ebx
		mov		al, IsPresent
		and		eax, 1
		shl		eax, 15
		or		ebx, eax

		// High-DWORD Bit 16-19, Limit 19:16, Settling to ebx
		mov		eax, Limit
		and		eax, 0xF0000
		or		ebx, eax

		// High-DWORD Bit 20, settling to ebx
		mov		al, Is_AVL_Set
		and		eax, 1
		shl		eax, 20
		or		ebx, eax

		// High-DWORD Bit 21
		mov		al, IsCanRun64BitCode
		and		eax, 1
		shl		eax, 21
		or		ebx, eax

		// High-DWORD Bit 22
		mov		al, Is_D_B_Set
		and		eax, 1
		shl		eax, 22
		or		ebx, eax

		// High-DWORD Bit 23
		mov		al, Is_G_Set_or_Is_4KB_unites_available
		and		eax, 1
		shl		eax, 23
		or		ebx, eax
		
		// High-DWORD Bit 24 - 31, Base 31:24
		mov		eax, Base
		and		eax, 0xFF000000   //0xFF00_0000
		or		ebx, eax
		
		// All is settled to EBX, now move it into pHighDoubleWord
		mov		eax, pHighDoubleWord
		mov		[eax], ebx
		xor		eax, eax

		pop		ebx
	}
	
	return ;
}


#endif // #ifndef INCLUDE_MAKE_GDT_ROUTINE_C_H_

#define						INCLUDE_MAKE_GDT_ROUTINE_C_H_

typedef		unsigned int 	DWORD;
typedef		unsigned char	BYTE;

////////////////////////////////////////////////////////////////////////////
//
// Function Name: InitGenerateGDT
//					Used to generate the 64-bit descriptor in GDT.
//
// Parameters   : <By stack>
//		[IN]  < 19 bytes >
//		[OUT] < 8  bytes >
//
void			InitGenerateGDT(
	// # Bit00 - Bit15, Bit48 - Bit51
	// Segment Limit field.
	DWORD		Limit,	// Segment's Limit, 20 bits make sense.

	// # Bit16 - Bit39
	// Base address field.
	DWORD		Base,	// Segment's Base address, 32 bits make sense.
	
	// # Bit40 - Bit43
	// TYPE, Type Field, one-byte-available for each.  
	BYTE		IsSegAccessed,	// Code/Data: A						
	BYTE		IsCodeCanRead_IsDataCanWrite,		// Code: R, Data: W		
	BYTE		IsDataExpandDown_IsCodeConforming,	// Data: Expand, Code:Conforming
	BYTE		IsCodeSegment,						// Data: 0, Code: 1 ( IsSegmentExecutable)

	// # Bit44
	// S, Descriptor Type flag, one-byte-available for each.
	BYTE		IsNonSystemSegment,		// 1=Code/Data, 0=System segment

	// # Bit45 - Bit46
	// DPL, Descriptor Privilege Level field, 2 bits available.
	BYTE		DscpPrivilegeLevel,		// Ring0, Ring1, Ring2, Ring3
	
	// # Bit47
	// P, segment Present flag, indicate whether segment is present in memory.
	BYTE		IsPresent,
	
	// # Bit52
	// AVL, always AVaiLable for system program
	BYTE		Is_AVL_Set,
	
	// # Bit53
	// L, In IA-32e Mode,1= 64-bit code-running method.
	BYTE		IsCanRun64BitCode,

	// # Bit54.
	// D_B, Default operation size, default stack pointer size
	//			and/or upper boundary( used for expand-down or stack segment )
	//			Recommended: 1 = 32-bit code/data, 0 = 16-bit ...
	BYTE		Is_D_B_Set,
	
	// # Bit55.
	// G, Granularity
	BYTE		Is_G_Set_or_Is_4KB_unites_available,
	
	//  ======> Return Value: Low  DOWRD
	DWORD		*pLowDoubleWord,
	
	//  ======> Return Value: High DOWRD
	DWORD		*pHighDoubleWord
)
{
	*pLowDoubleWord  = *pHighDoubleWord = 0;

	// The Low-DWORD Descriptor settling to dword ptr [pLowDoubleWord] 
	*pLowDoubleWord  = Limit & 0xFFFF;
	*pLowDoubleWord |=  ( Base & 0xFFFF ) << 16;

	__asm
	{
		push	ebx
		xor		ebx, ebx

		// High-DWORD Bit 0 - 7,  Base address 23:16 Settling to EBX.
		mov		eax, Base
		shr		eax, 16
		and		eax, 0xFF
		or		ebx, eax

		// High-DWORD Bit 8 - 11, TYPE field settling to EBX.
		and		al, IsSegAccessed
		and		eax, 1
		shl		eax, 8
		or		ebx, eax

		and		al, IsCodeCanRead_IsDataCanWrite
		and		eax, 1
		shl		eax, 9
		or		ebx, eax

		and		al, IsDataExpandDown_IsCodeConforming
		and		eax, 1
		shl		eax, 10
		or		ebx, eax

		and		al, IsCodeSegment
		and		eax, 1
		shl		eax, 11
		or		ebx, eax

		// High-DWORD Bit 12: S, settling to ebx
		and		al, IsNonSystemSegment
		and		eax, 1
		shl		eax, 12
		or		ebx, eax
		
		// High-DWORD Bit 13 - 14, settling to ebx
		and		al, DscpPrivilegeLevel
		and		eax, 0x3
		shl		eax, 13
		or		ebx, eax
		
		// High-DWORD Bit 15, settling to ebx
		and		al, IsPresent
		and		eax, 1
		shl		eax, 15
		or		ebx, eax

		// High-DWORD Bit 16-19, Limit 19:16, Settling to ebx
		mov		eax, Limit
		and		eax, 0xF0000
		or		ebx, eax

		// High-DWORD Bit 20, settling to ebx
		and		al, Is_AVL_Set
		and		eax, 1
		shl		eax, 20
		or		ebx, eax

		// High-DWORD Bit 21
		and		al, IsCanRun64BitCode
		and		eax, 1
		shl		eax, 21
		or		ebx, eax

		// High-DWORD Bit 22
		and		al, Is_D_B_Set
		and		eax, 1
		shl		eax, 22
		or		ebx, eax

		// High-DWORD Bit 23
		and		al, Is_G_Set_or_Is_4KB_unites_available
		and		eax, 1
		shl		eax, 23
		or		ebx, eax
		
		// High-DWORD Bit 24 - 31, Base 31:24
		mov		eax, Base
		and		eax, 0xFF000000   //0xFF00_0000
		or		ebx, eax
		
		// All is settled to EBX, now move it into pHighDoubleWord
		mov		[pHighDoubleWord], ebx

		pop		ebx
	}
	
	return ;
}


#endif // #ifndef INCLUDE_MAKE_GDT_ROUTINE_C_H_