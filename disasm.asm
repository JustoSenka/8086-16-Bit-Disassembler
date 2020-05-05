.MODEL small
.STACK 100h
.DATA
 
LAST_COMMAND equ LIST_41

poslinkisORG dw 100h
 
ok db 13, 10, 'File written successfully.', 13, 10, '$'
noFileMsg db 13, 10, 'No such file: ', '$'
InvalidParameters db 13, 10, 'Invalid arguments', 13, 10, '$'
Info db 13, 10, 'Made by Justas Glodenis', 13, 10, 'Arguments to use in order: ', 13, 10, 'arg 1: sourceFile - file to disassemble', 13, 10, 'arg 2: destinationFile - output for disassembled code', 13, 10, 'example: ', 96, 'disasm sourceFile.com destinationFile.txt', 96, '$'
                                                                                                                                                                                                                      
file1 db 20 dup(0), '$'
rezFile db 20 dup(0) 

duom1 db 255 dup(0)
rez db 60 dup(32), '$'

nl db 10, 13, '$'  

IsReg16 db 0
IsRegSEGMENT db 0
IsPoslinkis db 0
IsComJump db 0
safeDX dw 0
sx db 16  
nr dw 9
byteNumber dw 0
fileHandler dw 0

;            0   1   2   3   4   5   6   7   8   9   10  11  12  13  14  15  16
komandos db 'MOV PUSHPOP ADD INC SUB DEC CMP MUL DIV CALLRET JMP LOOPINT   :     '
jump db     'JO  JNO JB  JNB JE  JNE JNA JA  JS  JNS JP  JNP JL  JGE JLE JG  '
allRegs db 'ALCLDLBLAHCHDHBHAXCXDXBXSPBPSIDI'
segRegs db 'ESCSSSDS'

;			  0       1       2       3       4       5       6       7       
regMemory db '[BX+SI] [BX+DI] [BP+SI] [BP+DI] [SI]    [DI]    [BP]    [BX]    '


       ;      0          1        2  3   4   5   6    7       8       9      
	  ;  HAS or IS:   comBytes   MOD d   w   s  XCM  comNR   reg    p/bop
LIST_01 db 00000000b, 11111100b, 01, 01, 01, 00, 000b, 03, 00000000b, 00
LIST_02 db 00000100b, 11111110b, 00, 00, 01, 00, 000b, 03, 00000000b, 01
LIST_03 db 00101000b, 11111100b, 01, 01, 01, 00, 000b, 05, 00000000b, 00
LIST_04 db 00101100b, 11111110b, 00, 00, 01, 00, 000b, 05, 00000000b, 01
LIST_05 db 00111000b, 11111100b, 01, 01, 01, 00, 000b, 07, 00000000b, 00
LIST_06 db 00111100b, 11111110b, 00, 00, 01, 00, 000b, 07, 00000000b, 01

LIST_07 db 01000000b, 11111000b, 00, 00, 03, 00, 000b, 04, 00000111b, 00
LIST_08 db 01001000b, 11111000b, 00, 00, 03, 00, 000b, 06, 00000111b, 00
LIST_09 db 01010000b, 11111000b, 00, 00, 03, 00, 000b, 01, 00000111b, 00
LIST_10 db 01011000b, 11111000b, 00, 00, 03, 00, 000b, 02, 00000111b, 00

LIST_11 db 00000110b, 11100111b, 00, 00, 00, 00, 000b, 01, 00011000b, 00
LIST_12 db 00000111b, 11100111b, 00, 00, 00, 00, 000b, 02, 00011000b, 00

LIST_13 db 00100110b, 11100111b, 00, 00, 00, 00, 000b, 15, 00011000b, 00

LIST_14 db 10001000b, 11111100b, 01, 01, 01, 00, 000b, 00, 00000000b, 00
LIST_15 db 10001100b, 11111101b, 01, 01, 03, 00, 000b, 00, 00011000b, 00

LIST_16 db 10110000b, 11110000b, 00, 00, 00, 00, 000b, 00, 00001111b, 01

LIST_17 db 10100000b, 11111100b, 00, 01, 01, 00, 000b, 00, 00100000b, 00

LIST_18 db 11001101b, 11111111b, 00, 00, 00, 00, 000b, 14, 10000000b, 01
LIST_19 db 11000011b, 11111111b, 00, 00, 00, 00, 000b, 11, 10000000b, 00 
LIST_20 db 11000010b, 11111111b, 00, 00, 00, 00, 000b, 11, 10000000b, 02 
LIST_21 db 10011010b, 11111111b, 00, 00, 00, 00, 000b, 10, 10000000b, 04
LIST_22 db 11101010b, 11111111b, 00, 00, 00, 00, 000b, 12, 10000000b, 04

LIST_23 db 01110000b, 11110000b, 00, 00, 00, 00, 000b, 16, 10000000b, 00 ;isimtis

LIST_24 db 11101000b, 11111111b, 00, 00, 00, 00, 000b, 10, 10000000b, 20h
LIST_25 db 11101001b, 11111111b, 00, 00, 00, 00, 000b, 12, 10000000b, 20h
LIST_26 db 11101011b, 11111111b, 00, 00, 00, 00, 000b, 12, 10000000b, 10h                                                                                                                 
LIST_27 db 11100010b, 11111111b, 00, 00, 00, 00, 000b, 13, 10000000b, 10h 

LIST_28 db 11111110b, 11111110b, 02, 00, 01, 00, 000b, 04, 00000000b, 00
LIST_29 db 11111110b, 11111110b, 02, 00, 01, 00, 001b, 06, 00000000b, 00
LIST_30 db 11111111b, 11111111b, 02, 00, 03, 00, 010b, 10, 00000000b, 00
LIST_31 db 11111111b, 11111111b, 02, 00, 04, 00, 011b, 10, 00000000b, 00
LIST_32 db 11111111b, 11111111b, 02, 00, 02, 00, 100b, 12, 00000000b, 00
LIST_33 db 11111111b, 11111111b, 02, 00, 03, 00, 101b, 12, 00000000b, 00
LIST_34 db 11111111b, 11111111b, 02, 00, 03, 00, 110b, 01, 00000000b, 00

LIST_35 db 11110110b, 11111110b, 02, 00, 01, 00, 100b, 08, 00000000b, 00
LIST_36 db 11110110b, 11111110b, 02, 00, 01, 00, 110b, 09, 00000000b, 00
LIST_37 db 10001111b, 11111111b, 02, 00, 03, 00, 000b, 02, 00000000b, 00

LIST_38 db 10000000b, 11111100b, 02, 00, 01, 01, 000b, 03, 00000000b, 00
LIST_39 db 10000000b, 11111100b, 02, 00, 01, 01, 101b, 05, 00000000b, 00
LIST_40 db 10000000b, 11111100b, 02, 00, 01, 01, 111b, 07, 00000000b, 00
LIST_41 db 11000110b, 11111110b, 02, 00, 01, 02, 000b, 00, 00000000b, 00

.code          

mov ax, @data
mov ds, ax	

mov bx, 81h  ; pirmas simbolio parametre adresas  

cmp byte ptr es:[bx], 13
je skip 

mov dl, es:[bx + 1]
cmp dl, 13
je skip

cmp dl, '/'
jne testi
 
mov dl, es:[bx + 2]
cmp dl, '?'
jne wrongParams  
              
skip:              
              
jmp WriteInfo

testi:

               ; Nuskaito dvieju failu vardus
inc bx  
mov di, offset file1 
call ReadFileName 

cmp cl, 'E'
je wrongParams
           
              
          
inc bx           
mov di, offset rezFile 
call ReadFileName 

cmp cl, 'E'
je wrongParams

; %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
              ; Nuskaito duomenis is failo
                     
                     
mov dx, offset file1
mov cx, offset duom1  
call ReadFile    
push cx   

cmp cl, 'F'
je noFile
                     
                ; Atlieka skaiciavimus

mov bx, byteNumber     

call OpenFile
   
