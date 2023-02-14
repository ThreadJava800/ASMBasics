.model tiny

.code


org 100h

locals @@

Start:
	mov si, 00h
	mov di, 00h

	call IntInput
	mov si, di
	push si	

	mov di, 00h
	call IntInput
	pop si
	add si, di 

	mov bx, 0b800h
	mov es, bx
	mov bx, 80d * 10d + 40d

	push si	

	mov ax, si
	call ToBin
	add bx, 160d

	pop si
	push si
	call ToHex
	add bx, 160d

	pop si
	call ToDec
		
	ret

include liba.asm

end	Start
