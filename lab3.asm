.model tiny
.code
 
putc macro char
    push    ax
    mov     al, char
    mov     ah, 0Eh
    int     10h     
    pop     ax
endm

org 100h 

jmp start

overflow db  0Dh,0Ah,"Overflow$"
msg1 db  0Dh,0Ah, "enter first number: $"
msg2 db 0Dh,0Ah, "enter second number: $"
msg3 db 0Dh,0Ah, "plus: $" 
msg4 db 0Dh,0Ah, "minus: $"
msg5 db 0Dh,0Ah, "mul: $"
msg6 db 0Dh,0Ah, "div: $"
msg7 db 0Dh,0Ah, "and: $"
msg8 db 0Dh,0Ah, "or: $"
msg9 db 0Dh,0Ah, "xor: $"
msg10 db 0Dh,0Ah, "not1: $"
msg11 db 0Dh,0Ah, "not2: $"
err1 db  0Dh,0Ah,"invalid number$"
err2 db  0Dh,0Ah,"division by zero is incorrect!$"

num1 dw ?
num2 dw ? 
ten dw 10  
flag_minus db ? 
flag_minus_1 db ? 
flag_minus_2 db ?  

print_num_plus proc near
    push dx
    push ax

    cmp ax, 0
    jnz not_zero

    putc '0'
    jmp printed

    not_zero:
        cmp flag_minus_1,0
        je firstpositive           
        jmp firstnegative                    
        
    firstpositive:
        cmp flag_minus_2,0
        je positive
        push ax 
        mov ax,num2
        neg ax
        cmp num1,ax
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
        mov ax,num1
        neg ax
        cmp ax,num2
        ja makeneg
        jmp gopositive
      
    makeneg:
        pop ax 
        makenegoutpop:
        neg ax
        putc '-'
        jmp positive
                       
    positive:
        call print_num_ans
    printed:
        pop ax
        pop dx
        ret
print_num_plus endp 

print_num_minus proc near
    push dx
    push ax

    cmp ax, 0
    jnz not_zeromin

    putc '0'
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
        mov ax,num1
        cmp ax,num2
        ja makenegmin 
        jmp makenegoutpopmin 
        
    secondpositivemin:
        push ax
        mov ax,num1
        cmp ax,num2
        ja makenegmin
        jmp makenegoutpopmin
       
    makenegmin:
        pop ax
        jmp positivemin 
        makenegoutpopmin:
        pop ax
        makejustnegmin:
        neg ax
        putc    '-'
        jmp positivemin 
                  
    positivemin:

        call print_num_ans
    printedmin:
        pop ax
        pop dx
        ret
print_num_minus endp

print_num_mul proc near
    push dx
    push ax

    cmp ax, 0
    jnz not_zeromul

    putc '0'
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
        putc    '-'    
    positivemul:
        pop ax
        call print_num_ans
    printedmul:
        call return_neg_nums       
        pop ax
        pop dx
        ret
print_num_mul endp

print_num_div proc near
    push dx
    push ax

    cmp ax, 0
    jnz not_zerodiv

    putc '0'
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
        putc '-'
             
    positivediv:
        pop ax
        call print_num_ans 
        
    printeddiv:
        call return_neg_nums
        pop ax
        pop dx
        ret
print_num_div endp 

print_num_ans proc near
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
        putc al
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
        putc '0'
        
    end_print:
        pop dx
        pop cx
        pop bx
        pop ax
        ret
print_num_ans endp

check_minus proc near
    cmp ax,32767
    jna exit_check
    putc '-'
    neg ax
    exit_check:
        ret
check_minus endp

return_neg_nums proc near
    cmp flag_minus_1,1
    jz return_num1
    jnz cont
    cont:
        cmp flag_minus_2,1
        jz return_num2
        jnz quit    
    return_num1:
        neg num1
        jmp cont
    return_num2:
        neg num2
    quit:
        ret
