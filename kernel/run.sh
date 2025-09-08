#!/bin/bash

# Assembled/compiles the files specified in 'link' then links them
# Each line consists of a file type, then a colon then the filename
# The filetypes are:
# a = assembly
# o = object
# r = 16 bit c
# p = 32 bit c
# l = 64 bit c

objects=()
location=$(dirname $(realpath $0))

while read -r line; do
    type=$(echo "$line" | cut -d':' -f1)
    name=$(echo "$line" | cut -d':' -f2-)
    file="${location}/$name"
    object="${file%.*}.o"

    case "$type" in
        a)
            objects+=($object)
            nasm -f bin "$file" -o $object || exit 1 ;;
        o)
            # Uses file instead of object in the case the file did not end in .o
            objects+=($file) ;;
        r)
            objects+=($object)
            gcc -m16 -ffreestanding -c "$file" -o "$object" || exit 1 ;;
        p)
            objects+=($object)
            gcc -m32 -ffreestanding -c "$file" -o "$object" || exit 1 ;;
        l)
            objects+=($object)
            gcc -m64 -ffreestanding -c "$file" -o "$object" || exit 1 ;;
        *)
            echo "'$file' cannot be compiled"
            exit 1 ;;
    esac

done < "${location}/link" || exit 1

output="${location}/kernel.bin"
# ld -T "${location}/linker.ld" -o "$output" "${objects[@]}" || exit 1
ld -o "$output" "${objects[@]}" || exit 1
# Run it with 256MiB memory (-cpu qemu64,+smep)
qemu-system-x86_64 -kernel "$output" -m 256
