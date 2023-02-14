.model tiny
.code

org 100h

locals @@

Start:
	mov ax, 0501h	
	mov dx, 0502h
	
	mov bx, 0b800h
	mov es, bx
	mov bx, 160d * 11d + 40d
	
	mov cx, 30d
	mov di, 10d

	call DrawRect	

	ret

include ..\LIBA.ASM

end	Start