;--��������� ���� �� ������������ �����������--



org	0
	ljmp	START		;Reset
;org	3
;	reti
;org	0bh
;	reti; ljmp	Ti0
;org	13h
;	reti
;org	1Bh
;	reti;jmp	Ti1
;org	23h
;	reti

ORG 	30h

MEM0	ds	1; ������ ������ ��� �������� ������
MEM1	ds	1
MEM2	ds	1
MEM3	ds	1
MEM4	ds	1
MEM5	ds	1
MEM6	ds	1
MEM7	ds	1
MEM8	ds	1

MEM10	ds	1	; ������� � ��-��� ����
MEM11	ds	1	; ������ � ��-��� ����
MEM12	ds	1	; ���� � ��-��� ����
;	������� �������-�������
;	������� �������-�������

HRD	ds	1	; ���� � ������ ����
MIND	ds	1	; ������ � ������ ����

DHRV	ds	1	; ��� ����� ����� ������ �� �����
HRV	ds	1
DMINV	ds	1
MINV	ds	1

DHR	ds	1	; ������� �����
HR	ds	1	; ���� �����
DMin	ds	1	; ������� ���
Min	ds	1	; ���� �����

Mcikl	ds	1	; ������ ��� ������� 0
Sec	ds	1	; ������� �� ������� 0
Razr	ds	1	; ��������� ������
cikl	EQU	020h	; ��� ���� 1 ���
Tlicht	EQU	0Fh	; ���� ��������� �������

maxcntH	EQU	080h	;} ���� 0,5 ���
maxcntL	EQU	080h	;}

scl		equ		P1.6 ; P1.7
sda		equ		P1.7 ; P1.6

Y0	EQU	07DH;  ���� ����� ��� ����������
Y1	EQU	011H;
Y2	EQU	03EH
Y3	EQU	037H
Y4	EQU	053H
Y5	EQU	067H
Y6	EQU	06FH
Y7	EQU	031H
Y8	EQU	07FH
Y9	EQU	077H


ORG 	70h

START:	mov	p0,  #0FFh;
	mov	p1,  #0h;
	mov	p2,  #0h;
	mov	p3,  #0FFh;

	MOV	MEM12,	#012h;	12
	MOV	MEM11,	#034h;	34
	mov	Sec,	#0h
	mov	Razr,	#0h

	CALL	U	; ������ �����
	call	ti3
;		mov	R4,#01H	;	������ �����
;		call	read_rtc
		jmp	VYV2;	VYV1

;------�������� ���������� �� ������-------------
;-------������ ������� �� ds 1307------------------------
VYVtime:	mov	R4,#01H	;	������ �����
		call	read_rtc
		cjne	A,MEM1,VYV1 ; ���������� ������?-������ ���?
		jmp	M4;	VYVE

VYV1:		mov	MEM1,A	; ��� ��� �������� ����� � ��-��� ����
		mov	MEM11,A

VYV2:		MOV	R4,#02H	;	������ �����
		CALL	read_rtc
		mov	MEM12,A	; �������� ����� � ��-��� ����

;VYV2:
		mov	A,MEM11 ; ���������� ��-��� ���� min
		ANL	A,#70H  ;  �� ������� � �������
		SWAP	A	;	0-3  <---->  4-7
		mov	DMin,A	; ������� �����
		mov	A,MEM11
		ANL	A,#0FH
		mov	Min,A	; ������� �����

		mov	A,MEM12 ; ���������� ��-��� ���� �����
		ANL	A,#30H  ;  �� ������� � �������
		SWAP	A	;	0-3  <---->  4-7
		mov	DHR,A	; ������� �����
		mov	A,MEM12
		ANL	A,#0FH
		mov	HR,A	; ������� �����

		mov	A,DHR	; ������� ����� � ������ ���
		MOV	B,#10	;(������������� ����� ������) 
		MUL	AB
		ADD	A,HR
		MOV	HRD,A	; 

		mov	A,DMin	; ������� ����� � ������ ���
		MOV	B,#10
		MUL	AB
		ADD	A,Min
		MOV	MIND,A	; ������ ����� ������

