.org 00000h
		jmp start
.org 0003Ch
		jmp rotation							;hall sensor routine rst_7.5 
.org 00034h
		jmp timer							;timmer routine rst_6.5
.org 02000h
		.DB 057h,065h,06Ch,063h,06Fh,06Dh,065h,020h			;Welcome to
		.DB 074h,06fh,042h,069h,063h,079h,063h,06Ch			;Bicycle Computer
		.DB 065h,020h,043h,06Fh,06Dh,070h,075h,074h,065h,072h
.org 0201Ah
		.DB 041H,063H,063H,065H,06CH,02EH,020H,020H,020H,020H 		;A,c,c,e,l,'.',space(4)
		.DB 028H,06DH,02FH,073H,032H,029H  			        ;(,m,'/',s,2,) #2024
		.DB 053H,070H,065H,065H,064H,020H,020H,020H,020H,020h		;S,p,e,e,d,space(4)#202A
		.DB 028H,06DH,02FH,073H,029H,020H				;(,m,'/',s,),space#2034
.org 0203Ah
		.DB 041h,076H,067H,02EH,053H,070H,065H,065H,064H,020H		;A,v,g,'.',S,p,e,e,d,space
		.DB 028H,06DH,02FH,073H,029H,020H				;(,m,'/',s,)space #2044
		.DB 044h,069H,073H,074H,061H,06EH,063H,065H,020H,020H		;D,i,s,t,a,n,c,e,space(2)#204A
		.DB 028H,06BH,06DH,029H,020H,020H				;(,k,m,),space(2)#2054 upto 2059



start:		mvi a,0C0h
		sim
		lxi sp,08100h							;initializing stack 
		mvi e,010h
		lxi h,08020h
initcl1:	mvi m,000h
		inx h
		dcr e
		jnz initcl1
		mvi e,010h
		lxi h,08040h
initcl2:	mvi m,000h
		inx h
		dcr e
		jnz initcl2
		mvi e,020h
		lxi h,08050h
initcl3:	mvi m,000h
		inx h
		dcr e
		jnz initcl3

		lxi h,08000h							;timer zone
		mvi a,000h							;initialize timer memory 3 bytes for timer
		mov m,a								;1st-byte for sec, 2nd-byte for minute; 3rd-byte for hour
		inx h
		mov m,a	
		inx h
		mov m,a	
										;initialize these 5 locations with values 00h
										;Two are storage location for total time, one for rst 7.5 calculation ,two for time difference
 		Lxi h, 08030h 							; 8030,8031 total time
		Mvi m,000h
		Inx h
		Mvi m,000h
		Lxi h, 08035h      				          	;8035,8036 time difference
		Mvi m,000h
		Inx h
		Mvi m,000h

		

		lxi h,08009h							;button memory
		mov m,a

	
		lxi h,08011h							;memory to detect wheather the rotations start or not  
		mvi a,000h
		mov m,a
	
		dcx h								;#8010
		mov m,a

		lxi h,04020h							;2pi radius
		mvi m,019h
		inx h
		mvi m,000h
		
		mvi a,0c3h
		out 080h
		mvi a,0C5h							;load 1500 in counter
		out 085h
		mvi a,0DEh
		out 084h
		mvi a,038h							;lcd initialzation command
		out 081h
		call cmd
		mvi a,00fh
		out 081h
		call cmd
		mvi a,006h
		out 081h
		call cmd
		mvi a,001h
		out 081h
		call cmd

		mvi a,093h							;set location in lcd
		out 081h
		call cmd
	
		lxi d,02000h
		mvi b,00ah
wel:		ldax d
		out 081h
		call data
		inx d
		dcr b
		jnz wel
	
		mvi a,0d0h							;htyty
		out 081h
		call cmd

		mvi b,011h
bic:		ldax d
		out 081h
		call data
		inx d
		dcr b
		jnz bic

		mvi b,010h
shift:		mvi a,018h
		out 081h
		call cmd
		lxi d,0ff1fh
sdel:		dcr d
		jnz sdel
		dcr e
		jnz sdel
		dcr b
		jnz shift

		mvi a,05dh							;enable only rst 6.5 to get 5sec delay from timer
		sim 
		ei
del_5s:		lxi h,08000h							;delay for holding display for 5 sec
		mov a,m
		cpi 005h
		jnz del_5s
		di

		mvi a,0C9h
		sim								;enable rst_7.5,6.5
		ei
		 
main:		rim 								;button _chking
		ani 080h
		jnz main_chk
