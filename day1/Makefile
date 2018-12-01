OBJECTS = solution.o

main: $(OBJECTS)
	gcc -std=c99 -static -o main $(OBJECTS)

%.o: %.asm
	nasm -f elf64 $<

clean:
	rm -f $(OBJECTS) main
