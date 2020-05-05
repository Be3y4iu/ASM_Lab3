.model tiny
.code
 
putchar macro char
    push    ax
    mov     al, char
    mov     ah, 0Eh
    int     10h     
    pop     ax
endm

org 100h 

jmp start

overflow db  0Dh,0Ah,"Overflow$"
message1 db  0Dh,0Ah, "Enter first number: $"
message2 db 0Dh,0Ah, "Enter second number: $"
message3 db 0Dh,0Ah, "Plus: $" 
message4 db 0Dh,0Ah, "Minus: $"
message5 db 0Dh,0Ah, "Mul: $"
message6 db 0Dh,0Ah, "Div: $"
message7 db 0Dh,0Ah, "And: $"
message8 db 0Dh,0Ah, "Or: $"
message9 db 0Dh,0Ah, "Xor: $"
message10 db 0Dh,0Ah, "Not1: $"
message11 db 0Dh,0Ah, "Not2: $"
error1 db  0Dh,0Ah,"Invalid number. Please, try again.  $"
error2 db  0Dh,0Ah,"Division by zero is incorrect!$"

number1 dw ?
number2 dw ? 
ten dw 10  
flag_minus db ? 
flag_minus_1 db ? 
flag_minus_2 db ?  

print_number_plus proc near
    push dx
    push ax

    cmp ax, 0
    jnz not_zero

    putchar '0'
    jmp printed

    not_zero:
        cmp flag_minus_1,0
        je firstpositive           
        jmp firstnegative                    
        
    firstpositive:
        cmp flag_minus_2,0
        je positive
        push ax 
        mov ax,number2
        neg ax
        cmp number1,ax
        ja gopositive
        jmp makeneg
       
    gopositive:
        pop ax
        jmp positive
       
    firstnegative:
        cmp flag_minus_2,0
        je secondpositive
        jmp makenegoutpop 
       
    secondpositive:
        push ax
        mov ax,number1
        neg ax
        cmp ax,number2
        ja makeneg
        jmp gopositive
      
    makeneg:
        pop ax 
        makenegoutpop:
        neg ax
        putchar '-'
        jmp positive
                       
    positive:
        call print_number_ans
    printed:
        pop ax
        pop dx
        ret
print_number_plus endp 

print_number_minus proc near
    push dx
    push ax

    cmp ax, 0
    jnz not_zeromin

    putchar '0'
    jmp printed

    not_zeromin:  
        cmp flag_minus_1,0
        je firstpositivemin 
        jmp firstnegativemin 
        
        firstpositivemin:
        cmp flag_minus_2,0
        je secondpositivemin 
        jmp positivemin
        
    firstnegativemin:
        cmp flag_minus_2,0
        je makejustnegmin 
        push ax
        mov ax,number1
        cmp ax,number2
        ja makenegmin 
        jmp makenegoutpopmin 
        
    secondpositivemin:
        push ax
        mov ax,number1
        cmp ax,number2
        ja makenegmin
        jmp makenegoutpopmin
       
    makenegmin:
        pop ax
        jmp positivemin 
        makenegoutpopmin:
        pop ax
        makejustnegmin:
        neg ax
        putchar '-'
        jmp positivemin 
                  
    positivemin:

        call print_number_ans
    printedmin:
        pop ax
        pop dx
        ret
print_number_minus endp

print_number_mul proc near
    push dx
    push ax

    cmp ax, 0
    jnz not_zeromul

    putchar '0'
    jmp printed

    not_zeromul:
        push ax
        xor ax,ax
        mov al,flag_minus_1
        xor al,flag_minus_2
        cmp al,1
        je makemulneg 
        jmp positivemul 
        
        makemulneg: 
        putchar '-'    
    positivemul:
        pop ax
        call print_number_ans
    printedmul:
        pop ax
        pop dx
        ret
print_number_mul endp

print_number_div proc near
    push dx
    push ax

    cmp ax, 0
    jnz not_zerodiv

    putchar '0'
    jmp printed

    not_zerodiv:
        push ax
        xor ax,ax
        mov al,flag_minus_1
        xor al,flag_minus_2
        cmp al,1
        je makedivneg 
        jmp positivediv 
        
    makedivneg: 
        putchar '-'
             
    positivediv:
        pop ax
        call print_number_ans 
        
    printeddiv:
        pop ax
        pop dx
        ret
print_number_div endp 

print_number_ans proc near
    push ax
    push bx
    push cx
    push dx
       
    mov cx, 1
    mov bx, 10000      
    cmp ax, 0
    jz print_zero

    begin_print:
        cmp bx,0
        jz end_print

        cmp cx, 0
        je calc
        cmp ax, bx
        jb skip 
        
    calc:
        mov cx, 0   
        mov dx, 0
        div bx       
        add al, 30h    
        putchar al
        mov ax, dx  

    skip:
        push ax
        mov dx, 0
        mov ax, bx
        div CS:ten  
        mov bx, ax
        pop ax

        jmp begin_print
        
    print_zero:
        putchar '0'
        
    end_print:
        pop dx
        pop cx
        pop bx
        pop ax
        ret
print_number_ans endp

check_minus proc near
    cmp ax,32767
    jna exit_check
    putchar '-'
    neg ax
    exit_check:
        ret
check_minus endp

return_neg_numbers proc near
    cmp flag_minus_1,1
    jz neg_number1
    jnz cont
    cont:
        cmp flag_minus_2,1
        jz neg_number2
        jnz quit    
    neg_number1:
        neg number1
        jmp cont
    neg_number2:
        neg number2
    quit:
        ret
