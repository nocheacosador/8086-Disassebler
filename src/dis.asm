;  Lukas Zajončkovskis
;  lukas.zajonckovskis@mif.stud.vu.lt
;  Studento pažymejmo Nr. 2110647
;  Užduotis Disassembleris

.model small
.stack 100h

_putc macro 
    call    FilePutc
endm

_print macro
    call    FilePrint
endm

.data
    sArg1           db 32 dup(0)
    sArg2           db 32 dup(0)

    hInFile         dw ?
    hOutFile        dw ?

    sWriteBuf           db 10 dup(?)
    sReadBuf            db 10 dup(?)
    uReadBufParseIndex  db 0
    uReadBufSize        db 0

    sUtilBuf            db 32 dup('$')

    sError          db 'Error: $'
    sErrno          db '(Errno: $'
    sEndl           db 0dh, 0ah, '$'
    sHelp           db 'Autorius: Lukas Zajonckovskis, I kursas, 5 grupe', 0dh, 0ah, \
                       'Usage:', 0dh, 0ah, \
                       '    dis <in> <out>      in - input file,', 0dh, 0ah, \
                       '                        out - file to write to.', 0dh, 0ah, \
                       '    dis /?              displays this message', 0dh, 0ah, '$'
    
    sErrorNoArgs         db 'No arguments provided.$'
    sErrorWrongArgCount  db 'Wrong number of arguments$'
    sErrorOpeningFile    db 'Failed to open file.$'
    sErrorReadFile       db 'Failed to read from file.$'
    sErrorWriteFile      db 'Failed to write to file.$'
    sErrorCreatingFile   db 'Failed to create file.$'
    sErrorClosingFile    db 'Failed to close file.$'
    sErrorCharToNum      db 'Could not convert character to numeric.$'

    sIntToHexSamples    db '0123456789ABCDEF'
    
    sUnknown            db 'Unknown$'
    sNone               db '$'
    sMOV                db 'mov   $'
    sPUSH               db 'push  $'
    sPOP                db 'pop   $'
    sADD                db 'add   $'
    sSUB                db 'sub   $'
    sCMP                db 'cmp   $'
    sINC                db 'inc   $'
    sDEC                db 'dec   $'
    
    sJO                 db 'jo    $'
    sJNO                db 'jno   $'
    sJNAE               db 'jnae  $'
    sJAE                db 'jae   $'
    sJE                 db 'je    $'
    sJNE                db 'jne   $'
    sJBE                db 'jbe   $'
    sJA                 db 'ja    $'
    sJS                 db 'js    $'
    sJNS                db 'jns   $'
    sJP                 db 'jp    $'
    sJNP                db 'jnp   $'
    sJL                 db 'jl    $'
    sJGE                db 'jge   $'
    sJLE                db 'jle   $'
    sJG                 db 'jg    $'

    sINT                db 'int   $'
    sJCXZ               db 'jcxz  $'
    sLOOP               db 'loop  $'
    sJMP                db 'jmp   $' 
    
    sMUL                db 'mul   $'
    sDIV                db 'div   $'
    sCALL               db 'call  $'
    
    sRET                db 'ret   $'
    sRETF               db 'retf  $'
    
    sINTO               db 'into  $'

    ConditionalJMP      dw sJO  , sJNO , sJNAE, sJAE , \
                           sJE  , sJNE , sJBE , sJA  , \ 
                           sJS  , sJNS , sJP  , sJNP , \
                           sJL  , sJGE , sJLE , sJG  

    sRegAL              db 'al$'
    sRegCL              db 'cl$'
    sRegDL              db 'dl$'
    sRegBL              db 'bl$'
    sRegAH              db 'ah$'
    sRegCH              db 'ch$'
    sRegDH              db 'dh$'
    sRegBH              db 'bh$'
    sRegAX              db 'ax$'
    sRegCX              db 'cx$'
    sRegDX              db 'dx$'
    sRegBX              db 'bx$'
    sRegSP              db 'sp$'
    sRegBP              db 'bp$'
    sRegSI              db 'si$'
    sRegDI              db 'di$'
    
    Registers           dw sRegAL, sRegCL, sRegDL, sRegBL, sRegAH, sRegCH, sRegDH, sRegBH, \
                           sRegAX, sRegCX, sRegDX, sRegBX, sRegSP, sRegBP, sRegSI, sRegDI
    
    sRegES              db 'es$'
    sRegCS              db 'cs$'
    sRegSS              db 'ss$'
    sRegDS              db 'ds$'
    
    SRegisters          dw sRegES, sRegCS, sRegSS, sRegDS

    sRegMemBXSI         db 'bx+si$'
    sRegMemBXDI         db 'bx+di$'
    sRegMemBPSI         db 'bp+si$'
    sRegMemBPDI         db 'bp+di$'
    sRegMemSI           db 'si$'
    sRegMemDI           db 'di$'
    sRegMemBP           db 'bp$'
    sRegMemBX           db 'bx$'
    
    sBytePtr            db 'BYTE PTR $'
    sWordPtr            db 'WORD PTR $'
    sDwordPtr           db 'DWORD PTR $'

    PtrCast             dw sBytePtr, sWordPtr, sDwordPtr

    RegMem              dw sRegMemBXSI, sRegMemBXDI, sRegMemBPSI, sRegMemBPDI, \
                           sRegMemSI,   sRegMemDI,   sRegMemBP,   sRegMemBX  

    include hookmap.inc
    
    uIPValue            dw 0100h
    uInstrAddress       dw ?
    uInstrHistory       db 7 dup(0)
    uInstrByteCount     db 0

    uDbit               db 0
    uSBit               db 0
    uMod                db 0
    uReg                db 0
    uRM                 db 0
    
    bW                  db 0
    bD                  db 0
    bS                  db 0

    bSegmentOverride    db 0
    uSegmentOverrideVal db 0
    
    sOperationPtr       dw sUnknown
    sOperand1Buf        db 32 dup('$')
    sOperand2Buf        db 32 dup('$')

    Operands            dw sOperand1Buf, sOperand2Buf, sOperand1Buf
    
    uDefaultRegMemFormat    dw  0001h
