;=============================================================================================================|
;COURSE    : CSE 341 (Microprocessors)  Section: 06                                                           |
;Summer 2025                                                                                                  |
;Names      : AHAD ISLAM SHANTO                                                                               |
;             NAFISA HASAN                                                                                    |
;             SWAPNIL ROB                                                                                     |
;PROGRAM    : MORSE CODE TRANSLATOR                                                                           |
;-------------------------------------------------------------------------------------------------------------|
;               1. English Text Input & Validation                                                            |
;               2. Morse Code Conversion with Lookup Table                                                    |
;Features       3. Morse Output on Screen                                                                     |
;               4. Morse Sound Generation                                                                     |
;               5. Reverse Translation (Morse to English)                                                     |
;               6. Speed Control                                                                              |
;-------------------------------------------------------------------------------------------------------------|

.MODEL COMPACT

;================================================================================================================
;=====================                      DATA SEGMENT                        =================================
;================================================================================================================
.DATA

    ;===========================================DECODE===========================================================
    INPUT_DECODE DB 50 DUP (?)       ;RAW INPUT FROM USER
    INPUT_CHECKER DB 10 DUP (?)      ;INPUT IN BLOCK OF LETTERS & SEPARATED BY SPACE
    COUNT_DECODE_PERCHAR DB 00       ;CHECK LENGTH FROM INPUT_CHECKER ; Using -> FOR LOOP LIMITS
    COUNT_DECODE DB 00               ;CHECK TOTAL LENGTH FROM INPUT_DECODE ; Using -> FOR LOOP READ VARIABLE
    INDEX_DECODE DB 00               ;TO CHECK THE INPUT INDEX VALUE
    CODES DB 00                      ;SPECIAL VALUE FOR EACH CHARACTER AFTER CALCULATION
    LENGTHS_DECODE DB 00             ;TOTAL DECODE LENGTH FOR LOOP
    ;=============================================ENCODE=========================================================
    STOR DW 0                ;VARIABLE TO STORE BEEP FREQUENCY
    LETTER DB 0              ;TO STORE PER LETTER FROM INPUT
    INDEX DB 0               ;CHECK ENCODE INPUT INDEX
    COUNT DB 0               ;COUNT THE NUMBER OF ENCODE INPUT AS THE LOOP LIMIT
    LENGTHS DB 0             ;TOTAL MORSE CODE LENGTH PER CHAR
    INPUT  DB  50 dup(?)     ;VAR ACCOMMODATES AN ARRAY OF ENCODE INPUT

    ;=============================================STRINGS========================================================
    ; 13 = Carriage Return, 10 = Line Feed
    PRESS_ANY_KEY DB 13,10,13,10,"PRESS ANY KEY TO GO BACK MAIN MENU!$"
    ;----------------  speed control ----------------
    SPEED DB 2
    STR_SPEED DB 13,10,"Select speed (1=Fast, 2=Medium, 3=Slow): $"

    STR_INPUT DB 13,"========================================="
        DB 13,10,"MESSAGE ENCODER (STRING -> MORSE CODE)"
        DB 13,10,"========================================="

        DB 13,10,"Input the readable message to encrypt!"
        DB 13,10,"(In UPPERCASE ; A-Z, 0-9 and SPACE, COMMA, QMARK & DOT only!)"
        DB 13,10,10,"INPUT : ",13,10,"$"

    STR_INPUT_DECODE DB 13,"========================================="
        DB 13,10,"MESSAGE DECODER (MORSE -> STRING)"
        DB 13,10,"========================================="

        DB 13,10,"Input the Morse Code to translate!"
        DB 13,10,10,"INPUT : ",13,10,"$"

    STR_OUTPUT DB 13,10,"OUTPUT: ",13,10,"$"

    STR_EMPTY DB "NO INPUT$"

    MORSE_LISTS DB 13,"========================================="
        DB 13,10,"MORSE CODE TABLE"
        DB 13,10,"========================================="
        DB 13,10, "Alphabets"
        DB 13,10,"A = .-"
        DB "      B = -..."
        DB "   C = -.-."
        DB "    D = -.."
        DB "    E = ."
        DB 13,10,"F = ..-."
        DB "    G = --."
        DB "    H = ...."
        DB "    I = .."
        DB "     J = .---"
        DB 13,10,"K = -.-"
        DB "     L = .-.."
        DB "   M = --"
        DB "      N = -."
        DB "     O = ---"
        DB 13,10,"P = .--."
        DB "    Q = --.-"
        DB "   R = .-."
        DB "     S = ..."
        DB "    T = -"
        DB 13,10,"U = ..-"
        DB "     V = ...-"
        DB "   W = .--"
        DB "     X = -..-"
        DB "   Y = -.--"
        DB 13,10,"Z = --.."
        DB 13,10, "Numbers"
        DB 13,10,"0 = -----"
        DB "  1 = .----"
        DB "  2 = ..---"
        DB "  3 = ...--"
        DB "  4 = ....-"
        DB 13,10,"5 = ....."
        DB "  6 = -...."
        DB "  7 = --..."
        DB "  8 = ---.."
        DB "  9 = ----."
        DB 13,10, "Punctuations"
        DB 13,10,". = .-.-.-"
        DB "        , = --..--"
        DB "        ? = ..--.."
        DB "        ! = -.-.--$"

    HEADER DB           "======================================================="
           DB 13,10,    "||                                                   ||"
           DB 13,10,    "||               MORSE CODE TRANSLATOR               ||"
           DB 13,10,    "||                                                   ||"
           DB 13,10,    "=======================================================$"
    SELECT DB 13,10,10, "                WELCOME TO OUR 341 PROJECT!       "
           DB 13,10,10, "--------------------------- "
           DB 13,10,    "|MAIN MENU:               | "
           DB 13,10,    "|1.Encode                 | "
           DB 13,10,    "|2.Decode                 | "
           DB 13,10,    "|3.Show Morse code Table  | "
           DB 13,10,    "|4.Exit                   | "
           DB 13,10,    "--------------------------- "
           DB 13,10,    "USER kindly Select your choice: $"

    

;==================================================================
;====                      CODE SEGMENT                        ====
;==================================================================
.CODE
.STARTUP
;==================================================================
;====                       MAIN MENU                          ====
;==================================================================
    MAIN_MENU:

    CALL CLEAR_SCREEN

    MOV AH, 9H
    MOV DX, OFFSET HEADER
    INT 21H

    MOV AH, 9H
    MOV DX, OFFSET SELECT
    INT 21H

    MOV AH, 1H
    INT 21H

    CMP AL, 31H
    JNE NOT_ENCODE
    JMP _ENCODE
    NOT_ENCODE:

    CMP AL, 32H
    JNE NOT_DECODE
    JMP _DECODE
    NOT_DECODE:

    CMP AL, 33H
    JNE NOT_MORSECODE
    JMP _MORSECODE
    NOT_MORSECODE:

    CMP AL, 34H
    JNE NOT_REAL_EXIT
    JMP REAL_EXIT
    NOT_REAL_EXIT:
    JMP MAIN_MENU