return_neg_numbers endp

Input proc near
    push dx
    push ax
    push si
    mov cx, 0
    mov make_minus, 0

    next_digit:
        mov ah, 00h
        int 16h
        mov ah, 0Eh
        int 10h

        cmp al, '-'
        je set_minus
       
        cmp al, 0Dh  
        jne not_cr
        jmp stop_input

    not_cr:
        cmp al, 8                   
        jne backspace_checked
        mov dx, 0                   
        mov ax, cx                 
        div CS:ten                  
        mov cx, ax
        putchar ' '                     
        putchar 8                       
        jmp next_digit
        
    backspace_checked:
        cmp al, '0'
        jae ok_AE_0
        jmp remove_not_digit 
        
    ok_AE_0:        
        cmp al, '9'
        jbe ok_digit
        
    remove_not_digit:       
        putchar 8       
        putchar ' '     
        putchar 8            
        jmp next_digit
               
    ok_digit:
        push ax
        mov ax, cx
        mul CS:ten                  
        mov cx, ax
        pop ax

        cmp dx, 0
        jne too_big

        sub al, 30h

        mov ah, 0
        mov dx, cx      
        add cx, ax
        jc too_big2    

        jmp next_digit

    set_minus:
        mov CS:make_minus, 1
        jmp next_digit

    too_big2:
        mov cx, dx      
        mov dx, 0  
            
    too_big:
        mov ax, cx
        div CS:ten  
        mov cx, ax
        putchar 8       
        putchar ' '     
        putchar 8             
        jmp next_digit 
        
    stop_input:
        cmp CS:make_minus, 0
        je not_minus
        cmp cx, 32768
        ja over
        neg cx
        jmp quit_input
    not_minus:    
        cmp cx, 32767         
        ja over     
        jmp quit_input
   
    over:     
        lea dx, error1
        mov ah, 09h   
        int 21h
        xor cx, cx
        jmp next_digit    
        
    quit_input:
        pop si
        pop ax
        pop dx
        ret
make_minus db ?      
Input endp    

checkflags proc

    checknumber1:
        cmp number1,32767
        ja setflag1

    checknumber2:
        cmp number2,32767
        ja setflag2
        jbe exitflag
         
    setflag1: 
        mov flag_minus_1,1 
        jmp checknumber2

    setflag2: 
        mov flag_minus_2,1 

    exitflag:
        ret
checkflags endp

    start: 
        lea dx, message1
        mov ah, 09h   
        int 21h  
        call Input
        mov number1, cx

        lea dx, message2
        mov ah, 09h     
        int 21h
        call Input  
        mov number2, cx
         
        call checkflags        

        lea dx, message3
        mov ah, 09h      
        int 21h         
        jmp plus 
        
    continue1:
        lea dx, message4
        mov ah, 09h      
        int 21h 
        jmp minus
    
    continue2:
        lea dx, message5
        mov ah, 09h      
        int 21h 
        jmp mult
    
    continue3:
        lea dx, message6
        mov ah, 09h      
        int 21h
        jmp diiv
        
    continue4:
        lea dx, message7
        mov ah, 09h      
        int 21h
        mov dx, number1
        mov ax, number2
        and ax, dx
        call check_minus
        call print_number_ans
        
        lea dx, message8
        mov ah, 09h      
        int 21h
        mov dx, number1
        mov ax, number2
        or ax, dx
        call check_minus
        call print_number_ans
        
        lea dx, message9
        mov ah, 09h      
        int 21h
        mov dx, number1
        mov ax, number2
        xor ax, dx
        call check_minus
        call print_number_ans 
        
        lea dx, message10
        mov ah, 09h      
        int 21h
        mov ax, number1
        neg ax
        call check_minus
        call print_number_ans 
        
        lea dx, message11
        mov ah, 09h      
        int 21h
        mov ax, number2
        neg ax
        call check_minus
        call print_number_ans        

    exit:
        mov ax,4C00h
        int 21h
   
    plus:
        mov ax, number1
        add ax, number2 
        call print_number_plus   
        jmp continue1

    minus:
        mov ax, number1
        sub ax, number2 
        call print_number_minus    
        jmp continue2

    mult:
        cmp flag_minus_1,1
        je makenumber1pos
        jmp checknumber2mul 

    makenumber1pos:
        neg number1

    checknumber2mul:
        cmp flag_minus_2,1
        je makenumber2pos  
        jmp gomul 

    makenumber2pos:
        neg number2
  
    gomul:
        mov ax, number1
        mul number2
        jc overmul 
        jmp printmul

    overmul:
        lea dx, overflow
        mov ah, 09h   
        int 21h
        call return_neg_numbers
        jmp continue3 

    printmul:
        call print_number_mul
        call return_neg_numbers    
        jmp continue3

    diiv: 
        cmp flag_minus_1,1
        je makenumber1posdiv
        jmp checknumber2div 

    makenumber1posdiv:
        neg number1

    checknumber2div:
        cmp flag_minus_2,1
        je makenumber2posdiv  
        jmp godiv 

    makenumber2posdiv:
        neg number2
  
    godiv:
        xor dx,dx
        cmp number2,0
        je overdiv
        mov ax, number1
        div number2  
        jmp printdiv

    overdiv:
        lea dx, error2
        mov ah, 09h   
        int 21h
        call return_neg_numbers 
        jmp continue4  

    printdiv:
        call print_number_div
        call return_neg_numbers  
        jmp continue4
end start   
