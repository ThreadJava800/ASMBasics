.model tiny

.data
	hello:	db 'LOOL_ man, no way', 00h
	test2:  db 'WORD was changed$'

.code

org 100h

locals @@

Start:
	mov si, offset hello
	mov di, offset test2
	mov cx, 04h
	call Memcpy

	mov dx, offset test2
	mov ah, 09h
	int 21h
	ret

;------------------------------------------------------------
; Gets length of string (string must end with '\0' (0 ascii)
;------------------------------------------------------------
; Entry:	DS:SI - pointer to string
; Expects:	None
; Exit:		CX - amount of symbols in string
; Destroys:	CX, SI
;------------------------------------------------------------
Strlen		proc
		mov cx, 00h
		
@@Repeat:	lodsb		; DS:SI++ -> AL
		cmp al, 00h
		je  @@Exit

		inc cx		; count++
		jmp @@Repeat    ; if al == 0: exit() else: loop
		
@@Exit:		ret
		endp

;------------------------------------------------------------
; Copies bytes from one side of memory to another one
;------------------------------------------------------------
; Entry:	ES:DI - destination pointer
;		DS:SI - from where pointer
;		CX    - amount of bytes to copy
; Expects:	None
; Exit:		None
; Destroys:	CX, DI, SI
;------------------------------------------------------------
Memcpy		proc

		rep movsb

		ret
		endp

end	Start