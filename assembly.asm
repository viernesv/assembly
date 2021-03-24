TITLE String Primitives and Macros     (Proj6_viernesv.asm)

; Author:				Virgilio Viernes 
; Last Modified:		16 March 2021, 8:45pm
; OSU email address:	viernesv@oregonstate.edu
; Course number:		CS271 Section 401
; Project Number:		6		
; Due Date:				14 March 2021 - (USING TWO GRACE DAYS AS INDICATED ON CANVAS)
; Description:			This program prompts the user to enter a string of values and converts the 
;						string of ASCII characters to a signed integer and stores it to memory, ensuring
;						that the signed integer fits in a 32-bit register. Does	this until 10 strings 
;						have been properply converted and stored. Calculates the sum and average of these
;						10 integers and displays these values back to the user as strings. 


INCLUDE Irvine32.inc

;-----------------------------------------------------------------------------------------------------
; Name: mDisplayString
; 
; Prints the string which is stored in the input parameter 'string'
; 
; Receives:
;		*	string = OFFSET string
; 
; Returns: 
;		*	prints to screen the contents of 'string'
;-----------------------------------------------------------------------------------------------------
mDisplayString	MACRO string
	PUSH	EDX
	MOV		EDX, string
	CALL	WriteString
	POP		EDX

ENDM


;----------------------------------------------------------------------------------------------------
; Name: mGetString
; 
; Displays a prompt; accepts user's keyboard input and writes it to memory
; 
; Preconditions:
;		* inString is a string of BYTEs of size 20 intialized to zero
;
; Receives:
;		*	stringBuffer = OFFSET inString
;		*	strSize = SIZEOF inString
; 
; Returns: 
;		*	EAX = number of characters entered by the user
;		*	ECX = EAX
;		*	EDX = OFFSET inString; 
;----------------------------------------------------------------------------------------------------
mGetString	MACRO	strBuffer, strSize
	PUSH	EDX
	MOV		EDX, strBuffer				
	MOV		ECX, strSize				
	CALL	ReadString				
	MOV		ECX, EAX			;store length of string to ECX	
	POP		EDX
ENDM


	MAX_SIZE = 20				; maximum numbers of characters user is able to input
	ARRAY_SIZE = 10				; number of element in intArray

.data
	programHeader				BYTE			"                Designing Low-Level I/O Procedures by Virgilio Viernes",13,10,0
	underline					BYTE			"             ===========================================================",13,10,10,0
	intro_1						BYTE			"  Please provide 10 signed decimal integers. Each number needs to be small enough to fit inside a 32-bit register.",13,10,0
	intro_2						BYTE			"  Once entered, I will display a list of the integers, their sum, and their average value. ",13,10,10,0
	prompt						BYTE			"  Please enter a signed integer that will fit inside a 32-bit register: ",0
	tooLargeError				BYTE			"  ERROR - Inputted values do not fit in a 32-bit register. Please try again.",13,10,0	
	noneError					BYTE			"  ERROR - No value has been inputted. Please try again.",13,10,0	
	notNumError					BYTE			"  ERROR - Inputted string is a not a number. Please try again.",13,10,0
	displayInts					BYTE			"  You entered the following numbers: ",0
	displaySum					BYTE			"  The sum of these numbers is: ",0
	displayAvg					BYTE			"  The rounded average is: ",0
	whitespace					BYTE			"     ",0
	goodbye						BYTE			"  Thank you for using this program. Goodbye!",0

	inString					BYTE			MAX_SIZE DUP(?)
	outString					BYTE			MAX_SIZE DUP(?)
	solutionString				BYTE			MAX_SIZE DUP(?)
	blankString					BYTE			MAX_SIZE DUP(0)
	intArray					SDWORD			ARRAY_SIZE DUP(0)
	mainLoopCount				DWORD			10
	sLen						DWORD			?
	tempSum						SDWORD			0
	isNegative					DWORD			0
	arraySum					SDWORD			?
	arrayAvg					SDWORD			?


