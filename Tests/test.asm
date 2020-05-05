.MODEL small
.STACK 100h
.data

.code

; proc _memcpy

push bp          ; Set up the call frame
mov  bp,sp
push es          ; Save ES
mov  cx,[bp+6]   ; Set CX = len
jcxz done        ; If len = 0, return

mov  si,[bp+4]   ; Set SI = src
mov  di,[bp+2]   ; Set DI = dst
push ds          ; Set ES = DS
pop  es

loop_here:
mov  al,[si]     ; Load AL from [src]
mov  [di],al     ; Store AL to [dst]
inc  si          ; Increment src
inc  di          ; Increment dst
dec  cx          ; Decrement len
jnz  loop_here   ; Repeat the loop

done:
pop  es          ; Restore ES
pop  bp          ; Restore previous call frame
sub  ax,ax       ; Set AX = 0
ret              ; Return
end