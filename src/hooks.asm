EmptyHook proc
    nop
    ret
EmptyHook endp

SegRegHook proc
    push    ax bx di
    
    mov     bl, al
    and     bl, 0FDh
    cmp     bl, 8Ch
    je      @@op_mov

    mov     bl, al
    and     bl, 0E7h
    cmp     bl, 06h
    je      @@op_push
    cmp     bl, 07h
    je      @@op_pop
    cmp     bl, 26h
    je      @@op_seg_ovr
    pop     di bx ax
    ret

@@op_push:
    mov     [sOperationPtr], offset sPUSH
    jmp     @@parse_sreg
    
@@op_pop:
    mov     [sOperationPtr], offset sPOP

@@parse_sreg:  
    xor     bx, bx
    mov     bl, al
    shr     bl, 2
    and     bl, 06h
    lea     di, sOperand1Buf
    mov     si, [SRegisters + bx]
    call    StringCpy
    pop     di bx ax
    ret 

@@op_seg_ovr:
    mov     [sOperationPtr], offset sNone
    mov     [bSegmentOverride], 1
    shr     al, 3
    and     al, 03h
    mov     [uSegmentOverrideVal], al
    pop     di bx ax
    ret
    
@@op_mov:
    mov     [sOperationPtr], offset sMOV

    xor     bx, bx
    mov     bl, [uInstrHistory]
    and     bl, 02h
    shr     bl, 1
    mov     [bD], bl
    mov     [bW], 1

    call    ParseAddressingByte
    
    shl     bl, 1
    mov     di, [Operands + 2 + bx]
    xor     bx, bx
    mov     bl, [uReg]
    shl     bl, 1
    mov     si, SRegisters[bx]
    call    StringCpy

    mov     bl, [bD]
    shl     bl, 1
    mov     di, [Operands + bx]
    mov     bx, [uDefaultRegMemFormat]
    call    DecodeRegMem
    
    pop     di bx ax
    ret
SegRegHook endp

RegRegMemHook proc
    push    ax bx di
    
    xor     bx, bx
    mov     bl, al
    and     bl, 0FCh
    cmp     bl, 00h
    je      @@op_add
    cmp     bl, 28h
    je      @@op_sub
    cmp     bl, 38h
    je      @@op_cmp
    cmp     bl, 88h
    je      @@op_mov
    pop     di bx ax
    ret

@@op_add:
    mov     [sOperationPtr], offset sADD
    jmp     @@continue
@@op_sub:
    mov     [sOperationPtr], offset sSUB
    jmp     @@continue
@@op_cmp:
    mov     [sOperationPtr], offset sCMP
    jmp     @@continue
@@op_mov:
    mov     [sOperationPtr], offset sMOV

@@continue:
    mov     bl, [uInstrHistory]
    and     bl, 02h
    shr     bl, 1
    mov     [bD], bl
    
    mov     bl, [uInstrHistory]
    and     bl, 01h
    mov     [bW], bl
    
    call    ParseAddressingByte
    
    mov     bl, [bD]
    shl     bl, 1
    mov     di, [Operands + 2 + bx]
    call    DecodeReg
    
    mov     di, [Operands + bx]
    mov     bx, [uDefaultRegMemFormat]
    call    DecodeRegMem
    
    pop    di bx ax
    ret
RegRegMemHook endp

AccumHook proc
    push    ax bx di
    
    xor     bx, bx
    mov     bl, [uInstrHistory]
    and     bl, 02h
    shr     bl, 1
    mov     [bD], bl
    
    mov     bl, [uInstrHistory]
    and     bl, 01h
    mov     [bW], bl
    
    mov     bl, al
    and     bl, 0FEh
    cmp     bl, 04h
    je      @@op_add
    cmp     bl, 2Ch
    je      @@op_sub
    cmp     bl, 3Ch
    je      @@op_cmp
    cmp     bl, 0A0h
    je      @@op_mov
    cmp     bl, 0A2h
    je      @@op_mov
    pop     di bx ax
    ret

@@op_add:
    mov     [sOperationPtr], offset sADD
    jmp     @@continue
@@op_sub:
    mov     [sOperationPtr], offset sSUB
    jmp     @@continue
