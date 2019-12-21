TITLE Program # 6b    (Program06b.asm)

; Author: Pavel Gordeyev
; Description: Combinations Calculator

INCLUDE Irvine32.inc

;------------------------------------------------------------------
;------------------------------------------------------------------
; mDisplayString
;
; Prints out the string accepted as a parameter
;
; Receives: str
;
; Returns: N/A, prints out the string
;------------------------------------------------------------------
;------------------------------------------------------------------
mDisplayString	MACRO str
	push	edx					; save edx register
	mov		edx, OFFSET str
	call	WriteString
	pop		edx					; restore edx register
ENDM

;------------------------------------------------------------------
;------------------------------------------------------------------
; mDisplayVal
;
; Prints out the integer value accepted as a parameter
;
; Receives: val
;
; Returns: N/A, prints out the value
;------------------------------------------------------------------
;------------------------------------------------------------------
mDisplayVal	MACRO val
	push	eax					; save eax register
	mov		eax, val
	call	WriteDec
	pop		eax					; restore eax register
ENDM

.data

introTitle			BYTE	"Welcome to the Combinations Calculator!!", 0
introName			BYTE	"Brought to you by Pavel Gordeyev", 0
intro_1				BYTE	"I'll give you a combinations problem.", 0
intro_2				BYTE	"You enter the answer, and I'll let you know how you did!", 0
problemMessage_1	BYTE	"Combination Problem:", 0
problemMessage_2	BYTE	"Number of elements in the set: ", 0
problemMessage_3	BYTE	"Number of elements to choose from the set: ", 0
prompt				BYTE	"How many ways can you choose? ", 0
errorNumMessage		BYTE	"Invalid number! Please try again!", 0
errorYNMessage		BYTE	"Invalid response! ", 0
resultMessage_1		BYTE	"There are ", 0
resultMessage_2		BYTE	" combinations of ", 0
resultMessage_3		BYTE	" items from a set of ", 0
resultMessage_4		BYTE	"You entered: ", 0
correctMessage		BYTE	". You are correct!", 0
incorrectMessage	BYTE	". You need some more practice!", 0
playAgainMessage	BYTE	"Another problem? (y/n): ", 0
validCharY			BYTE	"y", 0
validCharN			BYTE	"n", 0
goodbyeMessage		BYTE	"Thanks for your participation! Till next time.", 0
lo					equ		3	; minimum n
hi					equ		12	; maximum n
MAXCHARS			equ		30	; max characters user can enter
minASCII			equ		48  ; ASCII value for 0
maxASCII			equ		57	; ASCII value for 9
randInt				DWORD	?
resultComb			DWORD	?
n					DWORD	?
r					DWORD	?
userInput			BYTE	?
userInput_2			BYTE	?
answer				DWORD	?
isValid				DWORD	?
val					DWORD	?
playAgain			DWORD	?



.code
main PROC
	
	; Introduction statements
	call	introduction

Play:
	; Show the problem
	push	OFFSET n
	push	OFFSET r
	call	showProblem

	; Get user data
	push	OFFSET isValid
	push	OFFSET answer
	call	getUserData

	; Calculate the combination
	push	n
	push	r
	push	OFFSET resultComb
	call	combinations

	; Show the results
	push	n
	push	r
	push	resultComb
	push	answer
	call	showResults

	; Prompt user to play again
	push	OFFSET	isValid
	push	OFFSET	playAgain
	call	checkPlayAgain
	mov		ebx, playAgain
	mov		eax, 1
	cmp		eax, ebx
	je		Play

	; Say Goodbye
	call	goodbye

	exit								; exit to operating system

main ENDP

;------------------------------------------------------------------
;------------------------------------------------------------------
; introduction
;
; Shows the title of the program, the programmer's name, and the 
; instructions and information needed for the user to operate
; the program.
;
; Receives: N/A
;
; Returns: N/A, prints out the introductory statements
;------------------------------------------------------------------
;------------------------------------------------------------------
introduction PROC

	; Display the introduction
	mDisplayString	introTitle
	call	CrLf
	mDisplayString	introName
	call	CrLf
	call	CrLf

	; Display the instructions
	mDisplayString	intro_1
	call	CrLf
	mDisplayString	intro_2
	call	CrLf
	call	CrLf

	ret

introduction ENDP