.code
main PROC

	; Introduction 
	PUSH	OFFSET programHeader				; EBP+20
	PUSH	OFFSET underline					; EBP+16
	PUSH	OFFSET intro_1						; EBP+12
	PUSH	OFFSET intro_2						; EBP+8
	CALL	introduction

	; Data input and validation
	PUSH	SIZEOF inString						; EBP+56
	PUSH	OFFSET intArray						; EBP+52
	PUSH	OFFSET inString						; EBP+48
	PUSH	OFFSET mainLoopCount				; EBP+44
	PUSH	OFFSET sLen							; EBP+40
	PUSH	OFFSET tempSum						; EBP+36
	PUSH	OFFSET isNegative					; EBP+32
	PUSH	OFFSET tooLargeError				; EBP+28
	PUSH	OFFSET notNumError					; EBP+24
	PUSH	OFFSET noneError					; EBP+20
	PUSH	OFFSET prompt						; EBP+16
	PUSH	ARRAY_SIZE							; EBP+12
	PUSH	MAX_SIZE							; EBP+8
	CALL	readVal


	; Calculate the sum and the average for the values stored in intArray
	PUSH	OFFSET arrayAvg						; EBP+16
	PUSH	OFFSET arraySum						; EBP+12
	PUSH	OFFSET intArray						; EBP+8
	CALL	calculate

	; Dipslays intArray that contain the 10 signed integers
	mDisplayString OFFSET displayInts	
	;CALL	Crlf
	;PUSH	OFFSET whitespace					; EBP+32
	;PUSH	ARRAY_SIZE							; EBP+28
	;PUSH	MAX_SIZE							; EBP+24
	;PUSH	OFFSET blankString					; EBP+20
	;PUSH	OFFSET solutionString				; EBP+16
	;PUSH	OFFSET outString					; EBP+12
	;PUSH	OFFSET intArray						; EBP+8
	;CALL	printArray							; NOTE TO GRADER: Unable to printArray properly; commented out
	CALL	Crlf

	; Displays the sum
	mDisplayString OFFSET displaySum	
	PUSH	MAX_SIZE							; EBP+24
	PUSH	OFFSET blankString					; EBP+20
	PUSH	OFFSET solutionString				; EBP+16
	PUSH	OFFSET outString					; EBP+12
	PUSH	OFFSET arraySum						; EBP+8
	CALL	writeVal
	CALL	Crlf

	; Displays the average
	mDisplayString OFFSET displayAvg
	PUSH	MAX_SIZE							; EBP+24
	PUSH	OFFSET blankString					; EBP+20
	PUSH	OFFSET solutionString				; EBP+16
	PUSH	OFFSET outString					; EBP+12
	PUSH	OFFSET arrayAvg						; EBP+8
	CALL	writeVal
	CALL	Crlf

	; Farewell
	PUSH	OFFSET goodbye						; EBP+8
	CALL	farewell


  exit  ; exit to operating system

	Invoke ExitProcess,0	; exit to operating system


main ENDP


; ----------------------------------------------------------------------------------------------------
; Name: introduction
; 
; Introduces the title and author of the program and explains the program's functionality.
; 
; Preconditions:
;		*	programHeader, underline, intro_1, intro_2 are BYTEs
;		*	myDisplayString macro receives a string buffer to display
;
; Postconditions: 
;		*	changed register: EDX
;
; Receives:
;		*	OFFSETS: programHeader, underline, intro_1, intro_2, ec1Statement
; ----------------------------------------------------------------------------------------------------
introduction PROC
	PUSH	EBP							
	MOV		EBP, ESP					
	PUSHAD		
		
	mDisplayString	[EBP+20]
	mDisplayString	[EBP+16]
	mDisplayString	[EBP+12]
	mDisplayString	[EBP+8]
	
	POPAD
	POP		EBP
	RET		8	
introduction ENDP


