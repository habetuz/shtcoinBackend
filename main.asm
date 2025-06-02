call 	init_keypad
call	clear_display

truth	DATA	50h
MOV	P3,	#00h

main_loop:
	CALL	read_number

	CALL	calculate

	MOV	P3,	truth

	JMP	main_loop


include 'keypad.asm'
include 'calculator.asm'
include	'display.asm'
END