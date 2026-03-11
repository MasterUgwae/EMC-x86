#!/bin/bash

# Assembles the assembly files it is given into object files in the same dir
# and name as the file it was given. Links together all object files given (and
# the ones it assembled) into a binary file in the directory and name of the
# first argument. If given '--' as an argument, all arguments after it will be
# passed to the executeable.
tmux
if [ $# -eq 0 ]; then
    echo "Must have at least one argument"
    exit 1
fi

objects=()
args=()
is_arg=false

for arg in "${@}"; do
    if [ $is_arg = true ]; then
        args+=($arg)
    elif [[ $arg = "--" ]]; then
        if [[ ${#objects[@]} = 0 ]]; then
            echo "Must give at least one file before the program arguments"
            exit 1
        else
            is_arg=true
        fi
    else
        file="$(pwd)/$arg"

        case $file in
            *.asm | *.s | *.S)
                object="${file%.*}.o"
                objects+=($object)
                nasm -f elf64 $file -o $object || exit 1 ;;
            *.o | *.a | *.so)
                objects+=($file) ;;
            *)
                echo "'$file' does not end in a correct file extention"
                exit 1 ;;
        esac
    fi
done

output="$(pwd)/${1%.*}.bin"
ld "${objects[@]}" -o $output || exit 1
$output "${args[@]}"
