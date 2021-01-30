/* BAREMETAL set: set sp, no command line arguments -> libcopper
   BAREMETAL unset: inherit sp with command line arguments from caller -> libplastic
 */

        .syntax unified

        .data
heap_end:       .word 0
errno:          .word 0

        .text
        .thumb
        .cpu cortex-m0



@ _start
@
@ Program entry point: call main(), then exit()
@
        .thumb_func
        .global _start
_start:

        @ clear bss (size must be a multiple of 16)
        ldr     r0, .Lstart
        ldr     r1, .Lend
        movs    r2, #0
1:      str     r2, [r0, #0]
        str     r2, [r0, #4]
        str     r2, [r0, #8]
        str     r2, [r0, #12]
        adds    r0, #16
        cmp     r0, r1
        blt     1b



        ldr     r0, [sp]
        add     r1, sp, #4
        bl      main
        @ fallthrough to exit


@ void exit(int status)
@
@ Exit from program: breakpoint 0
@
        .thumb_func
        .global _exit
_exit:
        bkpt    #0

                .align 2
.Lstack:        .word __stack           @ from linker file
.Lstart:        .word __bss_start__     @ from linker file
.Lend:          .word __bss_end__       @ from linker file



@ int *__errno()
@
@ Return the adress of errno (important for reentrant functions)
        .thumb_func
        .global __errno
__errno:
        ldr     r0, .Lerrno
        bx      lr

                .align 2
.Lerrno:        .word errno



@ _write(int file, char *buf, int nbytes)
@
        .thumb_func
        .global _write
_write:
        mov     r3, r2
        b       2f
1:
        ldrb    r0, [r1]
        svc     #1
        adds    r1, #1
        subs    r2, #1
2:
        cmp     r2, #0
        bhi     1b
        mov     r0, r3
        bx lr






        .thumb_func
        .global _close
_close:
        movs    r0, #0
        subs    r0, #1
        bx lr



        .thumb_func
        .global _fini
_fini:
        movs    r0, #0
        bx      lr



        .thumb_func
        .global _fstat
_fstat:
        movs    r0, #0
        bx      lr



        .thumb_func
        .global _getpid
_getpid:
        bx      lr



        .thumb_func
        .global _gettimeofday
_gettimeofday:
        bx      lr



        .thumb_func
        .global _isatty
_isatty:

        movs    r0, #1
        bx lr



        .thumb_func
        .global _kill
_kill:
        bx      lr



        .thumb_func
        .global _lseek
_lseek:
        movs    r0, #0
        bx      lr



        .thumb_func
        .global _open
_open:
        movs    r0, #0
        subs    r0, #1
        bx lr



        .thumb_func
        .global _read
_read:
        movs    r0, #0
        bx      lr




@ caddr_t _sbrk(int increment)
@
        .thumb_func
        .global _sbrk
_sbrk:
        ldr     r1, .Lheap_end
        ldr     r2, [r1]
        adds    r3, r0, r2
        bcs     .Loutofmem
        mov     r0, r2
        str     r3, [r1]
        bx      lr

.Loutofmem:
        movs    r0, #0
        bx      lr



                .align 2
.Lheap_end:     .word heap_end
