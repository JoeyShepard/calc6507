;Zero page variables
;===================

	TODO: assign unused locals space
	
	;Locals usage
	BYTE null       ;Reserve for use as null. Nothing stored here.

    LOCALS_BEGIN	$1
	LOCALS_END		$1F
	
	TODO: double check all used and move variables out of globals to here
	
	ORG $20
	;For macros
	WORD dummy
	WORD ret_val

    ;System
    BYTE keys_alpha ;Only used on hardware version!
    BYTE sys_bank   ;Only used on hardware version!

	;Temp address for variables
	WORD ret_address
	
	;Output
	WORD screen_ptr
	
	;Forth
	WORD dict_ptr
	WORD new_dict_ptr
	TODO: has to be in zero page?
	WORD dict_save
	WORD exec_ptr
	TODO: share with ret_address?
	WORD obj_address
	
	;Math
	WORD math_ptr1
	WORD math_ptr2

    TODO: one constant in const.asm
	;Don't need header byte, +1 for guard and round, +1 for exp sign
	R0: 	DFS OBJ_SIZE-TYPE_SIZE+GR_OFFSET+1
	R1: 	DFS OBJ_SIZE-TYPE_SIZE+GR_OFFSET+1
	R2: 	DFS OBJ_SIZE-TYPE_SIZE+GR_OFFSET+1
	R3: 	DFS OBJ_SIZE-TYPE_SIZE+GR_OFFSET+1
	R4: 	DFS OBJ_SIZE-TYPE_SIZE+GR_OFFSET+1
	R5: 	DFS OBJ_SIZE-TYPE_SIZE+GR_OFFSET+1
	R6: 	DFS OBJ_SIZE-TYPE_SIZE+GR_OFFSET+1
	R7: 	DFS OBJ_SIZE-TYPE_SIZE+GR_OFFSET+1
	R_ans:	DFS OBJ_SIZE-TYPE_SIZE+GR_OFFSET+1
	
	;Reg before R_ans in case double wide reg needed
	;+3 since only need 6 of 9 bytes 
	equ R_ans_wide, R7+3
	
	Regs_end:
