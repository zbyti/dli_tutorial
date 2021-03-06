; Written in 2019 by Rob McMullen, https://playermissile.com/dli_tutorial/
; Copyright and related rights waived via CC0: https://creativecommons.org/publicdomain/zero/1.0/
        *= $3000

.include "hardware.s"

temp_color = $80

init
        ; load display list & fill with test data
        jsr init_static_screen_mode4

        ; set DLI on the final mode 4 line
        lda #$84
        sta dlist_static_mode4_24th_line

        ; load display list interrupt address
        ldx #>dli
        ldy #<dli
        jsr init_dli

        jmp forever

.include "util.s"
.include "util_dli.s"

dli     pha             ; save A & X registers to stack
        txa
        pha
        ldx #64         ; make 64 color changes
        lda #$5f        ; initial bright pink color
        sta WSYNC       ; first WSYNC gets us to start of scan line we want
?loop   sta COLBK       ; change background color
        sec
        sbc #1          ; make dimmer by decrementing luminance value
        dex             ; update iteration count
        sta WSYNC       ; make it the color change last ...
        sta WSYNC       ;   for two scan lines
        bne ?loop       ; sta doesn't affect processor flags so we are still checking result of dex
        lda #$00        ; reset background color to black
        sta COLBK
        pla             ; restore X & A registers from stack
        tax
        pla
        rti             ; always end DLI with RTI!

; tell DOS where to run the program when loaded
        * = $2e0
        .word init
