	.zpvar .byte sixtyhz
	.proc hz_test ;tests if the machine runs at 50 or 60 Hz
	mva #0 559
	sta c
	sta 710
	mva #10 709
	mwa #ant_scr 560
	lda #7
	ldx >vbi_i
	ldy <vbi_i
	jsr $e45c	;setvbv
	mva #34 559
	mva #$40 nmien	;VBI on
;50Hz or 60 Hz?
	mva #0 vcount
@	lda vcount
	cmp #0
	beq w
	sta c
	jmp @-
w
	lda c
	cmp #$9b
	bmi ntsc
;--- Pal
	mva #0 sixtyhz
	rts
ntsc
	mva #1 sixtyhz
	rts
;----------
	.local ant_scr
	.he 41
	dta a(ant_scr)
	.endl
;----------
	.local vbi_i
	jmp $e462
	.endl
;----------
c	.he 00
	.endp