;==================================================================
;====                          ENCODE                          ====
;==================================================================
    _ENCODE:

    CALL CLEAR_SCREEN
    MOV AX, @DATA
    MOV DS, AX
    ; ask for speed
    MOV AH,9H
    MOV DX,OFFSET STR_SPEED
    INT 21H
    MOV AH,1H
    INT 21H
    CMP AL,'1'
    JB  NOSPD_ENC
    CMP AL,'3'
    JA  NOSPD_ENC
    SUB AL,'0'
    MOV SPEED,AL
NOSPD_ENC:
NOSPD:

    CALL GETINPUT

    MOV AH, 9H
    MOV DX, OFFSET STR_OUTPUT
    INT 21H

    CHECK_INPUT:
        MOV SI, OFFSET INPUT
        MOV COUNT, 0
        DEC LENGTHS

        LP:
            MOV DL, [SI]
            MOV AL, DL

            ; to support lowercase input: convert a-z -> A-Z
            CMP AL,'a'
            JB  NOCASE
            CMP AL,'z'
            JA  NOCASE
            SUB AL,20H
NOCASE:
            MOV LETTER, AL

            CALL CHECK_LETTER
            INC INDEX
            INC COUNT
            INC SI

            MOV BL, LENGTHS[0]     ;LOOP ALONG LENGTH OF INPUT
            CMP COUNT, BL
            JNE NOT_EXIT1
            JMP EXIT1
            NOT_EXIT1:

            JMP LP
    GETINPUT:
        MOV AH, 9H                ;PRINT INPUT STRING
        MOV DX, OFFSET STR_INPUT
        INT 21H

        MOV SI, OFFSET INPUT    ;TO CHECK INPUT VAR
        MOV LENGTHS, 0          ;TO KNOW THE SENTENCE INPUT LENGTH

            LO:
                MOV AH,1H
                INT 21H

                MOV [SI],AL
                INC SI
                INC LENGTHS

                CMP AL ,13
                JE DONE

                CMP AL, 8H
                JE BACK

                JMP LO
                    BACK:
                    CMP LENGTHS[0],1
                    JE LO
                    CMP SI,48
                    JE LO
                    DEC SI
                    MOV AH, 2H
                    MOV DL, 20H
                    INT 21H
                    MOV AH, 2H
                    MOV DL, 8H
                    INT 21H
                    DEC SI
                    DEC LENGTHS
                    DEC LENGTHS
                    JMP LO

            DONE:
                RET

    CHECK_LETTER: 
        
        CMP LETTER, "A"
        JNE NOT_PLAY_A
        JMP PLAY_A
        NOT_PLAY_A:
        CMP LETTER, "B"
        JNE NOT_PLAY_B
        JMP PLAY_B
        NOT_PLAY_B:
        CMP LETTER, "C"
        JNE NOT_PLAY_C
        JMP PLAY_C
        NOT_PLAY_C:
        CMP LETTER, "D"
        JNE NOT_PLAY_D
        JMP PLAY_D
        NOT_PLAY_D:
        CMP LETTER, "E"
        JNE NOT_PLAY_E
        JMP PLAY_E
        NOT_PLAY_E:
        CMP LETTER, "F"
        JNE NOT_PLAY_F
        JMP PLAY_F
        NOT_PLAY_F:
        CMP LETTER, "G"
        JNE NOT_PLAY_G
        JMP PLAY_G
        NOT_PLAY_G:
        CMP LETTER, "H"
        JNE NOT_PLAY_H
        JMP PLAY_H
        NOT_PLAY_H:
        CMP LETTER, "I"
        JNE NOT_PLAY_I
        JMP PLAY_I
        NOT_PLAY_I:
        CMP LETTER, "J"
        JNE NOT_PLAY_J
        JMP PLAY_J
        NOT_PLAY_J:
        CMP LETTER, "K"
        JNE NOT_PLAY_K
        JMP PLAY_K
        NOT_PLAY_K:
        CMP LETTER, "L"
        JNE NOT_PLAY_L
        JMP PLAY_L
        NOT_PLAY_L:
        CMP LETTER, "M"
        JNE NOT_PLAY_M
        JMP PLAY_M
        NOT_PLAY_M:
        CMP LETTER, "N"
        JNE NOT_PLAY_N
        JMP PLAY_N
        NOT_PLAY_N:
        CMP LETTER, "O"
        JNE NOT_PLAY_O
        JMP PLAY_O
        NOT_PLAY_O:
        CMP LETTER, "P"
        JNE NOT_PLAY_P
        JMP PLAY_P
        NOT_PLAY_P:
        CMP LETTER, "Q"
        JNE NOT_PLAY_Q
        JMP PLAY_Q
        NOT_PLAY_Q:
        CMP LETTER, "R"
        JNE NOT_PLAY_R
        JMP PLAY_R
        NOT_PLAY_R:
        CMP LETTER, "S"
        JNE NOT_PLAY_S
        JMP PLAY_S
        NOT_PLAY_S:
        CMP LETTER, "T"
        JNE NOT_PLAY_T
        JMP PLAY_T
        NOT_PLAY_T:
        CMP LETTER, "U"
        JNE NOT_PLAY_U
        JMP PLAY_U
        NOT_PLAY_U:
        CMP LETTER, "V"
        JNE NOT_PLAY_V
        JMP PLAY_V
        NOT_PLAY_V:
        CMP LETTER, "W"
        JNE NOT_PLAY_W
        JMP PLAY_W
        NOT_PLAY_W:
        CMP LETTER, "X"
        JNE NOT_PLAY_X
        JMP PLAY_X
        NOT_PLAY_X:
        CMP LETTER, "Y"
        JNE NOT_PLAY_Y
        JMP PLAY_Y
        NOT_PLAY_Y:
        CMP LETTER, "Z"
        JNE NOT_PLAY_Z
        JMP PLAY_Z
        NOT_PLAY_Z: 
        CMP LETTER, "0"
        JNE NOT_PLAY_0
        JMP PLAY_0
        NOT_PLAY_0:
        CMP LETTER, "1"
        JNE NOT_PLAY_1
        JMP PLAY_1
        NOT_PLAY_1:
        CMP LETTER, "2"
        JNE NOT_PLAY_2
        JMP PLAY_2
        NOT_PLAY_2:
        CMP LETTER, "3"
        JNE NOT_PLAY_3
        JMP PLAY_3
        NOT_PLAY_3:
        CMP LETTER, "4"
        JNE NOT_PLAY_4
        JMP PLAY_4
        NOT_PLAY_4:
        CMP LETTER, "5"
        JNE NOT_PLAY_5
        JMP PLAY_5
        NOT_PLAY_5:
        CMP LETTER, "6"
        JNE NOT_PLAY_6
        JMP PLAY_6
        NOT_PLAY_6:
        CMP LETTER, "7"
        JNE NOT_PLAY_7
        JMP PLAY_7
        NOT_PLAY_7:
        CMP LETTER, "8"
        JNE NOT_PLAY_8
        JMP PLAY_8
        NOT_PLAY_8:
        CMP LETTER, "9"
        JNE NOT_PLAY_9
        JMP PLAY_9
        NOT_PLAY_9:
        CMP LETTER, "."
        JNE NOT_PLAY_DOT
        JMP PLAY_DOT
        NOT_PLAY_DOT:
        CMP LETTER, ","
        JNE NOT_PLAY_COMMA
        JMP PLAY_COMMA
        NOT_PLAY_COMMA:
        CMP LETTER, "?"
        JNE NOT_PLAY_QMARK
        JMP PLAY_QMARK
        NOT_PLAY_QMARK:
        CMP LETTER, "!"
        JNE NOT_PLAY_BANG
        JMP PLAY_BANG
        NOT_PLAY_BANG:
        CMP LETTER, 13H
        JNE NOT_PLAY_KOSONG
        JMP PLAY_EMPTY
        NOT_PLAY_KOSONG:
        CMP LETTER, 00H
        JNE NOT_PLAY_NULL
        JMP PLAY_EMPTY
        NOT_PLAY_NULL:
        CMP LETTER, 20H
        JNE NOT_PLAY_SPACE
        JMP PLAY_SPACE
        NOT_PLAY_SPACE:
        RET
        
        
        PLAY_0: ; ----- 
            MOV AX, 3043
            MOV STOR, AX
            CALL BEEPL
            CALL DELAYS
            CALL BEEPL
            CALL DELAYS
            CALL BEEPL
            CALL DELAYS
            CALL BEEPL
            CALL DELAYS
            CALL BEEPL
            CALL BEEPSPACE
            CALL DELAYS
            RET
        
        PLAY_1: ; .----
            MOV AX, 3043
            MOV STOR, AX
            CALL BEEPS
            CALL DELAYS
            CALL BEEPL
            CALL DELAYS
            CALL BEEPL
            CALL DELAYS
            CALL BEEPL
            CALL DELAYS
            CALL BEEPL
            CALL BEEPSPACE
            CALL DELAYS
            RET
        
        PLAY_2: ; ..---
            MOV AX, 3043
            MOV STOR, AX
            CALL BEEPS
            CALL DELAYS
            CALL BEEPS
            CALL DELAYS
            CALL BEEPL
            CALL DELAYS
            CALL BEEPL
            CALL DELAYS
            CALL BEEPL
            CALL BEEPSPACE
            CALL DELAYS
            RET
        
        PLAY_3: ; ...--
            MOV AX, 3043
            MOV STOR, AX
            CALL BEEPS
            CALL DELAYS
            CALL BEEPS
            CALL DELAYS
            CALL BEEPS
            CALL DELAYS
            CALL BEEPL
            CALL DELAYS
            CALL BEEPL
            CALL BEEPSPACE
            CALL DELAYS
            RET
        
        PLAY_4: ; ....-
            MOV AX, 3043
            MOV STOR, AX
            CALL BEEPS
            CALL DELAYS
            CALL BEEPS
            CALL DELAYS
            CALL BEEPS
            CALL DELAYS
            CALL BEEPS
            CALL DELAYS
            CALL BEEPL
            CALL BEEPSPACE
            CALL DELAYS
            RET
        
        PLAY_5: ; .....
            MOV AX, 3043
            MOV STOR, AX
            CALL BEEPS
            CALL DELAYS
            CALL BEEPS
            CALL DELAYS
            CALL BEEPS
            CALL DELAYS
            CALL BEEPS
            CALL DELAYS
            CALL BEEPS
            CALL BEEPSPACE
            CALL DELAYS
            RET
        
        PLAY_6: ; -....
            MOV AX, 3043
            MOV STOR, AX
            CALL BEEPL
            CALL DELAYS
            CALL BEEPS
            CALL DELAYS
            CALL BEEPS
            CALL DELAYS
            CALL BEEPS
            CALL DELAYS
            CALL BEEPS
            CALL BEEPSPACE
            CALL DELAYS
            RET
        
        PLAY_7: ; --...
            MOV AX, 3043
            MOV STOR, AX
            CALL BEEPL
            CALL DELAYS
            CALL BEEPL
            CALL DELAYS
            CALL BEEPS
            CALL DELAYS
            CALL BEEPS
            CALL DELAYS
            CALL BEEPS
            CALL BEEPSPACE
            CALL DELAYS
            RET
        
        PLAY_8: ; ---..
            MOV AX, 3043
            MOV STOR, AX
            CALL BEEPL
            CALL DELAYS
            CALL BEEPL
            CALL DELAYS
            CALL BEEPL
            CALL DELAYS
            CALL BEEPS
            CALL DELAYS
            CALL BEEPS
            CALL BEEPSPACE
            CALL DELAYS
            RET
        
        PLAY_9: ; ----.
            MOV AX, 3043
            MOV STOR, AX
            CALL BEEPL
            CALL DELAYS
            CALL BEEPL
            CALL DELAYS
            CALL BEEPL
            CALL DELAYS
            CALL BEEPL
            CALL DELAYS
            CALL BEEPS
            CALL BEEPSPACE
            CALL DELAYS
            RET
        
        PLAY_QMARK: ; ..--..
            MOV AX, 3043
            MOV STOR, AX
            CALL BEEPS
            CALL DELAYS
            CALL BEEPS
            CALL DELAYS
            CALL BEEPL
            CALL DELAYS
            CALL BEEPL
            CALL DELAYS
            CALL BEEPS
            CALL DELAYS
            CALL BEEPS
            CALL BEEPSPACE
            CALL DELAYS
            RET
        
        PLAY_BANG: ; -.-.--
            MOV AX, 3043
            MOV STOR, AX
            CALL BEEPL
            CALL DELAYS
            CALL BEEPS
            CALL DELAYS
            CALL BEEPL
            CALL DELAYS
            CALL BEEPS
            CALL DELAYS
            CALL BEEPL
            CALL DELAYS
            CALL BEEPL
            CALL BEEPSPACE
            CALL DELAYS
            RET
        
        PLAY_DOT: ; .-.-.-
            MOV AX, 3043
            MOV STOR, AX
            CALL BEEPS
            CALL DELAYS
            CALL BEEPL
            CALL DELAYS
            CALL BEEPS
            CALL DELAYS
            CALL BEEPL
            CALL DELAYS
            CALL BEEPS
            CALL BEEPSPACE
            CALL DELAYS
            RET
        
        PLAY_COMMA: ; --..--
            MOV AX, 3043
            MOV STOR, AX
            CALL BEEPL
            CALL DELAYS
            CALL BEEPL
            CALL DELAYS
            CALL BEEPS
            CALL DELAYS
            CALL BEEPS
            CALL DELAYS
            CALL BEEPL
            CALL DELAYS
            CALL BEEPL
            CALL BEEPSPACE
            CALL DELAYS
            RET

        PLAY_A:
            MOV     AX, 3043
            MOV     STOR, AX
            CALL    BEEPS
            CALL    DELAYS
            CALL    BEEPL
            CALL    BEEPSPACE
            CALL    DELAYS
            RET

        PLAY_B:
            MOV     AX, 3043
            MOV     STOR, AX
            CALL    BEEPL
            CALL    DELAYS
            CALL    BEEPS
            CALL    DELAYS
            CALL    BEEPS
            CALL    DELAYS
            CALL    BEEPS
            CALL    BEEPSPACE
            CALL    DELAYS
            RET
        PLAY_C:
            MOV     AX, 3043
            MOV     STOR, AX
            CALL    BEEPL
            CALL    DELAYS
            CALL    BEEPS
            CALL    DELAYS
            CALL    BEEPL
            CALL    DELAYS
            CALL    BEEPS
            CALL    BEEPSPACE
            CALL    DELAYS
            RET
        PLAY_D:
            MOV     AX, 3043
            MOV     STOR, AX
            CALL    BEEPL
            CALL    DELAYS
            CALL    BEEPS
            CALL    DELAYS
            CALL    BEEPS
            CALL    BEEPSPACE
            CALL    DELAYS
            RET
        PLAY_E:
            MOV     AX, 3043
            MOV     STOR, AX
            CALL    BEEPS
            CALL    BEEPSPACE
            CALL    DELAYS
            RET
        PLAY_F:
            MOV     AX, 3043
            MOV     STOR, AX
            CALL    BEEPS
            CALL    DELAYS
            CALL    BEEPS
            CALL    DELAYS
            CALL    BEEPL
            CALL    DELAYS
            CALL    BEEPS
            CALL    BEEPSPACE
            CALL    DELAYS
            RET
        PLAY_G:
            MOV     AX, 3043
            MOV     STOR, AX
            CALL    BEEPL
            CALL    DELAYS
            CALL    BEEPL
            CALL    DELAYS
            CALL    BEEPS
            CALL    BEEPSPACE
            CALL    DELAYS
            RET
            RET
        PLAY_H:
            MOV     AX, 3043
            MOV     STOR, AX
            CALL    BEEPS
            CALL    DELAYS
            CALL    BEEPS
            CALL    DELAYS
            CALL    BEEPS
            CALL    DELAYS
            CALL    BEEPS
            CALL    BEEPSPACE
            CALL    DELAYS
            RET
        PLAY_I:
            MOV     AX, 3043
            MOV     STOR, AX
            CALL    BEEPS
            CALL    DELAYS
            CALL    BEEPS
            CALL    BEEPSPACE
            CALL    DELAYS
            RET
        PLAY_J:
            MOV     AX, 3043
            MOV     STOR, AX
            CALL    BEEPS
            CALL    DELAYS
            CALL    BEEPL
            CALL    DELAYS
            CALL    BEEPL
            CALL    DELAYS
            CALL    BEEPL
            CALL    BEEPSPACE
            CALL    DELAYS
            RET
        PLAY_K:
            MOV     AX, 3043
            MOV     STOR, AX
            CALL    BEEPL
            CALL    DELAYS
            CALL    BEEPS
            CALL    DELAYS
            CALL    BEEPL
            CALL    BEEPSPACE
            CALL    DELAYS
            RET
        PLAY_L:
            MOV     AX, 3043
            MOV     STOR, AX
            CALL    BEEPS
            CALL    DELAYS
            CALL    BEEPL
            CALL    DELAYS
            CALL    BEEPS
            CALL    DELAYS
            CALL    BEEPS
            CALL    BEEPSPACE
            CALL    DELAYS
            RET
        PLAY_M:
            MOV     AX, 3043
            MOV     STOR, AX
            CALL    BEEPL
            CALL    DELAYS
            CALL    BEEPL
            CALL    BEEPSPACE
            CALL    DELAYS
            RET
        PLAY_N:
            MOV     AX, 3043
            MOV     STOR, AX
            CALL    BEEPL
            CALL    DELAYS
            CALL    BEEPS
            CALL    BEEPSPACE
            CALL    DELAYS
            RET
        PLAY_O:
            MOV     AX, 3043
            MOV     STOR, AX
            CALL    BEEPL
            CALL    DELAYS
            CALL    BEEPL
            CALL    DELAYS
            CALL    BEEPL
            CALL    BEEPSPACE
            CALL    DELAYS
            RET
        PLAY_P:
            MOV     AX, 3043
            MOV     STOR, AX
            CALL    BEEPS
            CALL    DELAYS
            CALL    BEEPL
            CALL    DELAYS
            CALL    BEEPL
            CALL    DELAYS
            CALL    BEEPS
            CALL    BEEPSPACE
            CALL    DELAYS
            RET
        PLAY_Q:
            MOV     AX, 3043
            MOV     STOR, AX
            CALL    BEEPL
            CALL    DELAYS
            CALL    BEEPL
            CALL    DELAYS
            CALL    BEEPS
            CALL    DELAYS
            CALL    BEEPL
            CALL    BEEPSPACE
            CALL    DELAYS
            RET
        PLAY_R:
            MOV     AX, 3043
            MOV     STOR, AX
            CALL    BEEPS
            CALL    DELAYS
            CALL    BEEPL
            CALL    DELAYS
            CALL    BEEPS
            CALL    BEEPSPACE
            CALL    DELAYS
            RET
        PLAY_S:
            MOV     AX, 3043
            MOV     STOR, AX
            CALL    BEEPS
            CALL    DELAYS
            CALL    BEEPS
            CALL    DELAYS
            CALL    BEEPS
            CALL    BEEPSPACE
            CALL    DELAYS
            RET
        PLAY_T:
            MOV     AX, 3043
            MOV     STOR, AX
            CALL    BEEPL
            CALL    BEEPSPACE
            CALL    DELAYS
            RET
        PLAY_U:
            MOV     AX, 3043
            MOV     STOR, AX
            CALL    BEEPS
            CALL    DELAYS
            CALL    BEEPS
            CALL    DELAYS
            CALL    BEEPL
            CALL    DELAYS
            CALL    BEEPL
            CALL    BEEPSPACE
            CALL    DELAYS
            RET
        PLAY_V:
            MOV     AX, 3043
            MOV     STOR, AX
            CALL    BEEPS
            CALL    DELAYS
            CALL    BEEPS
            CALL    DELAYS
            CALL    BEEPS
            CALL    DELAYS
            CALL    BEEPL
            CALL    BEEPSPACE
            CALL    DELAYS
            RET
        PLAY_W:
            MOV     AX, 3043
            MOV     STOR, AX
            CALL    BEEPS
            CALL    DELAYS
            CALL    BEEPL
            CALL    DELAYS
            CALL    BEEPL
            CALL    BEEPSPACE
            CALL    DELAYS
            RET
        PLAY_X:
            MOV     AX, 3043
            MOV     STOR, AX
            CALL    BEEPL
            CALL    DELAYS
            CALL    BEEPS
            CALL    DELAYS
            CALL    BEEPS
            CALL    DELAYS
            CALL    BEEPL
            CALL    BEEPSPACE
            CALL    DELAYS
            RET
        PLAY_Y:
            MOV     AX, 3043
            MOV     STOR, AX
            CALL    BEEPL
            CALL    DELAYS
            CALL    BEEPS
            CALL    DELAYS
            CALL    BEEPL
            CALL    DELAYS
            CALL    BEEPL
            CALL    BEEPSPACE
            CALL    DELAYS
            RET
        PLAY_Z:
            MOV     AX, 3043
            MOV     STOR, AX
            CALL    BEEPL
            CALL    DELAYS
            CALL    BEEPL
            CALL    DELAYS
            CALL    BEEPS
            CALL    DELAYS
            CALL    BEEPS
            CALL    BEEPSPACE
            CALL    DELAYS
            RET
        RET
        PLAY_EMPTY:
            MOV AH, 9H
            MOV DX, OFFSET STR_EMPTY
            INT 21H
            RET
        PLAY_SPACE:
            MOV AH, 2H
            MOV DL, " "
            INT 21H
            CALL DELAYW
            RET

        EXIT1:
        JMP EXT

        ;GENERATE SOUND
        BEEPS:                  ; dot
        ; --- Beep sound ---
        MOV     AH,0Eh
        MOV     AL,07h
        INT     10h
        ; --- Print dot character ---
        MOV     AH,2
        MOV     DL,'.'
        INT     21h

        CALL    DELAYS   ; keep delay routine for timing
        CALL    CLR_KEYB ; clear keyboard buffer if needed
        RET


        BEEPL: ;dash
        ; --- Beep sound ---
        MOV     AH,0Eh
        MOV     AL,07h
        INT     10h
        ; --- Print dash character ---
        MOV     AH,2
        MOV     DL,'-'
        INT     21h

        CALL    DELAYL   ; keep long delay routine for dash
        CALL    CLR_KEYB ; clear keyboard buffer if needed
        RET

        BEEPSPACE:
            CALL    DELAYS
            MOV     AH, 2H
            MOV     DL, " "
            INT     21H
        RET

        ; dot delay (SPEED ticks)
        DELAYS:                  ; dot
            MOV     AH, 00H
            INT     1AH
            XOR     AX,AX
            MOV     AL, SPEED
            ADD     DX, AX
            MOV     BX, DX
        PZ:
            INT     1AH
            CMP     DX, BX
            JL      PZ
        RET
        DELAYL: ; dash = 3 dot
            MOV     AH, 00H
            INT     1AH
            XOR     AX,AX ; clear AX so we can put SPEED in AL safely
            MOV     AL, SPEED
            MOV     BL,3
            MUL     BL
            ADD     DX, AX
            MOV     BX, DX
        PX:
            INT     1AH
            CMP     DX, BX
            JL      PX
        RET
        DELAYW:  ; word gap = 7 dot
            MOV     AH, 00H
            INT     1AH
            XOR     AX,AX
            MOV     AL, SPEED
            MOV     BL,7
            MUL     BL
            ADD     DX, AX
            MOV     BX, DX
        PW:
            INT     1AH
            CMP     DX, BX
            JL      PW
        RET

        ;CLEAR KEYBOARD BUFFER
        CLR_KEYB:
            PUSH ES
            PUSH DI
            MOV AX, 40H
            MOV ES, AX
            MOV AX, 1AH
            MOV DI, AX
            MOV AX, 1EH
            MOV ES: WORD PTR [DI], AX
            INC DI
            INC DI
            MOV ES: WORD PTR [DI], AX
            POP DI
            POP ES
        RET
        CLEAR_SCREEN:
            MOV AH, 0H
            MOV AL, 3H
            INT 10H        ; fixed: use BIOS video interrupt
        RET

