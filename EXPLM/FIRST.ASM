.model tiny
.code

org 100h

Start:
	mov ah, 09h
	mov dx, offset Message1
	int 21h

	mov ah, 02h
	mov dl, 48h
	int 21h

	mov ax, 4c00h
	int 21h

Message1: db  46h, 55h, 43h, 48h, 20h, 4fh, 46h, 46h, 24h

end Start