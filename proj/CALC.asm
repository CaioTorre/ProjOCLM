TITLE CALCULADORA SHOW
.MODEL SMALL
.STACK 100H
.DATA
	LF		EQU 0AH
	CR		EQU 0DH
	BOUNDUP	DB "=======================================================$"
	TITULO 	DB "|                     Calculadora                     |$"
	DIGITE 	DB "|Operadores: (selecione um)                           |$"
	CMD1	DB "|  A - AND                                            |$"	;2
	CMD2	DB "|  B - OR                                             |$"	;2
	CMD3	DB "|  C - XOR                                            |$"	;2
	CMD4	DB "|  D - NOT                                            |$"	;1
	CMD5	DB "|  E - Soma                                           |$"	;2
	CMD6	DB "|  F - Subtracao                                      |$"	;2
	CMD7	DB "|  G - Multiplicacao                                  |$"	;2
	CMD8	DB "|  H - Divisao                                        |$"	;2
	CMD9	DB "|  I - Multiplicacao por 2 exp                        |$"	;1
	CMD10	DB "|  J - Divisao por 2 exp                              |$"	;1
	;CMD11	DB "|  B - Ajuda (imprimir comandos novamente)            |$"	;0
	CMD12	DB "|  X - Encerrar calculadora                           |$"	;0
	RCVOP1	DB "|Digite o primeiro valor: $"
	RCVOP2	DB "|Digite o segundo  valor: $"
	CCMD	DB 0H
	OP1		DB 0H
	OP2		DB 0H
	OPA		DB 0H
	SOOP	DB 0H
	TOADD	DB 0H
	RESUL	DB 0H
	DIVIS 	DB "|-----------------------------------------------------|$"
	DDIVIS	DB "|=====================================================|$"
	MODENT	DB "|Modos de entrada:                                    |$"
	MODOUT	DB "|Modos de saida:                                      |$"
	MOD1	DB "|  B - Binario           (0-1)                        |$"
	MOD2	DB "|  O - Octal             (0-7)                        |$"
	MOD3	DB "|  D - Decimal (DEFAULT) (0-9)                        |$"
	MOD4	DB "|  H - Hexadecimal       (0-F)                        |$"
	ERRMSG	DB "|              Valor fora dos limites                 |$"
	OFERR	DB "|          Resultado incorreto! (OVERFLOW)            |$"
	CMOD	DB 0H
	TEMP	DB 0H
	SEL1	DB "|Modo BINARIO selecionado!                            |$"
	SEL2	DB "|Modo OCTAL selecionado!                              |$"
	SEL3	DB "|Modo DECIMAL selecionado!                            |$"
	SEL4	DB "|Modo HEXADEC selecionado!                            |$"
	TEMPM	DB 0H
	MULTIB	DB 0H
	SEL		DB "|Calculando operacao $"
	I1		DB "AND                              |$"
	I2		DB "OR                               |$"
	I3		DB "XOR                              |$"
	I4		DB "NOT                              |$"
	I5		DB "Soma                             |$"
	I6		DB "Subtracao                        |$"
	I7		DB "Multiplicacao                    |$"
	I8		DB "Divisao                          |$"
	I9		DB "Multiplicacao por potencia de 2  |$"
	I10		DB "Divisao por potencia de 2        |$"
	EXMES	DB "|              Encerrando calculadora...              |$"
	CMULVAL	DB 0H
	DELFLAG	DB 0H

.CODE
BEGIN PROC
	MOV AX, @DATA
	MOV DS,AX

	LEA DX,BOUNDUP
	MOV AH,09 ;imprimir strings
	INT 21H
	
	CALL PE
	
	LEA DX,TITULO
	MOV AH,09 ;imprimir strings
	INT 21H

	CALL PE
IMPINT:
	CALL PRINTDLINE
	
	CALL PRINTMEN
	
	LEA DX,DDIVIS		;imprime linhas duplas
	MOV AH,09 
	INT 21H
	
	CALL PE

	MOV DX,03FH			;imprime interrogacao
	INT 21H
	
	MOV AH,01			;recebe comando (salva em AL)
	INT 21H				;esperar o CONFIRMA? (ENTER)
	MOV CCMD,AL

	MOV AX,3H			;limpar a tela
	INT 10H				;limpar a tela
	
	MOV OP1,0
	MOV OP1,0			;reseta os operandos
	
	MOV AL,CCMD

	;comeca a comparar o comando, verificar a operacao a ser executada
	;em algumas, salvar OP1 em OP2 e chamar GETINPUTENC de novo
	CMP AL,59H
	JB LWRC
	AND AL,0DFH ;minuscula
