;EEPROM banking
;==============
;Jumps from one bank to another should use BCALL which the optimizer
;will translate into a jump in the fixed bank which pushes the
;existing bank, sets the new bank and JSRs to the desired target.
;RTS from there goes back to fixed bank which pulls and restores
;bank then returns.

banking_begin:

;BCALL support
;=============

;Count of table entries to check for mismatch
    SET Bank1TrampolineCount,0
    SET Bank1IDCount,0
    SET Bank1TableCount,0
    SET Bank2TrampolineCount,0
    SET Bank2IDCount,0
    SET Bank2TableCount,0
    SET Bank3TrampolineCount,0
    SET Bank3IDCount,0
    SET Bank3TableCount,0
    SET Bank4TrampolineCount,0
    SET Bank4IDCount,0
    SET Bank4TableCount,0

;Macros
BFUNC MACRO funcname
__funcname_BANK_JUMP LABEL *
    IFNDEF ID_counter
        SET ID_counter,0
    ENDIF
    STY bank_temp_Y     ;Save Y in case used to pass args
    LDY #ID_counter     ;ID for called function
    SET ID_counter, ID_counter+1
    JMP ProcessBankJump

    IF banknum==1
        SET Bank1TrampolineCount,Bank1TrampolineCount+1
    ELSEIF banknum==2
        SET Bank2TrampolineCount,Bank2TrampolineCount+1
    ELSEIF banknum==3
        SET Bank3TrampolineCount,Bank3TrampolineCount+1
    ELSEIF banknum==4
        SET Bank4TrampolineCount,Bank4TrampolineCount+1
    ENDIF

    ENDM

BANK_ID MACRO funcname
    ;funcname not used but shows what ID was laid down for
    FCB banknum
    
    IF banknum==1
        SET Bank1IDCount,Bank1IDCount+1
    ELSEIF banknum==2
        SET Bank2IDCount,Bank2IDCount+1
    ELSEIF banknum==3
        SET Bank3IDCount,Bank3IDCount+1
    ELSEIF banknum==4
        SET Bank4IDCount,Bank4IDCount+1
    ENDIF

    ENDM

BANK_ADDRESS MACRO funcname
    FDB funcname-1
        
    IF banknum==1
        SET Bank1TableCount,Bank1TableCount+1
    ELSEIF banknum==2
        SET Bank2TableCount,Bank2TableCount+1
    ELSEIF banknum==3
        SET Bank3TableCount,Bank3TableCount+1
    ELSEIF banknum==4
        SET Bank4TableCount,Bank4TableCount+1
    ENDIF

    ENDM

;Jump function. Invoked for each banked function.
    ProcessBankJump:
        STA bank_temp_A         ;Save A in case used to pass args
        LDA sys_bank            ;Save existing bank
        PHA
        LDA BankJumpBankList,Y  ;Switch to new bank
        STA sys_bank
        ORA #LCD_RST
        STA PORT_B
        LatchLoad
        LDA #hi(BankJumpReturn-1)   ;Push return address to jump back here
        PHA
        LDA #lo(BankJumpReturn-1)   ;Push return address to jump back here
        PHA
        TYA                         ;Jump to target address
        ASL
        TAY
        LDA BankJumpFuncList+1,Y  ;Look up target address
        PHA
        LDA BankJumpFuncList,Y
        PHA
        LDA bank_temp_A         ;Restore in case args passed
        LDY bank_temp_Y         ;Restore in case args passed
        RTS                     ;Calculated jump
    BankJumpReturn:             ;Calculated jump returns here
        STA bank_temp_A         ;Save A in case return value
        PLA                     ;Restore bank of caller
        STA sys_bank
        ORA #LCD_RST
        STA PORT_B
        LatchLoad
        LDA bank_temp_A
        RTS


;BCALL trampolines in fixed EEPROM for banked functions

;Bank 1
    SET banknum,1

;Bank 2
    SET banknum,2
    ;BFUNC opt_test2
;Bank 3
    SET banknum,3

;Bank 4
    SET banknum,4
    BFUNC WORD_WORDS_GC


;List of bank numbers 
    BankJumpBankList:
;Bank 1
    SET banknum,1

;Bank 2
    SET banknum,2
    ;BANK_ID opt_test2
;Bank 3
    SET banknum,3

;Bank 4
    SET banknum,4
    BANK_ID WORD_WORDS_GC


;Jump table
    BankJumpFuncList:
;Bank 1
    SET banknum,1

;Bank 2
    SET banknum,2
    ;BANK_ADDRESS opt_test2

;Bank 3
    SET banknum,3

;Bank 4
    SET banknum,4
    BANK_ADDRESS WORD_WORDS_GC


;Check for missing entries from 3 tables above
TableCheckError MACRO trampoline,id,table
    MESSAGE "Trampline count: \{trampoline}"
    MESSAGE "ID count:        \{id}"
    MESSAGE "Table count:     \{table}"
    FATAL "Terminating assembly"
    ENDM

    IF ((Bank1TrampolineCount<>Bank1IDCount)||(Bank1IDCount<>Bank1TableCount))
        TableCheckError Bank1TrampolineCount,Bank1IDCount,Bank1TableCount
    ELSEIF ((Bank2TrampolineCount<>Bank2IDCount)||(Bank2IDCount<>Bank2TableCount))
        TableCheckError Bank2TrampolineCount,Bank2IDCount,Bank2TableCount
    ELSEIF ((Bank3TrampolineCount<>Bank3IDCount)||(Bank3IDCount<>Bank3TableCount))
        TableCheckError Bank3TrampolineCount,Bank3IDCount,Bank3TableCount
    ELSEIF ((Bank4TrampolineCount<>Bank4IDCount)||(Bank4IDCount<>Bank4TableCount))
        TableCheckError Bank4TrampolineCount,Bank4IDCount,Bank4TableCount
    ENDIF



;Custom trampolines as needed
;============================
    ;Wrapper for FindWord in bank_fixed.asm
    __FindWord_CUSTOM:
        LDA sys_bank
        PHA
        CALL SetBank, #BANK3     ;FORTH_WORDS start here
        JSR FindWord
        PLA
        STA bank_temp_A
        CALL SetBank, bank_temp_A
        RTS
    
banking_end:
