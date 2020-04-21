.model small 
.stack 100h 
.data 
message1 db "enter the first number: ",'$' 
message2 db "enter the second number: ",'$'
message3 db "sum: ",'$'
message4 db "dif: ",'$'
message5 db "mul: ",'$'
message6 db "div: ",'$'
message7 db "and: ",'$'
message8 db "or: ",'$'
message9 db "xor: ",'$'
message10 db "not: ",'$'
error_msg db "invalid number! ", '$'
overflow_msg db "overflow occured! ", '$'
div_by_zero db "division by zero is illegal! ", '$'
try_again db "try again: ", '$'
string db 7, 7 dup('$')
string_end = $ - 1 
num1 dw ?
num2 dw ?
minus dw 0
NumBuffer dw 0

.code 
start:  
    mov ax, @data 
	mov es, ax 
	mov ds, ax 

	lea dx, message1
	call output 

	;input first number
	call string_to_number
    mov [num1], ax
	mov NumBuffer, 0

	lea dx, message2 
	call output
	
	;input second number
	call string_to_number
	mov [num2], ax

	lea dx, message3
	call output

	mov ax, num2
	add ax, num1
	jo overflow1
	jmp alright1

overflow1:
	lea dx, overflow_msg
	call output
	jmp next1
	
alright1:	
	;translating the result to string and output
	call num_to_str
	lea dx, [di+1]
	call output
	
next1:
	call new_line
	lea dx, message4
	call output

	mov ax, num1
	sub ax, num2
	jo overflow2
	jmp alright2

overflow2:
	lea dx, overflow_msg
	call output
	jmp next2

alright2:
	call number_to_string
	lea dx, [di+1]
	call output 
	
next2:
	call new_line
	lea dx, message5
	call output

	mov ax, num1
	imul num2
	jo overflow3
	jmp alright3

overflow3:
	lea dx, overflow_msg
	call output
	jmp next3

alright3:
	call number_to_string
	lea dx, [di+1]
	call output 
	
next3:
	call new_line
	lea dx, message6
	call output

	cmp num2, 0
	jne continuee
	lea dx, div_by_zero
	call output
	call new_line
	jmp skip

continuee:
	xor ax, ax
	xor dx, dx
	mov ax, num1
	cmp ax, 0
	jg pos
	mov bx, -1
	imul bx
	idiv num2
	imul bx
	jo overflow4
	jmp next

pos:
	idiv num2
	jo overflow4
	jmp next

overflow4:
	lea dx, overflow_msg
	call output
	jmp next4

next:
	call number_to_string
	lea dx, [di+1]
	call output
	
next4:
	call new_line

skip:	
	mov dx, [num1] 
	mov ax, [num2] 
	and ax, dx 
	call number_to_string 
	lea dx, message7 
	call output 
	lea dx, [di+1] 
	call output 
	call new_line 

	mov dx, [num1] 
	mov ax, [num2] 
	or ax, dx 
	call number_to_string 
	lea dx, message8 
	call output 
	lea dx, [di+1] 
	call output 
	call new_line 

	mov dx, [num1] 
	mov ax, [num2] 
	xor ax, dx 
	call number_to_string 
	lea dx, message9 
	call output 
	lea dx, [di+1] 
	call output 
	call new_line 

	mov ax, [num1] 
	not ax 
	call number_to_string 
	lea dx, message10 
	call output 
	lea dx, [di+1] 
	call output 
	call new_line 

	mov ax, [num2] 
	not ax 
	call number_to_string 
	lea dx, message10 
	call output 
	lea dx, [di+1] 
	call output

	mov ax, 4C00h 
	int 21h 

output proc 
	mov ah, 09h 
	int 21h 
	ret 
endp output 

new_line proc
	mov dl, 10 
	mov ah, 2 
	int 21h
	ret
endp new_line

input proc 
	mov ah, 0Ah 
	int 21h 

	mov dl, 10 
	mov ah, 2 
	int 21h
	ret 
endp input 

string_to_number proc

again:

	xor ax,ax
    xor cx,cx
   
    mov al, 7
   
    mov [string],al
    mov [string + 1], 0
    lea dx, string
    call input
   
    mov cl, [string + 1]
    lea si, string
    add si,2

	xor ax,ax
    xor bx,bx
    xor dx,dx
    mov dx,10 
       
NextSym:
    xor ax,ax
    lodsb
    cmp bl,0
    je checkMinus
   
checkSym:
         
    cmp al,'0'
    jl badNum
    cmp al,'9'
    jg badNum
         
    sub ax, '0'
    mov bx, ax
    xor ax, ax
    mov ax, NumBuffer
         
    imul dx
    jo badNum
    cmp minus, 1
    je doSub
    add ax, bx

comeBack:
    jo badNum
    mov NumBuffer,ax
    mov bx,1
    mov dx,10
    loop NextSym

    mov ax, NumBuffer
    mov minus, 0
    ret
doSub:
    sub ax, bx
   	jmp comeBack
     
checkMinus:
    inc bl
    cmp al, '-'
   
    je SetMinus
   
    jmp checkSym
                 
SetMinus:
    mov minus,1
   	dec cx
    cmp cx,0
    je badNum
    jmp NextSym
   
badNum:
    clc ;clear carry flag
    mov minus,0
	lea dx, error_msg
    call output
	lea dx, try_again
	call output
	call new_line
    mov NumBuffer, 0
    jmp again                            
endp string_to_number



number_to_string proc 

	mov NumBuffer, 1
	cmp ax, 0
	jge positive
	mov bx, -1
	imul bx
	jmp negative

positive:
	mov NumBuffer, 0
negative:
	std 
	lea di, string_end - 1 

	mov cx,10 	
repeat: 
	xor dx,dx 	
	idiv cx 	; Делим DX:AX на CX (10), 
			; Получаем в AX частное, в DX остаток 
	xchg ax,dx 	; Меняем их местами (нас интересует остаток) 
	add al,'0' 	; Получаем в AL символ десятичной цифры 
	stosb 		; И записываем ее в строку 
	xchg ax,dx 	; Восстанавливаем AX (частное) 
	or ax,ax	; Сравниваем AX с 0 
jne repeat 

	cmp NumBuffer, 0
	jg setSign
	jmp eeend
setSign:
	xor ax, ax
	mov al, '-'
	stosb

eeend:
	ret 
endp number_to_string

end start