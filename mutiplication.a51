;add-shift mutiplaction
;BANK0 R0:LOWER BYTE OF MUTIPLICAND  R1:UPPER BYTE OF MUTIPLICAND R2:LOWER BYTE OF MUTIPLIER R3:UPPER BYTE OF MUTIPLIER R7:LENGTH *DON'T CHANGE*
;BANK1 R0:ADD-SHIFT PRODUCT(LOWER)	R1:ADD-SHIFT PRODUCT(UPPER)	R3: NUMBER OF ADDITIONS
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
		mov r6, a
		clr PSW.4
		clr PSW.3
		mov a, r1 
		clr PSW.4
		setb PSW.3
		mov r7, a
		clr PSW.4
		clr PSW.3 
		
addshift:	clr c
			mov b, r4
			JNB b.0, SHIFT
			clr PSW.4	;swap to bank1
			setb PSW.3
			inc r3	;increment number of additions
			mov a, r6
			add a, r0
			mov r0, a
			mov a, r7
			addc a,r1
			mov r1, a
SHIFT:		clr c
			clr PSW.4 ;swap to bank1
			setb PSW.3
			mov a, r6 ;shift mutiplicand to the left
			RLC a
			mov r6, a
			mov a, r7
			RLC a
			mov r7, a
			clr PSW.4 ;swap to bank0
			clr PSW.3
			clr c
			mov a, r4 ;shift mutiplier to the right
			RRC a
			mov r4, a
			mov a, r5
			RRC a
			mov r5, a
			DJNZ r6, addshift
			
			;add-shift ends here
			clr PSW.4 ;swap to bank1
			setb PSW.3
			
			;rest goes here
STALL: 		SJMP STALL
		end