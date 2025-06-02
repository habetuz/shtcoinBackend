await_display:
	MOV	B, #015h
	MOV	A, #0ECh
	NOP
	DJNZ	A, $
	DJNZ	B, $-7
	NOP
	NOP
	ret

init_display:
	mov 	P0, #00000000B
	mov 	P1, #00000000B
	call 	await_display
	ret

display_smile:
	mov 	DPTR, #smiley_laugh
	call 	display_dptr
	ret

display_dptr:
	mov 	A,  #8D
	mov 	P2, #1D

; Loop 8 times to display whole image
smiley_loop:
; Copy A (loop counter)
	mov 	B, A
	movc 	A, @A+DPTR

	; Set P0 (x-axis) and P1 (y-axis)
	mov 	P0, A

	; Flush row
	mov 	P1, P2
	mov 	P1, #0D

	; Next line
	mov 	A,  P2
	rl 	A
	mov 	P2, A
	mov 	A,  B
	dec 	A

	JNZ smiley_loop
	ret

smiley_laugh:
	db 24, 36, 66, 66, 66, 66, 66, 66