LWRC:
	CMP AL,58H	;X
	JE CENC	
	CMP AL,41H	;A || a
	JE CAND
	CMP AL,42H	;B || b
	JE COR
	CMP AL,43H	;C || c
	JE CXOR
	CMP AL,44H	;...
	JE CNOT
	CMP AL,45H
	JE CSUM
	CMP AL,46H
	JE CSUB
	CMP AL,47H
	JE CMUL
	CMP AL,48H
	JE CDIV
	CMP AL,49H
	JE CMU2
	CMP AL,4AH	
	JE CDV2
	
	;se nenhum comando foi achado, ele nao existe
	;imprimir erro e pedir o comando de novo
	CALL PRERR
	JMP IMPINT
CAND:
	CALL OPAND
	JMP PRRES
COR:
	CALL OPOR
	JMP PRRES
CXOR:
	CALL OPXOR
	JMP PRRES
CNOT:
	CALL OPNOT
	JMP PRRES
CSUM:
	CALL OPADD
	JMP PRRES
CSUB:
	CALL OPSUB
	JMP PRRES
CMUL:
	CALL OPMUL
	JMP PRRES
CDIV:
	CALL OPDIV
	JMP PRRES
CMU2:
	CALL OPM2E
	JMP PRRES
CDV2:
	CALL OPD2E
	JMP PRRES
CENC:
	CALL ENDCALC
PRRES:

	CALL PE
	JMP IMPINT
	
	MOV AH,4CH
	INT 21H
BEGIN ENDP

PRERR PROC	;print error
	CALL PE
	LEA DX,ERRMSG
	MOV AH,09 ;imprimir strings
	INT 21H
	CALL PE
	CALL PRINTSLINE
	RET
PRERR ENDP

PE PROC
	MOV DX,LF
	MOV AH,02
	INT 21H
	MOV DX,CR
	MOV AH,02
	INT 21H ;enter
	
	RET
PE ENDP

GETINENCOD PROC
	JMP BEINP
PRER:
	CALL PE
	CALL PRERR 
BEINP:
	MOV TEMP,AL
	
	LEA DX,MODENT
	MOV AH,09 ;imprimir strings
	INT 21H
	
	CALL PE
	CALL PRINTSLINE
	
	LEA DX,MOD1
	MOV AH,09 ;imprimir strings
	INT 21H
	
	CALL PE
	
	LEA DX,MOD2
	MOV AH,09 ;imprimir strings
	INT 21H
	
	CALL PE
	
	LEA DX,MOD3
	MOV AH,09 ;imprimir strings
	INT 21H
	
	CALL PE
	
	LEA DX,MOD4
	MOV AH,09 ;imprimir strings
	INT 21H
	
	CALL PE
	CALL PRINTSLINE
	
	MOV DX,03EH			;imprime seta
	INT 21H
	MOV AL,44H			;default comando D
	MOV TEMPM,44H
	MOV DX,03EH			;imprime seta
	INT 21H
	
ASKA:

	MOV AH,2
	MOV DX,08H			;apaga ultimo valor
	INT 21H
	MOV DX,08H			;apaga ultimo valor
	INT 21H
	MOV DX,08H			;apaga ultimo valor
	INT 21H
	MOV DX,03EH			;imprime seta
	INT 21H
	
	MOV AH,01			;recebe comando (salva em AL)
	INT 21H
	
	CMP AL,0DH
	JZ GOTMO
	MOV TEMPM,AL
	JMP ASKA
GOTMO:
	MOV AL,TEMPM
	
	CMP AL,59H
	JB BODHI
	AND AL,0DFH
BODHI:
	CMP AL,42H
	JE M1
	CMP AL,4FH
	JE M2
	CMP AL,44H
	JE M3
	CMP AL,48H
	JE M4

	JMP PRER
