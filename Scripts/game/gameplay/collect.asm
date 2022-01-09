COLLECT: {


	.label Margin = 30
	.label MinX = PLAYER.MinX + Margin
	.label MaxX = PLAYER.MaxX - Margin

	.label MinY = PLAYER.MinY + Margin
	.label MaxY = PLAYER.MaxY - Margin - 50

	.label StartPointer = 33
	.label FrameTime = 4



	PosX_LSB:		.byte 0
	PosX_MSB:		.byte 0
	PosY:			.byte 0
	Frame:			.byte 0
	FrameTimer: 	.byte 0
	Delay:			.byte 10


	Collected:		.byte 0


	Reset:	{

		lda #0
		sta FrameTimer

		lda #YELLOW
		sta SpriteColor + 1

		lda MAIN.GameIsOver
		beq Okay	

		dec MAIN.GameIsOver
		rts


		Okay:

		jsr New




		rts
	}





	New: {

		lda SpriteColor + 1
		and #%01111111
		sta SpriteColor + 1

		lda #0
		sta PosX_MSB

		jsr RANDOM.Get

		clc
		adc #40
		sta PosX_LSB
		sta SpriteX + 1

		cmp #40
		bcs NoMSB

		lda SpriteColor + 1
		ora #%10000000
		sta SpriteColor + 1

		inc PosX_MSB

		NoMSB:

		jsr RANDOM.Get
		cmp #MinY
		bcc NoMSB

		cmp #MaxY
		bcs NoMSB

		sta PosY
		

		lda #0
		sta FrameTimer
		sta SpriteCopyY + 1
		sta Frame

		lda #10
		sta SpritePointer + 1
		sta SpriteY + 1

		lda #2
		sta Delay


		rts

	}


	FrameUpdate: {

		lda Delay
		beq Ready2

		dec Delay
		rts

		Ready2:

		lda PosY
		sta SpriteY + 1

		lda FrameTimer
		beq Ready

		dec FrameTimer
		jmp NotYet

		Ready:

			lda #FrameTime
			sta FrameTimer

			inc Frame
			lda Frame
			cmp #4
			bcc Okay

			lda #0
			sta Frame

		Okay:

			clc
			adc #StartPointer
			sta SpritePointer + 1

		NotYet:

		rts
	}




}