chk_again:	rim 
		ani 080h
		jz chk_again

		lxi h,08009h
		inr m
		mov a,m
		cpi 002h
		jnz main_chk

		mvi a,000h
		mov m,a				
main_chk:	lxi h,08009h							;ytrtygft
		mov a,m
		cpi 001h
		jz main2
main1:		mvi a,001H
		out 081h
		call cmd

accl:		mvi c,00Ah
		lxi h,0201Ah
acc_sent:	mov a,m
		out 081h
		call data
		inx h 
		dcr c
		jnz acc_sent

		lxi h,08011h							
		mov a,m
		ori 000h
		jnz val11

letter_1:	mvi c,006h				
		lxi h,02024h							;hfcdvx
a_lt_1_1_sent:	mov a,m
		out 081h
		call data
		inx h
		dcr c
		jnz a_lt_1_1_sent
		jmp skip2

val11:		call accncalc
		lxi h,0806dh	 
		mvi d , 004h
avp:		mov a,m
		out 081h
		call data
		dcx h
		dcr d
		jnz avp
		mvi a, 02eh
		out 081h
		call data
		lxi h, 08069h
		mov a,m
		out 081h
		call data

skip2:		mvi a,0C0h							;setting cursor to second row 
		out 081h
		call cmd		


speed:		mvi c,00Ah
		lxi h,0202Ah
sp_sent:	mov a,m
		out 081h
		call data
		inx h 
		dcr c
		jnz sp_sent

		lxi h,08011h
		mov a,m
		ori 000h
		jnz val12

letter_1_2:	mvi c,006h				
		lxi h,02034h
a_lt_1_2_sent:	mov a,m
		out 081h
		call data
		inx h
		dcr c
		jnz a_lt_1_2_sent						;sczaqsw
		jmp hold

val12:		call instcalc
		lxi h,0805dh	 
		mvi d , 004h
ivp:		mov a,m
		out 081h
		call data
		dcx h
		dcr d
		jnz ivp
		mvi a, 02eh
		out 081h
		call data
		lxi h, 08059h
		mov a,m
		out 081h
		call data
		
hold:		mvi e,0ffh
dl1:		dcr e
		jnz dl1
		mvi e,0ffh
dl2:		dcr e
		jnz dl2
		mvi e,00fh
dl3:		dcr e
		jnz dl3
		jmp main
	
main2:		mvi a,001h
		out 081h
		call cmd
	
av.spd:		mvi c,00Ah
		lxi h,0203Ah
aspd_sent:	mov a,m
		out 081h
		call data
		inx h 
		dcr c
		jnz aspd_sent

		lxi h,08011h
		mov a,m
		ori 000h
		jnz val21

letter_2_1:	mvi c,006h				
		lxi h,02044h
a_lt_2_1_sent:	mov a,m								;dsmkai
		out 081h
		call data
		inx h
		dcr c
		jnz a_lt_2_1_sent
		jmp skip3

val21:		call avscalc

		lxi h,08066h	 
		mvi d , 004h
avsp:		mov a,m
		out 081h
		call data
		dcx h
		dcr d
		jnz avsp
		mvi a, 02eh
		out 081h
		call data
		lxi h, 08062h
		mov a,m
		out 081h
		call data
	
skip3:		mvi a,0C0h							;setting cursor to second row 
		out 081h
		call cmd		

dist.:		mvi c,00Ah
		lxi h,0204Ah
dis_sent:	mov a,m
		out 081h
		call data
		inx h 
		dcr c
		jnz dis_sent
		lxi h,08011h
		mov a,m
		ori 000h
		jnz val22
letter_2_2:	mvi c,006h				
		lxi h,02054h
a_lt_2_2_sent:	mov a,m
		out 081h
		call data
		inx h
		dcr c
		jnz a_lt_2_2_sent
		jmp hold

val22:		call distcalc
		lxi h,08056h							;kaijy 
		mvi d , 004h
dvp:		mov a,m
		out 081h
		call data
		dcx h
		dcr d
		jnz dvp
		mvi a, 02eh
		out 081h
		call data
		lxi h, 08052h
		mov a,m
		out 081h
		call data
		jmp hold

cmd:		push psw
		push d
		mvi a,001h
		out 082h
		mvi a,000h
		out 082h
		mvi d,0ffh
delay2ms:	dcr d
		jnz delay2ms
		pop d
		pop psw								;aoqpo
		ret
data:		push psw
		mvi a,003h
		out 082h
		mvi a,002h
		out 082h
		pop psw
		ret
timer:		push h
		push d
		push psw
		lxi  h,08000h
		mov a,m
		cpi 005h
		jnc tt2	
		inr m
		mvi d,0ffh