M1:
	MOV CMOD,AL
	LEA DX,SEL1
	MOV AH,09
	INT 21H
	CALL PE
	CALL PRINTSLINE
	JMP GOK
M2:
	MOV CMOD,AL
	LEA DX,SEL2
	MOV AH,09
	INT 21H
	CALL PE
	CALL PRINTSLINE
	JMP GOK
M3:
	MOV CMOD,AL
	LEA DX,SEL3
	MOV AH,09
	INT 21H
	CALL PE
	CALL PRINTSLINE
	JMP GOK
M4:
	MOV CMOD,AL
	LEA DX,SEL4
	MOV AH,09
	INT 21H
	CALL PE
	CALL PRINTSLINE
	JMP GOK
GOK:
	RET
GETINENCOD ENDP

GETINPUTENC PROC
BENINP:
	CMP AL,59H
	JB BODH
	AND AL,0DFH
	
BODH:
	CMP CMOD,42H
	JE CAS1IJ
	
	CMP CMOD,4FH
	JE CAS2IJ
	
	CMP CMOD,44H
	JE CAS3IJ
	
	CMP CMOD,48H
	JE CAS4I
	
	JMP IFERR
		;caso 4 HEXA
CAS4I:	
	MOV AH,2
	MOV DX,30H			;imprime zero
	INT 21H
	MOV DX,08H			;apaga ultimo valor
	INT 21H
CAS4:
		MOV CMULVAL,16
		;MOV HFLAG,0
		MOV AH,01
		INT 21H
		CMP AL,0DH
		JE JSHCT		;termina de receber o operando se receber CR
						;checar se esta fora dos limites
		CMP AL,08H
		JE CAS4DEL
		
		CMP AL,30H		;<0
		JL NIFER
		CMP AL,3AH		;0 <= X <= 9
		JL HOKN
		CMP AL,41H		;<A
		JL NIFER
		CMP AL,47H		;A <= X <= F
		JL HOKA
		CMP AL,61H		;<a
		JL NIFER
		CMP AL,67H		;a <= X <= f
		JL HOKI
		JMP NIFER
CAS1IJ:					;extensor do jump
	JMP CAS1I
	
CAS2IJ:
	JMP CAS2I
	
CAS3IJ:
	JMP CAS3I
	
HJ1:

HOKA:	SUB AL,37H		;X - "A" + 10
		JMP HOK
HOKI:	SUB AL,57H		;X - "a" + 10
		JMP HOK
HOKN:	SUB AL,30H		;X - "0"
HOK:
						;se chegou aqui, nao houveram erros de leitura
		CALL GETINPUT
		ADD OP1,AL
						
		JMP CAS2
NIFER:
	JMP CAS4CLR
JSHCT:
	JMP EXITMIMP
CAS4DEL:
	CALL DELCHARRR
	CALL SDCHAR
	JMP CAS4
CAS4CLR:
	CALL SDCHAR2
	JMP CAS4

CAS3DEL:
	CALL DELCHARRR
	CALL SDCHAR
	JMP CAS3
CAS3CLR:
	CALL SDCHAR2
	JMP CAS3

	
CAS3I:	;caso 3 DECIM
	MOV AH,2
	MOV DX,30H			;imprime zero
	INT 21H
	MOV DX,08H			;apaga ultimo valor
	INT 21H
CAS3:
		MOV CMULVAL,10
		
		MOV AH,01
		INT 21H


		CMP AL,0DH
		JZ EXITMIMPJ	;termina de receber um operando se receber CR

		CMP AL,08H		;checar se é o DEL
		JE CAS3DEL
						;checar se esta fora dos limites
		CMP AL,30H
		JB CAS3CLR
		CMP AL,39H
		JA CAS3CLR

		SUB AL,30H
		MOV TOADD,AL
						;se chegou aqui, nao houveram erros de leitura
		CALL GETINPUT
		
		;SUB AL,30H
		;ADD OP1,AL

		JMP CAS3		;receber proximo caracter
CAS2I:	;caso 2 OCT
	MOV AH,2
	MOV DX,30H			;imprime zero
	INT 21H
	MOV DX,08H			;apaga ultimo valor
	INT 21H
