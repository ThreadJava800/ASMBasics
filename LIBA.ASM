.data
	ErrorMsg: db 0Ah, 'This symbol is not allowed!$'

	symbArr   db "0123456789ABCDEF"

.code

;-----------------------------------------------------------
; Print binary of value
;-----------------------------------------------------------
; Entry: 		AX = value to convert to
;				BX = coordinates to print on string 
; Exit:			None
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
; Entry: 		SI = value to convert to
;				BX = coordinates to print in cmd 
; Exit:			None
; Expects:  	ES -> videomem (b800h)
; Destroys: 	BX, CX, DX, SI, DI
;----------------------------------------------------------
ToHex			proc
				mov cx, 04h				; amount of numbers in hex val
@@Loop:			mov di, 0Fh 			; byte mask
				and di, si 				; first num

				mov dl, [cs:[symbArr] + di]
				mov dh, 05h
				mov es:[bx], dx

				dec bx
				dec bx

				shr si, 4
				loop @@Loop

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
		
				sub cx, 2
				mov si, dx				; i = dx
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

@@SecondCycle:	mov bp, [di + 16d]
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

				sub ax, 1				; else: j--
				add bx, 2				; bx += 2
				jmp @@SecondCycle

@@DrawH:		mov bp, [di + 2d]
				mov es:[bx], bp
				jmp @@ContinueSecond

@@DrawLower:	mov bp, [di + 10d]
				mov es:[bx], bp
				jmp @@ContinueSecond

@@DrawV:		cmp si, 01h
				je @@LowLeft
				cmp si, dx
				je @@HighLeft
				jmp @@Left                          ; TODO: all labels !!!!! -> functions

@@HighLeft:		mov bp, [di]
				mov es:[bx], bp
				jmp @@ContinueMain
			
@@LowLeft:		mov bp, [di + 12d]
				mov es:[bx], bp
				jmp @@ContinueMain

@@Left:			mov bp, [di + 14d]
				mov es:[bx], bp
				jmp @@ContinueMain

@@DrawRightV:	cmp si, 01h
				je @@LowRight
				cmp si, dx
				je @@HighRight
				jmp @@Right
		
@@LowRight:		mov bp, [di + 8d]
				mov es:[bx], bp
				jmp @@ContinueSecond

@@HighRight:	mov bp, [di + 4d]
				mov es:[bx], bp
				jmp @@ContinueSecond
		
@@Right:		mov bp, [di + 6d]
				mov es:[bx], bp
				jmp @@ContinueSecond		; разные функции для границ

@@Exit:			pop bp
				ret
				endp


;-----------------------------------------------------------
; Put symbol with given ascii to videomem
;-----------------------------------------------------------
; Entry:	BX = coordinates of left higher corner of frame
; 			DX = height
; 			CX = length
;			SI = pointer to text
;			AX = text color
; Exit:		None
; Expects:	ES -> videomem (b800h)
; Destroys:	AX, DX, DI
;-----------------------------------------------------------
RectText		proc

				push ax 			; save color

				mov di, dx			; moving for div

				mov dx, 0h
				mov ax, bx
				mov bx, 160d
				div bx				; ax = lines, dx = columns

				add di, ax			; bottom
				add di, ax			; bottom + top
				shr di, 1			; (bottom + top) / 2

				push dx

				xchg ax, bx			; swap (ax, bx)
				mul di				; ax = 160 * height (di)
				xchg ax, bx			; swap (ax, bx)

				pop dx

				mov di, cx			; moving for strlen (di = length)
				push si

				call Strlen			; len(string) -> cx

				pop si

				add dx, di			; right border
				add dx, dx			
				shr dx, 1			; (left + right) / 2

				sub dx, cx
				dec dx
				dec dx

				mov ax, 01h 		; mask to check last byte
				and ax, dx
				cmp ax, 01h 
				je @@DoInc
				jmp @@Continue

@@DoInc:		inc dx

@@Continue:		add bx, dx
				mov di, bx

				cmp cx, 00h 
				je @@Exit

				cld
				
				pop ax
				mov ah, al
				; PRINTING STRING ;
@@Loop:			lodsb				; ds:si -> al
				stosw				; ax -> es:di
				loop @@Loop

@@Exit:			ret
				endp


;-----------------------------------------------------------
; Put symbol with given ascii to videomem
;-----------------------------------------------------------
; Entry:	AX = 0 || 1 if frame is double or not
;			BX = coordinates
;			SI = pointer to text
;			DI - pointer to array with symbols
;			DX - text color
; Exit:		None
; Expects:	ES -> videomem (b800h)
; Destroys:	AX, BX, CX, DX, SI, DI
;-----------------------------------------------------------
FrameByTxt		proc

				push si				; pointer to text
				push dx 			; save text color
				push ax
				call Strlen 		; len(si) -> cx
				pop ax

				push bx 			; where to print text

				sub bx, 320d		; two lines back
				sub bx, 2d			; two columns back

				mov dx, 5d 			; heght = 5

				add cx, 4d 			; length = strLen + 2

				cmp ax, 01h
				jne @@DrawUsual		; if ax != 1: draw not double frame

				; DRAWING DOUBLE RAM ;
				push bx				; coords
				push dx 			; height
				push cx 			; length

				sub bx, 162d		; new start
				inc dx
				inc dx

				inc cx
				inc cx				; len += 2; height += 2

				call DrawRect

				pop cx
				pop dx
				pop bx


