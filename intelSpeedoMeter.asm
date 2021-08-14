.org 00000h
	jmp start
.org 00034h
	jmp timer
.org 0003ch
	jmp rot
.org 02000h
	.DB 057h,065h,06ch,063h,06fh,06dh,065h,020h
	.DB 074h,06fh,042h,069h,063h,079h,063h,06ch
	.DB 065h,020h,043h,06fh,06dh,070h,075h,074h,065h,072h
.org 0201ah	
	.DB 41H,63H,63H,65H,6CH,2EH,20H,20H,20H,20H 	
	.DB 28H,6DH,2FH,73H,32H,29H  	
	.DB 53H,70H,65H,65H,64H,20H,20H,20H,20H,20h
	.DB 28H,6DH,2FH,73H,29H,20H
.org 0203ah
	.DB 41h,76H,67H,2EH,53H,70H,65H,65H,064H,20H			
	.DB 28H,6DH,2FH,73H,29H,20H					
	.DB 44h,69H,73H,74H,61H,6EH,63H,65H,20H,20H			
	.DB 20H,28H,6DH,29H,20H,20H
start:	mvi a,0C0h					;sod light
	sim
	lxi sp,8100h					;initializing stack pointer							
	lxi h,8034h							
	mvi c,010h
ckm1:	mvi m,000h
	inx h
	dcr c						;initializing memory location
	jnz ckm1		lxi h,0802ch
	mvi c,008h
ckm2:	mvi m,000h
	inx h
	dcr c
	jnz ckm2	
	lxi h,8045h
	mvi c,006h
ckm3:	mvi m,000h
	inx h
	dcr c
	jnz ckm3
	lxi h,08000h				;initializing timer zone								
	mvi m,001h							
	inx h
	mvi m,000h	
	inx h
	mvi m,000h	
	LXI H,08007H				;initializing time difference
	mvi m,001h
	lxi h,08003h				;initializing rotation zone 								 
	mvi m,000h				;					
	inx h
	mvi m,000h
	lxi h,8009h				;initialize bt_memory 	                         				 
	mvi m,001h
	lxi h,8011h				;flag for rotations								   
	mvi m,000h
							

	mvi a,0C5h					;load timer with 1500h								
	out 085h
	mvi a,0deh
	out 084h
	mvi a,0c3h					;start counter and initialize port as output								 
	out 080h

	mvi a,038h					;initializing lcd							
	out 081h
	call cmd
	mvi a,00ch
	out 081h
	call cmd
	mvi a,006h
	out 081h
	call cmd
	mvi a,001h
	out 081h
	call cmd

	mvi a,093h					;setting curser location								 
	out 081h
	call cmd
	
	lxi d,2000h					;writing bicycle computer in lcd
	mvi b,00ah
wel:	ldax d
	out 081h
	call data
	inx d
	dcr b
	jnz wel
       	mvi a,0d0h
	out 081h
	call cmd
	mvi b,011h
bic:	ldax d
	out 081h
	call data
	inx d
	dcr b
	jnz bic
	mvi b,010h
shift:	mvi a,018h					;shifting the mssg
	out 081h
	call cmd
	lxi d,0ff1fh
sdel:	dcr d
	jnz sdel
	dcr e
	jnz sdel
	dcr b
	jnz shift
	
	mvi a,05dh					;enable rst6.5 only							
	sim 
	ei

del_5s:	lxi h,08002h								
	mov a,m
	cpi 005h
	jc del_5s
	di
	mvi a,043h					;stop the timer
	out 080h 
	mvi a,0C9h					;enable rst 7.5 and 6.5 interrupts
	sim									
	ei
 	
main:	rim																		
	ani 080h
	jnz mainchk
chkagn:	rim
	ani 080h
	jz chkagn
	lxi h,08009h
	inr m
	mov a,m
	cpi 002h
	jnz mainchk
	mvi m,000h
	
mainchk:	lxi h,08009h
	mov a,m
	cpi 001h
	jz main2

main1:	mvi a,001H				;clear the lcd
	out 081h				;inst.speed
	call cmd
speed:	mvi c,00ah
	lxi h,202ah
spt:	mov a,m
	out 081h
	call data
	inx h 
	dcr c
	jnz spt

	lxi h,8011h
	mov a,m
	ori 000h
	jnz val12

l12:	mvi c,006h				
	lxi h,2034h
