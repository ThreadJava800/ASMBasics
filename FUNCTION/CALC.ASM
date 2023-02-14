.model tiny

.code


org 100h

locals @@

Start:
	call IntInput
	 
	mov si, di
	mov bx, 0b800h
	mov es, bx
	mov bx, 80d * 5d + 40d

	call ToDec
		
	ret

;------------------------------------------------------------
; Reads dec number
;------------------------------------------------------------
; Entry:	None
; Exit:		DX - dec value
; Expects:	None
; Destroys:	AX, CX, DI, SI
;------------------------------------------------------------
IntInput	proc

		mov di, 0000h		; di = 0
		mov cx, 0005h		; cx = 5 (max amount of numbers)
		
@@Loop:		mov ah, 01h
		int 21h			; reading char -> al

		sub al, 30h		; al -= 30 (ascii -> number)
		mov ah, 00h

		mov si, ax
		mov ax, di
		mov di, si		; swap (ax, di)

		mov si, 10d
		mul si			; ax *= 10

		add ax, di		; ax += di (last number)

		mov si, ax
		mov ax, di
		mov di, si		; swap (ax, di)

		loop @@Loop	

		ret
		endp

include liba.asm

end	Start