;------------------------------------------------------------------
;------------------------------------------------------------------
; combinations
;
; Calculates the combination value for a specified n & r.
;
; Receives: n, r, @resultComb
;
; Returns: resultComb, result of the combination calculation
;------------------------------------------------------------------
;------------------------------------------------------------------
combinations PROC

	push	ebp
	mov		ebp, esp

	pushad						; save registers

	push	[ebp + 16]			; n
	call	factorial
	mov		ebx, eax			; result of n!
	
	push	ebx					; save ebx
	push	[ebp + 12]			; r
	call	factorial
	pop		ebx					; restore ebx
	mov		ecx, eax			; result of r!

	mov		eax, [ebp + 16]		; n
	sub		eax, [ebp + 12]		; n - r
	push	ebx					; save ebx
	push	eax
	call	factorial
	pop		ebx					; restore ebx
	mov		edx, eax			; result of (n-r)!

	mov		eax, ecx
	mul		edx					; r! * (n-r)!
	mov		edx, 0
	mov		ecx, eax			; save eax result in ecx
	mov		eax, ebx			; move n! to eax
	div		ecx					; n!/(r!*(n-r)!)

	mov		ebx, [ebp + 8]
	mov		[ebx], eax			; resultComb

	popad						; restore registers

	pop		ebp
	ret		12					; clear the stack

combinations ENDP

;------------------------------------------------------------------
;------------------------------------------------------------------
; factorial
;
; Calculates the factorial for a specified number recursively.
;
; Receives: n
;
; Returns: result of the factorial calculation in eax
;------------------------------------------------------------------
;------------------------------------------------------------------
factorial PROC

	push	ebp
	mov		ebp, esp
	
	mov		eax, [ebp + 8]
	cmp		eax, 0
	ja		NextNum
	mov		eax, 1
	jmp		Base

NextNum:
	dec		eax
	push	eax
	call	factorial

	mov		ebx, [ebp + 8]
	mul		ebx

Base:
	pop		ebp
	ret		4					; clear the stack

factorial ENDP

;------------------------------------------------------------------
;------------------------------------------------------------------
; showProblem
;
; Prints out the combination problem statement.
;
; Receives: @n, @r
;
; Returns: N/A, prints out the problem statement
;------------------------------------------------------------------
;------------------------------------------------------------------
showProblem PROC
	
	push			ebp
	mov				ebp, esp

	call			Randomize				; seed the random numbers

	pushad									; save registers

	; Get the random value for n
	push			OFFSET randInt
	push			lo
	push			hi
	call			getRandomNumber
	mov				eax, randInt
	mov				ebx, [ebp + 12]			; @n
	mov				[ebx], eax

	; Get the random value for r
	push			OFFSET randInt
	push			lo
	push			[ebx]					; highest value would be n itself for r
	call			getRandomNumber
	mov				eax, randInt
	mov				ebx, [ebp + 8]			; @r
	mov				[ebx], eax				

	call			CrLf

	; Output the problem statement
	mDisplayString	problemMessage_1
	call			CrLf
	mDisplayString	problemMessage_2
	mov				ebx, [ebp + 12]
	mDisplayVal		[ebx]					; n
	call			CrLf
	mDisplayString	problemMessage_3
	mov				ebx, [ebp + 8]
	mDisplayVal		[ebx]					; r
	call			CrLf

	popad									; restore registers

	pop				ebp
	ret				8						; clear the stack

showProblem ENDP

;------------------------------------------------------------------
;------------------------------------------------------------------
; getRandomNumber
;
; Returns a random number in the specified range.
;
; Receives: @randInt, lo, hi
;
; Returns: randInt, random integer in the specified range
;------------------------------------------------------------------
;------------------------------------------------------------------
getRandomNumber PROC
	
	push	ebp
	mov		ebp, esp

	pushad						; save registers

	; Generate a random number in the specified range
	; Cited from Lecture20 (RandomRange Example)
	mov		eax, [ebp + 8]		; low value
	sub		eax, [ebp + 12]		; high value
	inc		eax
	call	RandomRange			; [0,high value - 1]
	add		eax, lo				; [low value, high value]

	; Save the result
	mov		ebx, [ebp + 16]
	mov		[ebx], eax

	popad						; restore registers
	
	pop		ebp
	ret		12					; clear the stack

getRandomNumber ENDP