;--�������� � ��� ������ �� ���������-------

N2:	MOV	A,Min
	call	S
	MOV	MINV,	A; ��� � �� ��� ��� ��� ������ ���

	MOV	A,DMin
	call	S
	MOV	DMINV,	A; ��� � �� ��� ��� ��� ��� ���

	MOV	A,HR
	call	S
	mov	HRV,	A

	MOV	A,DHR
	call	S
	MOV	DHRV,	A

M4:	CALL	VYV
	call	ti3

	JB	P0.1,M5 ; ���� �� ������ ������ �����-������ ��������
	jmp	UMIN	; ���� ������ ������ �����-���������
M5:	JB	P0.0,M6 ; ���� �� ������ ������ �����-������
	jmp	UHR	; ���� ������ ������ �����-���������
M6:	ljmp	VYVtime

;-------������������ ��������� ��������------------
VYV:	push	psw
	xch	A,Razr
	inc	A
	cjne	A,#1,V2
V1:	mov	P2,	MINV
	setb	P3.3
	clr	p3.0
	jmp	VE
V2:	cjne	A,#2,V3
	mov	P2,	DMINV
	setb	P3.0
	clr	p3.1
	jmp	VE
V3:	cjne	A,#3,V4
	mov	P2,	HRV
	setb	P3.1
	clr	p3.2
	jmp	VE
V4:	mov	P2,	DHRV
	setb	P3.2
	clr	p3.3
	mov	A,#0
VE:	xch	A,Razr
	pop	psw
	ret

;---------------�/� ��������--
ti3:	mov	MEM8, #01Fh;
	djnz	MEM8,  $;
	ret

;--------������ ���� ����� ��� ��� �� �����----
S:	CJNE	A,#0,S1
	mov	A,#07Dh; Y0
	jmp	SE
S1:	CJNE	A,#1,S2
	mov	A,#011h; Y1
	jmp	SE
S2:	CJNE	A,#2,S3
	mov	A,#03Eh; Y2
	jmp	SE
S3:	CJNE	A,#3,S4
	mov	A,#037h; Y3
	jmp	SE
S4:	CJNE	A,#4,S5
	mov	A,#053h; Y4
	jmp	SE
S5:	CJNE	A,#5,S6
	mov	A,#067h; Y5
	jmp	SE
S6:	CJNE	A,#6,S7
	mov	A,#06Fh; Y6
	jmp	SE
S7:	CJNE	A,#7,S8
	mov	A,#031h; Y7
	jmp	SE
S8:	CJNE	A,#8,S9
	mov	A,#07Fh; Y8
	jmp	SE
S9:	mov	A,#077h; Y9

SE:	ret

;---��������� �������-������� �����--------
U:		mov	R4,#0		;> ��� ������� �����
		mov	R5,#0		;>
		CALL	write_rtc	;>

		mov	R4,#7		;> ��� ������� 1 ��
		mov	R5,#10h		;>
		CALL	write_rtc	;>
	RET

;-------<��������� �������>-----------------------------------
;----------<��������� �����>-------------------------------
UHR:		JNB	P0.1,U1 ; ���� ������ ������ �����-������
		JB	P0.0,U1	; ���� �� ������ ������ �����-������

		mov	R4,#0H	;	������ ������
		call	read_rtc
		cjne	A,MEM0,U11	; ���������� �������?-������ ���?

U1:		jmp	M4	;UE

U11:		mov	MEM0,A	; ��� ��� �������� ���

		mov	R4,#02H	;	������ �����
		call	read_rtc
		mov	MEM2,A	; �������� ����� � ��-��� ����

;            ��������� �������� ����� ����� ������
		ANL	A,#30H	; �������� ������� � �������
		SWAP	A	;	0-3  <---->  4-7
		mov	DHR,A
		mov	A,MEM2
		ANL	A,#0FH
		mov	HR,A

		mov	A,DHR	; ������� ����� � ������ ���
		MOV	B,#10	;(������������� ����� ������) 
		MUL	AB
		ADD	A,HR
		MOV	HRD,A	; 
		INC	A	; ������ ���� �� 1
		CJNE	A,#24,U12
		MOV	MEM2,#0
		JMP	U13
U12:		mov	HRD,A	; �������� ������� 
		MOV	B,#10	;	     � ������� �����
		DIV	AB
		MOV	DHR,A	; ������� �����
		MOV	HR,B	; ������� �����
		SWAP	A	;  0-3  <---->  4-7
		ORL	A,B
		MOV	MEM2,A	; ����� � ��-��� ���� � ����� �����
		mov	MEM12,A

U13:		MOV	R4,#02H
		MOV	R5,MEM2
		CALL	write_rtc
		call	ti3
		jmp   VYV2	;VYVtime	; ����� �������



;--------------<��������� �����>----------------------
UMIN:		jb	P0.1,U2	; ���� �� ������ ������ �����-������
		jnb	P0.0,U2 ; ���� ������ ������ �����-������

		mov	R4,#0H	;	������ ������
		call	read_rtc
		cjne	A,MEM0,U21 ; ���������� �������?-������ ���?

U2:		jmp	M4	; UMIN

U21:		MOV	MEM0,A	; ��� ��� �������� ���

		mov	R4,#01H	;	������ �����
		call	read_rtc
		mov	MEM1,A	; �������� ����� � ��-��� ����

;            ��������� �������� ����� ����� ������
		ANL	A,#70H	; �������� ������� � �������
		SWAP	A	;	0-3  <---->  4-7
		mov	DMin,A	; ������� �����
		mov	A,MEM1
		ANL	A,#0FH
		mov	Min,A	; ������� �����

		mov	A,DMin	; ������� ����� � ������ ���
		MOV	B,#10
		MUL	AB
		ADD	A,Min
		MOV	MIND,A	; ������ ����� ������
		INC	A		; ������ ������ �� 1
		CJNE	A,#60,U22
		MOV	MEM1,#0
		JMP	U23
U22:		mov	MIND,A	; ��� ��� �������� ����� ����� ������
		MOV	B,#10	; ������� � ��-��� ���
		DIV	AB
		MOV	DMin,A
		MOV	Min,B
		SWAP	A	;   0-3  <---->  4-7
		ORL	A,B
		MOV	MEM1,A	; ����� � ��-��� ���� � ����� �����
		mov	MEM11,A

U23:		MOV	R4,#01H
		MOV	R5,MEM1
		CALL	write_rtc
U24:		jmp   VYV2	;VYVtime	; ����� �������

;	RET

;---------��� ds1307---------------------------------
; scl		equ		P2.6
; sda		equ		P2.7
start_cond:	setb	scl
		nop
		nop
		nop
		setb	sda
		nop
		nop
		nop
		clr	sda
		nop
		nop
		nop
		clr	scl
		ret
;-----------------------------------------------------
stop_cond:	clr	sda
		setb	scl
		nop
		nop
		nop
		setb	sda
;		nop
;		nop
;		nop
;		clr	scl
;		clr	sda
		ret
;------------------------------------------------------	
wr_mode:	PUSH	6	
		mov	R6,#8
wr_mode1:	rlc	a
		mov	sda,c
		setb	scl
		nop
		nop
		nop
		clr	scl
		djnz	R6,wr_mode1
		setb	sda
		mov	R6,#2
		setb	scl

wr_mode2:	jnb	sda,wr_mode3
		djnz	R6,wr_mode2	
		clr	scl
		nop
		call	stop_cond
		jmp	wr_mode_end;error

wr_mode3:	nop
		nop
		clr	scl
		nop
		clr	c
