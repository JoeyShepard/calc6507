;CORDIC routines for transcendentals
;===================================

;for atan, f(x)=x at some point
;what size table? seems tiny numbers could need huge table
;could also do fixed point but code larger?
;no need for GR if not shifting
;interesting that sin(0.01) and sin(0.001) on HP-48 produces 12 digits. sin(0.000001)=0.000001

;For now, table assumes xx.yy yy yy yy yy fixed point
;ACTUALLY x.y if radians!!!

;limiting it to above xx.y10 is TINY table
;intermediates at least will need larger range, so need full precision
;also, see if above tiny format will work for atan as well as tan
;	TWO DIFFERENT TABLES!
;	tan 89.999 is 57k :(
;	tan 89.9999999999 is 12 digit integer
;	could use large table of floats then determine what can be cut
;	actually, look at algorithm since may be possible to generate huge tan with shifts
;	look at hp-35 page - example table seems especially large tbh
;
;btw, figured out how to - then + division 


	;Constants
	;=========
	CORDIC_SIGN =			1
	
	CORDIC_CMP_Y =			0
	CORDIC_CMP_Z =			1
	CORDIC_CMP_MASK =		1
	CORDIC_ADD_Y =			0
	CORDIC_SUB_Y =			2
	CORDIC_ADD_MASK =		2
	CORDIC_HALF =			4
	CORDIC_HALF_MASK =		4
	
	INV_K:
		;1/k = 1/23.674377006269683 = 0.04223975987774335
		FCB $88, $59, $97, $23, $42, $0
	
	;Leading zero simplifies logic below
	ATAN_TABLE:
		FCB $40, $63, $81, $39, $85, $07, $00
		FCB $49, $52, $86, $66, $99, $00, $00
		FCB $69, $66, $96, $99, $09, $00, $00
		FCB $67, $99, $99, $99, $00, $00, $00
		FCB $00, $00, $00, $10, $00, $00, $00
		FCB $00, $00, $00, $01, $00, $00, $00
		FCB $00, $00, $10, $00, $00, $00, $00
		FCB $00, $00, $01, $00, $00, $00, $00
		FCB $00, $10, $00, $00, $00, $00, $00
		FCB $00, $01, $00, $00, $00, $00, $00
		FCB $10, $00, $00, $00, $00, $00, $00
		FCB $01, $00, $00, $00, $00, $00, $00
	
	ATAN_ROWS = 	12
	ATAN_WIDTH =	7
	
	;Functions
	;=========
	
	;Flags in A
	FUNC BCD_CORDIC
		
		TAY
		AND #CORDIC_CMP_MASK
		STA math_a
		TYA
		AND #CORDIC_ADD_MASK
		STA math_signs
		TYA
		AND #CORDIC_HALF_MASK
		STA math_b
	
		TODO: push status word?
		SED
	
		halt
		
		MOV.W #ATAN_TABLE, ret_address
		LDA #ATAN_ROWS
		STA math_c
		.loop_outer:
			TODO: magic number
			LDA #9
			STA math_d
			.loop_inner:
				LDA math_a
				BEQ .compare_y
				.compare_z:
					;if z positive, sub table from z
					;if z negative, add table to z
					LDX #ATAN_WIDTH
					LDY #0
					LDA R2+DEC_COUNT/2
					BNE .z_negative
					.z_positive:
						SEC
						.z_sub_loop:
							LDA R2,Y
							SBC (ret_address),Y
							STA R2,Y
							INY
							DEX
							BNE .z_sub_loop
							BEQ .z_comp_done
					.z_negative:
						CLC
						.z_add_loop:
							LDA R2,Y
							ADC (ret_address),Y
							STA R2,Y
							INY
							DEX
							BNE .z_add_loop
					.z_comp_done:
					DEC math_d
					BNE .compare_z
					BEQ .compare_done
				.compare_y:
					TODO: compare Y
					halt
				.compare_done:
				
			halt
				
			LDA ret_address
			CLC
			CLD
			ADC #ATAN_WIDTH
			SED
			STA ret_address
			BCC .no_inc
				INC ret_address+1
			.no_inc:

			DEC math_c
			BNE .loop_outer
			
			halt
			
		CLD
	
	END
	