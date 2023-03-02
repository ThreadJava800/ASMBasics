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
	push si

	;; DRAWING FRAME ;;
	
	mov ax, 0C985h	
	mov dx, 09C84h
	
	mov bx, 0b800h
	mov es, bx
	mov bx, 160d * 12d + 52d
	
	mov cx, 30d
	mov di, 9d

	; call DrawRect

	;; PRINTING VALUES ;;

	pop si
	pop di
	add si, di 

	mov bx, 0b800h
	mov es, bx
	mov bx, 160d * 15d + 66d

	push si	

	mov ax, si
	;call ToBin
	add bx, 160d - 20d

	pop si
	push si
	call ToHex
	add bx, 160d

	pop si
	;call ToDec
		
	int 20h

include ..\liba.asm

end	Start
