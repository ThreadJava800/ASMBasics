.286                                    ; so shr(4) do not takes 4 commands
.model tiny
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
            push ax bx es                   ; saving registers that will be killed

            mov bx, 0b800h
            mov es, bx
            mov bx, 160d * 5d + 80d         ; setting position on screen

            mov ah, 4eh                     ; setting color for print
            in al, 60h                      ; getting value from 60 port
            mov es:[bx], ax                 ; put in vmem

            in al, 61h                      ; get data from 61 port
            or al, 80h                      ; setting first bit = 1
            out 61h, al
            and al, not 80h
            out 61h, al                     ; blinking

            mov al, 20h
            out 20h, al                     ; sending verification to int controller

            pop es bx ax

            pushf                           ; putting flags to stack for int call immitation
            db 09ah                         ; call far
oldIntAd    dw 0
oldIntSeg   dw 0

            iret                            ; return from interruption 
                                            ; (iret does popf automatically)
            endp

ProgEnd:
end         Start