wr_mode_end:
		POP	6
		ret
;------------------------------------------------------	
rd_mode:	PUSH	6
		setb	sda
		mov	R6,#8
rd_mode1:	nop	
		setb	scl
		mov	c,sda
		rlc	a
		nop
		clr	scl
		nop
		djnz	R6,rd_mode1
		nop
		mov	sda,c
		setb	scl
		nop
		nop
		nop
		nop
		clr	scl
		setb	sda
		POP	6
		ret
;-------------------------------------------------------
;in	r4-address r5-data
write_rtc:	call	start_cond;������ RTC
		mov	a,#0d0h
		call	wr_mode
		mov	a,r4;address
		call	wr_mode
		mov	a,r5;data
		call	wr_mode
		call	stop_cond
		ret

;------------------------------------------------------
;ir r4-address
read_rtc:	call	start_cond;������ RTC
		mov	a,#0d0h
		call	wr_mode
		mov	a,r4;address
		call	wr_mode
		call	start_cond
		mov	a,#0d1h
		call	wr_mode		
		mov	a,#1;not acknol
		call	rd_mode
		call	stop_cond
		ret

	end

;====================================================================================
;************************************************************
;--------------------------------------------------
TIM:	MOV   TMOD,#21H  	; ������ 0 � ��� 1 , ������ 1 � ������ 2
	mov	TH0,#maxcntH
	mov	TL0,#maxcntL
	mov	TH1,Tlicht	; ���� ��������� ������� ���
	mov	Mcikl,cikl		; #cikl 
	mov	IE,#8Ah  	; ��������� ���������� �� ������ 0 � 1
	MOV   IP,#2     	; ��������� ������� 0
	setb	TCON.4		; �������� ������ 0
	setb	TCON.6		; �������� ������ 1
 	RET

;-------------���������� ���������� �� ������� 0-----
Ti0:	push	PSW
	mov	MEM3,A
	mov	MEM4,B
;	clr	TCON.6		; �������� ������ 1
	clr	TCON.4		; TR0=0 �������� ������ 0
	mov	TH0,#maxcntH
	mov	TL0,#maxcntL
	setb	TCON.4		; TR0=1 �������� ������ 0
	djnz	Mcikl,Ti01
	inc	Sec
	mov	Mcikl,cikl		; #cikl 
;	setb	TCON.6		; �������� ������ 1
;	cpl	P3.0		; ���. 10
Ti01:	mov	A,MEM3
	mov	B,MEM4
	pop	PSW
;	cpl	P3.1		; ���. 11
	reti

;-------------���������� ���������� �� ������� 1-----
;Ti1:	push	PSW
 	mov	MEM5,A
 	mov	MEM6,B
	clr	TCON.6		; TR0=0 �������� ������ 1
	CALL	VYV
	setb	TCON.6		; TR0=1 �������� ������ 1
;	cpl	P3.0		; ���. 10
	mov	A,MEM5
	mov	B,MEM6
	pop	PSW
;	cpl	P3.1		; ���. 11
	reti

;-----------------��� ds1307-------------------------------------------------------
;Time:

;UMIN:		jb	P0.1,UE	;  <��������� �����>
;		jnb	P0.0,UE


;VMIN:		mov	R4,#01H	;	������ �����
;		call	read_rtc
;		cjne	A,MEM1,U21 ; ���������� ������?-������ ���?
;		jmp	VMIN

;U21:		mov	MEM1,A	; ��� ��� �������� ����� � ��-��� ����
;		mov	MEM11,A	; Min

;		MOV	R4,#02H ; ������ ��� � ��-��� ����
;		CALL	read_rtc;  � ��� � MEM12
;		mov	MEM12,A	; HR

