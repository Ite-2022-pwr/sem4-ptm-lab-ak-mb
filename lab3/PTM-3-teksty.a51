ljmp start

LCDstatus  equ 0FF2EH       ; adres do odczytu gotowosci LCD
LCDcontrol equ 0FF2CH       ; adres do podania bajtu sterujacego LCD
LCDdataWR  equ 0FF2DH       ; adres do podania kodu ASCII na LCD

// bajty sterujace LCD, inne dostepne w opisie LCD na stronie WWW
#define  HOME     0x80     // put cursor to second line  
#define  INITDISP 0x38     // LCD init (8-bit mode)  
#define  HOM2     0xc0     // put cursor to second line  
#define  LCDON    0x0e     // LCD nn, cursor off, blinking off
#define  CLEAR    0x01     // LCD display clear

org 0100H
	
// deklaracje tekstów
	text1:  db "dwa",00
	text2:	db "jeden",00
	text3:	db "trzy",00
	text4:	db "siedem",00
		
// macro do wprowadzenia bajtu sterujacego na LCD
LCDcntrlWR MACRO x          ; x – parametr wywolania macra – bajt sterujacy
           LOCAL loop       ; LOCAL oznacza ze etykieta loop moze sie powtórzyc w programie
loop: MOV  DPTR,#LCDstatus  ; DPTR zaladowany adresem statusu
      MOVX A,@DPTR          ; pobranie bajtu z biezacym statusem LCD
      JB   ACC.7,loop       ; testowanie najstarszego bitu akumulatora
                            ; – wskazuje gotowosc LCD
      MOV  DPTR,#LCDcontrol ; DPTR zaladowany adresem do podania bajtu sterujacego
      MOV  A, x             ; do akumulatora trafia argument wywolania macra–bajt sterujacy
      MOVX @DPTR,A          ; bajt sterujacy podany do LCD – zadana akcja widoczna na LCD
      ENDM
	  
// macro do wypisania znaku ASCII na LCD, znak ASCII przed wywolaniem macra ma byc w A
LCDcharWR MACRO
      LOCAL tutu            ; LOCAL oznacza ze etykieta tutu moze sie powtórzyc w programie
      PUSH ACC              ; odlozenie biezacej zawartosci akumulatora na stos
tutu: MOV  DPTR,#LCDstatus  ; DPTR zaladowany adresem statusu
      MOVX A,@DPTR          ; pobranie bajtu z biezacym statusem LCD
      JB   ACC.7,tutu       ; testowanie najstarszego bitu akumulatora
                            ; – wskazuje gotowosc LCD
      MOV  DPTR,#LCDdataWR  ; DPTR zaladowany adresem do podania bajtu sterujacego
      POP  ACC              ; w akumulatorze ponownie kod ASCII znaku na LCD
      MOVX @DPTR,A          ; kod ASCII podany do LCD – znak widoczny na LCD
      ENDM
	  
// macro do inicjalizacji wyswietlacza – bez parametrów
init_LCD MACRO
         LCDcntrlWR #INITDISP ; wywolanie macra LCDcntrlWR – inicjalizacja LCD
         LCDcntrlWR #CLEAR    ; wywolanie macra LCDcntrlWR – czyszczenie LCD
         LCDcntrlWR #LCDON    ; wywolanie macra LCDcntrlWR – konfiguracja kursora
         ENDM

// funkcja opóznienia
	delay:	mov r0, #15H
	one:	mov r1, #0FFH
	dwa:	mov r2, #0FFH
    trzy:	djnz r2, trzy
			djnz r1, dwa
			djnz r0, one
			ret
			
// funkcja wypisania znaku
putcharLCD:	LCDcharWR
			ret
			
//funkcja wypisania lancucha znaków		
putstrLCD:  clr a
			movc a, @a+dptr
			jz koniec
			push dph
			push dpl
			acall putcharLCD
			pop dpl
			pop dph
			inc dptr
			sjmp putstrLCD
	koniec: ret

przycisk1:	LCDcntrlWR #CLEAR
		LCDcntrlWR #HOME
		mov dptr, #text1
		acall putstrLCD
		acall delay
		ljmp begin

przycisk2:	LCDcntrlWR #CLEAR
		LCDcntrlWR #HOME
		mov dptr, #text2
		acall putstrLCD
		acall delay
		ljmp begin

przycisk3:	LCDcntrlWR #CLEAR
		LCDcntrlWR #HOME
		mov dptr, #text3
		acall putstrLCD
		ljmp begin

przycisk4:	LCDcntrlWR #CLEAR
		LCDcntrlWR #HOME
		mov dptr, #text4
		acall putstrLCD
		acall delay
		ljmp begin

// program glówny
	start:	init_LCD
	
		begin: clr c
		mov a, p3
		subb a, #0cfh ; 1100 1111 - koniec
		jz finito
		mov a, p3
		subb a, #0dfh ; 1101 1111
		jnz omin1
	skok1:
		ljmp przycisk1
	omin1:
		mov a, p3
		subb a, #0efh ; 1110 1111
		jnz omin2
	skok2:
		ljmp przycisk2
	omin2:
		mov a, p3
		subb a, #0f7h ; 1111 0111
		jnz omin3
	skok3:
		ljmp przycisk3
	omin3:
		mov a, p3
		subb a, #0fbh ; 1111 1011
		jnz omin4
	skok4:
		ljmp przycisk4
	omin4:
		sjmp begin		
	
	finito: LCDcntrlWR #CLEAR				
	nop
	nop
	nop
	jmp $
	end start