;------------------------------------------------------------------
;------------------------------------------------------------------
; getUserData
;
; Prompts the user for a positive integer input between specified
; range. Will loop continously until the user enters a valid number.
; Utilizes the validate function to check the value entered.
; Saves the user input into answer.
;
; Receives: @isValid, @answer
;
; Returns: answer, a valid integer
;------------------------------------------------------------------
;------------------------------------------------------------------
getUserData PROC
	
	push			ebp
	mov				ebp, esp

	pushad								; save registers

GetInput:	
	; Ask the user for input
	mDisplayString	prompt
	mov				edx, OFFSET userInput
	mov				ecx, MAXCHARS
	call			ReadString
	
	; Validate user input - makes sure it is an integer
	push			[ebp + 12]			; @isValid
	push			minASCII
	push			maxASCII
	call			validateInt

	; Check if a valid input was entered
	; Otherwise reprompt user
	mov				eax, 0
	mov				ecx, [ebp + 12]		; @isValid
	cmp				eax, [ecx]
	je				GetInput

	push			OFFSET val
	call			convertToInt

	mov				ebx, [ebp + 8]		; @answer
	mov				eax, val
	mov				[ebx], eax			; answer

	popad								; restore registers

	pop				ebp
	ret				4					; clear the stack

getUserData ENDP

;------------------------------------------------------------------
;------------------------------------------------------------------
; validateInt
;
; Validates the user input is an integer. 
; Outputs error message if it is not valid.
;
; Receives: min, max, answer & @isValid
;
; Returns: isValid, 1 if true, 0 if false
;------------------------------------------------------------------
;------------------------------------------------------------------
validateInt PROC
	
	push	ebp
	mov		ebp, esp

	pushad								; save registers

	mov		edx, [ebp + 16]				; @isValid
	mov		esi, OFFSET userInput
	xor		eax, eax					; zero out eax

	; Check each character that it is a number
nxtChar:
	mov		ebx, [ebp + 8]				; maxASCII
	mov		al, [esi]
	test	al, al						; check for \0
	je		Valid						; reached the end with no errors
	cmp		eax, ebx
	jg		ErrMessage
	mov		ebx, [ebp + 12]				; minASCII
	cmp		eax, ebx
	jl		ErrMessage
	inc		esi							; next character
	jmp		nxtChar

ErrMessage:
	mDisplayString	errorNumMessage
	call			CrLf
	mov				eax, 0					
	mov				[edx], eax			; set return isValid to 0
	jmp				DoneV				

Valid:
	mov				eax, 1				
	mov				[edx], eax			; set return isValid to 1

DoneV:
	popad								; restore registers
	
	pop				ebp
	ret				12					; clear the stack

validateInt ENDP

;------------------------------------------------------------------
;------------------------------------------------------------------
; checkPlayAgain
;
; Prompts the user for y or n and sees if they want to play again.
;
; Receives: @isValid, @playAgain
;
; Returns: request, a valid user input in the specified range
;------------------------------------------------------------------
;------------------------------------------------------------------
checkPlayAgain PROC
	
	push			ebp
	mov				ebp, esp

	pushad								; save registers

RetryInput:	
	; Ask the user for input
	call			CrLf
	mDisplayString	playAgainMessage
	mov				edx, OFFSET userInput_2
	mov				ecx, MAXCHARS
	call			ReadString
	
	; Validate user input if it is a 'y'
	push			[ebp + 12]			; @isValid
	push			OFFSET validCharY	; "y"
	call			validateChar
	mov				eax, 1
	mov				ebx, [ebp + 12]
	cmp				eax, [ebx]
	je				PlayAgainYes
	jl				ErrorMessage

	; Validate user input if it is an 'n'
	push			[ebp + 12]			; @isValid
	push			OFFSET validCharN	; "n"
	call			validateChar
	mov				eax, 1
	cmp				eax, [ebx]
	je				PlayAgainNo
	jmp				ErrorMessage

ErrorMessage:
	mDisplayString	errorYNMessage
	call			CrLf
	jmp				RetryInput
	
PlayAgainYes:
	mov				ebx, [ebp + 8]		; @playAgain
	mov				[ebx], eax			; playAgain = 1
	jmp				DoneCheck

PlayAgainNo:
	mov				eax, 0
	mov				ebx, [ebp + 8]		; @playAgain
	mov				[ebx], eax			; playAgain = 0

DoneCheck:
	popad								; restore registers

	pop				ebp
	ret				8					; clear the stack

