TARGETS = solution_part1

$(TARGETS):
	nasm -f elf64 $@.asm
	gcc -std=c99 -static -o $@ $@.o

clean:
	rm -f $(TARGETS).o $(TARGETS)
