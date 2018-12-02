OBJECTS = solution_part2.o solution_part1.o
TARGETS = solution_part2 solution_part1

all: $(TARGETS)

solution_part1: solution_part1.o
	gcc -g -std=c99 -no-pie -fsanitize=address -fno-omit-frame-pointer -o $@ $<

solution_part2: solution_part2.o
	gcc -g -std=c99 -no-pie -fsanitize=address -fno-omit-frame-pointer -o $@ $<

%.o: %.asm
	nasm -f elf64 $<

clean:
	rm -f $(TARGETS) $(OBJECTS)