bsent:	mov a,m
	out 081h
	call data
	inx h
	dcr c
	jnz bsent
	jmp skip2

val12:	call ispd
	lxi h,8034h
	call cnvt	
	lxi h,8045h
	mov a,m			;in.spd
	adi 030h
	out 081h
	call data
	inx h
	mov a,m
	adi 030h
	out 081h
	call data
	mvi a,02eh
	out 081h
	call data
	inx h
	mov a,m
	adi 030h
	out 081h
	call data
	call cmm  

skip2:	mvi a,0C0h							 
	out 081h
	call cmd		 

accl:	mvi c,00ah				;print letters
	lxi h,201ah
act:	mov a,m
	out 081h
	call data
	inx h 
	dcr c
	jnz act
	
	lxi h,8011h				;check the flag for rotations
	mov a,m
	ori 000h
	jnz val11

leter1:	mvi c,006h				
	lxi h,2024h
asent:	mov a,m
	out 081h
	call data
	inx h
	dcr c
	jnz asent
	jmp hold

val11:  call acl
	lxi h,8040h
	call cnvt	
	lxi h,8045h
	mov a,m
	adi 030h
	out 081h
	call data		;accel
	inx h
	mov a,m
	adi 030h
	out 081h
	call data
	mvi a,02eh
	out 081h
	call data
	inx h
	mov a,m
	adi 030h
	out 081h
	call data
	call cmm	

hold:	jmp lcdhold
lcdhold:	mvi d,0ffh
lcdd1:	dcr d
	jnz lcdd1
	mvi d,0ffh
lcdd2:	dcr d
	jnz lcdd2
	mvi d,0ffh
lcdd3:	dcr d
	jnz lcdd3
	mvi d,0ffh
lcdd4:	dcr d
	jnz lcdd4

	jmp main	

main2:	mvi a,001h
	out 081h
	call cmd

dist:	mvi c,00Ah
	lxi h,0204Ah
disnt:	mov a,m
	out 081h
	call data
	inx h 
	dcr c
	jnz disnt

	lxi h,8011h
	mov a,m
	ori 000h
	jnz val22

lett22:	mvi c,006h
	lxi h,2054h
csent:	mov a,m
	out 081h
	call data
	inx h
	dcr c
	jnz csent
	jmp skip3

val22:	call dint
	lxi h,803ch
	call cnvt	
	lxi h,8045h					;accel
	mov a,m
	adi 030h
	out 081h
	call data
	inx h
	mov a,m
	adi 030h
	out 081h
	call data
	mvi a,02eh
	out 081h
	call data
	inx h
	mov a,m
	adi 030h
	out 081h
	call data
	call cmm

skip3:	mvi a,0C0h
	out 081h
	call cmd

avspd:	mvi c,00ah
	lxi h,203ah
aspdt:	mov a,m
	out 081h
	call data
	inx h 
	dcr c
	jnz aspdt

	lxi h,8011h
	mov a,m
	ori 000h
	jnz val21

lett21:	mvi c,006h				
	lxi h,2044h
a21st:	mov a,m
	out 081h
	call data
	inx h
	dcr c
	jnz a21st
	jmp hold2

val21:	call avsd
	lxi h,8038h
	call cnvt	
	lxi h,8045h
	mov a,m
	adi 030h
	out 081h
	call data
	inx h
	mov a,m
	adi 030h
	out 081h
	call data
	mvi a,02eh
	out 081h
	call data
	inx h
	mov a,m
	adi 030h
	out 081h
	call data
  	
hold2:	jmp lcdhold
cmd:	push psw
	push d
	mvi a,001h
	out 082h
	mvi a,000h
	out 082h
	mvi d,0ffh
del2ms:	dcr d
	jnz del2ms
	pop d
	pop psw
	ret
data:	push psw
	mvi a,003h
	out 082h
	mvi a,002h
	out 082h
	pop psw
	ret

rot:	push h
	push d
	push psw
	lxi h,08011h
	mov a,m
	cpi 003h
	jnc inc1
	inr m
	cpi 003h
	jz ldtimer
	pop psw
	pop d
	pop h
	ei 
	ret
ldtimer:	mvi a,0e9h				;load timer for 7 seconds interrupts
	out 085h
	mvi a,004h
	out 084h
	mvi a,0c3h					;start timer
	out 080h
	pop psw
	pop d
	pop h
	ei 
	ret