;		mov	A,MEM11 ; ���������� ��-��� ���� min
;		ANL	A,#70H  ;  �� ������� � �������
;		SWAP	A	;	0-3  <---->  4-7
;		mov	DMin,A
;		mov	A,MEM11 ; �.�. �������� �������
;		ANL	A,#0FH  ;                � �������
;		mov	Min,A   ; ��� ������ �� ���������

;		mov	A,MEM12 ; HR ����
;		ANL	A,#30H
;		SWAP	A	;	0-3  <---->  4-7
;		mov	DHR,A
;		mov	A,MEM12
;		ANL	A,#0FH
;		mov	HR,A



;---��������� �������---
U:		mov	R4,#0		;> ��� ������� �����
		mov	R5,#0		;>
		CALL	write_rtc	;>

		mov	R4,#7		;> ��� ������� 1 ��
		mov	R5,#10h		;>
		CALL	write_rtc	;>
	RET

;-----------------------------------------------------
UHR:		JNB	P0.1,U1
		JB	P0.0,U1	; <��������� �����>

		mov	R4,#0H	;	������ ������
		call	read_rtc
		cjne	A,MEM0,U11	; ���������� �������?-������ ���?
		jmp	UHR
U1:		jmp	UE

U11:		mov	MEM0,A	; ��� ��� �������� ���

		mov	R4,#02H	;	������ �����
		call	read_rtc
		mov	MEM2,A	; �������� ����� � ��-��� ����

;            ��������� �������� ����� ����� ������
		ANL	A,#30H	; �������� ������� � �������
		SWAP	A	;	0-3  <---->  4-7
		mov	DHR,A
		mov	A,MEM2
		ANL	A,#0FH
		mov	HR,A

		mov	A,DHR	; ������� ����� � ������ ���
		MOV	B,#10	;(������������� ����� ������) 
		MUL	AB
		ADD	A,HR
		MOV	HRD,A	; 
		INC	A	; ������ ���� �� 1
		CJNE	A,#24,U12
		MOV	MEM2,#0
		JMP	U13
U12:		mov	HRD,A	; �������� ������� 
		MOV	B,#10	;	     � ������� �����
		DIV	AB
		MOV	DHR,A	; ������� �����
		MOV	HR,B	; ������� �����
		SWAP	A	;  0-3  <---->  4-7
		ORL	A,B
		MOV	MEM2,A	; ����� � ��-��� ���� � ����� �����

U13:		MOV	R4,#02H
		MOV	R5,MEM2
		CALL	write_rtc
		CALL   VYVtime	; ����� �������
		jmp	UHR



UMIN:		jb	P0.1,UE	;  <��������� �����>
		jnb	P0.0,UE
		mov	R4,#0H	;	������ ������
		call	read_rtc
		cjne	A,MEM0,U21 ; ���������� �������?-������ ���?
		jmp	UMIN

U21:		MOV	MEM0,A	; ��� ��� �������� ���

		mov	R4,#01H	;	������ �����
		call	read_rtc
		mov	MEM1,A	; �������� ����� � ��-��� ����

;            ��������� �������� ����� ����� ������
		ANL	A,#70H	; �������� ������� � �������
		SWAP	A	;	0-3  <---->  4-7
		mov	DMin,A	; ������� �����
		mov	A,MEM1
		ANL	A,#0FH
		mov	Min,A	; ������� �����

		mov	A,DMin	; ������� ����� � ������ ���
		MOV	B,#10
		MUL	AB
		ADD	A,Min
		MOV	MIND,A	; ������ ����� ������
		INC	A		; ������ ������ �� 1
		CJNE	A,#60,U22
		MOV	MEM1,#0
		JMP	U23
U22:		mov	MIND,A	; ��� ��� �������� ����� ����� ������
		MOV	B,#10	; ������� � ��-��� ���
		DIV	AB
		MOV	DMin,A
		MOV	Min,B
		SWAP	A	;   0-3  <---->  4-7
		ORL	A,B
		MOV	MEM1,A	; ����� � ��-��� ���� � ����� �����

