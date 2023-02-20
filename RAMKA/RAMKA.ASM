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
				call ReadNumber			; ax -> line

				mov si, 160d 
				mul si					; ax *= 10
				mov di, ax 				; si = ax

				call ReadNumber
				add ax, ax
				add di, ax
				push di					; coordinates ready

				call ReadNumber
				push ax					; height

				call ReadNumber
				push ax					; length

				call ReadNumber			; type

				cmp ax, 01h
				je @@Parse1
				cmp ax, 02h
				je @@Parse2
				cmp ax, 03h
				je @@Parse3
				cmp ax, 04h
				je @@Parse4


@@Parse1:		mov cx, 08h
@@Loop1:		push 0531h		; 1s
				loop @@Loop1
				push 0020h		; inside = space

				jmp @@Call

@@Parse2:		mov cx, 08h
@@Loop2:		push 0532h
				loop @@Loop2
				push 0020h			; inside = space

				jmp @@Call


@@Parse3:		mov cx, 08h
@@Loop3:		push 052ah
				loop @@Loop3
				push 0020h			; inside = space		

				jmp @@Call


@@Parse4:		mov cx, 09h

@@Loop4:		mov byte ptr al, [bx]
				inc bl
				inc bl
				mov ah, 05h
				push ax		

				loop @@Loop4		


@@Call:			mov bx, 0b800h
				mov es, bx

				call DrawRect
				int 20h
				ret

; Destroys:		ax, bx, cx, dx, si
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

				inc bl
				jmp @@Loop

@@Exit:			inc bl
				ret
				endp


include ..\LIBA.ASM

end	Start