CiklasDisasm:     
    
	mov bx, byteNumber
	pop cx
	
	cmp bx, cx
    jge endDisasm
    push cx    
	
	mov si, offset duom1
	mov di, offset rez    
	
    mov dh, 0
    mov dl, [si][bx]  
          
                ; nulina reikesmes ir padeda \N zenkla
    push bx         
    mov bx, 0
    nulinaReiksmes:
    
        mov byte ptr [di][bx], 32
        inc bx
    
        cmp bx, 62
        jge poNulinaReiksmes
    
    jmp nulinaReiksmes
    poNulinaReiksmes:
                            ;--
         
         
    mov byte ptr [di][60], 10
    pop bx 
    
	mov nr, 9
    call CheckCommandByte               
    call WriteLine    
    
    inc byteNumber
	inc bx
	
    jmp CiklasDisasm

endDisasm:    

call CloseFile

                ; Iraso i faila
               
mov dx, offset ok
mov ah, 09h
int 21h 

jmp exit
               
wrongParams:

mov dx, offset InvalidParameters
mov ah, 09h
int 21h 
  
jmp exit 
    
WriteInfo:           
           
mov dx, offset Info
mov ah, 09h
int 21h

jmp exit    
    
noFile:
           
push dx
           
mov dx, offset noFileMsg
mov ah, 09h
int 21h 

pop dx
mov ah, 09h
int 21h 

mov dx, offset nl
mov ah, 09h
int 21h 
       
Exit: 
                        
mov ax, 4c00h
int 21h    


 
                     
                     
ReadFileName PROC    ;------------------------------------------
     
mov cl, 'F' 
mov dx, 0         
                            
Reallocate:
       
mov al, es:bx 


cmp al, 32 
je Allocated   

cmp al, 0  
je Allocated 
  
cmp al, 13 
je Allocated

push bx
mov bx, dx
mov [di][bx], al
pop bx    

inc bx  
inc dx

jmp Reallocate
      
      
Allocated:

cmp dx, 1
jle FileError 

mov cl, 'T'
jmp return2
      
      
FileError:

mov cl, 'E'
    
    
return2: 

ret    
ReadFileName ENDP   ;-------------------------------------------            
                                                                  
                                                                  
                                                                  
ReadFile PROC    ;------------------------------------------
     
mov ah, 3Dh ;open
mov al, 02h
int 21h    

jnc read   ; CF = 0 (no error)

mov cl, 'F'
jmp readReturn

read:

mov bx, ax      ; File Handler

mov dx, cx
mov cx, 255
mov ah, 3Fh ;read
int 21h   

mov cx, ax

mov ah, 3Eh ;close
int 21h  

readReturn:

ret    
ReadFile ENDP   ;-------------------------------------------        
                                             
                                             
                                             
OpenFile PROC    ;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

push ax
push dx

mov cx, 01000000b     
mov dx, offset rezFile      
            
mov ah, 3Ch ;Create
int 21h            
            
mov fileHandler, ax

pop dx
pop ax

ret    
OpenFile ENDP     

WriteLine PROC   
                   
push bx   
push dx             
                   
mov bx, fileHandler ; FileHandler 

mov dx, offset rez
mov cx, 61
mov ah, 40h ;Write
int 21h   

mov dx, offset rez
mov ah, 09h
int 21h
       
pop dx
pop bx

ret    
WriteLine ENDP  

CloseFile PROC   

push bx
push ax
                        
mov bx, fileHandler

mov ah, 3Eh ;close
int 21h
       
pop ax       
pop bx

ret    
CloseFile ENDP   ;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   

                                              
                                              
