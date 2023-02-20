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
ToBin		proc
	
			mov dx, 8000h		; dx = 2 ** 15
			jmp @@NewByte

@@Print1:
			mov es:[bx], 0531h	; put 0 to videomem
			add bx, 2			; bx += 2
			jmp @@Next

@@Print0:
			mov es:[bx], 0530h	; put 0 to videomem
			add bx, 2			; bx += 2
			jmp @@Next	

@@NewByte:
			mov cx, ax			; cx = ax
			and cx, dx			; cx && dx

			cmp cx, 0h			; if cx == 0: print(0) else: print(1)
			je  @@Print0
			jmp @@Print1	

@@Next:	
			cmp dx, 1h			; if dx == 1: return
			je @@Exit

			shr dx, 1			; dx >> 1
			jmp @@NewByte

@@Exit:		ret
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

				mov dx, 8000h		; first byte is 1 others are 0
				mov cx, 0004h		; cx = 0 
				mov di, 0000h		

@@ReadBytes:
				inc ch				; ch++ (byte counter in 4th)
				cmp ch, 05h			; if ch == 5: exit else: continue
				je @@Exit
				jmp @@Proceed4bit

@@Proceed4bit:
				mov ax, si			; ax = si (given value)
				and ax, dx			; ax && ax
				
				cmp ax, 00h			; if ax == 0: SkipMul()
				je @@SkipMul
				
				mov al, 01h			; al = 1 (value to add)
				mov ah, 00h			; ah = 0 (needed not to brake ax)
				sub cl, 1			; cl-- (bit num)
				shl al, cl			; al = 2^cl
				add cl, 1			; cl++
				add di, ax			; di += ax (di - result to print)

@@SkipMul:
				sub cl, 1			; cl--
				shr dx, 1			; dx /= 2
				
				cmp cl, 00h	
				je @@PrintSymbol
				jmp @@Proceed4bit	; if cl == 0: Print else continue reading byte
	
@@PrintSymbol:
				mov ax, di			; ax = di
				mov ah, 05h			; ah = 05h (COLOR)

				cmp al, 10d			; if al >= 10: PrintAsLetter
				jae @@LetterPrint

				add al, 30h			; else: al += 30h -> print as ASCII
				jmp @@ContinuePrint

@@LetterPrint:
				add al, 37h			; al += 37 -> add letter as ASCII
				jmp @@ContinuePrint	

@@ContinuePrint:
				mov es:[bx], ax		; put ax to videomem
				add bx, 2			; bx += 2
				mov di, 00h			; di = 0
				mov cl, 04h			; cl = 4 (byte count)
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
ToDec		proc
	
			mov ax, si			; ax = si
			mov di, 06h			; amount of digits
	
@@PrintSymb:
			mov cx, 000Ah		; cx = 10
			div cx				; ax = ax / 10, dx = ax % 10
				
			add dl, 30h			; dl += 30 (symb ascii)
			mov dh, 05h			; dh = 5   (color)

			mov es:[bx], dx  
			mov dx, 0000h		; print on screen
			
			sub bx, 2			; bx -= 2
			sub di, 1			; di -- 

			cmp di, 0
			je @@Exit

			jmp @@PrintSymb

@@Exit:		ret
			endp


;------------------------------------------------------------
; Reads dec number
;------------------------------------------------------------
; Entry:	None
; Exit:		DI - dec value
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
			int 21h				; print Error message
		
			jmp @@Exit

@@Loop:		mov ah, 01h
			int 21h				; reading char -> al
			
			cmp al, 0Dh
			je @@Exit		

			cmp al, 13h
			je @@Exit			; if al == '\n' || '\r': retunr

			cmp al, 30h
			jb @@OnError

			cmp al, 40h
			ja @@OnError		; if !alnum(al): OnError()

			sub al, 30h			; al -= 30 (ascii -> number)
			mov ah, 00h

			mov si, ax
			mov ax, di
			mov di, si			; swap (ax, di)

			mov si, 10d
			mul si				; ax *= 10

			add ax, di			; ax += di (last number)

			mov si, ax
			mov ax, di
			mov di, si			; swap (ax, di)

			loop @@Loop	

@@Exit:		ret
			endp


;-------------------------------------------------------------
; Draws rectangle on screen with given borders
;-------------------------------------------------------------
; Entry:	AX - horizontal border
;		DX - vertical   border
;		BX - left highest point
;		CX - horizontal size
;		DI - vertical   size
; Exit:		None
; Expects:	ES -> videomem (0b800h)
; Destroys:	BP, SI
;-------------------------------------------------------------
DrawRect		proc		

				push bp
				mov bp, sp

				mov bx, [bp + 26d]
				mov di, [bp + 24d]
				mov cx, [bp + 22d]
		
				sub cx, 2
				mov si, di				; i = di
				jmp @@MainCycle			

@@IterateI:		sub si, 1				; i--
	
				sub bx, cx				; start vertically
				sub bx, cx
				add bx, 160d			; new line

@@MainCycle:	mov ax, cx				; j = cx

				sub bx, 2				; bx -= 2 (then i += 2 to print)
				
				cmp si, 00h
				jne @@DrawV

@@ContinueMain:	add bx, 2				; bx += 2 (watch previous comment)
				cmp si, 00h
				je @@Exit 				; if i == 0: exit(0)

@@SecondCycle:	mov dx, [bp + 4]
				mov es:[bx], dx

				cmp ax, 00h
				je @@DrawRightV			; print left border (WORKS!)

				cmp si, di
				je @@DrawH				; draw highest border

				cmp si, 01h
				je @@DrawLower			; draw lowest border

@@ContinueSecond:
				cmp ax, 00h
				je @@IterateI			; if j == 0: i++

				sub ax, 1				; else: j--
				add bx, 2				; bx += 2
				jmp @@SecondCycle

@@DrawH:		mov dx, [bp + 20d]
				mov es:[bx], dx
				jmp @@ContinueSecond

@@DrawLower:	mov dx, [bp + 16d]
				mov es:[bx], dx
				jmp @@ContinueSecond

@@DrawV:		cmp si, 01h
				je @@LowLeft
				cmp si, di
				je @@HighLeft
				jmp @@Left

@@HighLeft:		mov dx, [bp + 12d]
				mov es:[bx], dx
				jmp @@ContinueMain
			
@@LowLeft:		mov dx, [bp + 8d]
				mov es:[bx], dx
				jmp @@ContinueMain

@@Left:			mov dx, [bp + 14d]
				mov es:[bx], dx
				jmp @@ContinueMain

@@DrawRightV:	cmp si, 01h
				je @@LowRight
				cmp si, di
				je @@HighRight
				jmp @@Right
		
@@LowRight:		mov dx, [bp + 6d]
				mov es:[bx], dx
				jmp @@ContinueSecond

@@HighRight:	mov dx, [bp + 10d]
				mov es:[bx], dx
				jmp @@ContinueSecond
		
@@Right:		mov dx, [bp + 18d]
				mov es:[bx], dx
				jmp @@ContinueSecond

@@Exit:			pop bp

				ret
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