; ----------------------------------------------------------------------------------------------------
; Name: readVal
; 
; Accepts a string of ASCII characters and stores to memory the integer representation of that string.
; 
; Preconditions: 
;		*	MAX_SIZE, ARRAY_SIZE are contstants 
;		*	prompt, noneError, notNumError, tooLargeError are BYTEs
;		*	mainLoopCount, sLen, isNegative are DWORDs
;		*	inString is a BYTE array of size 20 initialized with values of 0
;		*	intArray is a SDWORD array of size = ARRAY_SIZE initialized with values of 0
; 
; Postconditions: 
;		*	changed registers: EAX, EBX, ECX, EDX
;		*	intArray countains 10 integers that fit in a 32-bit register
;	
; Receives:
;		*	OFFSETS: prompt, noneError, notNumError, tooLargeError, isNegative, tempSum, sLen
;					 mainLoopCount, inString, intArray
;		*	Values:  ARRAY_SIZE, MAX_SIZE
; 
; Returns:
;		*	intArray contains 10 integers that fit in size 32-bit register.
; ----------------------------------------------------------------------------------------------------
readVal PROC
	PUSH	EBP							
	MOV		EBP, ESP					
	PUSHAD	

	mov		EDI, [EBP+52]						; copy to EDI destination index: intArray	
_mainLoop:					
	mDisplayString [EBP+16]
	mGetString [EBP+48], [EBP+56]				; prompts user and gets user input using macros

	PUSH	EDI
	MOV		EDI, [EBP+40]						; EDI pointing to sLen = +40
	mov		[EDI], ECX							; stores the number of chars entered from EAX into memory (sLen) 
	POP		EDI
	CMP		EAX, 0
	JE		_none								; no string entered, try again
	call	Crlf

	; Setup loop counter and indices
	CLD											
	PUSH	ESI
	MOV		ESI, [EBP+40]						; sLen = [EBP+40]
	mov		ECX, [ESI] 							
	POP		ESI
	mov		ESI, [EBP+48]						; copy from ESI source index: inString
	
	; Convert each string character into a digit
_convertLoop:
	XOR		EAX, EAX
	LODSB								
	CMP		AL, 43
	JE		_posIncluded
	CMP		AL, 45
	JE		_negIncluded
_charCheck:
	CMP		AL, 47
	JL		_notNum
	CMP		AL, 57
	JG		_notNum
	SUB		AL, 48
	PUSH	ESI
	MOV		ESI, [EBP+36]
	PUSH	EAX
	MOV		EAX, [ESI]							; pushes the current contents of tempSum to EAX
	MOV		EBX, 10
	MUL		EBX
	JO		_tooLarge							; if overflow flag is set, then number is too large to fit in 32-bit -> prompt error

	; stores the product of EAX x 10
	PUSH	EDI
	MOV		EDI, [EBP+36]				
	MOV		[EDI], EAX	
	POP		EDI

	; Adds the current digit to EAX
	POP		EAX
	ADD		EAX, [ESI]		
	JO		_tooLarge							; if overflow flag is set, then number is too large to fit in 32-bit -> prompt error
	POP		ESI

		
	; stores the current number to tempSum
	PUSH	EDI
	MOV		EDI, [EBP+36]				
	MOV		[EDI], EAX				
	POP		EDI
	
_signEntry:
	LOOP	_convertLoop

	; Store tempSum to memory	
	PUSH	ESI
	MOV		ESI, [EBP+32]						; isNegative
	MOV		EBX, [ESI]
	CMP		EBX, 1								; if isNegative is set to 1 -> jump to negate EAX
	POP		ESI
	JE		_negate
_storeInt:
	MOV		[EDI], EAX							; stores tempSum to memory in intArray
	ADD		EDI, 4								; moves pointer forward to the next element in the array
	MOV		EBX, 0
	PUSH	EDI
	MOV		EDI, [EBP+36]						; reset tempSum
	MOV		[EDI], EBX
	MOV		EDI, [EBP+32]						; reset isNegative
	MOV		[EDI], EBX
	POP		EDI
	PUSH	EDI
	MOV		EDI, [EBP+44]						; writing to mainLoopCount
	MOV		EAX, [EDI]
	SUB		EAX, 1								; decerements mainLoopCount
	MOV		[EDI], EAX
	POP		EDI
	PUSH	ESI
	MOV		ESI, [EBP+44]
	CMP		[ESI], EBX							; mainLooper counter; if EBX = 0, mainloop ends
	POP		ESI
	JNE		_mainLoop
	JMP		_end

_none:
	mDisplayString [EBP+20]
	CALL	Crlf
	JMP		_mainLoop