;###################################################################
CheckCommandByte PROC    ;------------------------------------------    
			; args: dl - byte, bx - byte address
	
	call WriteAddress                       
	
	mov dh, dl
	mov safeDX, dx
	
	mov si, offset LIST_01
	
	CheckCiklas:
		mov dx, safeDX
		
		mov al, [si + 1]
		and dl, al
		mov al, [si]
		
		cmp dl, al
		jne skipComPletinys
			cmp byte ptr [si + 2], 2
			jne CommandFound
				call ReadOneMoreByte
				mov safeDX, dx
				and dl, 00111000b
				shr dl, 3
				sub si, 10
				CheckCiklas2:
					add si, 10
					cmp [si + 6], dl
					je CommandFound
				jmp CheckCiklas2
		skipComPletinys:
		
		mov ax, offset LAST_COMMAND
		cmp si, ax
		jge NoCommand1
		
		add si, 10
	jmp CheckCiklas
	
	NoCommand1:
	jmp NoCommand
	
	CommandFound:
		mov al, [si + 7]
		call WriteCommand
		
		and dl, 11110000b
		cmp dl, 01110000b
		jne skipConditionalJMP
				; CONDITIONAL JUMPS
			mov IsComJump, 1
			mov al, dh
			and al, 00001111b
			call WriteCommand
			mov ax, 30
			mov IsPoslinkis, 1
			call WriteJumpPoslinkis
			jmp RetOfCheck
		skipConditionalJMP:
		mov dl, dh
		
		
		mov al, [si + 8]
		cmp al, 10000000b
		jne skipNoReg
			; Command with no reg
			mov al, [si + 9]
			cmp al, 0
			je endNoReg
			
			cmp al, 4
			je callException
			
			cmp al, 0Fh
			jg skipFreeOpernad 
					; Free Operand
				mov IsPoslinkis, al
				mov ax, 30
				call WriteFreeOperand
				jmp endNoReg
				
			skipFreeOpernad:	
					; Poslinkis
				and al, 11110000b
				shr al, 4
				mov IsPoslinkis, al
				mov ax, 30
				call WriteJumpPoslinkis
				jmp endNoReg
				
			callException:
				mov IsPoslinkis, 2
				mov ax, 37
				call WriteFreeOperand
				
				mov IsPoslinkis, 2
				mov ax, 30
				call WriteFreeOperand
				
				mov byte ptr [di + 36], ':'	
			endNoReg:
			jmp RetOfCheck
		skipNoReg:
		
		mov IsRegSEGMENT, 0
		
		mov al, [si + 8]	;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
		cmp al, 00011000b
		jne skipAddRegSeg
			; Has seg reg here
			
			mov IsRegSEGMENT, 1
			
			mov al, [si + 2]
			cmp al, 1			; if it has MOD, skip adding segment now
			je skipAddRegSeg 	; MOD will do it 
			
			mov al, [si + 7]
			cmp al, 15
			jne skipSegmentoKeitimas
			
					;segmento keitimo komanda
				mov ax, 24
				call WriteSegReg
				jmp RetOfCheck
			skipSegmentoKeitimas:
			
					;eiline komanda su segmento registru
				mov ax, 30
				call WriteSegReg
				jmp RetOfCheck
		skipAddRegSeg:
		
		
		mov al, [si + 8]	;@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
		cmp al, 00100000b
		jne SkipAtmintisAX
			
			mov IsReg16, 0
			call Check8or16Reg
			
			mov al, [si + 3]
			cmp al, 1
			jne AtmintisAXReverse
				and dl, 00000010b
				cmp dl, 00000000b
				je AtmintisAXReverse
						;NOrmal
					mov ax, 30
					call WriteDirectAddress
					
					mov [di + 38], ' ,'
					
					mov dl, dh
					mov al, [si + 8]
					and dl, al
					and dl, 00001111b
					or dl, IsReg16
					mov ax, 40
					call WriteReg
						
					jmp skip01
				AtmintisAXReverse:
						;Reverse
					mov ax, 34
					call WriteDirectAddress
					
					mov [di + 32], ' ,'
					
					mov dl, dh
					mov al, [si + 8]
					and dl, al
					and dl, 00001111b
					or dl, IsReg16
					mov ax, 30
					call WriteReg
			skip01:
			jmp RetOfCheck
		SkipAtmintisAX:
		
		
		mov al, [si + 2]
		cmp al, 0
		je NoMod
		Jmp HasMOD
		
		NoMod:
			;no MOD here..............................................

			; word or byte		
			mov al, [si + 4]
			
			cmp al, 2
			je Reg8
			
			cmp al, 3
			je Reg16
			
			cmp  al, 1
			jne skip02
				and dl, 00000001b
				cmp dl, 1
				je Reg16
			jmp Reg8
			skip02:
			
			mov dl, dh
			mov al, [si + 8]
			and dl, al
			cmp dl, 00000111b
			jg Reg16
			
			Reg8:
				mov dl, dh
				mov al, [si + 8]
				and dl, al
				
				mov ax, 30
				call WriteReg
				
				mov al, [si + 9]
				cmp al, 1
				jne skip2
					; has free operand
					call ReadOneMoreByte
					mov [di + 35], ax
					
					mov [di + 32], ' ,'
					mov byte ptr[di + 34], '0'
					mov byte ptr[di + 37], 'h'
				
				jmp skip2
			Reg16:
				mov dl, dh
				mov al, [si + 8]
				and dl, al
				or dl, 00001000b
				
				mov ax, 30
				call WriteReg
				
				mov al, [si + 9]
				cmp al, 1
				jne skip2
					; has two free operands
					call ReadOneMoreByte
					mov [di + 37], ax
					
					call ReadOneMoreByte
					mov [di + 35], ax	
					
					mov [di + 32], ' ,'
					mov byte ptr[di + 34], '0'
					mov byte ptr[di + 39], 'h'
									
			skip2:
		jmp RetOfCheck
		HasMOD:
			; has MOD here............................................
			
			cmp byte ptr [si + 2], 2
			jne skipMOD2
				call checkMOD2
				jmp RetOfCheck
			skipMOD2:
			
			call ReadOneMoreByte
			call checkMOD

	jmp RetOfCheck
	
	NoCommand:
	
	