return_neg_nums endp

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
        putc ' '                     
        putc 8                       
        jmp next_digit
        
    backspace_checked:
        cmp al, '0'
        jae ok_AE_0
        jmp remove_not_digit 
        
    ok_AE_0:        
        cmp al, '9'
        jbe ok_digit
        
    remove_not_digit:       
        putc 8       
        putc ' '     
        putc 8            
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
        putc 8       
        putc ' '     
        putc 8             
        jmp next_digit 
        
    stop_input:
        cmp cx, 32767         
        ja over               
        cmp CS:make_minus, 0
        je not_minus
        neg CX
        
    not_minus:
        pop si
        pop ax
        pop dx
        ret
make_minus db ?      
Input endp    

checkflags proc

    checknum1:
        cmp num1,32767
        ja setflag1

    checknum2:
        cmp num2,32767
        ja setflag2
        jbe exitflag
         
    setflag1: 
        mov flag_minus_1,1 
        jmp checknum2

    setflag2: 
        mov flag_minus_2,1 

    exitflag:
        ret
checkflags endp

    start: 
        lea dx, msg1
        mov ah, 09h   
        int 21h  
        call Input
        mov num1, cx
        jmp nextnumber
    over:
        lea dx, err1
        mov ah, 09h   
        int 21h
        jmp exit 
  
    nextnumber:
        lea dx, msg2
        mov ah, 09h     
        int 21h
        call Input  
        mov num2, cx
         
        call checkflags        

        lea dx, msg3
        mov ah, 09h      
        int 21h         
        jmp plus 
        
    continue1:
        lea dx, msg4
        mov ah, 09h      
        int 21h 
        jmp minus
    
    continue2:
        lea dx, msg5
        mov ah, 09h      
        int 21h 
        jmp mult
    
    continue3:
        lea dx, msg6
        mov ah, 09h      
        int 21h
        jmp divv
        
    continue4:
        lea dx, msg7
        mov ah, 09h      
        int 21h
        mov dx, num1
        mov ax, num2
        and ax, dx
        call check_minus
        call print_num_ans
        
        lea dx, msg8
        mov ah, 09h      
        int 21h
        mov dx, num1
        mov ax, num2
        or ax, dx
        call check_minus
        call print_num_ans
        
        lea dx, msg9
        mov ah, 09h      
        int 21h
        mov dx, num1
        mov ax, num2
        xor ax, dx
        call check_minus
        call print_num_ans 
        
        lea dx, msg10
        mov ah, 09h      
        int 21h
        mov ax, num1
        neg ax
        call check_minus
        call print_num_ans 
        
        lea dx, msg11
        mov ah, 09h      
        int 21h
        mov ax, num2
        neg ax
        call check_minus
        call print_num_ans        

    exit:
        mov ax,4C00h
        int 21h
   
    plus:
        mov ax, num1
        add ax, num2 
        call print_num_plus   
        jmp continue1

    minus:
        mov ax, num1
        sub ax, num2 
        call print_num_minus    
        jmp continue2

    mult:
        cmp flag_minus_1,1
        je makenum1pos
        jmp checknum2mul 

    makenum1pos:
        neg num1

    checknum2mul:
        cmp flag_minus_2,1
        je makenum2pos  
        jmp gomul 

    makenum2pos:
        neg num2
  
    gomul:
        mov ax, num1
        mul num2
        jc overmul 
        jmp printmul

    overmul:
        lea dx, overflow
        mov ah, 09h   
        int 21h
        jmp continue3 

    printmul:
        call print_num_mul    
        jmp continue3

    divv: 
        cmp flag_minus_1,1
        je makenum1posdiv
        jmp checknum2div 

    makenum1posdiv:
        neg num1

    checknum2div:
        cmp flag_minus_2,1
        je makenum2posdiv  
        jmp godiv 

    makenum2posdiv:
        neg num2
  
    godiv:
        xor dx,dx
        cmp num2,0
        je overdiv
        mov ax, num1
        div num2  
        jmp printdiv

    overdiv:
        lea dx, err2
        mov ah, 09h   
        int 21h
        jmp continue4  

    printdiv:
        call print_num_div 
        jmp continue4
end start   
