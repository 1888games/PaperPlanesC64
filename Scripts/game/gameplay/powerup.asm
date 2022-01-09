POWERUP: {


	.label Margin = 30
	.label MinX = PLAYER.MinX + Margin
	.label MaxX = PLAYER.MaxX - Margin

	.label MinY = PLAYER.MinY + Margin
	.label MaxY = PLAYER.MaxY - Margin - 50

	.label FirstPointer = 37
	.label FrameTime = 8



	PosX_LSB:		.byte 0
	PosX_MSB:		.byte 0
	PosY:			.byte 0
	Frame:			.byte 0
	FrameTimer: 	.byte 0
	Delay:			.byte 10


	Collected:		.byte 0
	
	PowerActive:	.byte 255

	TypeChance:		.byte POWER_SLOW, POWER_SLOW, POWER_SLOW, POWER_SLOW, POWER_DESPAWN, POWER_INVINCIBLE, POWER_INVINCIBLE, POWER_INVINCIBLE
	Type:			.byte 0
	StartPointer:	.byte 0
	TypeColour:		.byte WHITE, YELLOW, RED


	Reset:	{

		lda #0
		sta FrameTimer

		lda #YELLOW
		sta SpriteColor + 2

		lda #255
		sta PowerActive

		lda #0
		sta Collected

		lda #10
		sta SpriteY + 2
		//sta PowerActive

		//jsr New

		
		rts
	}



	Collect: {



		ldx PowerActive
		bmi Finish
		lda #1
		sta ENEMY.SlowMode, x

		lda TypeColour, x
		sta $d020

		lda #255
		sta PowerActive

		lda #200
		sta Collected

		lda #10
		sta PosY
		sta SpriteY + 2


		Finish:

		rts
	}



	New: {

		lda PowerActive
		asl
		asl
		clc
		adc #FirstPointer
		sta StartPointer

		ldx PowerActive
		lda TypeColour, x
		sta SpriteColor + 2

		lda SpriteColor + 2
		and #%01111111
		sta SpriteColor + 2

		lda #0
		sta PosX_MSB

		jsr RANDOM.Get

		clc
		adc #40
		sta PosX_LSB
		sta SpriteX + 2

		cmp #40
		bcs NoMSB

		lda SpriteColor + 2
		ora #%10000000
		sta SpriteColor + 2

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
		sta SpriteCopyY + 2
		sta Frame

		lda #10
		sta SpriteY + 2

		lda #250
		sta Delay


		rts

	}

	CheckSpawn: {

		lda Collected
		beq NotCollected

		lda ZP.Counter
		and #%00000001
		beq Finish

		dec Collected
		lda Collected
		beq TimeUp

			cmp #28
			bcs Finish

			and #%00000011
			cmp #2
			bcc Finish

			sta $d020

			sfx(SFX_WARN)

			jmp Finish

		TimeUp:

			lda ENEMY.Exit
			beq NotExit

			lda ENEMY.SpawnDelay
			sec
			sbc #50
			sta ENEMY.SpawnDelay

		NotExit:

			lda #0
			sta ENEMY.Invincible
			sta ENEMY.SlowMode
			sta ENEMY.Exit
			sta $d020

		NotCollected:
		// Try every 5 seconds

			jsr RANDOM.Get
			cmp #67
			bne Finish

			jsr RANDOM.Get
			and #%00001111
			cmp #8
			bcs Finish

			tax
			lda TypeChance, x
			sta PowerActive

			jsr New


		Finish:

			rts
	}

	EndPowerup: {

		lda #255
		sta PowerActive

		lda #10
		sta SpriteY + 2

		lda #0
		sta Collected

		rts
	}

	ProcessPowerup: {

		CheckWhetherExpired:

			lda ZP.Counter
			and #%00000011
			bne NoReduceTimer

			lda Delay
			beq ClearPowerup

			dec Delay
			jmp NoReduceTimer

		ClearPowerup:

			jmp EndPowerup

		NoReduceTimer:

			lda PosY
			sta SpriteY + 2

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
			adc StartPointer
			sta SpritePointer + 2

		NotYet:




		rts
	}

	FrameUpdate: {

		lda PLAYER.Active
		beq Finish

		lda PowerActive
		bpl ProcessPowerup

		jmp CheckSpawn


		Finish:
			

		rts
	}








}