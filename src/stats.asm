;Memory usage stats
;==================

	FUNC stats
		CALL DebugText, "\\n\\n\\lFree zp bytes: "
		LDA #(256-ZP_end-(STACK_SIZE*OBJ_SIZE))
		STA DEBUG_DEC
		CALL DebugText,"\\n\\lFree RIOT bytes: "
		LDA #($880-RIOT_mem_end)
		STA DEBUG_DEC
		CALL DebugText,"\\n"
	END 
	