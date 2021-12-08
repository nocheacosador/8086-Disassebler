.model small

fcall macro seg, ofs
        db 9Ah  ; CALL FAR instruction
        dw ofs
        dw seg
endm

bseg segment
    org	100h
	assume ds:bseg, cs:bseg, ss:bseg
main:
    push    ss
    push    cs
    pop     ss
    pop     ds
    mov     ds, [di]
    mov     es, ss:[si]
    add     cx, bx
    add     cx, ds:[0123h]
    sub     [bx + 0123h], sp
    cmp     es:[bx + di + 0123h], ax
    cmp     [si + bp + 0123h], bl
    add     al, 13h
    sub     ax, 3A2h
    cmp     ax, 0F0Fh
    mov     ax, ds:[1243h]
    mov     ds:[1243h], ah
    mov     ah, ds:[1243h]
label1:
    mov     ss:[0FFFh], al
    add     bx, 0FFFh
    add     bx, 0Fh
    shr     bl, 4
    into
    sub     bx, 0FFFFh
    add     cx, 0ABABh
    mov     word ptr [di + bx], 00CDh
    cmp     bx, 0FFFFh
    int     21h
    jcxz    label1
    loop    label1
    jmp     label1
    jo      label1
    mov     bl, 10h
    mov     cx, 1212h
    push    dx
    pop     di
    inc     di
    dec     si
    call    word ptr ss:[di + bx]
    push    ss:[di + bx]
    push    di
    mul     bl
    div     byte ptr es:[di + bp]
    dec     byte ptr [di]  
    int     3
    int     0
    call    FooNear
    fcall   0ABABh, 0CDCDh
    mov     word ptr [di + bx], 00CDh
    mov     word ptr [di + bx], 00CDh
    mov     word ptr [di + bx], 00CDh
    mov     word ptr [di + bx], 00CDh
    mov     word ptr [di + bx], 00CDh
    mov     word ptr [di + bx], 00CDh
    mov     word ptr [di + bx], 00CDh
    mov     word ptr [di + bx], 00CDh
    mov     word ptr [di + bx], 00CDh
    mov     word ptr [di + bx], 00CDh
    mov     word ptr [di + bx], 00CDh
    mov     word ptr [di + bx], 00CDh
    mov     word ptr [di + bx], 00CDh
    mov     word ptr [di + bx], 00CDh
    mov     word ptr [di + bx], 00CDh
    mov     word ptr [di + bx], 00CDh
    mov     word ptr [di + bx], 00CDh
    mov     word ptr [di + bx], 00CDh
    mov     word ptr [di + bx], 00CDh
    mov     word ptr [di + bx], 00CDh
    mov     word ptr [di + bx], 00CDh
    mov     word ptr [di + bx], 00CDh
    mov     word ptr [di + bx], 00CDh
    mov     word ptr [di + bx], 00CDh
    mov     word ptr [di + bx], 00CDh
    mov     word ptr [di + bx], 00CDh
    mov     word ptr [di + bx], 00CDh
    mov     word ptr [di + bx], 00CDh
    mov     word ptr [di + bx], 00CDh
    mov     word ptr [di + bx], 00CDh
    mov     word ptr [di + bx], 00CDh
    mov     word ptr [di + bx], 00CDh
    mov     word ptr [di + bx], 00CDh
    mov     word ptr [di + bx], 00CDh
    mov     word ptr [di + bx], 00CDh
    mov     word ptr [di + bx], 00CDh
    ;mov     [off_FooFar], offset FooFar
    ;mov     [seg_FooFar], seg FooFar
    ;call    far ptr off_FooFar

FooNear proc near
    ret
FooNear endp

FooFar proc far
    ret    10h
FooFar endp

    jmp     main
    ;off_FooFar  dw ?
    ;seg_FooFar  dw ?

bseg ends
end main