t_pass:		dcr d
		jnz t_pass
		pop psw
		pop d
		pop h
		ei 
		ret
tt2:		lhld 08030h
		lxi d, 00007h 							;akiju
		dad d
		shld 08030h
		mvi d,0ffh
t_pass1:	dcr d
		jnz t_pass1
		pop psw
		pop d
		pop h
		ei 
		ret

rotation:	push h
		push psw
		push d
		push b
		lxi h,08011h							;it is a memory location which check the condition
		Inr m
		Mov a,m
		Cpi 004h
		Cz Tim1
		mvi a,043h
		out 080h
		mvi a,0c5h							;load 7second in counter
		out 085h
		mvi a,0DEh
		out 084h
		lda 08011h
		cpi 003h
		jnz new
		mvi a,043h
		out 080h							; at second rst7.5 pulse it jumps to subroutine where value gets decreased by 1    							;stop timer
		mvi a,029h							;load 7second in counter
		out 085h
		mvi a,006h
		out 084h
new:		mvi a,0c3h 
		Out 080h  							;start timer
		Lxi h,08040h
ad1: 		Mov a,m
		Cpi 0ffh
		Jz ad2
		Inr m

		Pop b
		Pop d
		Pop psw
		Pop h
		ei
		Ret
ad2:		Inx h
		Jmp ad1

Tim1:		Push psw
		Push h
		Lxi h,08011h
		Dcr m 								; this again makes value of this memory=1 hence from now whenever rst7.5 pulse comes                                                                                                                                                                        it jumps to this subroutine
		Mvi a,043h							; stop timer
		Out 080h
		In 084h
		Mov l,a
		In 025h
		Ani 03fh
		Mov h,a
		shld 08024h							; 8024 hold value of count
		call timecalc
		Pop h
		Pop psw
		ret

timecalc:	Push psw
		Push h
		Push d
		Push b
		Lxi d,02906h							; calculation of time
		Lhld 08024h
		Mov a,e
		Sub l
		Mov l,a
		Mov a,d
		Sbb h
		Mov h,a
		Shld 08026h							;required time
		Lxi b, 00000h
		Lxi d,003e8h							; 1000in decimal
		Lhld 08026h							; load time in hl
tloop2:		Mov a,l
		Sub e
		Mov l,a
		Mov a,h
		Sbb d
		Mov h,a
		Jc tloop1
		Inx b
		Jmp tloop2
tloop1:  	dad d
		Shld 0802ah
		Mov l,c
		Mov h,b
		Shld 08028h							; 16 bit time
		Lxi h,08035h
		Mov e,m
		Inx h
		Mov d,m
		Lhld 08028h
		Mov a,l
		Sub e
		Mov l,a
		Mov a,h
		Sbb d
		Mov h,a
		Shld 08035h							; time difference for inst speed
		Lxi d,00000h
		Lhld 08030h
		Xchg
		Lhld 08028h
		Dad d
		Shld 05200h							; total time
		Pop b
		Pop d
		Pop h
		Pop psw
		ret
	
distcalc:	Push psw
		Push h
		Push b
		Push d
 		Lxi h,08040h							;halo
		Mov e,m
		Inx h
ad4:		Mov a,m
		Add e
		Jnc ad3
		Inr d
ad3:		Mov e,a
		Inx h
		Mov a,l
		Cpi 00ah
		Jnz ad4
		Xchg
		Shld 04000h							; hold value of total rotation

		lhld 04020h
		mov c,l  
 		mov b,h
		lhld 04000h
		xchg
		lxi h , 00000h
next:		dad b        
		dcx d
		mov a,e
		ora d	
		jnz next
		shld 08050h    							;8050 and 6001 hold distance
		call distdisplay
		Pop d
		Pop b
		Pop h
		Pop psw
		ret


instcalc:	Push psw
		Push h
		Push b
		Push d
		Lxi b, 00000h          						; Inst_speed=2*pi*r/time	
		Lxi d, 00000h
		Lhld 08035h							; time difference is divisor
		xchg
		Lhld 04020h							; load 2*pi*r in hl
lpi2:		Mov a,l
		Sub e
		Mov l,a
		Mov a,h
		Sbb d
		Mov h,a
		Jc lpi1
		Inx b
		Jmp lpi2
lpi1: 	 	dad d
		Shld 06022h
		Mov l,c
		Mov h,b
		Shld 08057h							; 16 bit inst speed
		call ispddisplay
		Pop d
		Pop b
		Pop h
		Pop psw
		ret
