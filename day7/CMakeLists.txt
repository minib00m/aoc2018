add_executable(d7p1 part1.asm)
add_executable(d7p2 part2.asm)

set_target_properties(d7p1 PROPERTIES LINKER_LANGUAGE NASM)
set_target_properties(d7p2 PROPERTIES LINKER_LANGUAGE NASM)