CAS2:
		MOV CMULVAL,8
		
		MOV AH,01
		INT 21H
		CMP AL,0DH
		JE EXITMIMPJ
						;checar se esta fora dos limites
		CMP AL,08H
		JE CAS2DEL
		
		CMP AL,30H
		JB CAS2CLR
		CMP AL,37H
		JA CAS2CLR
						;se chegou aqui, nao houveram erros de leitura
		CALL GETINPUT

		SUB AL,30H
		ADD OP1,AL		
	
		JMP CAS2
CAS2DEL:
	CALL DELCHARRR
	CALL SDCHAR
	JMP CAS2
CAS2CLR:
	CALL SDCHAR2
	JMP CAS2

IFERRJ: JMP IFERR
EXITMIMPJ: JMP EXITMIMP

CAS1I:	;caso 1 BIN
	MOV AH,2
	MOV DX,30H			;imprime zero
	INT 21H
	MOV DX,08H			;apaga ultimo valor
	INT 21H
CAS1:
		MOV CMULVAL,2
		
		MOV AH,01
		INT 21H

		CMP AL,0DH
		JE EXITMIMP
						;checar se esta fora dos limites
		CMP AL,08H
		JE CAS1DEL
		
		CMP AL,30H
		JB CAS1CLR
		CMP AL,31H
		JA CAS1CLR
						;se chegou aqui, nao houveram erros de leitura
		
		CALL GETINPUT
		
		SUB AL,30H
		ADD OP1,AL		
	
		JMP CAS1
CAS1DEL:
	CALL DELCHARRR
	CALL SDCHAR
	JMP CAS1
CAS1CLR:
	CALL SDCHAR2
	JMP CAS1
IFERR:
	CALL SDCHAR
	JMP BENINP
EXITMIMP:
	;LEA DX,DIVIS
	;MOV AH,09
	;INT 21H
	;CALL PE
	
	RET
GETINPUTENC ENDP

DELCHARRR PROC
	XOR AX,AX
	MOV AL,OP1

	XOR CX,CX
	MOV CL,CMULVAL

	DIV CL

	MOV OP1,AL

	RET
DELCHARRR ENDP

SDCHAR PROC
	MOV AH,2
	MOV DX,20H		;imprimir espaco em branco
	INT 21H
	MOV DX,8		;voltar o ponteiro
	INT 21H
	
	RET
SDCHAR ENDP

SDCHAR2 PROC
	MOV AH,2
	MOV DX,8		;voltar o ponteiro
	INT 21H
	MOV DX,20H		;imprimir espaco em branco
	INT 21H
	MOV DX,8		;voltar o ponteiro
	INT 21H
	
	RET
SDCHAR2 ENDP

TESTFOROF PROC
	JNO NOOF1
	JS NOOF1

	CALL PRINTSLINE
	LEA DX,OFERR
	MOV AH,09
	INT 21H
	CALL PE
	RET

NOOF1:
	JNC NOOF2
	JS NOOF1
	CALL PRINTSLINE
	LEA DX,OFERR
	MOV AH,09
	INT 21H
	CALL PE

NOOF2:
	RET
TESTFOROF ENDP

OPAND PROC
	CALL PRINTOPINTR
	LEA DX,I1
	MOV AH,09 ;imprimir strings
	INT 21H
	CALL PE
	CALL PRINTSLINE
	
	CALL GET2OPS
	AND BL,OP1
	CALL TESTFOROF

	MOV OP1,BL
	
	CALL OUTPUT
	RET
OPAND ENDP

OPOR PROC
	CALL PRINTOPINTR
	LEA DX,I2
	MOV AH,09 ;imprimir strings
	INT 21H
	CALL PE
	CALL PRINTSLINE
	
	CALL GET2OPS
	OR BL,OP1
	CALL TESTFOROF
	
	MOV OP1,BL
	
	CALL OUTPUT
	RET
OPOR ENDP

OPXOR PROC
	CALL PRINTOPINTR
	LEA DX,I3
	MOV AH,09 ;imprimir strings
	INT 21H
	CALL PE
	CALL PRINTSLINE
	
	CALL GET2OPS
	XOR BL,OP1
	CALL TESTFOROF
	
	MOV OP1,BL
	
	CALL OUTPUT
	RET