avscalc:	Push psw
		Push h
		Push b
		Push d
		Lxi b, 00000h             					; Avgspd	
		Lxi d, 00000h
		Lhld  08030h							; load total time
		xchg
		Lhld 08050h							; load distance in hl
lpas2:		Mov a,l
		Sub e
		Mov l,a
		Mov a,h
		Sbb d
		Mov h,a
		Jc lpas1
		Inx b
		Jmp lpas2
lpas1: 	 	dad d
		Shld 06042h
		Mov l,c
		Mov h,b
		Shld 08060h							; 16 bit avg speed
		call aspddisplay
		Pop d
		Pop b
		Pop h
		Pop psw
		ret

accncalc:	Push psw
		Push h
		Push b
		Push d
		Lxi b, 00000h               					; Acceleration=avgspeed/total time:
		Lxi d, 00000h
		Lhld 08030h							; load total time in hl
		xchg	
		Lhld 08060h							; load avg speed in hl
lpa2:		Mov a,l
		Sub e
		Mov l,a
		Mov a,h
		Sbb d
		Mov h,a
		Jc lpa1
		Inx b
		Jmp lpa2
lpa1: 		dad d
		Shld 06062h
		Mov l,c
		Mov h,b
		Shld 08067h							; 16 bit acceleration
		call accndisplay
		Pop d
		Pop b
		Pop h
		Pop psw
		ret
distdisplay:	Lhld 08050h
		call convert
		lxi h,08052h
		mov m,a
		inx h
		mov m,e
		inx h
		mov m,d
		inx h
		mov m,c
		inx h
		mov m,b
		call ascii_cvert1
		Ret
ispddisplay:	Lhld 08057h
		call convert
		lxi h,08059h							;hjajst
		mov m,a
		inx h
		mov m,e
		inx h
		mov m,d
		inx h
		mov m,c
		inx h
		mov m,b
		call ascii_cvert2
		Ret
aspddisplay:	Lhld 08060h
		call convert
		lxi h,08062h
		mov m,a
		inx h
		mov m,e
		inx h	
		mov m,d
		inx h
		mov m,c
		inx h
		mov m,b
		call ascii_cvert3						;kasjuui
		Ret
accndisplay:	Lhld 08067h
		call convert
		lxi h,08069h
		mov m,a
		inx h
		mov m,e
		inx h
		mov m,d
		inx h
		mov m,c
		inx h
		mov m,b
		call ascii_cvert4
		Ret
convert:	Push psw
		Push b
		Push d
		Lxi b,00000h
		Lxi d,00000h
cloop:		Mov a,l
		Sui 010h
		Mov l,a
		Mov a,h
		Sbi 027h
		Mov h,a
		Jc cloop1
		Inr b
		Jmp cloop
cloop1:		mov a,l
		Adi 010h
		Mov l,a
		Mov a,h
		Aci 027h
		Mov h,a

cloop2:		Mov a,l
		Sui 0e8h
		Mov l,a
		Mov a,h
		Sbi 003h
		Mov h,a
		Jc cloop3
		Inr c
		Jmp cloop2
cloop3:	 	mov a,l
		Adi 0e8h
		Mov l,a
		Mov a,h
		Aci 003h
		Mov h,a

cloop4:		Mov a,l
		Sui 064h
		Jc cloop5
		Inr d
		Jmp cloop4
cloop5:		Adi 064h
cloop6:		Sui 00Ah
		Jc cloop7
		Inr e
		Jmp cloop6
cloop7:		Adi 00ah
		ret


ascii_cvert1:	lxi h, 08056h
		mvi c,005h
prog1:		mov a,m
		cpi 00ah
		jc lcd1
		adi 007h
lcd1:		adi 030h
		mov m,a
		dcx h
		dcr c
		jnz prog1
		ret
ascii_cvert2: 	lxi h, 0805dh
		mvi c,005h
prog2:		mov a,m
		cpi 00ah
		jc lcd2
		adi 007h
lcd2:		adi 030h
		mov m,a
		dcx h
		dcr c
		jnz prog2
		ret

ascii_cvert3:	lxi h, 08066h
		mvi c,005h
prog3:		mov a,m
		cpi 00ah
		jc lcd3
		adi 007h
lcd3:		adi 030h
		mov m,a
		dcx h
		dcr c
		jnz prog3
		ret
ascii_cvert4:	lxi h, 0806dh
		mvi c,005h
prog4:		mov a,m
		cpi 00ah
		jc lcd4
		adi 007h
lcd4:		adi 030h
		mov m,a
		dcx h
		dcr c
		jnz prog4
		ret
.end



