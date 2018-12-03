add_executable(part1 solution_part1.asm)
add_executable(part2 solution_part2.asm)

set_target_properties(part1 PROPERTIES LINKER_LANGUAGE NASM)
set_target_properties(part2 PROPERTIES LINKER_LANGUAGE NASM)