RetOfCheck:                    
ret    
CheckCommandByte ENDP   ;-------------------------------------------  
;###################################################################
       
       
       
       
       
       
       
ValueToHex PROC    ;------------------------------------------
                      ;arguments: dl - 1byte value to change
mov ah, 0
mov al, dl

div sx

cmp al, 9
jg raide

add al, 48
jmp antrasSimbolis

raide:
add al, 55

antrasSimbolis:

cmp ah, 9
jg raide2

add ah, 48
jmp hexEnd

raide2:
add ah, 55
jmp hexEnd

hexEnd:
           
ret    
ValueToHex ENDP   ;------------------------------------------- 


WriteAddress PROC    ;------------------------------------------
                      ;arguments: bx - address
push bx
push dx

mov bx, byteNumber
add bx, poslinkisORG

mov dl, bh
call ValueToHex
mov [di + 0], ax
                   
mov dl, bl
call ValueToHex
mov [di + 2], ax
                   
mov byte ptr [di + 4], ':'                   
                             
pop dx			; also writes the first byte
pop bx

call ValueToHex
mov [di + 6], ax
          
ret    
WriteAddress ENDP   ;------------------------------------------- 

WriteCommand PROC
				; arguments: al - command num
push si
push bx

mov si, offset komandos

cmp IsComJump, 1
jne skipComJump
	mov si, offset jump
	mov IsComJump, 0
skipComJump:

mov ah, 0
mov bx, ax

shl bx, 2

mov ax, [si][bx]
mov [di + 24], ax

add bx, 2
mov ax, [si][bx]
mov [di + 26], ax

pop bx
pop si

ret
WriteCommand ENDP

WriteReg PROC    ;------------------------------------------
        ; args DL - reg nr or Shifted MOD REG R/M, AX - position to write
push bx
push dx
push si

mov bl, IsRegSEGMENT
cmp bl, 1
je writeSegment

mov bh, 0
mov bl, dl    
   
shl bx, 1 

mov si, offset allRegs

add di, ax               
mov bx, [si][bx]  
mov [di], bx      ; iraso i eilute
sub di, ax

jmp endWriteReg

writeSegment:
	mov dx, safeDX
	call WriteSegReg
	
endWriteReg:

pop si
pop dx
pop bx                  
     
ret    
WriteReg ENDP   ;-------------------------------------------  

WriteSegReg PROC    ;------------------------------------------
        ; args DL - ComByte, AX - position to write
push bx
push dx
push si

mov bh, 0
mov bl, dl    

and bl, 00011000b   
shr bx, 2 

mov si, offset segRegs

add di, ax               
mov bx, [si][bx]  
mov [di], bx      ; iraso i eilute
sub di, ax

mov IsRegSEGMENT, 0

pop si
pop dx
pop bx                  
     
ret    
WriteSegReg ENDP   ;-------------------------------------------  

WriteRegMemory PROC    ;------------------------------------------
        ; args: DH - ComByte, DL - MOD REG R/M, AX - position to write
		; return: AX - place to write next
