init_keypad:
	last	EQU	0x21
	MOV	last,	#0FFH
	RET

;--------------------------------------------------------------------------
; Reads the keypad until a button is pressed
; Output:
;	A: The value of the pressed button
; Values:
; 00 - 09 -> Numeric vallues 0-9
; 10 | 0001 0000 -> A
; 20 | 0010 0000 -> B
; 40 | 0100 0000 -> C
; 80 | 1000 0000 -> D
; F0 | 1111 0000 -> #
;--------------------------------------------------------------------------
read_keypad:
	; Setup
	MOV 	P1, 	#0FFH
	mask	EQU	0x22
	i	EQU	0x23
	MOV	i,	#4d
	MOV	mask,	#11111110b
	; Loop i times
keypad_line_loop:
	MOV	P1,	mask

	; Check wether a key in this line is pressed
	MOV	A,	P1
	ANL	A,	#0F0H
	CJNE 	A, #0F0h, keypad_map_value ; Found a pressed key
	
	; Shift mask one to the left (read next line)
	MOV	A,	mask
	RL	A
	MOV	mask,	A

	; Decrement loop counter
	DJNZ	i,	keypad_line_loop
	; No key pressed in this iteration
	MOV	last,	#0FFH
	JMP	read_keypad ; Read again
keypad_map_value:
	MOV	A,	P1
	CALL	map_value ; A contains the mapped value now
	CJNE 	A, last, keypad_return ; Read the same value as last time (no change)
	JMP	read_keypad
keypad_return:
	MOV	last,	A
	RET ; A is a new value, return

;--------------------------------------------------------------------------
; Maps value of A to another value listed in "map_table"
; input:
;	A: The value to map
; output:
;	A: The mapped value
;--------------------------------------------------------------------------
map_value:
	MOV 	DPTR, 	#map_table	; point DPTR at start of table
	; A already contains your input byte
    	MOVC 	A, 	@A+DPTR        ; A := map_table[A]
    	RET


;--------------------------------------------------------------------------
; 256-byte mapping table in code memory
; index = input value in A
; value = mapped output
;--------------------------------------------------------------------------
map_table:
    	DB 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh   ; 00 -> 0F
    	DB 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh   ; 10 -> 1F
    	DB 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh   ; 20 -> 2F
    	DB 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh   ; 30 -> 3F
    	DB 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh   ; 40 -> 4F
    	DB 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh   ; 50 -> 5F
    	DB 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh   ; 60 -> F
    	DB 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 80h,  0FFh, 0FFh, 0FFh, 40h,  0FFh, 20h,  10h,  0FFh   ; 70 -> 7F
    	DB 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh   ; 80 -> 8F
    	DB 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh   ; 90 -> 9F
    	DB 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh   ; A0 -> AF
    	DB 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0F0h, 0FFh, 0FFh, 0FFh, 09h,  0FFh, 06h,  03h,  0FFh   ; B0 -> BF
    	DB 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh   ; C0 -> CF
    	DB 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 00h,  0FFh, 0FFh, 0FFh, 08h,  0FFh, 05h,  02h,  0FFh   ; D0 -> DF
        DB 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 07h,  0FFh, 04h,  01h,  0FFh   ; E0 -> EF
        DB 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh, 0FFh   ; F0 -> FF