_notNum:
	mDisplayString [EBP+24]
	PUSH	EDI
	MOV		EBX, 0
	MOV		EDI, [EBP+36]						; reset tempSum
	MOV		[EDI], EBX
	MOV		EDI, [EBP+32]						; reset isNegative
	MOV		[EDI], EBX
	POP		EDI
	CALL	Crlf
	JMP		_mainLoop

_tooLarge:
	mDisplayString [EBP+28]
	PUSH	EDI
	MOV		EBX, 0
	MOV		EDI, [EBP+36]						; reset tempSum
	MOV		[EDI], EBX
	MOV		EDI, [EBP+32]						; reset isNegative
	MOV		[EDI], EBX
	POP		EDI
	CALL	Crlf	
	JMP		_mainLoop

_posIncluded:
	CMP		ECX, [EBP+40]						; if ECX == sLen, encountered sign is at the front of string, making it a valid number
	JE		_signEntry
	JMP		_notNum

_negIncluded:
	PUSH	EDI
	MOV		EDI, [EBP+32]
	MOV		EBX, 1
	MOV		[EDI], EBX
	POP		EDI
	PUSH	ESI
	MOV		ESI, [EBP+40]						; if ECX != sLen, encountered sign is in the middle/end of string, making it invalid 
	CMP		ECX, [ESI]
	POP		ESI
	JE		_signEntry
	JMP		_notNum

_negate:
	NEG		EAX
	JMP		_storeInt

_end:
	CALL	Crlf
	CALL	Crlf

	POPAD
	POP		EBP
	RET		8	
readVal ENDP

; ----------------------------------------------------------------------------------------------------
; Name: writeVal
; 
; Accepts a string of integers and converts them to ASCII characters to be displayed as a string.
; 
; Preconditions: 
;		*	intArray, arraySum, arrayAvg are SDWORDs
;		*	solutionString, outString, inString are BYTEs
;		*	blankString has been initialized to contain only zeros
;
; Postconditions: 
;		*	changed registers: EAX, EBX, ECX, EDX
;		*	the ASCII representation of the value is returned
;		*	values have been placed into solutionString, outString
;	
; Receives:
;		*	OFFSETS: arraySum, arrayAvg, intArray
;		*	Values: MAX_SIZE
; 
; Returns:
;		*	the ASCII representation of the value
; ----------------------------------------------------------------------------------------------------
writeVal	PROC		
	PUSH	EBP							
	MOV		EBP, ESP					
	PUSHAD		

	; clear outString and solutionString of any previous entries
	MOV		ECX, [EBP+24]						; sets counter to MAX_SIZE = 20
	MOV		ESI, [EBP+20]						; source is blankString
	MOV		EDI, [EBP+12]						; destination outString
	REP		MOVSB
	
	; clear solutionString 
	MOV		ECX, [EBP+24]						; sets counter to MAX_SIZE = 20
	MOV		ESI, [EBP+20]						; source is blankString
	MOV		EDI, [EBP+16]						; destination solutionString
	REP		MOVSB

	MOV		ESI, [EBP+8]			
    MOV		EAX, [ESI]			
    MOV		ECX, 0								; counter
	MOV		EBX, 0
	
	CMP		EAX, 0
	JL		_isNegative
_setUp:
	PUSH	EBX
	MOV		EDI, [EBP+12]
_divideLoop:
    MOV		EBX, 10								; divisor
    XOR		EDX, EDX			
    DIV		EBX						
    INC		ECX									; count digits
	ADD		EDX, 48
	MOV		[EDI], EDX
	MOV		EBX, 1
	ADD		EDI, EBX							; increment to point to next byte
    CMP		EAX, 0
    JNE		_divideLoop							; if EAX = 0, continue divideLoop
	JMP		_negate
_isNegative:
	MOV		EBX, -1
	NEG		EAX
	JMP		_setUp
_negate:
	POP		EBX
	CMP		EBX, -1
	JE		_addNegativeSign
	
	; reversing the string (no negative sign)
	MOV		ESI, [EBP+12]
	ADD		ESI, ECX
	DEC		ESI
	MOV		EDI, [EBP+16]
_revLoop1:
	STD
	LODSB
	CLD
	STOSB
	LOOP	_revLoop1
	mDisplayString  [EBP+16]					; display solution string
	JMP		_end