push bx
push dx
push si
push di
push ax

mov dx, safeDX    
mov bx, dx

and bl, 11000111b
cmp bl, 00000110b ; Tiesioginis adresas, MOD = 00, r/m = 110
je jmpCallDirectAddress

mov bh, 0
mov bl, dl
and bl, 00000111b 
   
shl bx, 3 

mov si, offset regMemory

add di, ax         
mov ax, [si][bx]  
mov [di], ax   

mov ax, [si][bx + 2]  
mov [di + 2], ax   

mov ax, [si][bx + 4]  
mov [di + 4], ax  
 
mov ax, [si][bx + 6]  
mov [di + 6], ax   

and dl, 00000111b
cmp dl, 4

pop ax

jge moreThan4
	;less than 5
	add ax, 7
	jmp skipToEnd01
moreThan4:
	add ax, 4
	jmp skipToEnd01
	
	
jmpCallDirectAddress:
	pop	ax
	call WriteDirectAddress
	add ax, 8
			
skipToEnd01:

pop di
pop si
pop dx
pop bx                  
     
ret    
WriteRegMemory ENDP   ;-------------------------------------------  

WritePoslinkis PROC
push bx
push cx
push dx

mov bx, ax

mov ch, 0
mov cl, IsPoslinkis

cmp cl, 0
je endPoslinkis
	;Yra poslinkis
	mov [di][bx], '+ ' 
	mov [di][bx + 2], '0 '
	add bx, 4
	
	cmp cl, 1
	jne DviejuBaituPoslinkis
		;Vieno baito poslinkis
			
		call ReadOneMoreByte
		
		mov [di + bx], ax
		mov byte ptr [di][bx + 2], 'h'
		mov ax, bx
		add ax, 3
		
		jmp endPoslinkis
	
	DviejuBaituPoslinkis:
		;Dvieju baitu poslinkis

		call ReadOneMoreByte
		mov [di][bx + 2], ax

		call ReadOneMoreByte
		mov [di][bx], ax
		
		mov byte ptr [di][bx + 4], 'h'
		
		mov ax, bx
		add ax, 5
	
		jmp endPoslinkis
endPoslinkis:

pop dx
pop cx
pop bx

mov IsPoslinkis, 0

ret
WritePoslinkis ENDP

WriteDirectAddress PROC
			;args: ax - place where to write
push bx
push cx
push dx

mov bx, ax

mov [di][bx], '0['
mov [di][bx + 6], ']h'

call ReadOneMoreByte
mov [di][bx + 4], ax

call ReadOneMoreByte
mov [di][bx + 2], ax

mov ax, bx

pop dx
pop cx
pop bx

ret
WriteDirectAddress ENDP


WriteFreeOperand PROC
				; args: IsPoslinkis - num of bytes, AX - place to write
					;return: AX - symbols written
push bx
push cx
push dx

mov bx, ax

mov ch, 0
mov cl, IsPoslinkis

cmp cl, 0
je endOperandas
	;Yra Operandas
	
	cmp cl, 1
	jg DviejuBaituOperandas
		;Vieno baito Operandas
			
		call ReadOneMoreByte
		
		mov byte ptr [di][bx], '0'
		mov [di][bx + 1], ax
		mov byte ptr [di][bx + 3], 'h'
		mov ax, 4
		
		jmp endOperandas
	
	DviejuBaituOperandas:
		;Dvieju baitu Operandas

		mov byte ptr [di][bx], '0'
		
		call ReadOneMoreByte
		mov [di][bx + 3], ax

		call ReadOneMoreByte
		mov [di][bx + 1], ax
		
		mov byte ptr [di][bx + 5], 'h'
		
		mov ax, 6
	
		jmp endOperandas
endOperandas:

pop dx
pop cx
pop bx

mov IsPoslinkis, 0

ret
WriteFreeOperand ENDP


WriteJumpPoslinkis PROC
			;args: AX - place to write, IsPoslinkis - bytes poslinkio
push bx
push cx
push dx

mov bx, ax