;==================================================================
;====                          DECODE                          ====
;==================================================================
_DECODE:
    MOV AX, 0000H
    MOV BX, 0000H
    MOV CX, 0000H
    MOV DX, 0000H
    MOV SI, 0000H
    MOV INPUT_DECODE, 0000H
    MOV INPUT_CHECKER, 0000H
    MOV COUNT_DECODE_PERCHAR, 0000H
    MOV COUNT_DECODE, 0000H
    MOV INDEX_DECODE, 0000H
    MOV CODES, 0000H
    MOV LENGTHS_DECODE, 0000H

    CALL CLEAR_SCREEN


NOSPD2:

    CALL GETINPUT_DECODE

    MOV AX, 0000H
    MOV AH, 9H
    MOV DX, OFFSET STR_OUTPUT
    INT 21H

    CALL CHECK_INPUT_DECODE


;------------------- GETINPUT_DECODE -------------------
GETINPUT_DECODE:
    MOV AH, 9H
    MOV DX, OFFSET STR_INPUT_DECODE
    INT 21H

    MOV SI, OFFSET INPUT_DECODE
    MOV LENGTHS_DECODE, 0

LZ:
    MOV AH,1H
    INT 21H

    CMP AL ,13
    JE DONE_DECODE

    MOV [SI],AL
    INC SI
    INC LENGTHS_DECODE

    CMP AL, 8H
    JE BACK_DECODE

    JMP LZ