U23:		MOV	R4,#01H
		MOV	R5,MEM1
		CALL	write_rtc
U24:		CALL   VYVtime	; ����� �������
		jmp	UMIN

UE:		mov	R6,#20H	;   ����� 8 ��������
		call	VYV1

	RET

;------�������� ���������� �� ������-------------
;-------������ ������� �� ds 1307------------------------
VYVtime:
;		MOV	R4,#0H	; M6 ����� �������
;		CALL	read_rtc
;		mov	MEM10,A	; Sec

		mov	R4,#01H	;	������ �����
		call	read_rtc
		cjne	A,MEM1,VYV1 ; ���������� ������?-������ ���?
		jmp	M4;	VYVE

VYV1:		mov	MEM1,A	; ��� ��� �������� ����� � ��-��� ����
		mov	MEM11,A	; Min

		MOV	R4,#02H
		CALL	read_rtc
		mov	MEM12,A	; HR

;		mov	A,MEM10
;		ANL	A,#70H
;		SWAP	A	;	0-3  <---->  4-7
;		mov	DSec,A
;		mov	A,MEM10
;		ANL	A,#0FH
;		mov	Sec,A

		mov	A,MEM11
		ANL	A,#70H
		SWAP	A	;	0-3  <---->  4-7
		mov	DMin,A
		mov	A,MEM11
		ANL	A,#0FH
		mov	Min,A

		mov	A,MEM12
		ANL	A,#30H
		SWAP	A	;	0-3  <---->  4-7
		mov	DHR,A
		mov	A,MEM12
		ANL	A,#0FH
		mov	HR,A

VYVE:	ret


;--------------------------------------------------
;TIM:	MOV   TMOD,#51H  	; ������ 0 � ��� 1 , ������� 1 � ������ 1
;	mov	TH0,#maxcntH	;} ���� 0,5 ���
;	mov	TL0,#maxcntL	;}
;	MOV   IE,#82H   	; ��������� ���������� �� ������� 0
;	MOV   IP,#2     		; ��������� ������� 0
;	mov	R3,cikl		; #cikl 
;	setb	TCON.4		; �������� ������ 0
;	setb	TCON.6		; �������� ������� 1
;	RET

;-----------------------------------------------------------
;Ti0: 	mov	MEM5,A	; ���������� ���������� �� ������� 0
;	clr	TCON.4		; TR0=0 �������� ������ 0
;	mov	TH0,#maxcntH
;	mov	TL0,#maxcntL
;	setb	TCON.4		; TR0=1 �������� ������ 0
;	djnz	R3,Ti01
;	clr	TCON.4		; TR0=0 �������� ������ 0
;	clr	TCON.6		; �������� ������� 1
;	mov	COL1,TL1
;	mov	COL2,TH1
;	CALL	TA
;	mov	TL1,#0
;	mov	TH1,#0
;	mov	TH0,#maxcntH
;	mov	TL0,#maxcntL
;	mov	R3,cikl		; #cikl 
;	setb	TCON.4		; TR0=1 �������� ������ 0
;	setb	TCON.6		; �������� ������� 1
;	cpl	P3.0		; ���. 10
;Ti01:	mov	A,MEM5
;	cpl	P3.1		; ���. 11
;	reti


;------------------------------------------------------------------
; scl		equ		P2.6
; sda		equ		P2.7
start_cond:	setb	scl
		nop
		nop
		nop
		setb	sda
		nop
		nop
		nop
		clr	sda
		nop
		nop
		nop
		clr	scl
		ret
;------------------------------------------------------------------
stop_cond:	clr	sda
		setb	scl
		nop
		nop
		nop
		setb	sda
;		nop
;		nop
;		nop
;		clr	scl
;		clr	sda
		ret
;-------------------------------------------------------------------		
wr_mode:	PUSH	6	
		mov	R6,#8
