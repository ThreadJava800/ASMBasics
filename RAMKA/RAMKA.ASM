.model tiny

.data
	first:	db 'Enter frame line num (max: 25d): $'
	second: db 'Enter frame col num (max: 80d): $'
	third:  db 'Enter frame height (max: 25d): $'
	forth:	db 'Enter frame length (max: 80d): $'
	fifth:  db 'Enter frame type (1 - ones, 2 - twos, 3 - *, 4 - custom): $'
	
	ub:  db 'Enter upper bound char: $' 
	rs:	db 0Ah, 'Enter right side border char: $'
	lb:     db 0Ah, 'Enter lower bound char: $'
	ls:	db 0Ah, 'Enter left side border char: $'
	
	lhc:    db 0Ah, 'Enter left higher corner: $'
	rhc:	db 0Ah, 'Enter right higher corner: $'
	llc:	db 0Ah, 'Enter left lower corner: $'
	rlc:	db 0Ah, 'Enter right lower corner: $'

	inside:	db 0Ah, 'Enter inside char: $'

	error_str:  db 'You are mistaken! IDIOT. Aborting...$'
.code

org 100h

locals @@

Start:	
		mov bx, 0082h
		call ReadNumber

		mov si, ax
		mov bx, 0b800h
		mov es, bx
		mov bx, 160d * 5d + 40d
		call ToDec

@@Exit:		ret


ReadNumber		proc
				mov ax, 00h
				mov dx, 00h

@@Loop:			mov byte ptr cl, [bx]
				cmp cl, 0Dh
				je @@Exit

				cmp cl, 20h
				je @@Exit

				mov si, 10d 
				mul si 

				add al, cl
				sub al, 30h

				add bl, 1
				jmp @@Loop

@@Exit:			add bl, 1
				ret
				endp


include ..\LIBA.ASM

end	Start