@@op_cmp:
    mov     [sOperationPtr], offset sCMP
    jmp     @@continue
@@op_mov:
    mov     [sOperationPtr], offset sMOV

    mov     bl, [bD]
    shl     bl, 1
    mov     di, [Operands + 2 + bx]
    mov     byte ptr [uMod], 00h
    mov     byte ptr [uRM], 06h
    mov     bx, [uDefaultRegMemFormat]
    call    DecodeRegMem
    
@@continue:
    mov     bl, [bD]
    shl     bl, 1

    cmp     [bW], 0
    je      @@w0
    jmp     @@w1
    
@@w0:
    mov     di, [Operands + bx]
    lea     si, sRegAL
    call    StringCpy

    cmp     [sOperationPtr], offset sMOV
    je      @@done

    mov     di, [Operands + 2 + bx]
    call    ParseAndCatByte

    jmp     @@done

@@w1:
    mov     di, [Operands + bx]
    lea     si, sRegAX
    call    StringCpy

    cmp     [sOperationPtr], offset sMOV
    je      @@done

    mov     di, [Operands + 2 + bx]
    call    ParseAndCatWord

@@done:
    pop     di bx ax
    ret
AccumHook endp

RegMemNumHook proc
    push    ax bx di
    
    mov     bl, [uInstrHistory]
    and     bl, 02h
    shr     bl, 1
    mov     [bS], bl

    mov     bl, [uInstrHistory]
    and     bl, 01h
    mov     [bW], bl
    
    call    ParseAddressingByte
    
    mov     bl, [uInstrHistory]
    and     bl, 0FEh
    cmp     bl, 0C6h
    je      @@op_mov
    and     bl, 0FCh
    cmp     bl, 80h
    je      @@op_cont
    pop     di bx ax
    ret

@@op_cont:
    cmp     [uReg], 00h
    je      @@op_add
    cmp     [uReg], 05h
    je      @@op_sub
    cmp     [uReg], 07h
    je      @@op_cmp
    pop     di bx ax
    ret

@@op_add:
    mov     [sOperationPtr], offset sADD
    jmp     @@continue
@@op_sub:
    mov     [sOperationPtr], offset sSUB
    jmp     @@continue
@@op_cmp:
    mov     [sOperationPtr], offset sCMP
    jmp     @@continue
@@op_mov:
    mov     [sOperationPtr], offset sMOV
    mov     [bS], 0

@@continue:
    lea     di, sOperand1Buf
    mov     bx, [uDefaultRegMemFormat]
    call    DecodeRegMem


    cmp     [bW], 0
    je      @@byte_val
    cmp     [bS], 1    
    je      @@word_val_s1
    jmp     @@word_val

@@byte_val:
    lea     di, sOperand2Buf
    call    ParseAndCatByte
    jmp     @@done

@@word_val_s1:
    lea     di, sUtilBuf
    call    ParseAndCatByte
    mov     al, [sUtilBuf]
    cmp     al, '8'
    jb      @@fill_00
    mov     dl, 'F'
    jmp     @@word_val_s1_continue

@@fill_00:
    mov     dl, '0'

@@word_val_s1_continue:
    lea     di, sOperand2Buf
    call    StringCatChar
    call    StringCatChar

    lea     si, sUtilBuf
    call    StringCat
    jmp     @@done

@@word_val:
    lea     di, sOperand2Buf
    call    ParseAndCatWord

@@done:
    pop     di bx ax
    ret
RegMemNumHook endp

RegMemHook proc
    push    ax bx cx di

    call    ParseAddressingByte
    
    mov     bl, [uInstrHistory]
    cmp     bl, 8Fh
    je      @@op_pop
    cmp     bl, 0FFh
    je      @@case_ff
    cmp     bl, 0FEh
    je      @@case_fe
    cmp     bl, 0F7h
    je      @@case_f7_f6
    cmp     bl, 0F6h
    je      @@case_f7_f6
    pop     di cx bx ax
    ret

