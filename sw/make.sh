#!/bin/sh

if [ $# -eq 0 ] 
then
    echo "Usage: $0 <command> ..."
    echo
    echo "General commands>"
    echo "  all           Build examples"
    echo "  run <elffile> Run compiled binary"
    echo
    echo "Build examples"
    echo "  argv"
    echo "  hello"
    echo "  printf"
    echo "  check_qfp     Compare qfp against gcc softfloat"
    echo "  cmp_m0fp_qfp  Compare m0fp against qfp"
    echo
    echo "$0 FOO run examples/FOO.m0.elf"
    exit 1
fi


# $1 main filename without extension
# $2 additional source files
build_c () {
    arm-none-eabi-gcc -mcpu=cortex-m0 -mthumb -O2 \
        crt.S $2 -o $1.m0.elf $1.c \
        -static -nostdlib -Tminimal.ld -lc -lm -lgcc 
}


while [ $# -ne 0 ]
do
    case $1 in
        argv|hello|printf)
            build_c examples/$1
            ;;
        check_qfp)
            build_c float/$1 float/qfplib-m0-full.s
            ;;
        cmp_m0fp_qfp)
            build_c float/$1 "float/qfplib-m0-full.s float/m0fp.S"
            ;;
        fp_size)
            arm-none-eabi-gcc -mcpu=cortex-m0 -mthumb \
                -c float/qfplib-m0-full.s -o float/qfplib-m0-full.o
            arm-none-eabi-objdump -h float/qfplib-m0-full.o
            arm-none-eabi-gcc -mcpu=cortex-m0 -mthumb \
                -c float/m0fp.S -o float/m0fp.o
            arm-none-eabi-objdump -h float/m0fp.o
            ;;
        run)
            ../m0emu.x $2
            shift
            ;;
        all)
            build_c examples/hello
            build_c examples/argv
            build_c examples/printf
            ;;
        clean)
            rm -f examples/*.elf
            rm -f float/*.elf float/*.o
            ;;
        *)
            echo "Unknown command $1. Stop."
            exit 1
            ;;
    esac
    shift
done

