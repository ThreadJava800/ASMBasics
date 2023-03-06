.model tiny

MAX_PASS_LEN    equ 20d

.data
    pass:       db '12345678912345678912$'
    userPass:   db MAX_PASS_LEN + 2 dup(0)

    akiTxt:     db 'ACCESS GRANTED$'
    nopeTxt:    db 'ACCESS DENIED$'
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
                mov cx, MAX_PASS_LEN
                lea di, userPass

@@Loop:         mov ah, 01h
                int 21h                 ; char -> al

                cmp al, 0Dh
                je @@Exit

                cmp al, 13h
                je @@Exit               ; if al == '\n' || '\r': return

                mov [di], al
                inc di
                loop @@Loop


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
; Destroys: AX, CX, DX, DI, SI
;-------------------------------------------------------------------------------
ComparePass     proc
                
                lea di, pass
                lea si, userPass

                mov cx, MAX_PASS_LEN + 2        ; setting up iterator

@@Loop:         mov al, [di]                ; etalon
                mov ah, [si]                ; user input
 
                cmp al, '$'
                je @@EtalonEnd              ; if etalon ended: check user input

                cmp ah, '$'
                je @@Nope                   ; if userInput ended: nope

                cmp ah, al
                jne @@Nope                  ; if symbols are not the same: nope

                inc di
                inc si                      ; etalon++, userInput++
                loop @@Loop                 ; iterate

@@EtalonEnd:    cmp ah, '$'
                je  @@Aki
                jmp @@Nope                  ; if userInput end: aki else nope

@@Aki:          mov ah, 09h
                lea dx, akiTxt
                int 21h                     ; print access granted
                ret             

@@Nope:         mov ah, 09h
                lea dx, nopeTxt
                int 21h                     ; print access denied
                ret
                endp
;-------------------------------------------------------------------------------

end     Start