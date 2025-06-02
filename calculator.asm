;--------------------------------------------------------------------------
; Reads numbers until an action key is pressed
; Outputs:
;	A: The read number
;	B: The action key terminating the input (see keypad)
;--------------------------------------------------------------------------
read_number:
	num	EQU	0x30
	MOV	num,	#00h
calculator_read_number_loop:
	CALL	read_keypad
	MOV	R0,	A
	ANL	A,	#0F0h
	JNZ	calculator_ret ; Actions are not 0 -> handle end of number reading
	MOV	A,	num
	MOV	B,	#10d
	MUL	AB
	ADD	A,	R0
	MOV	num,	A
	JMP	calculator_read_number_loop
calculator_ret:
	MOV	A,	num
	MOV	B,	R0
	RET

;--------------------------------------------------------------------------
; Calculates the new truth given a number and operation
; Inputs:
;	A: The number
;	B: The operation (see keypad)
; Side effect:
;	Outputs the calculation to the truth data
;--------------------------------------------------------------------------
calculate:
	MOV	R0,	A
	MOV	A,	B
	SWAP	A
	CJNE 	A, #1111b, check_plus
	JMP 	op_equal
check_plus:
	CJNE	A, #0001b, check_minus
	JMP 	op_add
check_minus:
	CJNE	A, #0010b, check_multiply
	JMP	op_minus
check_multiply:
	CJNE	A, #0100b, op_divide
	JMP	op_multiply

op_equal:
	; MOV	truth,	R0
	RET

op_add:
	MOV	A,	truth
	ADD	A,	R0
	MOV	truth,	A
	RET

op_minus:
	MOV	A,	truth
	SUBB	A,	R0
	MOV	truth,	A
	RET

op_multiply:
	MOV	A,	truth
	MOV	B,	R0
	MUL	AB
	MOV	truth,	A
	RET

op_divide:
	MOV	A,	truth
	MOV	B,	R0
	DIV	AB
	MOV	truth,	A
	RET
