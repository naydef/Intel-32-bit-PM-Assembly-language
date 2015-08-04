//
//  divided_by_ZERO.cpp
//
//	Test How to do with the occurence of divided by ZERO
//
//   18:43, Jul 23, 2015, By Mighten Dai
//
#include <iostream>

using namespace std;

int main(void)
{
	int dividend = 18;
	int divider = 1;
	
	divider = 0;
	cout << "18 / 0 = " << dividend / divider <<endl;

	return 0;
}


/*
MSVS2010 no output, but a dialog give you a tip that this program was killed immediately.

By step-by-step tracking, I see "Unhandled exception" and Debugger give you two choices: continue or break,
     which means, #DE is handled by users rather than OS Kernel.

	I remember Windows has a mechanism named "Structed Exception Handling"(SEH for short), maybe this is involved.


	18:54, July 23, 2015
	Mighten Dai
*/