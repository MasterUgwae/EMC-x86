#!/bin/bash

if [ $# -eq 0 ]; then
	echo "Must have at least one argument"
	exit 1
fi

objects=()

for arg in "${@}"; do
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
done

output="$(pwd)/${1%.*}.bin"
ld "${objects[@]}" -o $output || exit 1
echo $output
