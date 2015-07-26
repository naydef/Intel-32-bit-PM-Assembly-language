//
//        test_wsprintf_calling_function_must_clean_stack.cpp
//
//      whether  __stdcall or __cdecl is required ?
//
//   Or rather, who will clean the stack, the calling one or the called one?
//
//  From the result that supported by the Disassemblier, we can draw a conclusion that:
//      the calling function must clean the stack by add 0xC or 12 indecimal.
//
#include <iostream>
#include <windows.h>

using namespace std;

int main(void)
{
	char szBuffer[200];

	MessageBox(0, 0, 0, 0);
	MessageBox(0, 0, 0, 0);
	MessageBox(0, 0, 0, 0);

	wsprintf( (LPWSTR)&szBuffer[0], TEXT("The Test integer is %d\n"), 11);

	MessageBox(0, 0, 0, 0);
	MessageBox(0, 0, 0, 0);
	MessageBox(0, 0, 0, 0);


	return 0;
}
/*
Attention the last one which add the esp with 0x0C.

Which means that the calling function must clean the stack.
    Totallly 3 parameters, which measures 0xC = 3 X 4 Decimally.

-------------------------------------------------------------
00B1103D  push        0Bh                           ; 0xB == 11 Decimally
00B1103F  push        offset ___xi_z+2Ch (0B120F4h) ; Offset address that stores TEXT("The Test integer is %d\n") 
00B11044  lea         eax,[ebp-0D0h]  
00B1104A  push        eax                           ; Buffer
00B1104B  call        dword ptr [__imp__wsprintfW (0B120A4h)]
00B11051  add         esp,0Ch
-------------------------------------------------------------

*/