cmp IsPoslinkis, 0
je endJumpPoslinkis
	
	cmp IsPoslinkis, 1
	jne DviejuBaituJumpPoslinkis
		;Vieno baito Jump poslinkis
			
		call ReadOneMoreByte
		
		mov cx, byteNumber
		inc cx
		add cx, poslinkisORG
		
		mov dh, 0
		cmp dl, 080h
		jb skipNeigiamas
			mov dh, 0FFh
		skipNeigiamas:
		
		add cx, dx
		
		jmp endJumpPoslinkis
	
	DviejuBaituJumpPoslinkis:
		;Dvieju baitu Jump poslinkis

		call ReadOneMoreByte
		mov dh, dl
		call ReadOneMoreByte
		
		xchg dl, dh
		
		mov cx, byteNumber
		inc cx
		add cx, poslinkisORG
		
		add cx, dx
endJumpPoslinkis:

mov byte ptr [di][bx + 4], 'h'

mov dl, ch
call ValueToHex
mov [di][bx + 0], ax

mov dl, cl
call ValueToHex
mov [di][bx + 2], ax

mov IsPoslinkis, 0

pop dx
pop cx
pop bx

ret
WriteJumpPoslinkis ENDP


ReadOneMoreByte PROC
			; arguments: bx - last command num
			; nr   --- where to put byte in line
			; return -- AX, byte in hex, DL - byte
	push si
	push bx
	
	mov bx, byteNumber
	inc bx
	
	mov si, offset duom1
    mov dl, [si][bx]
	
	mov byteNumber, bx
	
	mov bx, nr
    call ValueToHex
    mov [di][bx], ax 

	add bx, 3
	mov nr, bx
	
	pop bx
	pop si
ret
ReadOneMoreByte ENDP


Check8or16Reg PROC
		;args: si - command prototype address, DH - ComByte
push ax
push dx
	
	mov al, [si + 4]
	cmp al, 1
	
	jne skip03
		and dh, 00000001b
		cmp dh, 00000001b
		jne skip03
			mov IsReg16, 00001000b
	
	skip03:
	
	cmp al, 3
	jne skip04
		mov IsReg16, 00001000b
	skip04:	
	
	cmp al, 4
	jne skip00
		mov IsReg16, 00010000b
	skip00:
	
pop dx
pop ax
ret
Check8or16Reg ENDP

CheckSBit PROC
		;args: DH - com byte, DL - MOD ... R/M byte, ax - where to write
push bx
push dx

mov bx, ax

cmp IsReg16, 0
jne skip1byteBOP
	mov IsPoslinkis, 1
	call WriteFreeOperand	
	jmp skipBOP2
skip1byteBOP:

mov dl, [si + 5]
cmp dl, 2
je skipCheckPletimas
	mov dx, safeDX
	and dh, 00000010b
	cmp dh, 00000010b
	je skip2byteBOP
skipCheckPletimas:

	mov IsPoslinkis, 2
	call WriteFreeOperand	
	jmp skipBOP2			
skip2byteBOP:

	; Pleciama pagal pletimo taisykle
	call ReadOneMoreByte
	mov dh, 0
	cmp dl, 10000000b
	
	jb skipNeigiamas2
		mov dh, 0FFh
	skipNeigiamas2:
	
	call ValueToHex
	mov [di][bx + 3], ax
	
	mov dl, dh
	call ValueToHex
	mov [di][bx + 1], ax
	
	mov byte ptr [di][bx + 0], '0'
	mov byte ptr [di][bx + 5], 'h'

skipBOP2:	
pop dx 
pop bx
 
ret
CheckSBit ENDP 
 
 
checkMOD PROC    ;------------------------------------------
              ; args: DH - command byte, DL - mod reg r/m
push si 
push bx
push dx

mov safeDX, dx

mov IsReg16, 0
mov IsPoslinkis, 0

call Check8or16Reg

and dl, 11000000b  
       
cmp dl, 11000000b
je MODregister

cmp dl, 00000000b
jne skip05
	jmp MODatmintis
skip05:

shr dl, 6

mov IsPoslinkis, dl

jmp MODatmintis
	
