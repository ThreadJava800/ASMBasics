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
		mov bx, 0b800h
		mov es, bx
		mov bx, 00h

		; LINE NUMBER ;
		mov ah, 09h
		mov dx, offset first
		int 21h

		call IntInput
		mov di, 25d
		call CheckValue
		mov ax, si
		mov cx, 160d
		mul cx
		mov bx, ax		; bx = line * 160		

		; STRING ID NUM ;
		mov ah, 09h
		mov dx, offset second
		int 21h

		call IntInput
		mov di, 80d
		call CheckValue	
		add si, si 
		add bx, si		; bx += strintId
					; position ready

		push bx

		; FRAME HEIGHT ;
		mov ah, 09h
		mov dx, offset third
		int 21h

		call IntInput
		mov di, 25d
		call CheckValue
		push si			; di = height

		; FRAME LENGTH ;

		mov ah, 09h
		mov dx, offset forth
		int 21h
		
		call IntInput
		mov di, 80d
		call CheckValue
		push si			; cx = length
					; sizes ready

		; TYPE NUMBER ;
		mov ah, 09h
		mov dx, offset fifth
		int 21h

		call IntInput
		mov di, 04h
		call CheckValue		; si = type
		
		cmp si, 01h
		je @@Parse1
		cmp si, 02h
		je @@Parse2
		cmp si, 03h
		je @@Parse3
		cmp si, 04h
		je @@Parse4

@@Parse1:	mov cx, 09h
@@Loop1:	push 0531h		; 1s
		loop @@Loop1

		jmp @@Call

@@Parse2:	mov cx, 09h
@@Loop2:	push 0532h
		loop @@Loop2

		jmp @@Call

@@Parse3:	mov cx, 09h
@@Loop3:	push 2ah
		loop @@Loop3
		
		jmp @@Call

@@Parse4:	mov ah, 09h
		mov dx, offset ub
		int 21h

		mov ah, 01h
		int 21h

		mov ah, 05h
		push ax			; read upper bound
		
		mov ah, 09h
		mov dx, offset rs
		int 21h
				
		mov ah, 01h
		int 21h

		mov ah, 05h
		push ax			; read right side

		mov ah, 09h
		mov dx, offset lb
		int 21h

		mov ah, 01h
		int 21h

		mov ah, 05h
		push ax			; lower bound

		mov ah, 09h
		mov dx, offset ls
		int 21h

		mov ah, 01h
		int 21h

		mov ah, 05h
		push ax			; left side border

		mov ah, 09h
		mov dx, offset lhc
		int 21h

		mov ah, 01h
		int 21h

		mov ah, 05h
		push ax			; left higher corner

		mov ah, 09h
		mov dx, offset rhc
		int 21h

		mov ah, 01h
		int 21h

		mov ah, 05h
		push ax			; right higher corner

		mov ah, 09h
		mov dx, offset llc
		int 21h

		mov ah, 01h
		int 21h
		
		mov ah, 05h
		push ax			; left lower corner

		mov ah, 09h
		mov dx, offset rlc
		int 21h

		mov ah, 01h
		int 21h

		mov ah, 05h
		push ax			; right lower corner

		mov ah, 09h
		mov dx, offset inside
		int 21h

		mov ah, 01h
		int 21h

		mov ah, 05h
		push ax			; inside char



@@Call:		call DrawRect
		add sp, 26
		int 20h	
@@Exit:		ret


CheckValue	proc				; compares if si <= di
		
		cmp si, di
		ja @@Error
		jmp @@Exit

@@Error:	mov ah, 09h
		mov dx, offset error_str
		int 21h
		int 20h		

@@Exit:		ret
		endp

include ..\LIBA.ASM

end	Start