OPXOR ENDP

OPNOT PROC
	CALL PRINTOPINTR
	LEA DX,I4
	MOV AH,09 ;imprimir strings
	INT 21H
	CALL PE
	CALL PRINTSLINE
	
	CALL GETINENCOD
	LEA DX,RCVOP1
	MOV AH,9
	INT 21H
	CALL GETINPUTENC
	
	MOV BL,OP1
	NOT BL
	CALL TESTFOROF
	
	MOV OP1,BL
	
	CALL OUTPUT
	RET
OPNOT ENDP

OPADD PROC
	CALL PRINTOPINTR
	LEA DX,I5
	MOV AH,09 ;imprimir strings
	INT 21H
	CALL PE
	CALL PRINTSLINE
	
	CALL GET2OPS
	ADD BL,OP1
	CALL TESTFOROF
	
	MOV OP1,BL
	
	CALL OUTPUT
	RET
OPADD ENDP

OPSUB PROC
	CALL PRINTOPINTR

	LEA DX,I6
	MOV AH,09 ;imprimir strings
	INT 21H
	CALL PE
	CALL PRINTSLINE
	
	CALL GET2OPS
	
	MOV BL,OP1
	CMP OP2,BL
	JB NEGATIVO
	
	MOV BL,OP2
	SUB BL,OP1
	CALL TESTFOROF

	MOV OP1,BL
	CALL OUTPUT
	RET
	
NEGATIVO:
	MOV BL,OP1
	SUB BL,OP2
	MOV OP1,BL
	MOV OPA,1
	CALL OUTPUT
	RET
OPSUB ENDP

OPMUL PROC
	CALL PRINTOPINTR
	LEA DX,I7
	MOV AH,09 ;imprimir strings
	INT 21H
	CALL PE
	CALL PRINTSLINE

	CALL GET2OPS
	
	MOV TEMP,AL
	MOV AL,OP1 
	MOV CL,OP2
	MOV CH,0H
	MUL CL
	CALL TESTFOROF
	
	MOV OP1,AL
	MOV AL,TEMP
	
	CALL OUTPUT
	RET
OPMUL ENDP

OPDIV PROC
	CALL PRINTOPINTR
	LEA DX,I8
	MOV AH,09 ;imprimir strings
	INT 21H
	CALL PE
	CALL PRINTSLINE

	CALL GET2OPS
	CMP OP1,0
	JZ DIVER
	
	MOV TEMP,AL
	MOV AL,OP2
	XOR AH,AH
	XOR BH,BH
	MOV BL,OP1
	DIV OP1
	CALL TESTFOROF
	
	MOV OP1,AL
	MOV AL,TEMP
	
	CALL OUTPUT
	RET
	
DIVER:
	CALL PRERR
	MOV OP1,0
	CALL OUTPUT
	RET
OPDIV ENDP

OPM2E PROC
	CALL PRINTOPINTR
	LEA DX,I9
	MOV AH,09 ;imprimir strings
	INT 21H
	CALL PE
	CALL PRINTSLINE

	CALL GET2OPS
	
	MOV CL,OP1
	MOV BL,OP2
	SHL BL,CL
	CALL TESTFOROF
	
	MOV OP1,BL
	
	CALL OUTPUT
	
	RET
OPM2E ENDP

OPD2E PROC
	CALL PRINTOPINTR
	LEA DX,I9
	MOV AH,09 ;imprimir strings
	INT 21H
	CALL PE
	CALL PRINTSLINE

	CALL GET2OPS
	
	MOV CL,OP1
	MOV BL,OP2
	SHR BL,CL
	CALL TESTFOROF
	
	MOV OP1,BL
	
	CALL OUTPUT
	
	RET
OPD2E ENDP

GET2OPS PROC
	CALL GETINENCOD

	LEA DX,RCVOP1
	MOV AH,9
	INT 21H

	CALL GETINPUTENC
	MOV BL,OP1
	MOV OP2,BL
	MOV OP1,0

	LEA DX,RCVOP2
	MOV AH,9
	INT 21H

	CALL GETINPUTENC
	RET
GET2OPS ENDP

