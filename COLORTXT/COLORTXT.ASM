.model tiny
.code

org 100h

Start:	
	mov bx, 0b800h
	mov es, bx
	mov di, 160d * 4d + 78d 	; setting place of string (line 5)

	mov si, offset String		; setting string to print
	mov ah, 00h			; setting color

	call PrintString
	ret


ChangeColor:
	mov ah, al			; setting color attribute for letter
	ret


PrintString:
	lodsb				; getting letter to al
	call CheckIfExit
	call ChangeColor

	lodsb				; getting letter to al
	call CheckIfExit
	stosw				; printing letter

	jmp PrintString
	ret

CheckIfExit:
	cmp al, '$'			
	je Exit				; compare letter with '$' and jumping
	ret

Exit:
	mov ax, 4c00h			; exit(0)
	int 21h

	
String: db 05h, 41h, 07h, 42h, 08h, 43h, 09h, 44h, 10h, 45h, 24h
	; ABCDE (colored) every even letter is a color for the following ascii


end	Start