wr_mode1:	rlc	a
		mov	sda,c
		setb	scl
		nop
		nop
		nop
		clr	scl
		djnz	R6,wr_mode1
		setb	sda
		mov	R6,#2
		setb	scl

wr_mode2:	jnb	sda,wr_mode3
		djnz	R6,wr_mode2	
		clr	scl
		nop
		call	stop_cond
		jmp	wr_mode_end;error

wr_mode3:	nop
		nop
		clr	scl
		nop
		clr	c
wr_mode_end:
		POP	6
		ret
;------------------------------------------------------------------		
rd_mode:	PUSH	6
		setb	sda
		mov	R6,#8
rd_mode1:	nop	
		setb	scl
		mov	c,sda
		rlc	a
		nop
		clr	scl
		nop
		djnz	R6,rd_mode1
		nop
		mov	sda,c
		setb	scl
		nop
		nop
		nop
		nop
		clr	scl
		setb	sda
		POP	6
		ret
;--------------------------------------------------------------------		
;in	r4-address r5-data
write_rtc:	call	start_cond;������ RTC
		mov	a,#0d0h
		call	wr_mode
		mov	a,r4;address
		call	wr_mode
		mov	a,r5;data
		call	wr_mode
		call	stop_cond
		ret
;----��������� �������, ��������� � TABLE_2--------		
;in	r4-address r5-data
write_rtc1:	call	start_cond;������ RTC
		mov	a,#0d0h
		call	wr_mode
		MOV	A,#0H	;		mov	a,r4;address
		call	wr_mode

                MOV     DPTR,#TABLE_2
                MOV     R7,#8
W1:         MOV     A,#0
                MOVC    A,@A+DPTR
		call	wr_mode
                 INC     DPTR
                DJNZ    R7,W1
;		mov	a,r5;data
;		call	wr_mode
		call	stop_cond
		ret
;---------------------------------------------------------------------
;ir r4-address
read_rtc:	call	start_cond;������ RTC
		mov	a,#0d0h
		call	wr_mode
		mov	a,r4;address
		call	wr_mode
		call	start_cond
		mov	a,#0d1h
		call	wr_mode		
		mov	a,#1;not acknol
		call	rd_mode
		call	stop_cond
		ret



;NUM:	mov	r0,	#Y0
	jz	N2
N1:	inc	r0
	dec	a
	jnz	N1
N2:	ret

;PP3:	setb	p0.6;
	clr	p0.7
	setb	p3.7
	ret

;--------------------------
Tabl:	DB	07DH,011H,03EH,037H,053H,067H,06FH,031H,07FH,077H

***********	
---------------
	mov	A,HRD	; �������� ������� 
	MOV	B,#10	;	    � ������� �����
	DIV	AB
	MOV	DHR,A	; ������� �����
	MOV	HR,B	; ������� �����
	mov	A,MIND	; �������� �������
	MOV	B,#10	;      � ������� �����
	DIV	AB	;
	MOV	DMin,A	;
	MOV	Min,B	;
	jmp	N2
M:	ljmp	M4

N1:	mov	A,Sec
	cjne	A,#60,M
	mov	A,#0
	mov	Sec,A
	inc	MIND
	mov	A,MIND
	cjne	A,#60,SU12
	mov	A,#0
	mov	MIND,A
	inc	HRD
	mov	A,HRD
	cjne	A,#24,SU12
	mov	A,#0
	mov	HRD,A

;------------------------------------------------
SU12:		mov	A,HRD	; �������� ������� 
		MOV	B,#10	;	    � ������� �����
		DIV	AB
		MOV	DHR,A	; ������� �����
		MOV	HR,B	; ������� �����

SU22:		mov	A,MIND	; �������� �������
		MOV	B,#10	;      � ������� �����
		DIV	AB
		MOV	DMin,A
		MOV	Min,B

;			MOV	DHR,#1 ;������� �����
;			MOV	HR,#2	; ������� �����
;			MOV	DMin,#3
;			MOV	Min,#4
