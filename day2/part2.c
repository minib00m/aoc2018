#define _GNU_SOURCE
#include <stdio.h>
#include <stdlib.h>

struct strings_buffer
{
    char **ptr;
    size_t size;
};

void double_buffer(struct strings_buffer *buf)
{
    buf->size = buf->size * 2;
    buf->ptr = realloc(buf->ptr, buf->size * sizeof(*buf->ptr));
}

void print_most_similiar_strings(char **strings, size_t string_count);

int main()
{
    struct strings_buffer buf;
    buf.size = 8;
    buf.ptr = malloc(sizeof(*buf.ptr) * buf.size);

    char *input_string;
    size_t string_read_count = 0;
    while (scanf("%ms", &input_string) != EOF) {
        if (string_read_count == buf.size) {
            double_buffer(&buf);
        }
        buf.ptr[string_read_count] = input_string;
        string_read_count++;
    }

    print_most_similiar_strings(buf.ptr, string_read_count);

    for (size_t i = 0; i < string_read_count; i++) {
        free(buf.ptr[i]);
    }
    free(buf.ptr);
}
