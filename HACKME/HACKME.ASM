.model tiny

MAX_PASS_LEN    equ 20d
winTxtLen       equ 7h
err1TxtLen      equ 45d
err2TxtLen      equ 46d
err3TxtLen      equ 50d
err4TxtLen      equ 47d
err5TxtLen      equ 9d
err6TxtLen      equ 39d
err7TxtLen      equ 47d
err8TxtLen      equ 58d

.data

    akiTxt:     db 'ACCESS GRANTED$'
    nopeTxt:    db 'ACCESS DENIED$'

    winTxt:     dw 8157h, 8149h, 814eh, 8144h, 814fh, 8157h, 8153h
    err1Txt:    db 'A 16-bit device driver has corrupted critical'
    err2Txt:    db 'system memory, resulting in an exception 0D at'
    err3Txt:    db '0028:80001812 in VxD VMM(01) + 00001812. This was '
    err4Txt:    db 'called from 0028:80014C34 in VxD CONTOSO(03) + '
    err5Txt:    db '00000575.'
    err6Txt:    db '* Press any key to attempt to continue.'
    err7Txt:    db '* Press CTRL+ALT+DEL to restart your computer. '
    err8Txt:    db 'You will lose any unsaved information in all applications.'

.code

org 100h

locals @@

Start:          
                call ReadPass
                call ComparePass

                ret

;-------------------------------------------------------------------------------
; Reads string password from keyboard
;-------------------------------------------------------------------------------
; Entry:    None
; Expects:  MAX_PASS_LEN
; Exit:     userPass
; Destroys: AX, CX, DI
;-------------------------------------------------------------------------------
ReadPass        proc
                lea di, userPass

@@Loop:         mov ah, 01h
                int 21h                 ; char -> al

                cmp al, 0Dh
                je @@Exit

                cmp al, 13h
                je @@Exit               ; if al == '\n' || '\r': return

                mov [di], al
                inc di
                jmp @@Loop


@@Exit:         mov byte ptr [di], '$'
                ret
                endp
;-------------------------------------------------------------------------------

;-------------------------------------------------------------------------------
; Reads string password from keyboard
;-------------------------------------------------------------------------------
; Entry:    None
; Expects:  pass, userPass
; Exit:     None
; Destroys: AX, BX, CX, DX, DI, SI
;-------------------------------------------------------------------------------
ComparePass     proc
                push bp
                
                lea di, pass
                lea si, userPass

                mov cx, MAX_PASS_LEN + 2    ; setting up iterator
                xor bp, bp                  ; bp = 0 (7th counter)

@@Loop:         mov bh, [di]                ; etalon
                mov al, [si]                ; user input
 
                cmp bh, '$'
                je @@EtalonEnd              ; if etalon ended: check user input

                cmp al, '$'
                je @@Nope                   ; if userInput ended: nope

                push ax
                push bx
 
                xor ah, ah                  ; ah = 0
                mov bl, 7h                  
                div bl                      ; ah = %

                cmp ah, 00h 
                jne @@Continue                  ; if % != 0: leave

                inc bp 
                cmp bp, 3d
                je @@Aki                   ; if everythin is ok then aki
                jmp @@SkipCheck

@@Continue:     pop bx
                pop ax

                cmp bh, al
                jne @@Nope                  ; if symbols are not the same: nope

@@SkipCheck:    inc di
                inc si                      ; etalon++, userInput++
                loop @@Loop                 ; iterate

@@EtalonEnd:    cmp al, '$'
                je  @@Aki
                jmp @@Nope                  ; if userInput end: aki else nope

@@Aki:          mov ah, 09h
                lea dx, akiTxt
                int 21h                     ; print access granted

                pop bp
                int 20h             

@@Nope:         pop bp

                call DrawBsod                  ; print access denied
                int 20h
                endp
;-------------------------------------------------------------------------------

DrawBsod        proc

                mov ah, 06h
                xor al, al     ; clean all screen
                xor cx, cx     ; left higher
                mov dx, 184fh  ; right lower (dh = row, dl = column)
                mov bh, 1Eh    ; how to replace 
                int 10h

                mov ax, 1003h
                mov bl, 00h
                int 10h         ; switch off blinking

                mov di, 0b800h
                mov es, di

                mov cx, winTxtLen
                lea si, winTxt
                mov di, 7d * 160d + 72d         ; printing windows in center

@@Loop:         lodsw
                stosw
                loop @@Loop

                mov cx, err1TxtLen
                lea si, err1Txt
                mov di, 10d * 160d + 10d
                call PrintText

                mov cx, err2TxtLen
                lea si, err2Txt
                mov di, 11d * 160d + 10d
                call PrintText

                mov cx, err3TxtLen
                lea si, err3Txt
                mov di, 12d * 160d + 10d
                call PrintText

                mov cx, err4TxtLen
                lea si, err4Txt
                mov di, 13d * 160d + 10d
                call PrintText
            
                mov cx, err5TxtLen
                lea si, err5Txt
                mov di, 14d * 160d + 10d
                call PrintText

                mov cx, err6TxtLen
                lea si, err6Txt
                mov di, 16d * 160d + 10d
                call PrintText

                mov cx, err7TxtLen
                lea si, err7Txt
                mov di, 17d * 160d + 10d
                call PrintText

                mov cx, err8TxtLen
                lea si, err8Txt
                mov di, 18d * 160d + 10d
                call PrintText

                ret
                endp


PrintText       proc

                mov ah, 00010111b              ; ah = white

@@Loop:         lodsb           ; ds:si -> al
                stosw
                loop @@Loop

                ret 
                endp

userPass:   db MAX_PASS_LEN + 2 dup(0)
pass:       db '3476JDF17$'

end     Start