BACK_DECODE:
    CMP LENGTHS_DECODE[0],0
    JE LZ
    DEC SI
    MOV AH, 2H
    MOV DL, 20H
    INT 21H
    MOV AH, 2H
    MOV DL, 8H
    INT 21H
    DEC SI
    DEC LENGTHS_DECODE
    DEC LENGTHS_DECODE
    JMP LZ

DONE_DECODE:
    MOV AL, 20H
    MOV [SI], AL
    INC LENGTHS_DECODE
    INC SI
    MOV AL, 0DH
    MOV [SI],AL
    INC LENGTHS_DECODE
    RET

;------------------- CHECK_INPUT_DECODE -------------------
CHECK_INPUT_DECODE:
    MOV AX, @DATA
    MOV DS, AX
    LEA SI, INPUT_DECODE
    MOV AX, 0H
    MOV AL, INDEX_DECODE[0]
    MOV SI, AX
    MOV DI, 0
    MOV COUNT_DECODE_PERCHAR, 0

LD:
    MOV DL, INPUT_DECODE[SI] 
            
    CMP DL, 2FH             ; '/'
    JE  PRINT_WORD_SPACE
    CMP DL, 20H             ; space separates one character
    JE  ONE_CHAR_DONE

    MOV INPUT_CHECKER[DI], DL
    INC INDEX_DECODE
    INC COUNT_DECODE_PERCHAR
    INC COUNT_DECODE
    INC SI
    INC DI
    MOV BL, LENGTHS_DECODE[0]
    CMP COUNT_DECODE, BL
    JNE NOT_EXT
    JMP EXT
