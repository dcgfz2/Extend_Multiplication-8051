;BANK0 R0:LOWER BYTE OF MUTIPLICAND  R1:UPPER BYTE OF MUTIPLICAND R2:LOWER BYTE OF MUTIPLIER R3:UPPER BYTE OF MUTIPLIER R6:LENGTH COPY (USE THIS TO COUNT DOWN) R7:LENGTH *DON'T CHANGE*
;BANK1 R0:ADD-SHIFT PRODUCT(LOWER)	R1:ADD-SHIFT PRODUCT(MIDDLE) R2::ADD-SHIFT PRODUCT(UPPER) R3: NUMBER OF ADDITIONS R4:LOWER TIMER VALUE R5:UPPER TIMER VALUE
;USE BANK2/3 FOR BOOTHS
		org 0000h
		;input1
		mov a,#0FFh  
		mov P1,a
		mov a, P1	;take input from p1
		mov r0, a	;store value as lower byte
		
		mov a,#0FFh
		mov P2,a
		mov a, P2	;take input from p2
		mov r1, a	;store value as upper byte
		
		;input 2
		mov a,#0FFh  
		mov P1,a
		mov a, P1	;take input from p1
		mov r2, a	;store value as lower byte input2
		
		mov a,#0FFh
		mov P2,a
		mov a, P2	;take input from p2
		mov r3, a	;store value as upper byte input2
		
		;get length
		mov a,#0FFh  
		mov P1,a
		mov a, P1	;take input from p1
		mov r7, a	;store value for length 
		mov r6, a	;copy of length for deincrementing
		
		mov a, r2
		mov r4, a  ;copy mutiplier to other registers
		mov a, r3
		mov r5,	a
		
		;start of add-shift
		mov a, r0 ;copy mutiplicand to bank1
		clr PSW.4
		setb PSW.3
		mov r5, a
		clr PSW.4
		clr PSW.3
		mov a, r1 
		clr PSW.4
		setb PSW.3
		mov r6, a
		clr PSW.4
		clr PSW.3 
		
		mov TL0, #00H ;clear timer0
		mov TH0, #00H
		mov TMOD, #09H ;set timer0 to mode 1 
		setb TR0 ;start timer0
		
addshift:	clr c
			mov b, r4
			JNB b.0, SHIFT
			clr PSW.4	;swap to bank1
			setb PSW.3
			inc r3	;increment number of additions
			mov a, r5
			add a, r0
			mov r0, a
			mov a, r6
			addc a,r1
			mov r1, a
			mov a, r7
			addc a,r2
			mov r2,a
SHIFT:		clr c
			clr PSW.4 ;swap to bank1
			setb PSW.3
			mov a, r5 ;shift mutiplicand to the left
			RLC a
			mov r5, a
			mov a, r6
			RLC a
			mov r6, a
			mov a, r7
			RLC a
			mov r7, a
			clr PSW.4 ;swap to bank0
			clr PSW.3
			clr c
			mov a, r5 ;shift mutiplier to the right
			RRC a
			mov r5, a
			mov a, r4
			RRC a
			mov r4, a
			DJNZ r6, addshift
			
			CLR TR0 ;stop timer
			clr PSW.4 ;swap to bank1
			setb PSW.3
			mov r4, TL0 ;load timer values into register
			mov r5, TH0
			
			;add-shift ends here
			;set-up for booths
			mov TL0, #00H ;clear timer0
			mov TH0, #00H
			clr PSW.4 ;swap to bank0
			clr PSW.3
			mov a, r7
			mov r6, a ;reset counter
			mov a, r2
			mov r4, a  
			mov a, r3
			mov r5,	a ;reset mutiplier
			
			mov a, r4
			setb PSW.4 ;swap to bank2
			clr PSW.3
			mov r0,a
			clr PSW.4 ;swap to bank0
			clr PSW.3
			mov a,r5
			setb PSW.4 ;swap to bank2
			clr PSW.3
			mov r1,a ;move mutiplier into product registers
			clr c
			mov a, r0
			RLC a
			mov r0,a
			mov a,r1
			RLC a
			mov r1,a ;shift mutiplier to the left 1 bit
			
			clr PSW.4 ;swap to bank0
			clr PSW.3
			mov a, r0
			setb PSW.4 ;swap to bank2
			clr PSW.3
			mov r6, a
			clr PSW.4 ;swap to bank0
			clr PSW.3
			mov a, r1
			setb PSW.4 ;swap to bank2
			clr PSW.3
			mov r7, a
			; booths starts here
			setb TR0 ;start timer0
			
booths:		setb PSW.4 ;swap to bank2
			clr PSW.3
			clr c
			mov b,r0
			JNB b.0, zero
			JB b.1, shiftb ;shift if 11
			inc r3 			;since 01 add shift
			mov a,r1
			add a, r6
			mov r2, a
			mov a, r2
			addc a, r7
			mov r2, a
			ljmp shiftb
zero:		JNB b.1, shiftb ;shift if 00
			inc r4			;since 10 sub shift
			mov a,r1
			subb a, r6
			mov r2, a
			mov a, r2
			subb a, r7
			mov r2, a
shiftb:		clr c
			mov a, r2
			RR a
			mov r2,a
			mov a, r1
			RRC a
			mov r1, a
			mov a, r0
			RRC a
			mov r0, a
			clr PSW.4 ;swap to bank0
			clr PSW.3
			DJNZ r6, booths
			
			CLR TR0 ;stop timer
			setb PSW.4 ;swap to bank2
			clr PSW.3
			mov r5, TL0 ;load timer values into register
			mov r6, TH0
			clr PSW.4
			setb PSW.3
			mov a,r0
			setb PSW.4
			clr PSW.3
			mov r0,a
			clr PSW.4
			setb PSW.3
			mov a,r1
			setb PSW.4
			clr PSW.3
			mov r1,a
			clr PSW.4
			setb PSW.3
			mov a,r2
			setb PSW.4
			clr PSW.3
			mov r2,a
			mov r7, #00H
		
STALL: 		SJMP STALL
		end