.model tiny

.data
	hello:	db 'LOOL_ $'
	test2:  db 'LOOL_$'

.code

org 100h

locals @@

Start:
	mov ax, cs
	mov ds, ax
	mov es, ax
	
	lea di, hello
	lea si, test2
	call Strcmp

	;mov dx, offset hello
	;mov ah, 09h
	;int 21h

	ret

include ..\liba.asm 

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
		
@@Repeat:	cld
		lodsb		; DS:SI++ -> AL
		
		cmp al, 00h	; ('\0')
		je  @@Exit

		cmp al, 24h	; ('$')
		je @@Exit

		inc cx		; count++
		jmp @@Repeat    ; if al == 0 || '$': exit() else: loop
		
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
		
		cld
		rep movsb	; while (cx--) DS:SI -> ES:DI

		ret
		endp

;------------------------------------------------------------
; Copies strings
;------------------------------------------------------------
; Entry:	ES:DI - destination pointer
;		DS:SI - string to copy
; Expects:	None
; Exit:		None
; Destroys:	AL, CX, DI, SI
;------------------------------------------------------------
Strcpy		proc

		cld

		push si
		push di

		call Strlen	; strlen(ds:si) -> cx
		
		pop di
		pop si

		call Memcpy		

		mov al, '$'
		stosb		; destStr[-1] = '$'

		ret
		endp


;-------------------------------------------------------------
; Fills first n bytes with given symbol
;-------------------------------------------------------------
; Entry:	ES:DI - pointer to write bytes
;		AL    - byte
;		CX    - count
; Exit:		None
; Expects:	None
; Destroys:	CX, DI
;-------------------------------------------------------------
Memset		proc
		
		cld
		rep stosb

		ret
		endp

;--------------------------------------------------------------
; Compares first n bytes in buffers
;--------------------------------------------------------------
; Entry:	ES:DI - buf1
;		DS:SI - buf2
;		CX    - byte count
; Exit:		DX    - 0 if eq, < 0 if buf1 < buf2 && > 0 if buf1 > buf2
; Expects:	None
; Destroys:	CX, DX, DI, SI
;-------------------------------------------------------------
Memcmp		proc
		cld

		mov dx, 00h
		
@@Loop:		cmp cx, 00h
		je @@Exit		
		dec cx

		cmpsb		; rep cmpsb doesn't work???
		je @@Loop	; if ZF == 1: repeat

		dec di		; else return di - si 
		dec si

		mov dx, es:[di]
		sub dx, ds:[si]		

@@Exit:		ret
		endp


;-------------------------------------------------------------
; Compares to string
;-------------------------------------------------------------
; Entry:	ES:DI - buf1
;		DS:SI - buf2
; Exit:		DX    - 0 if equ, < 0 if buf1 < buf2 && > 0 if buf1 > buf2
; Expects:	None
; Destroys:	AX, DX, DI, SI
;-------------------------------------------------------------
Strcmp		proc

		cld
		mov dx, 00h

@@Loop:		mov al, es:[di]
		mov ah, ds:[si]

		cmp ah, '$'
		je @@CheckLenSI
		
		cmp al, '$'
		je @@CheckLenDI		; if al == '$': cmp lens
		
		cmpsb
		je @@Loop		; if zf == 1: repeat

		dec di
		dec si
		mov dx, es:[di]
		sub dx, ds:[si]
		jmp @@Exit		; else return *di - *si

@@CheckLenSI:	cmp al, '$'
		je @@Exit		; if al == '$' return 0

		mov dx, 01h		; dx = 1
		jmp @@Exit		
		
@@CheckLenDI:				; di ended faster
		mov dx, 0fffeh		; dx = -1

@@Exit:		ret
		endp

end	Start