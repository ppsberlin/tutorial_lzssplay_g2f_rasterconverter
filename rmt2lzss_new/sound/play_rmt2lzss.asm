/*
RMT2LZSS player based on rensoup and dmsc sources for DLI or VBI usage
call as often as needed to have the correct speed (e.g. 1 time/VBI for 50 or 60 Hz speed or 2 times/VBI for 100 or 120 Hz)
*/


.ifndef PLAYER				;compile to this address
PLAYER	= $9000
.endif
.ifndef POKEY
POKEY	= $d200
.endif
.ifndef POKEY2
POKEY2	= $d210
.endif

	.proc ZPLZS
/*
zero page vars
*/
	.zpvar .word SongPtr
	.zpvar .byte bit_data
	.endp

	org PLAYER
/*
vars
*/
SongIdx
	.byte 0
SongsSLOPtrs
	.byte .LO(Song0Start)
SongsSHIPtrs
	.byte .HI(Song0Start)
SongsSHIPtrs2

SongsELOPtrs
	.byte .LO(Song0End)
SongsEHIPtrs
	.byte .HI(Song0End)
/*
song
*/
Song0Start
        ins     'rhythm is a dancer.lz16'	;music file from RMT2LZSS
Song0End

/*
init once before play
*/
	.proc init_song
	jsr t_stereo
	bmi present
	mva #3 skctl			;init POKEY
	jmp w
present
	mva #3 skctl			;init POKEY
	sta skctl+16			;init 2nd POKEY
	mva #1 LZS.stereo
w	jsr SetNewSongPtrs		;call for initial song pointer
	rts
;---
t_stereo
	inc $d40e
	lda #$03
	sta $d21f
	sta $d210
	ldx #$00
	stx $d211
	inx
	stx $d21e

	ldx:rne $d40b

	stx $d219
loop	ldx $d40b
	bmi stop
	lda #$01
	bit $d20e
	bne loop

stop	lda $10
	sta $d20e
	dec $d40e

	txa
	rts
	.endp

/*
song pointer
	-SongSpeed must be 1 to work fine
*/
SongSpeed = 1// 1 = 50/60hz, 2 = 100/120hz, ..., -> 6

	.proc SetNewSongPtrs
	ldx SongIdx
	cpx #SongsSHIPtrs2-SongsSHIPtrs
	beq DontSet
	lda SongsSLOPtrs,x
	sta LZS.SongStartPtr
	lda SongsSHIPtrs,x
	sta LZS.SongStartPtr+1

	lda SongsELOPtrs,x
	sta LZS.SongEndPtr
	lda SongsEHIPtrs,x
	sta LZS.SongEndPtr+1

	inc SongIdx
DontSet
	rts
	.endp

/*
play routine
	-call this inside VBI or DLI
*/
	.proc play_song
	jsr LZSSPlayFrame
	lda LZS.stereo
	beq mono
;stereo
	jsr LZSSUpdatePokeyRegisters

w_back	jsr LZSSCheckEndOfSong
	bne Continue
	lda #0
	sta LZS.Initialized
	jsr SetNewSongPtrs
Continue
	rts
mono
	jsr LZSSUpdatePokeyRegisters_mono
	jmp w_back
	.endp
/*
needed player routine
*/
	icl "playlzs16u"