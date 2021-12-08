; es:di - string
; calculates string length without terminating character $
; return value in ax
StringLength proc 
    push    di
    xor     ax, ax
@@count_loop:
    cmp     byte ptr [di], '$'
    je      @@count_done
    inc     di
    inc     ax
    jmp     @@count_loop
@@count_done:
    pop     di
    ret
StringLength endp

; es:di - string 1
; ds:si - string 2
; concatenates string 2 to string 1
StringCat proc
    push    di si ax
    call    StringLength
    add     di, ax
    push    di es
    mov     di, si
    mov     ax, ds
    mov     es, ax
    call    StringLength
    mov     cx, ax
    pop     es di
    inc     cx
    cld
    rep movsb
    pop     ax si di
    ret
StringCat endp

; es:di - string
; dl - char
; concatenates char to string
StringCatChar proc
    push    di si ax
    call    StringLength
    add     di, ax
    mov     byte ptr [di], dl
    inc     di
    mov     byte ptr [di], '$'
    pop     ax si di
    ret
StringCatChar endp

; es:di - string 1 (dest)
; ds:si - string 2 (src)
; copies string 2 to string 1
StringCpy proc
    push    di si ax
    push    di es
    mov     di, si
    mov     ax, ds
    mov     es, ax
    call    StringLength
    mov     cx, ax
    pop     es di
    inc     cx
    cld
    rep movsb
    pop     ax si di
    ret
StringCpy endp

; es:di - string 1 (dest)
; ax - word
StringCatWord proc
    push    ax dx di

    xor     bx, bx
    mov     bl, ah
    shr     bl, 4
    mov     dl, sIntToHexSamples[bx]
    call    StringCatChar
    mov     bl, ah
    and     bl, 0Fh
    mov     dl, sIntToHexSamples[bx]
    call    StringCatChar
    
    xor     bx, bx
    mov     bl, al
    shr     bl, 4
    mov     dl, sIntToHexSamples[bx]
    call    StringCatChar
    mov     bl, al
    and     bl, 0Fh
    mov     dl, sIntToHexSamples[bx]
    call    StringCatChar
    mov     dl, 'h'
    call    StringCatChar

    pop     di dx ax
    ret
StringCatWord endp