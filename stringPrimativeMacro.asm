TITLE Program Template     (template.asm)

; Author: Danielle Guedea
; Last Modified: 03/14/2021
; OSU email address: guedead@oregonstate.edu
; Course number/section:   CS271 Section 400
; Project Number: 6                Due Date: 03/14/2021
; Description: This project is aimed at practicing implementing Macros, Procedures and low-level I/O Procedures
;			   The program will:
;				1) Ask the user to input 10 integers. Checking if each is valid
;				2) Store the input values in an array
;				3) Displays the 10 integer's, their sum and average (rounded down) as strings


INCLUDE Irvine32.inc

; ===============================
; MACROS
; ===============================
; Name: mGetString
; Description: Displays a prompt and stores user's keyboard input into userInput 
; Preconditions: Do not use EDX, EAX or ECX as arguments. These are utilized in the macro
; Receives:
;			1) strInput = string prompt
;			2) userInput = un-initialized, where user input will be stored
;			3) sizeOf = size of userInput
;			4) outSize = un-initialized, where size of user's input is stored
; Returns:
;			1) userInput = holds user's string input
;			2) outSize = holds length of user's input
; ===============================
mGetString MACRO strInput:REQ, userInput:REQ, sizeOf:REQ, outSize:REQ
	PUSH	EDX
	PUSH	EAX
	PUSH	ECX

	MOV		EDX, strInput
	CALL	WriteString

	MOV		EDX, userInput
	MOV		ECX, sizeOf
	CALL	ReadString
	MOV		outSize, EAX
	
	POP		ECX
	POP		EAX
	POP		EDX

ENDM
; ===============================
; Name: mDisplayString
; Description: Displays string located at memory address
; Preconditions: String must be stored in memory address. Do not use EDX as argument - used in macro
; Receives:
;			1) memoryLoc = address of string to be printed
; Returns: none
; ===============================
mDisplayString MACRO memoryLoc:REQ
	PUSH	EDX
	MOV		EDX, memoryLoc
	CALL	WriteString
	POP		EDX
ENDM
; ===============================
; CONSTANTS
SIZEARRAY = 10
; ===============================
.data

titleProg			BYTE		"Project 6: Designing Low-Level I/O procedures.",10,13,0
authorProg			BYTE		"Created by Danielle Guedea",10,13,10,13,0
description			BYTE		"Please provide 10 signed decimal integers.",10,13
					BYTE		"Each number needs to be small enough to fit inside a 32 bit register.",10,13
					BYTE		"After you have finished inputting the numbers, I will display:",10,13
					BYTE		"A list of the integers, their sum and their average value.",10,13,10,13,0
inputPrompt			BYTE		"Please enter a signed number: ",0
errorPrompt1		BYTE		"ERROR: You did not enter a signed number!",10,13,0
errorPrompt2		BYTE		"ERROR: Your number was too big!",10,13,0
listPrompt			BYTE		"You entered the following numbers:",10,13,0
sumPrompt			BYTE		"The sum of these numbers is: ",0
averagePrompt		BYTE		"The rounded average of these numbers is: ",0
endGame				BYTE		"Thanks for playing this final game!",0
commaSpace			BYTE		", ",0
userNum				BYTE		256 DUP(?)												
sizeUserNum			DWORD		?
numArray			SDWORD		SIZEARRAY DUP(?)
outVal				SDWORD		?
sum					SDWORD		?
average				SDWORD		?
strOutput			SDWORD		40 DUP(?)
revString			SDWORD		40 DUP(?)
listVal				SDWORD		?
sumString			SDWORD		11 DUP(?)
sumReversed			SDWORD		11 DUP(?)
avgString			SDWORD		11 DUP(?)
avgReversed			SDWORD		11 DUP(?)


.code
main PROC

; Program introduction - title, author, description of program
	PUSH	OFFSET titleProg
	PUSH	OFFSET authorProg
	PUSH	OFFSET description
	CALL	introduction

; Gather strings from user, validate & store as numeric values in array
	PUSH	SIZEARRAY
	PUSH	OFFSET numArray
	PUSH	OFFSET sizeUserNum
	PUSH	SIZEOF userNum
	PUSH	OFFSET inputPrompt
	PUSH	OFFSET errorPrompt1
	PUSH	OFFSET errorPrompt2
	PUSH	OFFSET userNum
	CALL	readVal

