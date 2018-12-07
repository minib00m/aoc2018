#include "string_buffer.h"
#include <stdlib.h>
#include <string.h>

void string_buffer_initialize(struct string_buffer *sb, size_t init_size)
{
    sb->size = init_size;
    sb->position = 0;
    sb->ptr = malloc(sb->size * sizeof(*sb->ptr));
}

static void double_buffer(struct string_buffer *sb)
{
    sb->size *= 2;
    sb->ptr = realloc(sb->ptr, sb->size * sizeof(*sb->ptr));
}

void string_buffer_add_string(struct string_buffer *sb, char *string)
{
    if (sb->position == sb->size) {
        double_buffer(sb);
    }
    sb->ptr[sb->position] = string;
    sb->position++;
}

void string_buffer_add_copy_string(struct string_buffer *sb, const char *string_to_copy)
{
    if (sb->position == sb->size) {
        double_buffer(sb);
    }
    char *new_string = malloc(strlen(string_to_copy) + 1);
    strcpy(new_string, string_to_copy);
    sb->ptr[sb->position] = new_string;
    sb->position++;
}

void string_buffer_destroy(struct string_buffer *sb)
{
    for (size_t i = 0; i < sb->position; i++) {
        free(sb->ptr[i]);
    }
    free(sb->ptr);
}
