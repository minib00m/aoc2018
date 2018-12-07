#define _GNU_SOURCE
#include "string_buffer.h"
#include <errno.h>
#include <stdlib.h>
#include <string.h>
#include <stdio.h>
#include <time.h>

struct nap_entry
{
    int64_t guard_no;
    char asleep_in_min[60];
};

struct nap_buffer
{
    struct nap_entry *ptr;
    size_t size;
    size_t position;
};

void nap_buffer_initialize(struct nap_buffer *nb, size_t init_size)
{
    nb->size = init_size;
    nb->ptr = malloc(nb->size * sizeof(*nb->ptr));
    nb->position = 0;
}

void nap_buffer_double_buffer(struct nap_buffer *nb)
{
    nb->size *= 2;
    nb->ptr = realloc(nb->ptr, nb->size * sizeof(*nb->ptr));
}

void nap_buffer_add_nap_entry(struct nap_buffer *nb, struct nap_entry *ne)
{
    // if guard is present in nap buffer, add asleep times to it
    // otherwise add new entry
    for (size_t i = 0; i < nb->position; i++) {
        if (nb->ptr[i].guard_no == ne->guard_no) {
            for (size_t min = 0; min < 60; min++) {
                nb->ptr[i].asleep_in_min[min] += ne->asleep_in_min[min];
            }
            return;
        }
    }
    if (nb->position == nb->size) {
        nap_buffer_double_buffer(nb);
    }
    nb->ptr[nb->position] = *ne;
    nb->position++;
}

void nap_buffer_destroy(struct nap_buffer *nb)
{
    free(nb->ptr);
}

static int32_t compare_strings(const void *lhs, const void *rhs)
{
    const char *lhs_s = *(const char**)lhs;
    const char *rhs_s = *(const char**)rhs;
    return strcmp(lhs_s, rhs_s);
}

static void read_input_strings(struct string_buffer *sb)
{
    char *line = NULL;
    size_t line_len = 0;

    while (getline(&line, &line_len, stdin) != EOF) {
        char *newline_pos = strchr(line, '\n');
        if (newline_pos) {
            *newline_pos = 0;
        }
        string_buffer_add_copy_string(sb, line);
    }
    free(line);
}

int main()
{
    struct string_buffer sb;
    string_buffer_initialize(&sb, 8);
    read_input_strings(&sb);
    qsort(sb.ptr, sb.position, sizeof(*sb.ptr), compare_strings);

    struct nap_entry ne = {0};
    struct nap_buffer nb;
    nap_buffer_initialize(&nb, 8);

    int32_t from_minute;
    for (size_t i = 0; i < sb.position; i++) {
        struct tm tp = {0};
        sscanf(sb.ptr[i], "[%4d-%2d-%2d %2d:%2d]", &tp.tm_year, &tp.tm_mon, &tp.tm_mday, &tp.tm_hour, &tp.tm_min);

        const char *description_start = sb.ptr[i];
        while (*++description_start != ']') {} // one past ] character
        ++description_start; // skip ]
        ++description_start; // skip space

        if (!strcmp(description_start, "wakes up")) {
            int32_t to_minute = tp.tm_min;
            for (int32_t i = from_minute; i < to_minute; i++) {
                ne.asleep_in_min[i]++;
            }
            nap_buffer_add_nap_entry(&nb, &ne);
        } else if (!strcmp(description_start, "falls asleep")) {
            from_minute = tp.tm_min;
            memset(ne.asleep_in_min, 0, 60);
        } else {
            memset(&ne, 0, sizeof(ne));
            int64_t guard_no;
            sscanf(description_start, "Guard #%ld begins shift", &guard_no);
            ne.guard_no = guard_no;
        }
    }

    {
        int64_t sleepy_guard_no = 0;
        int64_t sleepy_mins = 0;
        int64_t most_sleepy_min = 0;
        for (size_t i = 0; i < nb.position; i++) {
            int64_t mins_tmp = 0;
            int64_t most_sleepy_min_for_guard = 0;
            int64_t max_nappy_min = 0;
            for (int64_t min = 0; min < 60; min++) {
                int64_t naps_in_min = nb.ptr[i].asleep_in_min[min];
                if (naps_in_min > max_nappy_min) {
                    max_nappy_min = naps_in_min;
                    most_sleepy_min_for_guard = min;
                }
                mins_tmp += naps_in_min;
            }
            if (mins_tmp > sleepy_mins) {
                sleepy_guard_no = nb.ptr[i].guard_no;
                sleepy_mins = mins_tmp;
                most_sleepy_min = most_sleepy_min_for_guard;
            }
        }
        printf("part1: %ld\n", sleepy_guard_no * most_sleepy_min);
    }

    {
        int64_t sleepy_guard_no = 0;
        int64_t most_sleepy_min = 0;
        int64_t max_naps_in_min = 0;
        for (size_t i = 0;i < nb.position; i++) {
            for (int64_t min = 0; min < 60; min++) {
                int64_t naps_in_min = nb.ptr[i].asleep_in_min[min];
                if (naps_in_min > max_naps_in_min) {
                    sleepy_guard_no = nb.ptr[i].guard_no;
                    most_sleepy_min = min;
                    max_naps_in_min = naps_in_min;
                }
            }
        }
        printf("part2: %ld\n", sleepy_guard_no * most_sleepy_min);
    }

    nap_buffer_destroy(&nb);
    string_buffer_destroy(&sb);
}
