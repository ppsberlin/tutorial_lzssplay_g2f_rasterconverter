	.proc scroll
;------------------------------------------------------------------------------
; simple scroll routine
; set shscrol to 7 if graphics 1 or two
; set it to 4, if graphics 0
;------------------------------------------------------------------------------
	lda shscrol
	bpl set
	inc lobyte
	bne nohigh
	inc hibyte

; now check if shscrol has to be reset (change the value here too, to match your scrollers gfx mode)
nohigh	lda #4

	sta shscrol
	lda lobyte
	cmp <scrolltext.endtext
	bne set
	lda hibyte
	cmp >scrolltext.endtext
	bne set
	mwa <scrolltext lobyte
	mva >scrolltext hibyte
set
	mva shscrol $d404	;-> set this into DLI on correct line might be better: mva scroll.shscrol $d404
	dec shscrol
	rts
;----------
shscrol 	dta 4
	.endp
;-----------------------------------------------------------
; now font and the scrolltext

	.align $0400
	.proc fnt_own
	ins 'SNOKIE.FNT'
	.endp

	.align $1000
; the star at the end gives "invers" char.
	.proc scrolltext
	dta d'                                '
	dta d'Hello this is a small example '
	dta d'HOW TO add'*
	dta d' scroller and lzss sound '
	dta d'to g2f or rasterconverter graphics'
	dta d'               ...--- stay ',d'ATARI'*,d'!!! ---...                     greets PPs'
endtext
	dta d'                    '
	.endp
;------------------------------------------------------------