.code
    locals @@

Exit proc
    mov     ax, 4c00h
    int     21h
    ret
Exit endp

include io.asm
include err.asm
include hooks.asm
include str.asm

; Parses CLI argumments
ParseCliArgs proc
    push    si
    push    di
    push    ax
    push    dx

    mov     si, 80h
    mov     ax, 0
    mov     al, es:[si]
    cmp     al, 0
    je      err_no_args

find_first_char1:
    inc     si
    mov     al, es:[si]
    cmp     al, ' '
    je      find_first_char1
    
    lea     di, sArg1
copy_arg1_from_cli:
    mov     [di], al
    inc     si
    inc     di
    mov     al, es:[si]
    cmp     al, 0dh
    je      one_arg
    cmp     al, ' '
    jne     copy_arg1_from_cli
    
find_first_char2:
    inc     si
    mov     al, es:[si]
    cmp     al, ' '
    je      find_first_char2
    
    lea     di, sArg2
copy_arg2_from_cli:
    mov     [di], al
    inc     si
    inc     di
    mov     al, es:[si]
    cmp     al, 0dh
    je      parse_args_done
    cmp     al, ' '
    je      err_wrong_arg_number
    jmp     copy_arg2_from_cli

one_arg:
    lea     di, sArg1
    mov     ax, word ptr [di]
    cmp     ax, '?/'
    jne     err_wrong_arg_number

help_msg:
    lea     dx, sHelp
    call    Print
    call    Exit

err_no_args:
    lea     dx, sErrorNoArgs
    call    Puts
    lea     dx, sHelp
    call    Print
    call    Exit

err_wrong_arg_number:
    lea     dx, sErrorWrongArgCount
    call    Puts
    lea     dx, sHelp
    call    Puts
    call    Exit

parse_args_done:
    lea     di, sArg1
    mov     ax, word ptr [di]
    cmp     ax, '?/'
    je      help_msg

    pop     dx
    pop     ax
    pop     di
    pop     si
    ret
ParseCliArgs endp

; returns parsed byte in ax
; increments uIPValue
; if ax = FFFF - eof
ParseOneByte proc
    push    bx cx dx di
    mov     al, [uReadBufSize]
    cmp     al, [uReadBufParseIndex]
    jne     parse_byte_from_buffer

    mov     bx, [hInFile]
    mov     cx, 10
    lea     dx, sReadBuf    
    call    ReadFile
    mov     byte ptr [uReadBufSize], al
    mov     byte ptr [uReadBufParseIndex], 0h
    cmp     ax, 0
    jne     parse_byte_from_buffer
    mov     ax, 0FFFFh
    pop     di dx cx bx
    ret

parse_byte_from_buffer:
    xor     bx, bx
    mov     bl, [uReadBufParseIndex]
    xor     ax, ax
    lea     di, sReadBuf
    mov     al, [di + bx]
    inc     [uReadBufParseIndex]
    inc     [uIPValue]
    xor     bx, bx
    mov     bl, [uInstrByteCount]
    mov     byte ptr [uInstrHistory + bx], al
    inc     [uInstrByteCount]
    pop     di dx cx bx
    ret
ParseOneByte endp