@@case_ff:
    mov     al, [uReg]
    cmp     al, 00h
    je      @@op_inc
    cmp     al, 01h
    je      @@op_dec
    cmp     al, 02h
    je      @@op_call
    cmp     al, 03h
    je      @@op_call
    cmp     al, 04h
    je      @@op_jmp
    cmp     al, 05h
    je      @@op_jmp
    cmp     al, 06h
    je      @@op_push
    pop     di cx bx ax
    ret

@@case_fe:
    mov     al, [uReg]
    cmp     al, 00h
    je      @@op_inc
    cmp     al, 01h
    je      @@op_dec
    pop     di cx bx ax
    ret

@@case_f7_f6:
    mov     al, [uReg]
    cmp     al, 04h
    je      @@op_mul
    cmp     al, 06h
    je      @@op_div
    pop     di cx bx ax
    ret

@@op_pop:
    mov     [sOperationPtr], offset sPOP
    jmp     @@continue

@@op_inc:
    mov     [sOperationPtr], offset sINC
    jmp     @@continue

@@op_dec:
    mov     [sOperationPtr], offset sDEC
    jmp     @@continue

@@op_mul:
    mov     [sOperationPtr], offset sMUL
    jmp     @@continue
    
@@op_div:
    mov     [sOperationPtr], offset sDIV
    jmp     @@continue

@@op_push:
    mov     [sOperationPtr], offset sPUSH
    jmp     @@continue

@@op_jmp:
    mov     [sOperationPtr], offset sJMP
    jmp     @@continue

@@op_call:
    mov     [sOperationPtr], offset sCALL

@@continue:
    mov     bl, [uInstrHistory]
    and     bl, 01h
    mov     [bW], bl

    lea     di, sOperand1Buf
    mov     bx, [uDefaultRegMemFormat]
    
    mov     al, [uInstrHistory]
    cmp     al, 0FFh
    jne     @@skip_override_regmem_format
    mov     al, [uReg]
    cmp     al, 03h
    je      @@override_regmem_format
    cmp     al, 05h
    jne     @@skip_override_regmem_format

@@override_regmem_format:
    mov     bx, 4

@@skip_override_regmem_format:
    call    DecodeRegMem

    pop     di cx bx ax
    ret
RegMemHook endp

RegHook proc
    push    ax bx di
    
    mov     [bW], 1
    mov     bl, [uInstrHistory]
    and     bl, 07h
    mov     [uReg], bl
    
    mov     bl, [uInstrHistory]
    and     bl, 0F8h
    cmp     bl, 40h
    je      @@op_inc
    cmp     bl, 48h
    je      @@op_dec
    cmp     bl, 50h
    je      @@op_push
    cmp     bl, 58h
    je      @@op_pop
    cmp     bl, 0B0h
    je      @@op_mov
    cmp     bl, 0B8h
    je      @@op_mov
    pop     di bx ax
    ret

@@op_inc:
    mov     [sOperationPtr], offset sINC
    jmp     @@continue

@@op_dec:
    mov     [sOperationPtr], offset sDEC
    jmp     @@continue

@@op_push:
    mov     [sOperationPtr], offset sPUSH
    jmp     @@continue

@@op_pop:
    mov     [sOperationPtr], offset sPOP
    jmp     @@continue

@@op_mov:
    mov     [sOperationPtr], offset sMOV
    mov     bl, [uInstrHistory]
    and     bl, 08h
    shr     bl, 3
    mov     [bW], bl
    
    lea     di, sOperand2Buf

    cmp     bl, 1
    je      @@op_mov_word
    jmp     @@op_mov_byte

@@op_mov_byte:
    call    ParseAndCatByte
    jmp     @@continue

@@op_mov_word:
    call    ParseAndCatWord

@@continue:
    lea     di, sOperand1Buf
    call    DecodeReg

    pop     di bx ax
    ret
RegHook endp

FarAddrHook proc
    push    bx di

    mov     bl, [uInstrHistory]
    cmp     bl, 0EAh
    je      @@op_jmp
    cmp     bl, 9Ah
    je      @@op_call
    pop     di bx
    ret 

@@op_jmp:
    mov     [sOperationPtr], offset sJMP
    jmp     @@continue

@@op_call:
    mov     [sOperationPtr], offset sCALL
    
