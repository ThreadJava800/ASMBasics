.model tiny
.code

org 100h

Start:	
	mov bx, 0b800h
	mov es, bx
	mov bx, 160d * 4d + 78d 	; setting place of string (line 5)

	mov si, offset String		; setting string to print
	mov ah, 00h			; setting color

	call PrintString
	ret

;----------------------------------------------------------------------------
; Prints string 
; String format: sym1 - attr1, sym2 - attr2, sym3 = ...
; Example: 41h, 05h, 24h - A
;----------------------------------------------------------------------------
; Entry:	BX - place where to print letter
;		SI - pointer to string
; Exit:		None
; Expects:	ES -> video register (b800h)
; Destroys:	AX, BX, SI
;---------------------------------------------------------------------------

PrintString:
	mov al, [si]
	mov ah, al			; setting color of letter	

	mov al, [si]			; getting letter to al
	cmp al, '$'
	je Exit	

	inc si
	; flag
	mov word ptr es:[bx], ax
	inc bx				; printing letter
	;inc si
	jmp PrintString
	ret

Exit:
	mov ax, 4c00h			; exit(0)
	int 21h

	
String: db 41h, 05h, 42h, 05h, 43h, 06h, 44h, 05h, 45h, 06h, 00h, '$'
	; ABCDE (colored) every even letter is a color for the following ascii


end	Start