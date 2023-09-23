
;Custom characters
;=================

;a - left arrow
  ;FCB $4, $C, $1C, $3C, $1C, $C, $4, $0
  ;shifted left one space
  ;FCB $00, $FE, $7C, $38, $10
  FCB $08, $1C, $3E, $7F, $00

;b - dark square bottom
  ;FCB $F0, $F0, $F0, $F0, $F0
  FCB $0F, $0F, $0F, $0F, $0F

;c - minus sign (todo if needed)
  FCB $00, $00, $00, $00, $00

;d - store arrow
  ;FCB $10, $38, $7C, $FE, $00	;mirror of left arrow
  ;FCB $10, $38, $7C, $FE, $38	;mirror of left arrow with stem
  ;FCB $10, $38, $54, $92, $10	;single line outline
  FCB $08, $49, $2A, $1C, $08   ;single line outline
  
;e - exponent
  ;FCB $18, $2a, $2a, $2a, $1c
  FCB $18, $54, $54, $54, $38
  
  
  
  
