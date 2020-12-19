
;Custom characters
;=================

;a - left arrow
  ;FCB $4, $C, $1C, $3C, $1C, $C, $4, $0
  ;shifted left one space
  FCB $10, $38, $7C, $FE, $00

;b - dark square bottom
  FCB $F0, $F0, $F0, $F0, $F0

;c - minus sign (todo if needed)
  FCB $00, $00, $00, $00, $00

;d - unassigned  
  FCB $FF, $FF, $FF, $FF, $FF
  
;e - exponent
  FCB $1c, $2a, $2a, $2a, $18
  
  
  
  
  