NOT_EXT:
    JMP LD
            
PRINT_WORD_SPACE:
    MOV AH, 02H
    MOV DL, 20H
    INT 21H
    INC INDEX_DECODE
    INC COUNT_DECODE
    INC SI
    JMP LD
            

ONE_CHAR_DONE:
    INC INDEX_DECODE
    INC COUNT_DECODE
    CALL CHAR_CHECK


;------------------- CHAR_CHECK -------------------
CHAR_CHECK:
    MOV BL, COUNT_DECODE_PERCHAR      ; BL = length of symbol sequence (8-bit)
    CMP BL, 1
    JE  LEN1
    CMP BL, 2
    JE  LEN2
    CMP BL, 3
    JE  LEN3
    CMP BL, 4
    JE  LEN4
    CMP BL, 5
    JE  LEN5
    CMP BL, 6
    JE  LEN6
    JMP PRINT_UNKNOWN

; length = 1
LEN1:
    MOV AL, INPUT_CHECKER[0]
    CMP AL, '.'
    JE  PRINT_E
    CMP AL, '-'
    JE  PRINT_T
    JMP PRINT_UNKNOWN

; length = 2
LEN2:
    MOV AL, INPUT_CHECKER[0]
    MOV DL, INPUT_CHECKER[1]
    CMP AL, '.'
    JE  L2DOT
    CMP AL, '-'
    JE  L2DASH
    JMP PRINT_UNKNOWN
L2DOT:
    CMP DL, '.'
    JE PRINT_I
    CMP DL, '-'
    JE PRINT_A
    JMP PRINT_UNKNOWN
L2DASH:
    CMP DL, '.'
    JE PRINT_N
    CMP DL, '-'
    JE PRINT_M
    JMP PRINT_UNKNOWN
    
; length = 3
LEN3:
    MOV AL, INPUT_CHECKER[0]
    MOV DL, INPUT_CHECKER[1]
    MOV DH, INPUT_CHECKER[2]
    CMP AL,'.'
    JE L3DOT
    CMP AL,'-'
    JE L3DASH
    JMP PRINT_UNKNOWN
L3DOT:
    CMP DL,'.'
    JE L3DD
    CMP DL,'-'
    JE L3DA
    JMP PRINT_UNKNOWN
L3DD:
    CMP DH,'.'
    JE PRINT_S
    CMP DH,'-'
    JE PRINT_U
    JMP PRINT_UNKNOWN
L3DA:
    CMP DH,'.'
    JE PRINT_R
    CMP DH,'-'
    JE PRINT_W
    JMP PRINT_UNKNOWN
L3DASH:
    CMP DL,'.'
    JE L3DASHDOT
    CMP DL,'-'
    JE L3DASHDASH
    JMP PRINT_UNKNOWN
L3DASHDOT:
    CMP DH,'.'
    JE PRINT_D
    CMP DH,'-'
    JE PRINT_K
    JMP PRINT_UNKNOWN
L3DASHDASH:
    CMP DH,'.'
    JE PRINT_G
    CMP DH,'-'
    JE PRINT_O
    JMP PRINT_UNKNOWN

; length = 4
LEN4:
    MOV AL, INPUT_CHECKER[0]
    MOV DL, INPUT_CHECKER[1]
    MOV DH, INPUT_CHECKER[2]
    MOV CH, INPUT_CHECKER[3]
    CMP AL,'.'
    JE L4DOT
    CMP AL,'-'
    JE L4DASH
    JMP PRINT_UNKNOWN
L4DOT:
    CMP DL,'.'
    JE L4DD
    CMP DL,'-'
    JE L4DA
    JMP PRINT_UNKNOWN
L4DD:
    CMP DH,'.'
    JE L4DDD
    CMP DH,'-'
    JE L4DDASH
    JMP PRINT_UNKNOWN
L4DDD:
    CMP CH,'.'
    JE PRINT_H
    CMP CH,'-'
    JE PRINT_V
    JMP PRINT_UNKNOWN
L4DDASH:
    CMP CH,'.'
    JE PRINT_F
    JMP PRINT_UNKNOWN
L4DA:
    CMP DH,'.'
    JE L4DADOT
    CMP DH,'-'
    JE L4DADASH
    JMP PRINT_UNKNOWN
L4DADOT:
    CMP CH,'.'
    JE PRINT_L
    JMP PRINT_UNKNOWN
L4DADASH:
    CMP CH,'.'
    JE PRINT_P
    CMP CH,'-'
    JE PRINT_J
    JMP PRINT_UNKNOWN
L4DASH:
    CMP DL,'.'
    JE L4DASHDOT
    CMP DL,'-'
    JE L4DASHDASH
    JMP PRINT_UNKNOWN
