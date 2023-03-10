.model tiny

.data
	printText:	db 160d dup('$')
	arguments:	dw 10d dup(0)

.code

org 100h

locals @@

Start:	
				mov bx, 0082h			; TODO: constant
				call ReadNumber			; ax -> line

				mov si, 80d * 2d 		
				mul si					; ax *= 10
				mov di, ax 				; si = ax

				call ReadNumber
				add ax, ax
				add di, ax
				push di					; coordinates ready

				call ReadNumber
				push ax					; height

				call ReadNumber
				push ax					; length

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

				pop cx					; length
				pop dx					; height

				mov si, bx				; address of argument cmd

				mov bx, 0b800h
				mov es, bx				; es -> 0b800h
				pop bx					; coordinates

				push cx					; save len
				push bx					; save coords

				inc cx
				inc cx
				inc dx
				inc dx
				sub bx, 162d

				push si					; address of argument cmd
				call DrawRect			; draw bigger frame

				pop si					; args
				pop bx					; coords
				pop cx					; length
				dec dx
				dec dx
				push bx					; coords
				push dx					; height
				push cx
				mov bx, si
				jmp @@Call

				int 20h					; exit(0)

; MODE = 3 ;
@@Parse3:		mov cx, 08h				; TODO: describe modes
				lea di, arguments
										; loop can bwithout @@
@@Loop3:		mov word ptr [di], 052ah; red star
				inc di
				inc di
				loop @@Loop3

				mov word ptr [di], 0020h			; inside = space	
				lea di, arguments	

				jmp @@Call

; MODE = 4 ;
@@Parse4:		mov cx, 09h
				lea di, arguments

@@Loop4:		mov byte ptr al, [bx]	; al = ascii code
				inc bl					; bl++
				mov ah, 05h
				
				mov [di], ax
				inc di
				inc di

				loop @@Loop4	

				lea di, arguments	
				inc bl					; move to next symbol


@@Call:			pop cx					; length
				pop dx					; height

				mov byte ptr al, [bx]	; al = ascii code
				inc bl					

@@StartRead:	
				push cx
				push di
				push dx
				dec bl
				call ReadNumber
				inc bl
				pop dx
				pop di
				pop cx

				push ax 				; save color

				push cx
				push di
				call ReadText
				pop di
				pop cx
				pop ax

@@Continue:		mov bx, 0b800h
				mov es, bx				; es -> 0b800h
				pop bx					; coordinates

				push ax					; text color
				push bx					; save coords
				push dx					; save height
				push cx					; save length

				call DrawRect

				pop cx
				pop dx
				pop bx
				pop ax
				lea si, printText
				call RectText

				int 20h					; exit(0)
				ret ; base

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
;-----------------------------------------------------------


include ..\LIBA.ASM

end	Start