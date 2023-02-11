.model tiny
.code

org 100h

Start:
	mov ah, 09h
	mov dx, offset String
	int 21h	

	mov bx, 0b800h
	mov es, bx
	mov bx, 160d * 4d

	mov ch, 0d
	mov cl, 5d
	call PrintSymb

	mov ax, 4c00h
	int 21h


PrintSymb:
	inc ch	
	
	mov ax, word ptr String
	mov [es:[bx]], ax
	add bx, 2 
	
	cmp ch, cl
	jl PrintSymb

	ret

	
String: db 'TEST, HELLO$'


end	Start