call 	init_keypad
call	init_calculator
call	clear_display

main_loop:
	CALL	read_number

	;CALL	calculate
	;CALL	write_number

	CALL	display_number
	JMP	main_loop




include 'keypad.asm'
include 'calculator.asm'
include	'display.asm'
