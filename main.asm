call 	init_keypad
call	init_calculator

read:
CALL	read_number
MOV	0x00,	A
MOV	0x01,	B
JMP	read



jmp ending
; Imports
include 'keypad.asm'
include 'calculator.asm'
ending:
end