EndParseCycle proc
    push    dx di bx
    lea     dx, sEndl
    mov     bx, [hOutFile]
    _print
    
    mov     [uInstrByteCount], 0    
    mov     [sOperationPtr], offset sUnknown
    mov     [sOperand1Buf], '$'
    mov     [sOperand2Buf], '$'
    mov     [sUtilBuf], '$'
    
    cmp     [bSegmentOverride], 0
    je      @@done 
    cmp     [bSegmentOverride], 1
    je      @@inc_bsegmentoverride
    mov     [bSegmentOverride], 0
    jmp     @@done

@@inc_bsegmentoverride:
    inc     [bSegmentOverride]
@@done:
    pop     bx di dx
    ret
EndParseCycle endp

; al - byte to _print
PrintHexByte proc
    push    ax bx dx si
    lea     si, sIntToHexSamples
    xor     ah, ah
    mov     bx, ax
    shr     bl, 4
    mov     dl, ds:[si + bx]
    mov     bx, [hOutFile]
    _putc
    mov     bx, ax
    and     bl, 0Fh
    mov     dl, ds:[si + bx]
    mov     bx, [hOutFile]
    _putc
    pop     si dx bx ax
    ret
PrintHexByte endp

; ax - word to _print
PrintHexWord proc
    push    ax
    mov     al, ah
    call    PrintHexByte
    pop     ax
    call    PrintHexByte
    ret
PrintHexWord endp

PrintOffset proc
    push    ax bx
    mov     ax, [uInstrAddress]
    call    PrintHexWord
    mov     bx, [hOutFile]
    mov     dl, ':'
    _putc
    mov     dl, 09h     ; TAB
    _putc
    pop     bx ax
    ret
PrintOffset endp

PrintInstruction proc
    push    ax bx cx dx
    mov     bx, 0
print_instr_loop:    
    mov     al, [uInstrHistory + bx]
    call    PrintHexByte
    inc     bx
    cmp     bl, [uInstrbyteCount]
    jl      print_instr_loop

    mov     cx, 10
    sub     cl, [uInstrbyteCount]
    mov     bx, [hOutFile]
    mov     dl, ' '
print_instr_loop_fill:
    _putc
    _putc
    loop    print_instr_loop_fill
    pop     dx cx bx ax
    ret
PrintInstruction endp

; parses addresing byte, sets sReg, sRM and sMod
ParseAddressingByte proc
    push    ax
    call    ParseOneByte
    and     al, 07h
    mov     [uRM], al
    mov     al, [uInstrHistory + 1]
    shr     al, 3
    and     al, 07h
    mov     [uReg], al
    mov     al, [uInstrHistory + 1]
    shr     al, 6
    mov     [uMod], al
    pop     ax
    ret
ParseAddressingByte endp

; parses word into string at ds:di (concats)
ParseAndCatWord proc
    push    ax bx dx
    call    ParseOneByte
    push    ax
    call    ParseOneByte

    xor     bx, bx
    mov     bl, al
    shr     bl, 4
    mov     dl, sIntToHexSamples[bx]
    call    StringCatChar
    mov     bl, al
    and     bl, 0Fh
    mov     dl, sIntToHexSamples[bx]
    call    StringCatChar
    
    pop     ax
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
    
    pop     dx bx ax
    ret
ParseAndCatWord endp

; parses byte into string at ds:di (concats)
ParseAndCatByte proc
    push    ax bx dx
    call    ParseOneByte
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
    pop     dx bx ax
    ret
ParseAndCatByte endp 

; ds:di - where to write dissasembled operand
DecodeReg proc
    push    di si ax bx
    xor     ax, ax
    mov     al, [bW]
    shl     al, 3   ; * 8
    add     al, [uReg]
    mov     bx, ax
    shl     bx, 1   ; * 2
    mov     si, [Registers + bx]
    call    StringCpy

    pop     bx ax si di
    ret
DecodeReg endp

; ds:di - where to write dissasembled operand
; bx - ptr type (0 - non-explicit, 1 - determine by bW, 2 - byte, 3 - word, 4 dword)
DecodeRegMem proc
    push    di si ax bx dx
    
    cmp     [uMod], 03h
    je      @@mod11

    mov     byte ptr [di], '$'
    
    cmp     bx, 0
    je      @@end_ptr_decode
    cmp     bx, 1
    je      @@determine_ptr_with_bw
    cmp     bx, 5
    jb      @@ptr_overide
    jmp     @@end_ptr_decode

@@determine_ptr_with_bw:    
    mov     bl, [bW]
    shl     bl, 1
    mov     si, PtrCast[bx]
    call    StringCat
    jmp     @@end_ptr_decode

