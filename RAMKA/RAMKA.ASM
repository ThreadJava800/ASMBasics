.model tiny

.data
	first:	db 'Enter frame line num (max: 25d): $'
	second: db 'Enter frame col num (max: 80d): $'
	third:  db 'Enter frame height (max: 25d): $'
	forth:	db 'Enter frame length (max: 80d): $'
	fifth:  db 'Enter frame type (3 - *, 4 - custom): $'

	error_str:  db 'You are mistaken! IDIOT. Aborting...$'
.code

org 100h

locals @@

Start:		mov bx, 0b800h
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
		add bx, si		; bx += strintId
					; position ready
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

		mov ax, 0541h
		mov dx, 0542h
		
		pop cx
		pop di
		call DrawRect
			
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