@@continue:
    mov     byte ptr [sUtilBuf], '$'
    lea     di, sUtilBuf
    call    ParseAndCatWord
    
    lea     di, sOperand1Buf
    call    ParseAndCatWord

    mov     dl, ':'
    call    StringCatChar
    
    lea     si, sUtilBuf
    call    StringCat

    pop     di bx
    ret
FarAddrHook endp

OneByteOpcHook proc
    push    bx di
    mov     bl, [uInstrHistory]
    
    cmp     bl, 0C3h
    je      @@op_ret
    cmp     bl, 0CBh
    je      @@op_retf
    cmp     bl, 0CCh
    je      @@op_int
    cmp     bl, 0CEh
    je      @@op_into
    jmp     @@done

@@op_ret:
    mov     [sOperationPtr], offset sRET
    jmp     @@done

@@op_retf:
    mov     [sOperationPtr], offset sRETF
    jmp     @@done

@@op_int:
    mov     [sOperationPtr], offset sINT
    
    lea     di, sOperand1Buf
    mov     dl, '3'
    call    StringCatChar

    jmp     @@done
    
@@op_into:
    mov     [sOperationPtr], offset sINTO

@@done:    
    pop     di bx
    ret
OneByteOpcHook endp

WordOperandHook proc
    push    ax bx dx di

    mov     bl, [uInstrHistory]
    cmp     bl, 0C2h
    je      @@op_ret
    cmp     bl, 0CAh
    je      @@op_retf
    cmp     bl, 0E8h
    je      @@op_call
    cmp     bl, 0E9h
    je      @@op_jmp
    pop     di bx
    ret

@@op_ret:
    mov     [sOperationPtr], offset sRET
    jmp     @@continue

@@op_retf:
    mov     [sOperationPtr], offset sRETF
    jmp     @@continue

@@op_call:
    mov     [sOperationPtr], offset sCALL
    jmp     @@continue

@@op_jmp:
    mov     [sOperationPtr], offset sJMP

@@continue:
    lea     di, sOperand1Buf
    
    cmp     [uInstrHistory], 0E8h
    je      @@print_addr
    cmp     [uInstrHistory], 0E9h
    je      @@print_addr
    
    call    ParseAndCatWord
    jmp     @@done 

@@print_addr:
    call    ParseOneByte
    mov     dl, al
    call    ParseOneByte
    mov     ah, al
    mov     al, dl
    add     ax, [uIPValue]
    call    StringCatWord

@@done:
    pop     di dx bx ax
    ret
WordOperandHook endp

ByteOperandHook proc
    push    ax bx di

    xor     bx, bx
    mov     bl, [uInstrHistory]
    and     bl, 0F0h
    cmp     bl, 70h
    je      @@conditional_jmp
    mov     bl, [uInstrHistory]
    cmp     bl, 0E3h
    je      @@op_jcxz
    cmp     bl, 0CDh
    je      @@op_int
    cmp     bl, 0EBh
    je      @@op_jmp
    cmp     bl, 0E2h
    je      @@op_loop
    pop     di bx ax
    ret

@@conditional_jmp:
    mov     bl, [uInstrHistory]
    and     bl, 0Fh
    shl     bl, 1
    mov     ax, ConditionalJMP[bx]
    mov     [sOperationPtr], ax
    jmp     @@parse_byte

@@op_jcxz:
    mov     [sOperationPtr], offset sJCXZ
    jmp     @@parse_byte

@@op_int:
    mov     [sOperationPtr], offset sINT
    jmp     @@parse_byte

@@op_jmp:
    mov     [sOperationPtr], offset sJMP
    jmp     @@parse_byte

@@op_loop:
    mov     [sOperationPtr], offset sLOOP
    
@@parse_byte:
    lea     di, sOperand1Buf
    
    cmp     [uInstrHistory], 0CDh
    je      @@print_raw
    jmp     @@print_addr

@@print_raw:
    call    ParseAndCatByte
    jmp     @@done 

@@print_addr:
    call    ParseOneByte
    mov     bx, [uIPValue]
    cbw
    add     ax, bx
    call    StringCatWord

@@done:
    pop     di bx ax
    ret
ByteOperandHook endp

