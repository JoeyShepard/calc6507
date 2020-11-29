;Memory usage stats
;==================

	FUNC stats
		CALL DebugText, "\\n\\n\\lFree zp bytes: "
		LDA #(256-((STACK_SIZE+SYS_STACK_SIZE)*OBJ_SIZE)-Regs_end)
		STA DEBUG_DEC
		CALL DebugText,"\\n\\lFree RIOT bytes: "
		LDA #($880-RIOT_mem_end)
		STA DEBUG_DEC
		CALL DebugText,"\\n"
	END 
	