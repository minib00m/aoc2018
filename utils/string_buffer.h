#pragma once
#include <stdio.h>

struct string_buffer
{
    char **ptr;
    size_t size;
    size_t position;
};

void string_buffer_initialize(struct string_buffer *sb, size_t init_size);
void string_buffer_add_string(struct string_buffer *sb, char *string);
void string_buffer_add_copy_string(struct string_buffer *sb, const char *string);
void string_buffer_destroy(struct string_buffer *sb);