L4DASHDOT:
    CMP DH,'.'
    JE L4DASHDDOT
    CMP DH,'-'
    JE L4DASHDDASH
    JMP PRINT_UNKNOWN
L4DASHDDOT:
    CMP CH,'.'
    JE PRINT_B
    CMP CH,'-'
    JE PRINT_X
    JMP PRINT_UNKNOWN
L4DASHDDASH:
    CMP CH,'.'
    JE PRINT_C
    CMP CH,'-'
    JE PRINT_Y
    JMP PRINT_UNKNOWN
L4DASHDASH:
    CMP DH,'.'
    JE L4DASHDASHDOT
    CMP DH,'-'
    JE L4DASHDASHDASH
    JMP PRINT_UNKNOWN
L4DASHDASHDOT:
    CMP CH,'.'
    JE PRINT_Z
    CMP CH,'-'
    JE PRINT_Q
    JMP PRINT_UNKNOWN
L4DASHDASHDASH:
    JMP PRINT_UNKNOWN 
    ; length = 5 (digits)
LEN5:
    ; load 5 symbols
    MOV AL, INPUT_CHECKER[0]
    MOV DL, INPUT_CHECKER[1]
    MOV DH, INPUT_CHECKER[2]
    MOV CH, INPUT_CHECKER[3]
    MOV BH, INPUT_CHECKER[4]

    ; .---- (1)
    CMP AL,'.'  
    JNE L5_NOT_DOT
    CMP DL,'-'  
    JNE L5_DOT_NOT_1
    CMP DH,'-'  
    JNE L5_DOT_NOT_1
    CMP CH,'-'  
    JNE L5_DOT_NOT_1
    CMP BH,'-'  
    JNE L5_DOT_NOT_1
    JMP PRINT_1
L5_DOT_NOT_1:
        ; ..--- (2)
        CMP DL,'.'  
        JNE L5_DOT_NOT_2
        CMP DH,'-'  
        JNE L5_DOT_NOT_2
        CMP CH,'-'  
        JNE L5_DOT_NOT_2
        CMP BH,'-'  
        JNE L5_DOT_NOT_2
        JMP PRINT_2
L5_DOT_NOT_2:
        ; ...-- (3)
        CMP DH,'.'  
        JNE L5_DOT_NOT_3
        CMP CH,'-'  
        JNE L5_DOT_NOT_3
        CMP BH,'-'  
        JNE L5_DOT_NOT_3
        JMP PRINT_3
L5_DOT_NOT_3:
        ; ....- (4)
        CMP CH,'.'  
        JNE L5_DOT_NOT_4
        CMP BH,'-'  
        JNE L5_DOT_NOT_4
        JMP PRINT_4
L5_DOT_NOT_4:
        ; ..... (5)
        CMP BH,'.'  
        JNE L5_FAIL
        JMP PRINT_5

L5_NOT_DOT:
    ; ----- (0)
    CMP DL,'-'  
    JNE L5_NOT_ZERO
    CMP DH,'-'  
    JNE L5_NOT_ZERO
    CMP CH,'-'  
    JNE L5_NOT_ZERO
    CMP BH,'-'  
    JNE L5_NOT_ZERO
    CMP AL,'-'  
    JNE L5_NOT_ZERO
    JMP PRINT_0
L5_NOT_ZERO:
    ; -.... (6)
    CMP AL,'-'  
    JNE L5_NOT_6
    CMP DL,'.'  
    JNE L5_NOT_6
    CMP DH,'.'  
    JNE L5_NOT_6
    CMP CH,'.'  
    JNE L5_NOT_6
    CMP BH,'.'  
    JNE L5_NOT_6
    JMP PRINT_6
L5_NOT_6:
    ; --... (7)
    CMP DL,'-'  
    JNE L5_NOT_7
    CMP DH,'.'  
    JNE L5_NOT_7
    CMP CH,'.'  
    JNE L5_NOT_7
    CMP BH,'.'  
    JNE L5_NOT_7
    JMP PRINT_7
L5_NOT_7:
    ; ---.. (8)
    CMP DH,'-'  
    JNE L5_NOT_8
    CMP CH,'.'  
    JNE L5_NOT_8
    CMP BH,'.'  
    JNE L5_NOT_8
    JMP PRINT_8
L5_NOT_8:
    ; ----. (9)
    CMP CH,'-'  
    JNE L5_FAIL
    CMP BH,'.'  
    JNE L5_FAIL
    JMP PRINT_9

L5_FAIL:
    JMP PRINT_UNKNOWN

; length = 6 (punctuation)
LEN6:
    ; load 6 symbols
    MOV AL, INPUT_CHECKER[0]
    MOV DL, INPUT_CHECKER[1]
    MOV DH, INPUT_CHECKER[2]
    MOV CH, INPUT_CHECKER[3]
    MOV BL, INPUT_CHECKER[4]
    MOV BH, INPUT_CHECKER[5]

    ; .-.-.-  (.)
    CMP AL,'.'  
    JNE L6_NOT_DOT
    CMP DL,'-'  
    JNE L6_NOT_DOT
    CMP DH,'.'  
    JNE L6_NOT_DOT
    CMP CH,'-'  
    JNE L6_NOT_DOT
    CMP BL,'.'  
    JNE L6_NOT_DOT
    CMP BH,'-'  
    JNE L6_NOT_DOT
    JMP PRINT_DOT

L6_NOT_DOT:
    ; --..--  (,)
    CMP AL,'-'  
    JNE L6_NOT_COMMA
    CMP DL,'-'  
    JNE L6_NOT_COMMA
    CMP DH,'.'  
    JNE L6_NOT_COMMA
    CMP CH,'.'  
    JNE L6_NOT_COMMA
    CMP BL,'-'  
    JNE L6_NOT_COMMA
    CMP BH,'-'  
    JNE L6_NOT_COMMA
    JMP PRINT_COMMA

L6_NOT_COMMA:
    ; ..--..  (?)
    CMP AL,'.'  
    JNE L6_NOT_Q
    CMP DL,'.'  
    JNE L6_NOT_Q
    CMP DH,'-'  
    JNE L6_NOT_Q
    CMP CH,'-'  
    JNE L6_NOT_Q
    CMP BL,'.'  
    JNE L6_NOT_Q
    CMP BH,'.'  
    JNE L6_NOT_Q
    JMP PRINT_QMARK

L6_NOT_Q:
    ; -.-.--  (!)
    CMP AL,'-'  
    JNE L6_FAIL
    CMP DL,'.'  
    JNE L6_FAIL
    CMP DH,'-'  
    JNE L6_FAIL
    CMP CH,'.'  
    JNE L6_FAIL
    CMP BL,'-'  
    JNE L6_FAIL
    CMP BH,'-'  
    JNE L6_FAIL
    JMP PRINT_BANG

