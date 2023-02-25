.model tiny

.data
    printText:  db 160d dup('$')
    arguments:	dw 9 dup(0)

.code

.386

org 100h

locals @@

Start:          
				mov bx, 0082h
				call ReadNumber			; ax -> line

				mov si, 160d 
				mul si					; ax *= 10
				mov di, ax 				; si = ax

				call ReadNumber
				add ax, ax
				add di, ax
				push di					; coordinates ready

                call ReadNumber			; type
				push ax					; type

				call ReadNumber
				mov dx, ax				; dx = color
				pop ax 					; ax = type

				cmp ax, 01h
				je @@Parse1
				cmp ax, 02h
				je @@Parse2
				cmp ax, 03h
				je @@Parse3
				cmp ax, 04h
				je @@Parse4

; MODE = 1 ;
@@Parse1:		
				mov cx, 08h				; counter for loop
				lea di, arguments

				; READING ASCII ;
				mov byte ptr al, [bx]	; al = ascii code
				inc bl
				inc bl					; bl += 2

				mov ah, dl

@@Loop1:		mov [di], ax
				inc di
				inc di
				loop @@Loop1			; symb -> argument x8

				mov word ptr [di], 0020h			; inside = space
				lea di, arguments

                push 00h                ; is double
				jmp @@Call

; MODE = 2 ;
@@Parse2:		
				mov cx, 08h				; counter for loop
				lea di, arguments

				; READING ASCII ;
				mov byte ptr al, [bx]	; al = ascii code
				inc bl
				inc bl					; bl += 2

				mov ah, dl

@@Loop2:		mov [di], ax
				inc di
				inc di
				loop @@Loop2			; symb -> argument x8

				mov word ptr [di], 0020h ; inside = space
				lea di, arguments

                push 01h                ; is double
				jmp @@Call

				int 20h					; exit(0)

; MODE = 3 ;
@@Parse3:		mov cx, 08h
				lea di, arguments

@@Loop3:		mov ah, dl
                mov al, 2ah
                mov word ptr [di], ax
				inc di
				inc di
				loop @@Loop3

				mov word ptr [di], 0020h			; inside = space	
				lea di, arguments	

                push 00h                ; is double
				jmp @@Call

; MODE = 4 ;
@@Parse4:		mov cx, 09h
				lea di, arguments

@@Loop4:		mov byte ptr al, [bx]	; al = ascii code
				inc bl					; bl++
				mov ah, dl
				
				mov [di], ax
				inc di
				inc di

				loop @@Loop4	

				lea di, arguments	
				inc bl					; move to next symbol
                push 00h                ; is double

@@Call:	
				mov byte ptr al, [bx]	; al = ascii code
				inc bl					

@@StartRead:	push ax
                push bx
                push si
				dec bl
                call ReadNumber         ; ax -> text color
                pop si
                pop bx
                mov dx, ax              ; dx = text color
                pop ax

                push bx
				inc bl 
				inc bl
				call ReadText
				pop bx

@@Continue:		mov bx, 0b800h
				mov es, bx				; es -> 0b800h
                pop ax                  ; ax = is_double
				pop bx					; coordinates

                lea si, printText
                lea di, arguments
				call FrameByTxt

@@Exit:         ret


;-----------------------------------------------------------
; Reads command line int arguments
;-----------------------------------------------------------
; Entry: 		BX = position in command line (starting 80h)
; Exit:			AX - read value
; Expects:  	None
; Destroys: 	AX, BX, CL, DX, SI
;-----------------------------------------------------------
ReadNumber		proc
				mov ax, 00h
				mov dx, 00h					; dx:ax = 0

@@Loop:			mov byte ptr cl, [bx]		; cl = arg symb
				cmp cl, 0Dh
				je @@Exit

				cmp cl, 20h
				je @@Exit					; if cl == ' ' or 0D: exit()

				mov si, 10d 
				mul si 						; ax *= 10

				add al, cl
				sub al, 30h					; ax += read ascii.toChar()

				inc bl						; bx++
				jmp @@Loop

@@Exit:			inc bl						; bx++
				ret
				endp


;-----------------------------------------------------------
; Reads text from command line arguments
;-----------------------------------------------------------
; Entry: 		BX = position in command line (starting 80h)
; Exit:			printText
; Expects:  	None
; Destroys: 	BX, CX, DI
;-----------------------------------------------------------
ReadText		proc
				lea di, printText

@@Loop:			mov byte ptr cl, [bx]		; cl = arg symb

				cmp cl, 60h
				je @@Exit					; if al == ': exit()

				mov [di], cl

				inc di						; di++
				inc bl						; bx++
				jmp @@Loop

@@Exit:			mov al, '$'
				mov [di], al
				inc bl						; bx++

				ret
				endp


include ..\LIBA.ASM

end         Start