/***************************************/
/*  Use MADS http://mads.atari8.info/  */
/*  Mode: GED- (bitmap mode)           */
/***************************************/
/*
no_name.asq adapted to get a picture plus lzss sound and scroller by PPs

find my changes with ;------- PPs mark
*/
	icl "no_name.h"

;------- PPs
PLAYER	equ $9000	;assemble sound to this address ->adapt this if it does not run
;------- PPs

	org $00

fcnt	.ds 2
fadr	.ds 2
fhlp	.ds 2
cloc	.ds 1
regA	.ds 1
regX	.ds 1
regY	.ds 1
byt2	.ds 1

zc	.ds ZCOLORS
;------- PPs
soundfinished
	.ds 1
;------- PPs

* ---	BASIC switch OFF
	org $2000\ mva #$ff portb\ rts\ ini $2000

* ---	MAIN PROGRAM
	org $2010
	IFT PIC_HEIGHT>=204
scr	ins "output.png.mic", 0, 8160
	:16 .byte 0
	ins "output.png.mic" , +8160
	ELS
scr	ins "output.png.mic"
	EIF

	.ifdef nil_used
nil	:8*40 brk
	eif

	.ALIGN $0400
;------- PPs
ant	
	:+8 dta $4e,a(scr+$0000+#*40)
	:+8 dta $4e,a(scr+$0140+#*40)
	:+8 dta $4e,a(scr+$0280+#*40)
	:+8 dta $4e,a(scr+$03C0+#*40)
	:+8 dta $4e,a(scr+$0500+#*40)
	:+8 dta $4e,a(scr+$0640+#*40)
	:+8 dta $4e,a(scr+$0780+#*40)
	:+8 dta $4e,a(scr+$08C0+#*40)
	:+8 dta $4e,a(scr+$0A00+#*40)
	:+8 dta $4e,a(scr+$0B40+#*40)
	:+8 dta $4e,a(scr+$0C80+#*40)
	:+8 dta $4e,a(scr+$0DC0+#*40)
	:+8 dta $4e,a(scr+$0F00+#*40)
	:+8 dta $4e,a(scr+$1040+#*40)
	:+8 dta $4e,a(scr+$1180+#*40)
	:+8 dta $4e,a(scr+$12C0+#*40)
	:+8 dta $4e,a(scr+$1400+#*40)
	:+8 dta $4e,a(scr+$1540+#*40)
	:+8 dta $4e,a(scr+$1680+#*40)
	:+8 dta $4e,a(scr+$17C0+#*40)
	:+8 dta $4e,a(scr+$1900+#*40)
	:+8 dta $4e,a(scr+$1A40+#*40)
	:+8 dta $4e,a(scr+$1B80+#*40)
	:+8 dta $4e,a(scr+$1CC0+#*40)
	:+1 dta $4e,a(scr+$1E00+#*40)
	.he 52
lobyte	.by <scrolltext
hibyte	.by >scrolltext

	.he 41
	.wo ant
;------- PPs
fnt

	ift USESPRITES
	.ALIGN $0800
	.ds $0300
pmg	SPRITES
	eif

main
;------- PPs
	jsr hz_test
	mva #0 soundfinished
	jsr init_song		;init sound
;------- PPs
* ---	init PMG

	ift USESPRITES
	mva >pmg pmbase		;missiles and players data address
	mva #$03 pmcntl		;enable players and missiles
	eif

	lda:cmp:req $14		;wait 1 frame

	sei			;stop interrups
	mva #$00 nmien		;stop all interrupts
	mva #$fe portb		;switch off ROM to get 16k more ram

	ZPINIT

////////////////////
// RASTER PROGRAM //
////////////////////

;	jmp line239
	jmp raster_program_end

LOOP	lda vcount		;synchronization for the first screen line
	cmp #$02
	bne LOOP

	mva #%00111110 dmactl	;set new screen width
	mva <ant dlptr
	mva >ant dlptr+1

  icl "output.png.rp.ini"

;--- wait 18 cycles
	jsr _rts
	inc byt3

;--- set global offset (23 cycles)
	jsr _rts
	cmp byt3\ pha:pla

;--- empty line
	jsr wait54cycle
	inc byt2

  icl "output.png.rp"

raster_program_end

	lda >fnt_own
	sta chbase
c0	lda #$00
	sta colbak
c1	lda #$00
	sta color0
c2	lda #$0e
	sta color1
c3	lda #$00
	sta color2
c4	lda #$00
	sta color3
s0	lda #$03
	sta sizep0
	sta sizep1
	sta sizep2
	sta sizep3
	mva #$ff sizem
	sta grafm
	mva #$20 hposm0
	mva #$28 hposm1
	mva #$d0 hposm2
	mva #$d8 hposm3
	mva #$02 pmcntl
	lda #$14
	sta gtictl
:8	sta wsync
//--------------------
//	EXIT
//--------------------
;------- PPs
	jsr scroll
	jsr mukke	;use this if your 50Hz Song should be adapted to run correct even on 60 Hz machines
	;jsr play_frame		;use this instead, if you want to play song without any adaption
;------- PPs
;------- PPs
	lda soundfinished	;was the whole sound played?
	bne stop
;------- PPs

	lda trig0		; FIRE #0
	beq stop

	lda trig1		; FIRE #1
	beq stop

	lda consol		; START
	and #1
	beq stop

	lda skctl		; ANY KEY
	and #$04
	bne skp

stop	mva #$00 pmcntl		;PMG disabled
	tax
	sta:rne hposp0,x+

	mva #$ff portb		;ROM switch on
	mva #$40 nmien		;only NMI interrupts, DLI disabled
	cli			;IRQ enabled

	rts			;return to ... DOS
skp

//--------------------
	jmp LOOP

;---

wait54cycle
	:2 inc byt2
wait44cycle
	inc byt3
	nop
wait36cycle
	inc byt3
	jsr _rts
wait18cycle
	inc byt3
_rts	rts

byt3	brk


;---
;------- PPs	
	.local mukke
	lda sixtyhz
	cmp #1
	bne itspal
*------ ntsc, so we have to use the counter
	lda count_s
	cmp #0
	beq reset_count
	dec count_s
itspal
; go for the music
	jsr play_frame
	rts
reset_count
	mva #5 count_s
	rts
;----------
count_s	.he 00
	.endl
;------- PPs

;------- PPs
	icl '../hz_test/hztest.asm'
	icl '../scroll/scroll.asm'
	icl '../sound/playlzs16_one_pokey_output.asm'
;------- PPs

;------- PPs
/*
.MACRO	ANTIC_PROGRAM
	:+8 dta $4e,a(:1+$0000+#*40)
	:+8 dta $4e,a(:1+$0140+#*40)
	:+8 dta $4e,a(:1+$0280+#*40)
	:+8 dta $4e,a(:1+$03C0+#*40)
	:+8 dta $4e,a(:1+$0500+#*40)
	:+8 dta $4e,a(:1+$0640+#*40)
	:+8 dta $4e,a(:1+$0780+#*40)
	:+8 dta $4e,a(:1+$08C0+#*40)
	:+8 dta $4e,a(:1+$0A00+#*40)
	:+8 dta $4e,a(:1+$0B40+#*40)
	:+8 dta $4e,a(:1+$0C80+#*40)
	:+8 dta $4e,a(:1+$0DC0+#*40)
	:+8 dta $4e,a(:1+$0F00+#*40)
	:+8 dta $4e,a(:1+$1040+#*40)
	:+8 dta $4e,a(:1+$1180+#*40)
	:+8 dta $4e,a(:1+$12C0+#*40)
	:+8 dta $4e,a(:1+$1400+#*40)
	:+8 dta $4e,a(:1+$1540+#*40)
	:+8 dta $4e,a(:1+$1680+#*40)
	:+8 dta $4e,a(:1+$17C0+#*40)
	:+8 dta $4e,a(:1+$1900+#*40)
	:+8 dta $4e,a(:1+$1A40+#*40)
	:+8 dta $4e,a(:1+$1B80+#*40)
	:+8 dta $4e,a(:1+$1CC0+#*40)
	:+8 dta $4e,a(:1+$1E00+#*40)
	:+4 dta $4e,a(:1+$1F40+#*40)
	:+4 dta $4e,a(:1+$1FF0+#*40)
	:+8 dta $4e,a(:1+$2090+#*40)
	:+8 dta $4e,a(:1+$21D0+#*40)
	:+8 dta $4e,a(:1+$2310+#*40)
	:+8 dta $4e,a(:1+$2450+#*40)
	dta $41,a(:2)
.ENDM
*/
;------- PPs

CL

.MACRO	ZPINIT
.ENDM

ZCOLORS	= 0

;---
	run main
;---

	opt l-

.MACRO	SPRITES
	icl "output.png.pmg"
.ENDM

USESPRITES = 1

