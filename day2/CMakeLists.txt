add_executable(d2p1 part1.asm)
add_executable(d2p2 part2.c part2.asm)

set_target_properties(d2p1 PROPERTIES LINKER_LANGUAGE NASM)
set_target_properties(d2p2 PROPERTIES LINKER_LANGUAGE NASM)
