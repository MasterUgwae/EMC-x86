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

nasm -f elf64 $ASM -o $OBJECT
ld $OBJECT -o $BASE
$BASE