_addNegativeSign:
	; reversing the string
	MOV		ESI, [EBP+12]
	ADD		ESI, ECX
	DEC		ESI
	MOV		EDI, [EBP+16]
	MOV		BYTE PTR [EDI], 45					; write negative at 0th index of solutionString
	INC		EDI
_revLoop2:
	STD
	LODSB
	CLD
	STOSB
	LOOP	_revLoop2
	mDisplayString  [EBP+16]					; display solution string
	JMP		_end

_end:
	CALL	Crlf

	POPAD
	POP		EBP
	RET		8	
writeVal	ENDP

; ----------------------------------------------------------------------------------------------------
; Name: calculate
; 
; Calculates intArray's sum and average.
; 
; Preconditions: 
;		*	intArray contains 10 integers that fit within a 32-bit register
;		*	arraySum, arrayAverage are SDWORDs
; 
; Postcondition: 
;		*	registers changed: EAX, EBX, ECX, EDX
;		*	arraySum, arrayAverage are evaluated
; 
; Receives:
;		*	intArray
;
; Returns:
;		*	arraySum, arrayAverage contains appropriate values
; ----------------------------------------------------------------------------------------------------
calculate PROC
	PUSH	EBP							
	MOV		EBP, ESP					
	PUSHAD	

	; finding the sum of values in intArray
	MOV		EAX, 0
	MOV		EBX, 0
	MOV		ESI, [EBP+8]

	MOV		ECX, 10					; set loop counter to size of the array = 10
_addLoop:
	MOV		EBX, [ESI]
	ADD		EAX, EBX
	ADD		ESI, 4
	LOOP	_addLoop
	MOV		EDI, [EBP+12]			; stores EAX to arraySum
	MOV		[EDI], EAX

	; finding the average value for intArray
	XOR		EAX, EAX
	XOR		EDX, EDX
	MOV		ESI, [EBP+12]			; access to arraySum
	MOV		EAX, [ESI]				; moves arraySum to EAX for division
	MOV		EBX, 10			
	CDQ
	IDIV	EBX
	MOV		EDI, [EBP+16]			
	MOV		[EDI], EAX				; stores EAX to arrayAvg

	POPAD
	POP		EBP
	RET		8
calculate ENDP

; Note to grade: unable to properly print values in array; hence, procedure is not called in Main.
; ----------------------------------------------------------------------------------------------------
; Name: printArray
; 
; Displays the integer values stored in intArray as ASCII characters.
; 
; Preconditions: 
;		*  displayInts, blankSolution, outSolution, inString are BYTEs
;		*  intArray is SDWORD
;
; ; Postcondition: 
;		*  registers changed: EDX, EAX
;
; Receives:
;		*  OFFSETS: intArray, displayInts, blankSolution, outSolution, inString
;		*  VALUES: MAX_SIZE, ARRAY_SIZE
;
; Returns:
;		*  the ASCII representation of the values present in intArray
; ----------------------------------------------------------------------------------------------------
printArray PROC
	PUSH	EBP							
	MOV		EBP, ESP					
	PUSHAD		

	MOV		ECX, [EBP+28]								; set counter to ARRAY_SIZE = 10
	MOV		ESI, [EBP+8]								; intArray
_printLoop:
	PUSH	ECX
	PUSH	ESI
	PUSH	EDI
	CALL	writeVal
	ADD		ESI, 4
	LOOP	_printLoop
	mDisplayString [EBP+32]

	CALL	Crlf

	POPAD
	POP		EBP
	RET		8
printArray ENDP



; ----------------------------------------------------------------------------------------------------
; Name: farewell
; 
; Says goodbye to the user.
; 
; Preconditions: 
;		*  goodbye is BYTE
; 
; Postcondition: 
;		*  registers changed: EDX
; ----------------------------------------------------------------------------------------------------
farewell PROC
	PUSH	EBP							
	MOV		EBP, ESP					
	PUSHAD		
		
	CALL	Crlf
	mDisplayString	[EBP+8]
	CALL	Crlf
	CALL	Crlf

	POPAD
	POP		EBP
	RET		8
farewell ENDP

END main




