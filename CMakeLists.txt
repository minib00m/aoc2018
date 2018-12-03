cmake_minimum_required(VERSION 3.0)
project(AdventOfCode2018 C)

enable_language(ASM_NASM)
set(CMAKE_ASM_NASM_FLAGS "-f elf64 -F dwarf -g -I ${PROJECT_SOURCE_DIR}")
set(CMAKE_C_FLAGS "-std=c99 -no-pie -fsanitize=address -fno-omit-frame-pointer")
set(CMAKE_NASM_LINK_EXECUTABLE "gcc -g ${CMAKE_C_FLAGS} -o <TARGET> <OBJECTS>")

add_subdirectory(day1)
add_subdirectory(day2)
