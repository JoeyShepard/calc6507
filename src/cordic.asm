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
	INV_K:
		;1/k = 1/23.674377006269683 = 0.04223975987774335
		FCB $88, $59, $97, $23, $42, $0
	
	
	
	