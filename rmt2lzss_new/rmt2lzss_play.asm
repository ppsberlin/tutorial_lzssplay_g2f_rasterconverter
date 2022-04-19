/*
rmt2lzss_new	by PPs
started:	19.04.2022
*/

	icl 'atari.hea'

BEGIN	equ $2000				;address of first bytes
PLAYER	equ $a000				;address of LZSS player

;------------
	.zpvar	.byte	sixtyhz,count_s
;------------

	org BEGIN
;------------
	.proc ant
:12	.he 70
	.he 42
	.wo screen
	.he 41
	.wo ant
	.endp
;------------
	.proc main
	jsr hz_test
	mva #0 559
	sta.w ZPLZS.SongPtr
	sta ZPLZS.bit_data
	mwa #ant 560
	lda #7			;VBI
	ldx >vbi		;wird
	ldy <vbi		;jetzt
	jsr setvbv		;initialisiert

	mva #$40 nmien		;VBI an
	mva #34 559

	jsr init_song
	jmp *
	.endp
;------------
	.proc vbi
	mva #0 77
	jsr mukke
;Test ob Ende
	lda trig0
	beq @+
	lda trig1
	beq @+
	lda skctl
	and #$04
	beq @+
	lda consol
	and #1
	bne nixtun
@	jmp $e477	;raus
nixtun
	jmp xitvbv
	.endp
;------------
	.proc mukke
	lda sixtyhz
	beq itspal
*------ ntsc, so we have to use the counter
	lda count_s
	beq reset_count
	dec count_s
itspal
; go for the music
	jsr play_song	;play the song
	rts
reset_count
	mva #5 count_s
	rts
	.endp
;------------
	.proc hz_test
	mva #0 559
	sta count_s
	lda #7				;VBI
	ldx >vbi_i			;wird
	ldy <vbi_i			;jetzt
	jsr setvbv			;initialisiert
	mva #34 559
	mva #$40 nmien			;VBI an
;50Hz or 60 Hz?
	mva #0 vcount
@	lda vcount
	cmp #0
	beq w
	sta count_s
	jmp @-
w
	lda count_s
	cmp #$9b
	bmi ntsc
;PAL
	mva #0 sixtyhz
	sta count_s
	rts
ntsc
	mva #1 sixtyhz
	mva #0 count_s
	rts
;--------
	.local vbi_i
	jmp xitvbv
	.endl
;--------
	.endp
;------------
	.align $1000
	.proc screen
	dta d'play ',d'50Hz RMT2LZSS'*,d'files 50/60Hz + STEREO'
	.endp
;------------
	icl 'sound/play_rmt2lzss.asm'
;------------
	run main
