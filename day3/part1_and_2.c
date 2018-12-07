#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>

struct claim
{
    int64_t no;
    int64_t top_x;
    int64_t top_y;
    int64_t width;
    int64_t height;
};

struct claims_buffer
{
    struct claim *ptr;
    size_t size;
};

void realloc_claims_buffer(struct claims_buffer* cb)
{
    cb->size *= 2;
    cb->ptr = realloc(cb->ptr, cb->size * sizeof(*cb->ptr));
}

struct overlap_result
{
    int64_t overlapped_claims_area;
    int64_t loner_no;
};

struct overlap_result claims_area_overlap(struct claim *c, size_t size, struct overlap_result* res);

int main()
{
    struct claim clm;

    struct claims_buffer cb;
    cb.size = 8;
    cb.ptr = malloc(sizeof(*cb.ptr) * cb.size);
    size_t claims_count = 0;
    while (scanf("#%ld @ %ld,%ld: %ldx%ld\n", &clm.no, &clm.top_x, &clm.top_y, &clm.width, &clm.height) != EOF) {
        if (claims_count >= cb.size) {
            realloc_claims_buffer(&cb);
        }
        cb.ptr[claims_count] = clm;
        claims_count++;
    }

    struct overlap_result res;
    claims_area_overlap(cb.ptr, claims_count, &res);
    printf("part1: %lu\n", res.overlapped_claims_area);
    printf("part2: %lu\n", res.loner_no);

    free(cb.ptr);
}