@@ptr_overide:
    sub     bx, 2
    shl     bx, 1
    mov     si, PtrCast[bx]
    call    StringCat

@@end_ptr_decode:
    cmp     [bSegmentOverride], 0
    je      @@skip_seg_ovr
    
    mov     [bSegmentOverride], 0
    xor     bx, bx
    mov     bl, [uSegmentOverrideVal]
    shl     bl, 1
    mov     si, SRegisters[bx]
    call    StringCat
    mov     dl, ':'
    call    StringCatChar

@@skip_seg_ovr:
    mov     dl, '['
    call    StringCatChar

    cmp     [uMod], 00h
    je      @@mod00
    jmp     @@modXX
@@mod00:
    call    DecodeRegMemMod00
    jmp     @@done

@@mod11:
    call    DecodeRegMemMod11
    jmp     @@done

@@modXX:
    call    DecodeRegMemModXX

@@done:
    pop     dx bx ax si di
    ret
DecodeRegMem endp

DecodeRegMemMod00 proc
    xor     bx, bx
    mov     bl, [uRM]
    cmp     bl, 06h     ; tiesioginis adressas
    je      @@mod00_directaddr
    
    shl     bl, 1
    mov     si, RegMem[bx]
    call    StringCat
    mov     dl, ']'
    call    StringCatChar
    ret
    
@@mod00_directaddr:
    call    DecodeRegMemMod00DA 
    ret
DecodeRegMemMod00 endp

DecodeRegMemMod00DA proc 
    call    ParseOneByte
    push    ax
    call    ParseOneByte

    xor     bx, bx
    mov     bl, al
    shr     bl, 4
    mov     dl, sIntToHexSamples[bx]
    call    StringCatChar
    mov     bl, al
    and     bl, 0Fh
    mov     dl, sIntToHexSamples[bx]
    call    StringCatChar
    
    pop     ax
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

    mov     dl, ']'
    call    StringCatChar
    
    ret
DecodeRegMemMod00DA endp

DecodeRegMemMod11 proc
    xor     ax, ax
    mov     al, [bW]
    shl     al, 3   ; * 8
    add     al, [uRM]
    mov     bx, ax
    shl     bx, 1   ; * 2
    mov     si, [Registers + bx]
    call    StringCpy
    ret
DecodeRegMemMod11 endp

DecodeRegMemModXX proc
    xor     bx, bx
    mov     bl, [uRM]
    shl     bl, 1
    mov     si, RegMem[bx]
    call    StringCat
    mov     dl, '+'
    call    StringCatChar

    cmp     [uMod], 01h
    je      @@mod01
    jmp     @@mod10
@@mod01:
    call    ParseOneByte
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

    mov     dl, ']'
    call    StringCatChar
    ret
@@mod10:
    call    ParseOneByte
    push    ax
    call    ParseOneByte

    xor     bx, bx
    mov     bl, al
    shr     bl, 4
    mov     dl, sIntToHexSamples[bx]
    call    StringCatChar
    mov     bl, al
    and     bl, 0Fh
    mov     dl, sIntToHexSamples[bx]
    call    StringCatChar
    
    pop     ax
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

    mov     dl, ']'
    call    StringCatChar
    ret
DecodeRegMemModXX endp

Main:
    mov     ax, @data
    mov     ds, ax

    call    ParseCliArgs
    
    mov     ax, @data
    mov     es, ax

    lea     dx, sArg1
    call    OpenReadFile
    mov     bx, ax
    mov     [hInFile], ax

    lea     dx, sArg2
    call    CreateFile
    mov     bx, ax
    mov     [hOutFile], ax

parse_loop:
    mov     dx, [uIPValue]
    mov     [uInstrAddress], dx
    call    ParseOneByte
    cmp     ax, 0FFFFh
    je      done
    call    PrintOffset
    mov     bl, 2
    mul     bl
    mov     bx, ax
    mov     dx, word ptr HookMap[bx]
    mov     al, [uInstrHistory]
    call    dx
    
    call    PrintInstruction
    mov     bx, [hOutFile]
    mov     dx, [sOperationPtr]
    _print
    mov     dl, ' '
    _putc
    lea     dx, sOperand1Buf
    _print

    lea     di, sOperand2Buf
    call    StringLength
    cmp     ax, 0
    je      skip_second_operand

    mov     dl, ','
    _putc
    mov     dl, ' '
    _putc
    lea     dx, sOperand2Buf
    _print

skip_second_operand:
    call    EndParseCycle
    jmp     parse_loop

done:
    mov     bx, [hInFile]
    call    CloseFile

    mov     bx, [hOutFile]
    call    CloseFile
    
    call    Exit

end Main