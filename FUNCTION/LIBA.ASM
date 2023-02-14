.data
	ErrorMsg: db 0Ah, 'This symbol is not allowed!$'

.code

;-----------------------------------------------------------
; Print binary of value
;-----------------------------------------------------------
; Entry: 	AX = value to convert to
;		BX = coordinates to print on string 
; Exit:		None
; Expects:  	ES -> videomem (b800h)
; Destroys: 	BX, CX, DL
;-----------------------------------------------------------
ToBin	proc
	
	mov dx, 8000h		; dx = 2 ** 15
	jmp @@NewByte

@@Print1:
	mov es:[bx], 0531h	; put 0 to videomem
	add bx, 2		; bx += 2
	jmp @@Next

@@Print0:
	mov es:[bx], 0530h	; put 0 to videomem
	add bx, 2		; bx += 2
	jmp @@Next	

@@NewByte:
	mov cx, ax		; cx = ax
	and cx, dx		; cx && dx

	cmp cx, 0h		; if cx == 0: print(0) else: print(1)
	je  @@Print0
	jmp @@Print1	

@@Next:	
	cmp dx, 1h		; if dx == 1: return
	je @@Exit

	shr dx, 1		; dx >> 1
	jmp @@NewByte

@@Exit:	ret
	endp

;-----------------------------------------------------------
; Print hex of value
;-----------------------------------------------------------
; Entry: 	SI = value to convert to
;		BX = coordinates to print in cmd 
; Exit:		None
; Expects:  	ES -> videomem (b800h)
; Destroys: 	AX, BX, CX, DX, DI, BP, SP
;----------------------------------------------------------
ToHex	proc

	mov dx, 8000h
	mov cx, 0004h		; cx = 0
	mov di, 0000h	

@@ReadBytes:
	inc ch
	cmp ch, 05h
	je @@Exit
	jmp @@Proceed4bit

@@Proceed4bit:
	mov ax, si
	and ax, dx
	
	cmp ax, 00h
 	je @@SkipMul
	
	mov al, 01h
	mov ah, 00h
	sub cl, 1
	shl al, cl
	add cl, 1
	add di, ax

@@SkipMul:
	sub cl, 1
	shr dx, 1
	
	cmp cl, 00h
	je @@PrintSymbol
	jmp @@Proceed4bit
	
@@PrintSymbol:
	mov ax, di
	mov ah, 05h

	cmp al, 10d
	jae @@LetterPrint

	add al, 30h
	jmp @@ContinuePrint

@@LetterPrint:
	add al, 37h
	jmp @@ContinuePrint	

@@ContinuePrint:
	mov es:[bx], ax
	add bx, 2
	mov di, 00h
	mov cl, 04h
	jmp @@ReadBytes 

@@Exit:
	ret
	endp


;-----------------------------------------------------------
; Print dec of value
;-----------------------------------------------------------
; Entry: 	SI = value to convert to
;		BX = coordinates to print on string 
; Exit:		None
; Expects:  	ES -> videomem (b800h)
; Destroys: 	AX, BX, CX, DX, DI
;-----------------------------------------------------------
ToDec	proc
	
	mov ax, si
	mov di, 06h
	
@@PrintSymb:
	mov cx, 000Ah		; cx = 10
	div cx			; ax = ax / 10, dx = ax % 10
		
	add dl, 30h
	mov dh, 05h

	mov es:[bx], dx  
	mov dx, 0000h
	
	sub bx, 2
	sub di, 1

	cmp di, 0
	je @@Exit

	jmp @@PrintSymb

@@Exit:	ret
	endp


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
		jmp @@Loop		
@@OnError:
		mov dx, offset ErrorMsg
		mov ah, 09h
		int 21h
		
		jmp @@Exit

@@Loop:		mov ah, 01h
		int 21h			; reading char -> al
		
		cmp al, 0Dh
		je @@Exit		

		cmp al, 13h
		je @@Exit

		cmp al, 30h
		jb @@OnError

		cmp al, 40h
		ja @@OnError

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

@@Exit:		ret
		endp

	
;-----------------------------------------------------------
; Put symbol with given ascii to videomem
;-----------------------------------------------------------
; Entry:	BX = coordinates where to print symbol
;		CX = symbol itself
; Exit:		None
; Expects:	ES -> videomem (b800h)
; Destroys:	None
;-----------------------------------------------------------
PutChar proc

	mov es:[bx], cx		; put symbol to videomem

	ret
	endp
