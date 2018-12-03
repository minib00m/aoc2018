add_executable(d1p1 part1.asm)
add_executable(d1p2 part2.asm)

set_target_properties(d1p1 PROPERTIES LINKER_LANGUAGE NASM)
set_target_properties(d1p2 PROPERTIES LINKER_LANGUAGE NASM)
