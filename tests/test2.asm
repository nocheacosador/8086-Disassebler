.model small

buferioDydis	EQU	121

BSeg SEGMENT

	ORG	100h
	ASSUME ds:BSeg, cs:BSeg, ss:BSeg

Pradzia:
;	MOV	ax, @data
;	MOV	ds, ax

	MOV	ah, 9
	MOV	dx, offset ivesk
	INT	21h

	MOV	ah, 0Ah
	MOV	dx, offset bufDydis
	INT	21h

	MOV	ah, 9
	MOV	dx, offset enteris
	INT	21h

	XOR	ch, ch
	SUB	ax, ax
	MOV	cl, nuskaite
	MOV	bx, offset buferis
	MOV	dl, 'A'
	MOV	dh, 'Z'

ciklas1:
	CMP	dl, [ds:bx]
	JG	nelygu
	CMP	dh, [ds:bx]
	JL	nelygu
	INC	ax

nelygu:
	INC	bx
	DEC	cx
	CMP	cx, 0
	JG	ciklas1

	MOV	dl, 10
	DIV	dl
	MOV	[rezult2 + 2], ah
	ADD	[rezult2 + 2], 030h
	XOR	ah, ah
	DIV	dl
	MOV	[rezult2 + 1], ah
	ADD	[rezult2 + 1], 030h
	MOV	[rezult2], al
	ADD	[rezult2], 030h

	MOV	ah, 9
	MOV	dx, offset rezult
	INT	21h

	MOV	ah, 4Ch
	MOV	al, 0
	INT	21h

	bufDydis DB  buferioDydis
	nuskaite DB  ?
	buferis	 DB  buferioDydis dup ('$')
	ivesk	 DB  'Iveskite eilute:', 13, 10, '$'
	rezult	 DB  'Radau tiek didziuju raidziu: '
	rezult2	 DB  3 dup (' ')
	enteris	 DB  13, 10, '$'
BSeg ENDS
END	Pradzia		