@@DrawUsual:	call DrawRect		; drawing frame

				sub cx, 2d 			; cx - strlen
				pop di 				; where to print text -> di
				pop dx				; dx = text color
				pop si 				; pointer to text

				mov ah, dl
@@Loop:			lodsb				; ds:si -> al
				stosw				; ax -> es:di
				loop @@Loop


@@Exit:			ret
				endp

	
;-----------------------------------------------------------
; Put symbol with given ascii to videomem
;-----------------------------------------------------------
; Entry:	BX = coordinates where to print symbol
;			CX = symbol itself
; Exit:		None
; Expects:	ES -> videomem (b800h)
; Destroys:	None
;-----------------------------------------------------------
PutChar proc

	mov es:[bx], cx		; put symbol to videomem

	ret
	endp



;----------------STRING FUNCTIONS-------------------;



;------------------------------------------------------------
; Gets length of string (string must end with '\0' (0 ascii)
;------------------------------------------------------------
; Entry:	DS:SI - pointer to string
; Expects:	None
; Exit:		CX - amount of symbols in string
; Destroys:	AX, CX, SI
;------------------------------------------------------------
Strlen		proc
			mov cx, 00h
		
@@Repeat:	cld
			lodsb			; DS:SI++ -> AL
			
			cmp al, 00h		; ('\0')
			je  @@Exit

			cmp al, 24h		; ('$')
			je @@Exit

			inc cx			; count++
			jmp @@Repeat    ; if al == 0 || '$': exit() else: loop
		
@@Exit:		ret
			endp

;------------------------------------------------------------
; Copies bytes from one side of memory to another one
;------------------------------------------------------------
; Entry:	ES:DI - destination pointer
;			DS:SI - from where pointer
;			CX    - amount of bytes to copy
; Expects:	None
; Exit:		None
; Destroys:	CX, DI, SI
;------------------------------------------------------------
Memcpy		proc
		
			cld
			rep movsb	; while (cx--) DS:SI -> ES:DI

			ret
			endp

;------------------------------------------------------------
; Copies strings
;------------------------------------------------------------
; Entry:	ES:DI - destination pointer
;		DS:SI - string to copy
; Expects:	None
; Exit:		None
; Destroys:	AL, CX, DI, SI
;------------------------------------------------------------
Strcpy		proc

			cld

			push si
			push di

			call Strlen		; strlen(ds:si) -> cx
			
			pop di
			pop si

			call Memcpy		

			mov al, '$'
			stosb			; destStr[-1] = '$'

			ret
			endp


;-------------------------------------------------------------
; Fills first n bytes with given symbol
;-------------------------------------------------------------
; Entry:	ES:DI - pointer to write bytes
;		AL    - byte
;		CX    - count
; Exit:		None
; Expects:	None
; Destroys:	CX, DI
;-------------------------------------------------------------
Memset		proc
		
			cld
			rep stosb

			ret
			endp

;--------------------------------------------------------------
; Compares first n bytes in buffers
;--------------------------------------------------------------
; Entry:	ES:DI - buf1
;			DS:SI - buf2
;			CX    - byte count
; Exit:		DX    - 0 if eq, < 0 if buf1 < buf2 && > 0 if buf1 > buf2
; Expects:	None
; Destroys:	CX, DX, DI, SI
;-------------------------------------------------------------
Memcmp		proc
			cld

			mov dx, 00h
		
@@Loop:		cmp cx, 00h
			je @@Exit		
			dec cx

			cmpsb			; rep cmpsb doesn't work???
			je @@Loop		; if ZF == 1: repeat

			dec di			; else return di - si 
			dec si

			mov dx, es:[di]
			sub dx, ds:[si]		

@@Exit:		ret
			endp


;-----------------------------------------------------------------------
; Compares to string
;-----------------------------------------------------------------------
; Entry:	ES:DI - buf1
;		DS:SI - buf2
; Exit:		DX    - 0 if equ, < 0 if buf1 < buf2 && > 0 if buf1 > buf2
; Expects:	None
; Destroys:	AX, DX, DI, SI
;-----------------------------------------------------------------------
Strcmp			proc

				cld
				mov dx, 00h

@@Loop:			mov al, es:[di]
				mov ah, ds:[si]

				cmp ah, '$'
				je @@CheckLenSI
				
				cmp al, '$'
				je @@CheckLenDI		; if al == '$': cmp lens
				
				cmpsb
				je @@Loop			; if zf == 1: repeat

				dec di
				dec si
				mov dx, es:[di]
				sub dx, ds:[si]
				jmp @@Exit			; else return *di - *si

@@CheckLenSI:	cmp al, '$'
				je @@Exit			; if al == '$' return 0

				mov dx, 01h			; dx = 1
				jmp @@Exit		
		
@@CheckLenDI:						; di ended faster
				mov dx, 0fffeh		; dx = -1

@@Exit:			ret
				endp
