#!/bin/sh

if [ $# -eq 0 ] 
then
    echo "Usage: $0 <target> ..."
    echo
    echo "<target>"
    echo "  all             Build the emulator"
    echo "  run <elf-file>  Run elf-file in emulator"
    exit 1
fi


while [ $# -ne 0 ]
do
    case $1 in
        all)
            clang -O2 -Wall -o m0emu.x m0emu.c memory.c share.c
            ;;
        run)
            shift
            ./m0emu.x "$@"
            exit
            ;;
        *)
            echo "Unknown target $1. Stop."
            exit 1
            ;;
    esac
    shift
done