; Print list as a string calling writeVal
	PUSH	OFFSET listVal
	PUSH	OFFSET revString
	PUSH	OFFSET commaSpace
	PUSH	TYPE strOutput
	PUSH	TYPE numArray
	PUSH	OFFSET listPrompt
	PUSH	SIZEARRAY
	PUSH	OFFSET numArray
	PUSH	OFFSET strOutput
	CALL	displayList

; Calculate sum and print as string calling writeVal
	PUSH	OFFSET sumPrompt
	PUSH	OFFSET sumString
	PUSH	OFFSET sumReversed
	PUSH	SIZEARRAY
	PUSH	OFFSET numArray
	PUSH	OFFSET sum
	CALL	sumCalc

; Calculate average and print as string calling writeVal
	PUSH	SIZEARRAY
	PUSH	OFFSET avgString
	PUSH	OFFSET avgReversed
	PUSH	OFFSET averagePrompt
	PUSH	OFFSET sum
	PUSH	OFFSET average
	CALL	averageCalc

; Say goodbye to user
	PUSH	OFFSET endGame
	CALL	goodBye

	Invoke ExitProcess,0	; exit to operating system
main ENDP

; ===========================
; Name: introduction
; Description: Displays the title and author and introduces what the program will do.  Utilizes mDisplayString macro
; Preconditions: titleProg, authorProg and description initialized as strings. mDisplayString macro is defined
; Postconditions: None
; Receives: On system stack
;			1) Address of titleProg, authorProg and description
; Returns: None
; ===========================

introduction PROC

	PUSH	EBP
	MOV		EBP, ESP

	mDisplayString [EBP+16]											; Title
	mDisplayString [EBP+12]											; Author
	mDisplayString [EBP+8]											; Description

	POP		EBP

	RET	12
introduction ENDP

; ===========================
; Name: readVal
; Description: Gets user's input in the form of a string of digits and converts it (using string primitives) to ascii digits. Stores value in memory
;				Utilizes mGetString macro to get input from user
; Preconditions: 
;				1) mGetString defined as macro to get user input
;				2) SIZEARRAY defined as constant
;				3) numArray initialized to empty array w/ size of SIZEARRAY
;				4) userNum and sizeUserNum initialized with ?
;				5) inputPrompt, errorPrompt1 and errorPrompt2 defined as strings
; Postconditions: None
; Receives: On system stack
;			1) Value of SIZEARRAY and SIZEOF userNum
;			2) Address of numArray, userNum and sizeUserNum
;			3) Address of inputPrompt, errorPrompt1 and errorPrompt2
; Returns: User input value stored in userNum, size of input stored in sizeUserNum
; ===========================

readVal PROC

	PUSH	EBP
	MOV		EBP, ESP
	PUSH	ESI
	PUSH	ECX
	PUSH	EDI
	PUSH	EDX
	PUSH	EAX
	PUSH	EBX

	MOV		EDI, [EBP+32]										; numArray in EDI to hold number input
	MOV		ECX, [EBP+36]										; count of 10 (SIZEARRAY) in ECX
	
