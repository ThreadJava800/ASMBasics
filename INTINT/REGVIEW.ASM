.286                                    ; so shr(4) do not takes 4 commands
.model tiny

.data
    status: dw 0                        ; whether on or off

.code

org 100h

locals @@

Start:      cli
            xor bx, bx
            mov es, bx
            mov bx, 9 * 4

            mov ax, es:[bx]
            mov [oldIntAd], ax
            mov ax, es:[bx + 2]
            mov [oldIntSeg], ax             ; saving all data about old interruption

            mov es:[bx], offset NewInt
            mov ax, cs
            mov es:[bx + 2], ax
            sti

            mov ax, 3100h                   ; code for exiting program leaving it in memory
            mov dx, offset ProgEnd          ; amount of memory to keep resident
            shr dx, 4                       ; dx /= 16 (as paragraph == 16 byte)
            inc dx                          ; trunc(dx)
            int 21h

            ret

NewInt      proc
            push ax bx cx di es             ; saving registers that will be killed

            call CodeFromPort
            cmp cl, 1Dh                     ; ctrl
            je @@OnOff
            jmp @@Else                      ; if ctrl pressed read next

@@OnOff:    lea di, status
            mov cl, cs:[di]                 ; di = status

            cmp cl, 00h                     ; if isOff: switchOn               
            je @@SwOn                       ; else: SwitchOff

@@SwOff:    mov bx, 0b800h
            mov es, bx
            mov bx, 160d * 5d + 80d         ; setting position on screen

            mov ah, 4eh                     ; setting color for print
            mov al, 21h                     ; '!'
            mov es:[bx], ax

            mov cl, 00h
            mov cs:[di], cl                 ; set status = 1

            jmp @@Exit

@@SwOn:     mov bx, 0b800h
            mov es, bx
            mov bx, 160d * 5d + 80d         ; setting position on screen

            mov ah, 4eh                     ; setting color for print
            mov al, 2Bh                     ; '+'
            mov es:[bx], ax

            mov cl, 01h
            mov cs:[di], cl                 ; set status = 1

            jmp @@Exit


@@Else:     mov bx, 0b800h
            mov es, bx
            mov bx, 160d * 5d + 80d         ; setting position on screen

            mov ah, 4eh                     ; setting color for print
            mov al, cl                     ; space
            mov es:[bx], ax


@@Exit:     pop es di cx bx ax

            pushf                           ; putting flags to stack for int call immitation
            db 09ah                         ; call far
oldIntAd    dw 0
oldIntSeg   dw 0

            iret                            ; return from interruption 
                                            ; (iret does popf automatically)
            endp


;------------------------------------------------------------------------------
; Gets scan code from 61st port and puts it to register
;------------------------------------------------------------------------------
; Entry:        None
; Exit:         CL - read symbol
; Expects:      None
; Destroys:     AL, CL
;------------------------------------------------------------------------------
CodeFromPort    proc
                in al, 60h
                mov cl, al

                in al, 61h                      ; get data from 61 port

                or al, 80h                      ; setting first bit = 1
                out 61h, al
                and al, not 80h
                out 61h, al                     ; blinking

                mov al, 20h
                out 20h, al                     ; sending verification to int controller

                ret
                endp

ProgEnd:
end         Start