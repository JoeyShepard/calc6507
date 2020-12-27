
;Custom characters
;=================

;a - left arrow
  ;FCB $4, $C, $1C, $3C, $1C, $C, $4, $0
  ;shifted left one space
  FCB $00, $FE, $7C, $38, $10

;b - dark square bottom
  FCB $F0, $F0, $F0, $F0, $F0

;c - minus sign (todo if needed)
  FCB $00, $00, $00, $00, $00

;d - unassigned  
  FCB $FF, $FF, $FF, $FF, $FF
  
;e - exponent
  FCB $18, $2a, $2a, $2a, $1c
  
  
  
  
  