_getTenNum:
	PUSH	ECX													; Preserve outer counter
	_askAgain:
		MOV		EBX, 0
		MOV		EAX, 0
		MOV		EDX, 0

		mGetString [EBP+20], [EBP+8], [EBP+24], [EBP+28]		; Gets input from user in form of a string

		CLD
		MOV		ESI, [EBP+8]									; userNum in ESI
		MOV		EBX, [EBP+28]									; size of user number for counter

																; Checks if number input has + or - in front
		LODSB
		CMP		AL, 43
		JE		_checkDigitsPlusMinus
		CMP		AL, 45
		JE		_checkDigitsPlusMinus
		JMP		_checkDigits
		
	_checkDigitsPlusMinus:										; Must start at second place after sign to validate number
		LODSB
		CMP		AL, 48											; To validate, checks within ascii digit bounds
		JL		_notNum
		CMP		AL, 57
		JG		_notNum
		DEC		EBX
		CMP		EBX, 1
		JG		_checkDigitsPlusMinus
		JMP		_reset

	_checkDigits:												; Must start at first place, since no + or -
		CMP		AL, 48
		JL		_notNum
		CMP		AL, 57
		JG		_notNum
		LODSB
		DEC		EBX
		CMP		EBX, 0
		JG		_checkDigits
		JMP		_reset

	_reset:														; Reset for LODSB
		MOV		ESI, [EBP+8]
		MOV		ECX, [EBP+28]
		MOV		EBX, 0

	_addDigits:													; converts to digits depending on having +/- or not
		LODSB
		CMP		AL, 43
		JE		_convertPositive
		CMP		AL, 45
		JE		_convertNegative
		JMP		_convertNoSymbol

	_convertPositive:											; converts to positive number
		LODSB
		PUSH	ECX
		PUSH	EAX
		MOV		EAX, EBX
		MOV		EDX, 0
		MOV		ECX, 10
		MUL		ECX												; Multiply by 10 and check if too large for 32 bit register
		CMP		EDX, 0
		JNE		_tooLarge
		MOV		EBX, EAX
		POP		EAX
		POP		ECX
		SUB		AL, 48d											; Get digit value of AL and add to running total in EBX
		ADD		EBX, EAX
		JC		_tooLarge										; checks for overflow after addition
		MOV		[EDI], EBX
		DEC		ECX
		CMP		ECX, 1
		JG		_convertPositive
		JMP		_end

	_convertNoSymbol:											; Converts to positive number, starting value has no +
		PUSH	ECX
		PUSH	EAX
		MOV		EAX, EBX
		MOV		EDX, 0
		MOV		ECX, 10
		MUL		ECX												; Multiply by 10 and check if too large for 32 bit register
		CMP		EDX, 0
		JNE		_tooLarge
		MOV		EBX, EAX
		POP		EAX
		POP		ECX
		SUB		AL, 48d											; Get digit value of AL and add to running total in EBX
		ADD		EBX, EAX
		JC		_tooLarge
		MOV		[EDI], EBX
		LODSB
		DEC		ECX
		CMP		ECX, 0
		JG		_convertNoSymbol
		JMP		_end

	_convertNegative:											; Converts to negative number
		LODSB
		PUSH	ECX
		PUSH	EAX
		MOV		EAX, EBX
		MOV		EDX, 0
		MOV		ECX, 10
		MUL		ECX												; Multiply by 10 and check if too large for 32 bit register
		CMP		EDX, 0
		JNE		_tooLarge
		MOV		EBX, EAX
		POP		EAX
		POP		ECX
		SUB		AL, 48d											; Get digit value of AL and add to running total in EBX
		ADD		EBX, EAX
		JC		_tooLarge
		DEC		ECX
		CMP		ECX, 1
		JG		_convertNegative
		IMUL	EBX, -1											; Multiply running total by -1 to get negative value
		MOV		[EDI], EBX
		JMP		_end

	_notNum:
		mDisplayString [EBP+16]
		JMP		_askAgain

	_tooLarge:
		mDisplayString [EBP+12]
		POP		EAX
		POP		ECX
		JMP		_askAgain

	_end:
	POP		ECX												; Pop the outer count, move to next space in array and loop
	ADD		EDI, 4
	DEC		ECX
	CMP		ECX, 0
	JG		_getTenNum

	POP		EBX
	POP		EAX
	POP		EDX
	POP		EDI
	POP		ECX
	POP		ESI
	POP		EBP

	RET	32
readVal ENDP

; ===========================
; Name: displayList
; Description: Displays the 10 numbers of user input as strings with a prompt. Calls writeVal to display prompt & values
; Preconditions: 
;				1) writeVal is defined as macro
;				2) listPrompt, revString, commaSpace, strOutput defined as strings
;				3) numArray contains 10 user values in numeric notation
;				4) SIZEARRAY defined as constant
;				5) listVal initialized as SDWORD ?
; Postconditions: None
; Receives: On system stack
;			1) Address of strings revString, commaSpace, listPrompt, strOutput
;			2) value of TYPE of strOutput and numArray
;			3) value of SIZEARRAY 
;			4) Address of numarray and strOutput
;			5) Address of listVal
; Returns: Converted numerical digits to ascii values stored in revString to be displayed
; ===========================

