
symbols: dw 8d dup(042Ah), 0020h

;-----------------------------------------------------------
; Print hex of value
;-----------------------------------------------------------
; Entry: 	SI = value to convert to
;			BX = coordinates to print in cmd 
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


;-------------------------------------------------------------
; Draws rectangle on screen with given borders
;-------------------------------------------------------------
; Entry:	DI - pointer to array with symbols
;			BX - coordinates where to print
;			CX - horizontal size
;			DX - vertical size
; Exit:		None
; Expects:	ES -> videomem (0b800h)
; Destroys:	AX, BX, CX, SI
;-------------------------------------------------------------
DrawRect		proc	
				push bp	
                lea di, symbols
		
				; sub cx, 2
				mov si, dx				; i = dx
				jmp @@MainCycle			

@@IterateI:		sub si, 1				; i--
	
				; sub bx, cx				; start vertically
				; sub bx, cx
				; inc bx
				; inc bx
				; add bx, 160d			; new line

@@MainCycle:	mov ax, cx				; j = cx

				sub bx, 2				; bx -= 2 (then i += 2 to print)
				
				cmp si, 00h
				jne @@DrawV

@@ContinueMain:	add bx, 2				; bx += 2 (watch previous comment)
				cmp si, 00h
				je @@CExit 				; if i == 0: exit(0)
				jmp @@SecondCycle

@@CExit:		pop bp
				ret

@@SecondCycle:	mov bp, 052Ah
				mov es:[bx], bp

				cmp ax, 00h
				je @@DrawRightV			; print left border (WORKS!)

				cmp si, dx
				je @@DrawH				; draw highest border

				cmp si, 01h
				je @@DrawLower			; draw lowest border

@@ContinueSecond:
				cmp ax, 00h
				je @@IterateI			; if j == 0: i++

				sub ax, 2				; else: j--
				add bx, 2				; bx += 2
				jmp @@SecondCycle

@@DrawH:		mov bp, cs:[di + 14d]
				mov es:[bx], bp
				jmp @@ContinueSecond

@@DrawLower:	mov bp, cs:[di + 12d]
				mov es:[bx], bp
				jmp @@ContinueSecond

@@DrawV:		cmp si, 01h
				je @@LowLeft
				cmp si, dx
				je @@HighLeft
				jmp @@Left                          ; TODO: all labels !!!!! -> functions

@@HighLeft:		mov bp, cs:[di]
				mov es:[bx], bp
				jmp @@ContinueMain
			
@@LowLeft:		mov bp, cs:[di + 10d]
				mov es:[bx], bp
				jmp @@ContinueMain

@@Left:			mov bp, cs:[di + 8d]
				mov es:[bx], bp
				jmp @@ContinueMain

@@DrawRightV:	cmp si, 01h
				je @@LowRight
				cmp si, dx
				je @@HighRight
				jmp @@Right
		
@@LowRight:		mov bp, cs:[di + 6d]
				mov es:[bx], bp
				jmp @@ContinueSecond

@@HighRight:	mov bp, cs:[di + 4d]
				mov es:[bx], bp
				jmp @@ContinueSecond
		
@@Right:		mov bp, cs:[di + 2d]
				sub bx, 4
				mov es:[bx], bp
				add bx, 4
				jmp @@ContinueSecond		; разные функции для границ

@@Exit:			pop bp
				ret
				endp