L6_FAIL:
    JMP PRINT_UNKNOWN

;------------------- PRINT LETTERS -------------------
PRINT_A: MOV AH,2
    MOV DL,'A'
    INT 21H
    JMP RESET_AFTER_PRINT
PRINT_B: MOV AH,2
    MOV DL,'B'
    INT 21H
    JMP RESET_AFTER_PRINT
PRINT_C: MOV AH,2
    MOV DL,'C'
    INT 21H
    JMP RESET_AFTER_PRINT
PRINT_D: MOV AH,2
    MOV DL,'D'
    INT 21H
    JMP RESET_AFTER_PRINT
PRINT_E: MOV AH,2
    MOV DL,'E'
    INT 21H
    JMP RESET_AFTER_PRINT
PRINT_F: MOV AH,2
    MOV DL,'F'
    INT 21H
    JMP RESET_AFTER_PRINT
PRINT_G: MOV AH,2
    MOV DL,'G'
    INT 21H
    JMP RESET_AFTER_PRINT
PRINT_H: MOV AH,2
    MOV DL,'H'
    INT 21H
    JMP RESET_AFTER_PRINT
PRINT_I: MOV AH,2
    MOV DL,'I'
    INT 21H
    JMP RESET_AFTER_PRINT
PRINT_J: MOV AH,2
    MOV DL,'J'
    INT 21H
    JMP RESET_AFTER_PRINT
PRINT_K: MOV AH,2
    MOV DL,'K'
    INT 21H
    JMP RESET_AFTER_PRINT
PRINT_L: MOV AH,2
    MOV DL,'L'
    INT 21H
    JMP RESET_AFTER_PRINT
PRINT_M: MOV AH,2
    MOV DL,'M'
    INT 21H
    JMP RESET_AFTER_PRINT
PRINT_N: MOV AH,2
    MOV DL,'N'
    INT 21H
    JMP RESET_AFTER_PRINT
PRINT_O: MOV AH,2
    MOV DL,'O'
    INT 21H
    JMP RESET_AFTER_PRINT
PRINT_P: MOV AH,2
    MOV DL,'P'
    INT 21H
    JMP RESET_AFTER_PRINT
PRINT_Q: MOV AH,2
    MOV DL,'Q'
    INT 21H
    JMP RESET_AFTER_PRINT
PRINT_R: MOV AH,2
    MOV DL,'R'
    INT 21H
    JMP RESET_AFTER_PRINT
PRINT_S: MOV AH,2
    MOV DL,'S'
    INT 21H
    JMP RESET_AFTER_PRINT
PRINT_T: MOV AH,2
    MOV DL,'T'
    INT 21H
    JMP RESET_AFTER_PRINT
PRINT_U: MOV AH,2
    MOV DL,'U'
    INT 21H
    JMP RESET_AFTER_PRINT
PRINT_V: MOV AH,2
    MOV DL,'V'
    INT 21H
    JMP RESET_AFTER_PRINT
PRINT_W: MOV AH,2
    MOV DL,'W'
    INT 21H
    JMP RESET_AFTER_PRINT
PRINT_X: MOV AH,2
    MOV DL,'X'
    INT 21H
    JMP RESET_AFTER_PRINT
PRINT_Y: MOV AH,2
    MOV DL,'Y'
    INT 21H
    JMP RESET_AFTER_PRINT
PRINT_Z: MOV AH,2
    MOV DL,'Z'
    INT 21H
    JMP RESET_AFTER_PRINT 
; digits 0–9
PRINT_0: 
    MOV AH,2  
    MOV DL,'0'  
    INT 21H  
    JMP RESET_AFTER_PRINT
PRINT_1: 
    MOV AH,2  
    MOV DL,'1'  
    INT 21H  
    JMP RESET_AFTER_PRINT
PRINT_2: 
    MOV AH,2  
    MOV DL,'2'  
    INT 21H  
    JMP RESET_AFTER_PRINT
PRINT_3: 
    MOV AH,2  
    MOV DL,'3'  
    INT 21H  
    JMP RESET_AFTER_PRINT
PRINT_4: 
    MOV AH,2  
    MOV DL,'4'  
    INT 21H  
    JMP RESET_AFTER_PRINT
PRINT_5: 
    MOV AH,2  
    MOV DL,'5'    
    INT 21H  
    JMP RESET_AFTER_PRINT
PRINT_6: 
    MOV AH,2  
    MOV DL,'6'      
    INT 21H  
    JMP RESET_AFTER_PRINT
PRINT_7: 
    MOV AH,2  
    MOV DL,'7'  
    INT 21H  
    JMP RESET_AFTER_PRINT
PRINT_8: 
    MOV AH,2  
    MOV DL,'8'  
    INT 21H  
    JMP RESET_AFTER_PRINT
PRINT_9: 
    MOV AH,2  
    MOV DL,'9'  
    INT 21H  
    JMP RESET_AFTER_PRINT

; punctuation . , ? !
PRINT_DOT:   
    MOV AH,2  
    MOV DL,'.'  
    INT 21H  
    JMP RESET_AFTER_PRINT
PRINT_COMMA: 
    MOV AH,2  
    MOV DL,','  
    INT 21H  
    JMP RESET_AFTER_PRINT
PRINT_QMARK: 
    MOV AH,2  
    MOV DL,'?'  
    INT 21H  
    JMP RESET_AFTER_PRINT
PRINT_BANG:  
    MOV AH,2  
    MOV DL,'!'  
    INT 21H  
    JMP RESET_AFTER_PRINT
    

PRINT_UNKNOWN:
    MOV AH,2
    MOV DL,'?'
    INT 21H
    JMP RESET_AFTER_PRINT

RESET_AFTER_PRINT:
    MOV CODES[0],0
    MOV COUNT_DECODE_PERCHAR,0
    MOV INPUT_CHECKER[0],0
    JMP CHECK_INPUT_DECODE


;------------------- EXT -------------------
EXT:
    MOV AH, 9H
    MOV DX, OFFSET PRESS_ANY_KEY
    INT 21H

    MOV AH, 1H
    INT 21H

    JMP MAIN_MENU


;==================================================================
;====                 SHOW MORSE CODE LISTS                    ====
;==================================================================
    _MORSECODE:
            CALL CLEAR_SCREEN
            MOV AH, 9H
            MOV DX, OFFSET MORSE_LISTS
            INT 21H
            JMP EXT

    REAL_EXIT:
    .EXIT
END