inc1:	mvi a,043h
	out 080h
	in 085h
	cma
	mov d,a
	in 084h
	cma
	mov e,a
	inx d
	lxi h,0e904h
	dad d
	shld 08023h				;time count difference
	lxi h,005dch				;dividing by 1500 to get time in seconds
	shld 08021h				
	call divide
	lhld 08027h
	inx h				;get the time in seconds 
	shld 08007h				;store that difference
	xchg					;adding with total time
	lhld 08000h
	dad d
	shld 08000h
	mvi a,0e9h				;reinitialize the counter
	out 085h
	mvi a,004h
	out 084h	
	mvi a,0c3h
	out 080h

	lhld 8003h				;count store in 2 bytes
	inx h
	shld 8003h
	pop psw
	pop d
	pop h
	ei 
	ret


timer:	push h
	push d
	push psw
	lxi h,08002h
	mov a,m
	cpi 005h
	jnc addt
	inr m
t_pas:	mvi d,0ffh
t_pass:	dcr d
	jnz t_pass
	pop psw
	pop d
	pop h
	ei 
	ret
addt:	lhld 8000h
	lxi d,0007h
	dad d
	shld 8000h
	lxi h,0015h	
	shld 8007h
 	jmp t_pas

avsd:	push h
	push b
	push d
	push psw
	lhld 803ch
	shld 802ch
	lxi h,802bh
	mvi m,00ah
	call mul
	lhld 8030h
	shld 8023h
	lhld 8000h
	shld 8021h
	call divide
	lhld 8027h
	shld 8038h
	pop psw
	pop d
	pop b
	pop h
	ret

ispd:	push h
	push d
	push b
	push psw
	lxi h,0014h								 
	shld 8023h								
	lhld 8007h								
	shld 8021h
	call divide
	lhld 8027h
	shld 8034h								
	pop psw
	pop b
	pop d
	pop h
	ret

dint:	push h							
	push d
	push b
	push psw
	lxi h,0802bh
	mvi m,002h
	lhld 8003h
	shld 802ch
	call mul
	lhld 8030h
	shld 803ch
	pop psw
	pop b
	pop d
	pop h
	ret

acl:	push h
	push b
	push d
	push psw
	lxi h,8034h
	mov b,m
	mov a,m
	lxi h,8049h
	sub m
	mov m,b
	lxi h,8040h
	mov m,a
	pop psw
	pop d
	pop b
	pop h
	ret



mul:	push h											
	push b										
	push d										
	push psw
	lxi h,0802bh
	mov a,m
	ori 000h
	jz zero
	mov e,m
	lhld 802ch								
	shld 8030h
radd:	dcr e
	jz back
	lhld 802ch
	mov c,l
	mov b,h										
	lhld 8030h
	dad b
	shld 8030h					
	jmp radd
back:	pop psw
	pop d
	pop b
	pop h
	ret
zero:   lxi h,0000h
	shld 8030h
	jmp back


divide:	push psw
	push d
	push h
	push b
	lxi b,0000h
	lhld 8023h	 
	xchg
	mov a,l
	ora h
	lhld 8021h
	mov a,h
	ora l
	jz store
	cpi 002h
	jc ais
		 
loop:	mov a,h		
	cmp d
	jz comp_lsb
	jnc store
su:	push h
	mov a,l
	cma
	mov l,a
	mov a,h
	cma
	mov h,a
	inx h
	dad d
	xchg
	pop h
	inx b
	ori 00
	jmp loop
comp_lsb:	mov a,l
	cmp e
	jz get_bc
	jc su
store:	mov h,b
	mov l,c
ais2:	shld 8027h
	pop b
	pop h
	pop d
	pop psw
	ret
get_bc:	inx b
	jmp store
ais:	lhld 8023h
	jmp ais2	

	

cnvt:	push psw
	push b
	mov a,m
	call pwrt
	pop b
	pop psw
	ret
pwrt:	lxi h,08045h
	mvi b,064h
	call binbcd
	mvi b,00ah
	call binbcd
	mov m,a
	ret
binbcd:		mvi m,0ffh
nxtbuf:		inr m
	sub b
	jnc nxtbuf
	add b
	inx h
	ret
cmm:	push h
	lxi h,8045h
	mvi m,000h
	inx h
	mvi m,000h
	inx h
	mvi m,000h
	pop h
	ret
	.end	
		
		 