checkPlayAgain ENDP

;------------------------------------------------------------------
;------------------------------------------------------------------
; validateChar
;
; Validates the user input is a correct char.
; Outputs error message if it is not valid.
;
; Receives: @isValid, @validChar
;
; Returns: isValid, 1 if true, 0 if false
;------------------------------------------------------------------
;------------------------------------------------------------------
validateChar PROC
	
	push	ebp
	mov		ebp, esp

	pushad								; save registers

	mov		edx, [ebp + 12]				; @isValid
	mov		esi, OFFSET userInput_2
	mov		edi, [ebp + 8]				; validCharY/N
	xor		eax, eax					; zero out eax

	; Check if character matches validChar
	mov		al, [esi]
	mov		bl, [edi]
	cmp		al, bl
	jne		NoMatch
	inc		esi						; next character
	mov		al, [esi]
	test	al, al					; check for \0
	jne		TooMany
	jmp		Valid
	
NoMatch:
	inc		esi
	mov		al, [esi]
	test	al, al					; check for \0			
	jne		TooMany
	mov		eax, 0					
	mov		[edx], eax				; set return isValid to 0
	jmp		DoneV				

TooMany:							; too many characters
	mov		eax, 2
	mov		[edx], eax
	jmp		DoneV

Valid:
	mov		eax, 1				
	mov		[edx], eax				; set return isValid to 1

DoneV:
	popad							; restore registers
	
	pop		ebp
	ret		8						; clear the stack

validateChar ENDP

;------------------------------------------------------------------
;------------------------------------------------------------------
; convertToInt
;
; Converts a string to an integer.  String was previously validated.
; Citation: 64bit conversion example used to help write function
; https://gist.github.com/tnewman/63b64284196301c4569f750a08ef52b2
;
; Receives: @val
;
; Returns: val
;------------------------------------------------------------------
;------------------------------------------------------------------
convertToInt PROC
	
	push	ebp
	mov		ebp, esp

	pushad							; save registers

	mov		ecx, [ebp + 8]			; @val
	mov		edi, OFFSET userInput
	xor		eax, eax				; zero out eax
	xor		ebx, ebx				; zero out ebx

nextChar:
	mov		bl, [edi]				; get character
	test	bl, bl					; check for the \0 character
	je		DoneC
	inc		edi						; next character
	sub		bl, 48					; convert to integer
	mov		edx, 10					
	mul		edx						; multiply eax by 10
	add		eax, ebx				; add to current value in eax
	jmp		nextChar

DoneC:
	mov		[ecx], eax				; save the converted value
	
	popad							; restore registers

	pop		ebp
	ret		4						; clear the stack

convertToInt ENDP

;------------------------------------------------------------------
;------------------------------------------------------------------
; showResults
;
; Prints out the results of the combination problem.
;
; Receives: n, r, result, answer
;
; Returns: N/A, prints out the results of the combination problem
;------------------------------------------------------------------
;------------------------------------------------------------------
showResults PROC
	
	push			ebp
	mov				ebp, esp

	call			CrLf

	pushad							; save registers
	
	; Output the answer for the combination
	mDisplayString	resultMessage_1
	mDisplayVal		[ebp + 12]				; resultComb
	mDisplayString	resultMessage_2
	mDisplayVal		[ebp + 16]				; r
	mDisplayString	resultMessage_3
	mDisplayVal		[ebp + 20]				; n
	call			CrLf

	; Ouput the user's answer and if it was correct
	mDisplayString	resultMessage_4
	mDisplayVal		[ebp + 8]
	mov				eax, [ebp + 8]			; answer
	cmp				eax, [ebp + 12]			; resultComb
	je				Correct
	mDisplayString	incorrectMessage
	jmp				DoneC

Correct:
	mDisplayString	correctMessage
	
DoneC:
	call			CrLf

	popad								; restore registers

	pop				ebp
	ret				16					; clear the stack

showResults ENDP

;------------------------------------------------------------------
;------------------------------------------------------------------
; goodbye
;
; Prints out the goodbye message to the user.
;
; Receives: N/A
;
; Returns: N/A, prints out the goodbye statement
;------------------------------------------------------------------
;------------------------------------------------------------------
goodbye PROC
	
	call	CrLf
	mDisplayString	goodbyeMessage
	call	CrLf

	ret

goodbye ENDP

END main