ENDCALC PROC
	LEA DX,EXMES
	MOV AH,09 ;imprimir strings
	INT 21H
	CALL PE
	CALL PRINTDLINE
	CALL PE
	
	MOV AH,4CH
	INT 21H

ENDCALC ENDP

GETINPUT PROC
	MOV TEMP,AL
	MOV AL,OP1
	MOV SOOP,AL

	XOR AX,AX
	MOV AL,OP1
	XOR CX,CX
	MOV CL,CMULVAL

	MUL CL
	JNO SAFE

	CALL SDCHAR2
	MOV AL,SOOP
	MOV OP1,AL
	MOV AL,TEMP
	RET
SAFE:
	ADD AL,TOADD
	JNC SAFE2
	
	CALL SDCHAR2
	MOV AL,SOOP
	MOV OP1,AL
	MOV AL,TEMP
	RET
SAFE2:
	MOV OP1,AL

	MOV AL,TEMP
	RET
GETINPUT ENDP

DELCHAR PROC
	MOV DELFLAG,0
	CMP AL,8
	JNE RETU
	MOV DELFLAG,1
	MOV AL,OP1 
	XOR AH,AH
	XOR BH,BH
	MOV BL,CMULVAL
	DIV BL
	MOV OP1,AL
	
	MOV AH,2
	MOV DX,20H		;imprimir espaco em branco
	INT 21H
	MOV DX,8		;voltar o ponteiro
	INT 21H
RETU:
	RET
DELCHAR ENDP

PRINTOPINTR PROC
	LEA DX,SEL
	MOV AH,09 ;imprimir strings
	INT 21H
	RET
PRINTOPINTR ENDP

PRINTSLINE PROC
	LEA DX,DIVIS
	MOV AH,09 ;imprimir strings
	INT 21H
	CALL PE
	RET
PRINTSLINE ENDP

PRINTDLINE PROC
	LEA DX,DDIVIS
	MOV AH,09 ;imprimir strings
	INT 21H
	CALL PE
	RET
PRINTDLINE ENDP

PRINTMEN PROC
	CALL PE
	
	LEA DX,DIVIS
	MOV AH,09 ;imprimir strings
	INT 21H
	
	CALL PE
	
	LEA DX,DIGITE
	MOV AH,09 ;imprimir strings
	INT 21H
	
	CALL PE
	
	LEA DX,CMD1
	MOV AH,09 ;imprimir strings
	INT 21H
	
	CALL PE
	
	LEA DX,CMD2
	MOV AH,09 ;imprimir strings
	INT 21H
	
	CALL PE
	
	LEA DX,CMD3
	MOV AH,09 ;imprimir strings
	INT 21H
	
	CALL PE
	
	LEA DX,CMD4
	MOV AH,09 ;imprimir strings
	INT 21H
	
	CALL PE
	
	LEA DX,CMD5
	MOV AH,09 ;imprimir strings
	INT 21H
	
	CALL PE
	
	LEA DX,CMD6
	MOV AH,09 ;imprimir strings
	INT 21H
	
	CALL PE
	
	LEA DX,CMD7
	MOV AH,09 ;imprimir strings
	INT 21H
	
	CALL PE
	
	LEA DX,CMD8
	MOV AH,09 ;imprimir strings
	INT 21H
	
	CALL PE
	
	LEA DX,CMD9
	MOV AH,09 ;imprimir strings
	INT 21H
	
	CALL PE
	
	LEA DX,CMD10
	MOV AH,09 ;imprimir strings
	INT 21H

	CALL PE
	
	LEA DX,CMD12
	MOV AH,09 ;imprimir strings
	INT 21H
	
	CALL PE
	
	RET
PRINTMEN ENDP