displayList PROC

	PUSH	EBP
	MOV		EBP, ESP
	PUSH	ESI
	PUSH	EDI
	PUSH	ECX

	mDisplayString [EBP+20]											; Print listPrompt

	MOV		ESI, [EBP+12]											; numarray
	MOV		EDI, [EBP+8]											; strOutput (where string values will be stored)
	MOV		ECX, [EBP+16]											; size of numArray
	MOV		EBX, [EBP+36]


	_getNumLoop:													; grabs number to send to be printed
		MOV		EDX, [EBP+40]											; moves current value in ESI to listVal 
		MOV		EAX, [ESI]
		MOV		[EDX], EAX


		PUSH	EBX														; where reversed string will be stored (value that is printed)
		PUSH	OFFSET listVal											; number to be converted
		PUSH	EDI														; first destination	(where number is coverted to string)
		CALL	writeVal												; calls writeVal to convert + print number

		CMP		ECX, 1
		JE		_noComma	

		mDisplayString [EBP+32]											; add , and space

		_noComma:														; skips adding comma to last number in printed list
		ADD		ESI, [EBP+24]											; move to next in array
		ADD		EDI, [EBP+28]
		ADD		EBX, [EBP+28]
		DEC		ECX
		CMP		ECX, 0 
		JG		_getNumLoop

	CALL	CrLf

	POP		ECX
	POP		EDI
	POP		ESI
	POP		EBP

	RET	36
displayList ENDP

; ===========================
; Name: sumCalc
; Description: Calculates and displays the sum of the 10 user input numbers. Calls writeVal to print
; Preconditions: 
;				1) The 10 user inputs are stored as numerical values in numArray
;				2) mDisplayString is defined as a macro to display strings
;				3) SIZEARRAY defined as constant
;				4) sumPrompt defined as string
;				5) sumString and sumReversed initialized as strings to ?
;				6) writeVal defined as procedure
;				7) sum defined as SDWORD ?
; Postconditions: None
; Receives: On system stack
;			1) Addresses of sumPrompt, sumString and sumReversed
;			2) SIZEARRAY
;			3) Address of numArray
;			4) Address of sum
; Returns: Sum of user's 10 numbers and stores as numerical value in sum.  Translated numerical value to string stored in sumString and sumReversed.
; ===========================

sumCalc PROC

	PUSH	EBP
	MOV		EBP, ESP
	PUSH	ESI
	PUSH	ECX
	PUSH	EAX
	PUSH	EBX
	PUSH	EDI

	mDisplayString [EBP+28]

	MOV		ESI, [EBP+12]									; numArray in ESI
	MOV		ECX, [EBP+16]									; Size of numARray in ECX
	MOV		EDI, [EBP+8]									; sum in EDI

	MOV		EAX, 0

	_sumLoop:
		ADD		EAX, [ESI]
		ADD		ESI, 4
		DEC		ECX
		CMP		ECX, 0
		JG		_sumLoop

		MOV		[EDI], EAX
		MOV		EBX, [EBP+20]
		MOV		EDI, [EBP+24]

		; Print Sum Strings (Prompt & Number of Sum)
		PUSH	EBX											; Reversed string is stored (val to be printed)
		PUSH	OFFSET sum
		PUSH	EDI											; Conversion from number to string is stored
		CALL	writeVal


	CALL	CrLf

	POP		EDI
	POP		EBX
	POP		EAX
	POP		ECX
	POP		ESI
	POP		EBP

	RET	24
sumCalc ENDP

; ===========================
; Name: averageCalc
; Description: Calculates and displays average of the 10 user inputs. Uses floor rounding method. Calls writeVal to print
; Preconditions: 
;				1) avgPrompt is defined as a string
;				2) sum is calculated and stored 
;				3) SIZEARRAY is initialized as constant
;				4) writeVal defined as a procedure
;				5) average defined as SDWORD ?
; Postconditions: None
; Receives: On system stack
;			1) SIZEARRAY constant
;			2) avgString and avgReversed places to be passed to writeVal to store string conversion
;			3) avgPrompt defined as string
;			4) Address of sum which has already been calculated
;			5) Address of average which will be calculated
; Returns: Numerical value of average, stored in average.  String value of average stored in avgString and avgReversed (used in display)
; ===========================