MODregister:
              ; args: DH - command byte, DL - mod reg r/m
			  ; si - offset LIST_?? 
	mov al, [si + 3]
	cmp al, 1
	jne directionNORMAL
	
	and dh, 00000010b
	cmp dh, 00000010b
	mov dx, safeDX
	je directionNORMAL
	
	directionREVERSE:
		; r/m <- reg // d = 0

		and dl, 00111000b
		shr dl, 3
		or dl, IsReg16
		mov ax, 34
		call WriteReg
		
		mov dx, safeDX
		
		and dl, 00000111b
		or dl, IsReg16
		mov ax, 30
		call WriteReg
		
		mov [di + 32], ' ,'
		jmp MODend
	
	directionNORMAL:
		; reg <- r/m // d = 1 or no at all

		and dl, 00111000b
		shr dl, 3
		or dl, IsReg16
		mov ax, 30
		call WriteReg
		
		mov dx, safeDX
		
		mov dx, safeDX
		and dl, 00000111b
		or dl, IsReg16
		mov ax, 34
		
		call WriteReg
		mov [di + 32], ' ,'
jmp MODend
	
	
MODatmintis:
	mov al, [si + 3]
	cmp al, 1
	jne directionNORMAL2
	
	and dh, 00000010b
	cmp dh, 00000010b
	mov dx, safeDX
	je directionNORMAL2
	
	directionREVERSE2:
		; r/m <- reg // d = 0

		mov ax, 30
		call WriteRegMemory
		call WritePoslinkis

		add di, ax
		mov [di], ' ,'
		sub di, ax
		
		mov dx, safeDX
		
		and dl, 00111000b
		shr dl, 3
		or dl, IsReg16
		add ax, 2
		call WriteReg
		
		jmp MODend
	
	directionNORMAL2:
		; reg <- r/m // d = 1 or no at all
                
		mov ax, 34
		call WriteRegMemory
		call WritePoslinkis
		
		mov dx, safeDX
		
		and dl, 00111000b
		shr dl, 3
		or dl, IsReg16
		mov ax, 30
		call WriteReg
		
		mov [di + 32], ' ,'
jmp MODend
       
MODend:

pop dx
pop bx
pop si  
                  
     
ret    
checkMOD ENDP   ;-------------------------------------------  
 

checkMOD2 PROC    ;------------------------------------------
         ; args: safeDX: DH - command byte, DL - mod reg r/m
push si 
push bx
push dx

mov dx, safeDX

mov IsReg16, 0
mov IsPoslinkis, 0

call Check8or16Reg

and dl, 11000000b  
       
cmp dl, 11000000b
je MOD2register

cmp dl, 00000000b
jne skip06
	jmp MOD2atmintis
skip06:

shr dl, 6
mov IsPoslinkis, dl

jmp MOD2atmintis
	
MOD2register:
              ; args: DH - command byte, DL - mod reg r/m
			  ; si - offset LIST_?? 
	
		; r/m(reg) <- (bop) // d = 0	
		mov dx, safeDX

		and dl, 00000111b
		or dl, IsReg16
		mov ax, 30
		call WriteReg
		
		mov al, [si + 5]
		cmp al, 0
		je skipBOP
			mov [di + 32], ' ,'
			mov dx, safeDX
			
			mov ax, 34
			call CheckSBit
		skipBOP:
		jmp MOD2end
	
MOD2atmintis:
		; r/m <- (bop) // d = 0
		mov ax, 30
		
		cmp IsReg16, 0
		jne skipByte
			mov [di + 30], '.b'
			add ax, 2
		skipByte:
		
		cmp IsReg16, 00001000b
		jne skipWord
			mov [di + 30], '.w'
			add ax, 2
		skipWord:		
		
		cmp IsReg16, 00010000b
		jne skipDoubleWord
			mov [di + 30], 'wd'
			mov byte ptr [di + 32], '.'
			add ax, 3
		skipDoubleWord:	

		call WriteRegMemory
		call WritePoslinkis

		cmp byte ptr [si + 5], 0
		je skipBOP0
			add di, ax
			mov [di], ' ,'
			sub di, ax
			
			mov dx, safeDX
			add ax, 2
			
			call CheckSBit
		skipBOP0:
MOD2end:

pop dx
pop bx
pop si  
                   
ret    
checkMOD2 ENDP   ;-------------------------------------------   

end