OUTPUT PROC
		CALL PRINTDLINE
		LEA DX,MODOUT
		MOV AH,09 ;imprimir strings
		INT 21H
		
		CALL PE

		CALL PRINTSLINE

		LEA DX,MOD1
		MOV AH,09 ;imprimir strings
		INT 21H
		
		CALL PE
		
		LEA DX,MOD2
		MOV AH,09 ;imprimir strings
		INT 21H
		
		CALL PE

		LEA DX,MOD3
		MOV AH,09 ;imprimir strings
		INT 21H

		CALL PE

		LEA DX,MOD4
		MOV AH,09 ;imprimir strings
		INT 21H
		
		CALL PE

		CALL PRINTSLINE

		MOV DX,03EH			;imprime seta
		INT 21H
		MOV TEMPM,44H		;default modo D
	ASKAO:
	MOV AH,2

	MOV DX,08H			;apaga ultimo valor
	INT 21H

	MOV DX,08H			;apaga ultimo valor
	INT 21H
	MOV DX,08H			;apaga ultimo valor
	INT 21H
	MOV DX,03EH			;imprime seta
	INT 21H
	
	MOV AH,01			;recebe comando (salva em AL)
	INT 21H
	
	CMP AL,0DH
	JZ GOTMOO
	MOV TEMPM,AL
	JMP ASKAO
	GOTMOO:
	
		MOV AL,TEMPM
		
		CMP AL,59H
		JB LMNO

		AND AL,0DFH			;minuscula
		
	LMNO:
		CMP AL,42H			;verifica opção digitada
		JE CASE1

		CMP AL,4FH
		JE CASE2

		CMP AL,44H
		JE CASE3

		CMP AL,48H
		JE CASE4
	
		CALL PRERR

		JMP OUTPUT

		CASE1:
		LEA DX,SEL1
		MOV AH,09 ;imprimir strings
		INT 21H
		CALL PE
		CALL PRINTDLINE
		CALL LIKE

		MOV BX,2
		JMP MAGIC

		CASE2:
		LEA DX,SEL2
		MOV AH,09 ;imprimir strings
		INT 21H
		CALL PE
		CALL PRINTDLINE
		CALL LIKE

		MOV BX,8
		JMP MAGIC

		CASE3:
		LEA DX,SEL3
		MOV AH,09 ;imprimir strings
		INT 21H
		CALL PE
		CALL PRINTDLINE
		CALL LIKE
		
		MOV BX,10
		JMP MAGIC

		CASE4:
		LEA DX,SEL4
		MOV AH,09 ;imprimir strings
		INT 21H
		CALL PE
		CALL PRINTDLINE
		CALL LIKE

		MOV BX,16
		JMP MAGIC

	MAGIC:

		CMP OPA,1
		JE DIMM

        MOV AL, OP1     ;move operador 1 para al            

        MOV CL, AL		;move al para cl 
		XOR AX,AX

        MOV AL, CL      ;retorna cl para al     

						;inicializa o contador
		XOR CX,CX

        		    	;limpa dx
		XOR DX,DX

        DVD2:   		;divide por 16
            DIV BX      ; divide ax por bx, resultado da div em ax   

            PUSH DX    	;resto fica em dx e epilha

            ADD CX, 1   ;adiciona 1 ao contador

            			;limpa dx
			XOR DX,DX

            CMP AX, 0   ;compara o resultado da div com 0

            JNE DVD2   	;se o resultado for !=0 faz a operação novamente

        GHEX:
            			;limpa DX 
			XOR DX,DX

            POP DX   	;copia o conteúdo da memória indicado por dx

            ADD DL, 30h ;adiciona 30h em dl(conteudo de dx) devido a tabela ascii   


            CMP DL, 39h	;compara

            JG MHEX	;Caso o valor ultrapassar 9 pula para função mhex para descobrir letra equivalente

        PRINTHEX:        
            MOV AH, 02h  ;imprime resultado na tela

            INT 21H

            LOOP GHEX    ;executa ghex decrementando cx até que este seja 0        

            JMP STOP	;para o programa - NAO NAO NAO NAO NAO

        MHEX:
            ADD DL, 7h	;adiciona 7 devido ao espaço entre as letras e números da tabela ascii

            JMP PRINTHEX            

        STOP:
        RET

	DIMM:
	MOV DL,2DH
	MOV AH, 02h  ;imprime resultado na tela
    INT 21H
	MOV OPA,0
	JMP MAGIC

OUTPUT ENDP

LIKE PROC
		MOV AH,2
		MOV DX,20H		;imprimir espaco em branco
		INT 21H
		MOV AH,2
		MOV DX,3DH		;imprimir sinal de igual
		INT 21H
		MOV AH,2
		MOV DX,20H		;imprimir espaco em branco
		INT 21H
	RET
LIKE ENDP

END BEGIN