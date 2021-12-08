; Prints formatted error message drom ds:dx
PrintError proc
    push    dx
    lea     dx, sError
    call    Print
    pop     dx
    call    Puts
    ret
PrintError endp

; Prints integer stored in register ax
PrintInt proc
    push    ax
    push    bx
    push    cx
    push    dx

    mov     bx, 10
    xor     cx, cx

l2:
    xor     dx, dx
    div     bx
    push    dx
    inc     cx
    test    ax, ax
    jnz     l2

l3: 
    pop     dx
    add     dl, '0'
    mov     ah, 02h
    int     21h
    loop    l3

    pop     dx
    pop     cx
    pop     bx
    pop     ax
    ret
PrintInt endp

; Prints formatted error number stored in ax
PrintErrno proc    
    push    dx
    lea     dx, sErrno
    call    Print
    call    PrintInt
    mov     dl, ')'
    call    Putc
    pop     dx
    ret
PrintErrno endp

; Prints formatted error message and error number stored in ax
PrintErrorAndErrno proc
    push    dx
    lea     dx, sError
    call    Print
    pop     dx
    call    Print
    call    PrintErrno
    lea     dx, sEndl
    call    Print
    ret
PrintErrorAndErrno endp
