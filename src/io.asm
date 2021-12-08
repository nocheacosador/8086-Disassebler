; Prints character stored in dl register
Putc proc
    push    ax
    mov     ah, 02h
    int     21h
    pop     ax
    ret
Putc endp

; Prints string from ds:dx
Print proc 
    push    ax
    mov     ah, 09h
    int     21h
    pop     ax
    ret
Print endp

; Prints string from ds:dx with endl
Puts proc
    push    dx
    call    Print
    lea     dx, sEndl
    call    Print
    pop     dx
    ret
Puts endp

; input:
;   ds:dx - ASCIZ filename 
; return:
;   file handle in ax
OpenReadFile proc
    mov     al, 00h
    mov     ah, 3Dh
    int     21h
    jc      open_read_error
    ret
open_read_error:
    lea     dx, sErrorOpeningFile
    call    PrintErrorAndErrno
    call    Exit
    ret
OpenReadFile endp

; input:
;   ds:dx - ASCIZ filename 
; return:
;   file handle in ax
CreateFile proc
    xor     cx, cx
    mov     ah, 3Ch
    int     21h
    jc      create_error
    ret
create_error:
    lea     dx, sErrorCreatingFile
    call    PrintErrorAndErrno
    call    Exit
    ret
CreateFile endp

; file handle in BX
CloseFile proc
    mov     ah, 3Eh
    int     21h
    jc      close_error
    ret
close_error:
    lea     dx, sErrorClosingFile
    call    PrintErrorAndErrno
    ret
CloseFile endp

; input:
;   BX - file handle
;   CX - number of bytes to read
;   DS:DX - buffer for data
; return:
;   AX - bytes read
ReadFile proc
    mov     ah, 3Fh
    int     21h
    jc      read_error
    ; for debug
    ; lea     dx, sBytesRead
    ; call    Print
    ; call    PrintInt
    ; lea     dx, sEndl
    ; call    Print
    ret
read_error:
    lea     dx, sErrorReadFile
    call    PrintErrorAndErrno
    mov     ax, 0
    ret
ReadFile endp

; input:
;   BX - file handle
;   CX - number of bytes to write
;   DS:DX - buffer for data
; return:
;   AX - bytes read
WriteFile proc
    mov     ah, 40h
    int     21h
    jc      write_error
    ret
write_error:
    lea     dx, sErrorWriteFile
    call    PrintErrorAndErrno
    mov     ax, 0
    ret
WriteFile endp

; input:
;   BX - file handle
;   DL - char to write
FilePutc proc
    push    dx cx ax di

    mov     al, dl
    lea     di, sWriteBuf
    mov     byte ptr [di], dl
    lea     dx, sWriteBuf
    mov     cx, 1
    call    WriteFile
    
    pop     di ax cx dx
    ret
FilePutc endp 

; input:
;   BX - file handle
;   DS:DX - string to print
FilePrint proc
    push    di ax cx
    
    mov     di, dx
    call    StringLength
    cmp     ax, 0
    je      @@done

    mov     cx, ax
    call    WriteFile

@@done:
    pop     cx ax di
    ret
FilePrint endp