init_calculator:
	display	EQU	0x28
	MOV	display,0

;--------------------------------------------------------------------------
; Reads numbers until an action key is pressed
; Outputs:
;	A: The read number
;	B: The action key terminating the input (see keypad)
;--------------------------------------------------------------------------
read_number:
	num	EQU	0x29
	MOV	num,	0
calculator_read_number_loop:
	CALL	read_keypad
	MOV	R0,	A
	ANL	A,	#0F0H
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