#!/bin/bash

if [ $# -ne 1 ]; then
	echo "Incorrect Args"
	exit 1
fi

ASM="$(pwd)/$1"
if [[ $ASM == *.asm ]]; then
	BASE="${ASM%.asm}"
else
	echo "File does not end in .asm"
	exit 1
fi

OBJECT="${BASE}.o"

nasm -f elf32 $ASM -o $OBJECT
ld -m elf_i386 $OBJECT -o $BASE
$BASE