averageCalc PROC

	PUSH	EBP
	MOV		EBP, ESP
	PUSH	EAX
	PUSH	EBX
	PUSH	EDI
	PUSH	EDX

	mDisplayString [EBP+16]

	MOV		EDI, [EBP+12]

	MOV		EAX, [EDI]
	CDQ
	MOV		EBX, 10
	IDIV	EBX

	CMP		EAX, 0
	JGE		_positiveRound
	CMP		EDX, 0
	JE		_positiveRound
	SUB		EAX, 1												; Rounds value away from 0 if negative and has remainder
	
	_positiveRound:
																; Move storing strings into registers to pass to writeVal
		MOV		EBX, [EBP+20]
		MOV		EDI, [EBP+24]

		MOV		EDI, [EBP+8]									; Store value of average
		MOV		[EDI], EAX

		;Print average prompt + number
		PUSH	EBX												; Reversed string stored (val to be printed)
		PUSH	OFFSET average
		PUSH	EDI												; Coverted number to string stored
		CALL	writeVal
		CALL	CrLf


	POP		EDX
	POP		EDI
	POP		EBX
	POP		EAX
	POP		EBP

	RET	24
averageCalc ENDP

; ===========================
; Name: writeVal
; Description: Converts numeric value to a string of ascii digits for printing. Envokes mDisplayString macro
;			   Does this by storing translated values to ascii digits and then reversing them 
; Preconditions: 
;				1) mDisplayString defined as a macro that prints out a string
;				2) Numerical value is defined and stored 
; Postconditions: None
; Receives: On system stack
;			1) Address of numerical value to be printed
;			2) Address where ascii value will be stored
;			3) Address where ascii value will be reversed and stored
; Returns: Translated & reversed ascii strings
; ===========================

writeVal PROC

	PUSH	EBP
	MOV		EBP, ESP
	PUSH	EDI
	PUSH	EAX
	PUSH	EBX
	PUSH	ECX
	PUSH	ESI

	MOV		EDI, [EBP+8]									; Storing in EDI
	MOV		ESI, [EBP+12]
	MOV		EAX, [ESI]
	MOV		ECX, 0

															; Accounting for negative numbers
	PUSH	EAX
	CMP		EAX, 0											; if it is negative, get numbers first and then add negative sign
	JGE		_writeToString
	IMUL	EAX, -1

	_writeToString:											; This adds the string backwards in the location EDI, will reverse later

		MOV		EBX, 10										; Divisor
		MOV		EDX, 0										; Set to 0 for division
		CDQ
		IDIV	EBX
		CMP		EAX, 0
		JE		_complete									; If result in EAX is 0, number is complete
		PUSH	EAX
		MOV		EAX, EDX
		ADD		AL, 48d										; Switch to string notation
		STOSB
		POP		EAX
		INC		ECX
		JMP		_writeToString

	_complete:
		MOV		EAX, EDX
		ADD		AL, 48d
		INC		ECX
		STOSB

	; Since string was stored backwards by the conversion from # to string, will have to store it in reverse
	POP		EAX
	CMP		EAX, 0
	JGE		_printOut
	INC		ECX
	MOV		AL, 45
	STOSB
	
	_printOut:
		MOV		ESI, [EBP+8]								; Where string is backwards
		MOV		EDI, [EBP+16]								; Where string will go reversed
		ADD		ESI, ECX
		DEC		ESI
		
		_revLoop:											; Loop to reverse string
			STD
			LODSB
			CLD
			STOSB
		LOOP	_revLoop

		mDisplayString [EBP+16]

	POP		ESI
	POP		ECX
	POP		EBX
	POP		EAX
	POP		EDI
	POP		EBP

	RET	12
writeVal ENDP

; ===========================
; Name: goodBye
; Description: Displays a goodbye message to the user
; Preconditions: endGame is initialized as a string
; Postconditions: None
; Receives: On system stack
;			1) Address of endGame
; Returns: None
; ===========================

goodBye PROC

	PUSH	EBP
	MOV		EBP, ESP

	mDisplayString [EBP+8]
	CALL	CrLf

	POP		EBP

	RET	4
goodBye ENDP



END main
