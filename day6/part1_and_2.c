#include <stdio.h>
#include <stdlib.h>
#include <limits.h>
#include <stdint.h>

struct point
{
    int32_t x;
    int32_t y;
};

struct point_buffer
{
    struct point *ptr;
    int32_t size;
    int32_t position;
};

static void point_buffer_initialize(struct point_buffer *pb, int32_t init_size)
{
    pb->size = init_size;
    pb->ptr = malloc(pb->size * sizeof(*pb->ptr));
    pb->position = 0;
}

static void point_buffer_double_buffer(struct point_buffer *pb)
{
    pb->size *= 2;
    pb->ptr = realloc(pb->ptr, pb->size * sizeof(*pb->ptr));
}

static void point_buffer_add_point(struct point_buffer *pb, struct point *p)
{
    if (pb->position == pb->size) {
        point_buffer_double_buffer(pb);
    }
    pb->ptr[pb->position] = *p;
    pb->position++;
}

static void point_buffer_destroy(struct point_buffer *pb)
{
    free(pb->ptr);
}

struct distance_cell
{
    int32_t min_distance;
    int32_t is_alone;
    int32_t alone_id;
    int32_t total_distance;
};

char *calculate_border_points(struct distance_cell *dc, int32_t max_x, int32_t max_y, int32_t points_count);

int32_t *calculate_point_areas(struct distance_cell *dc, int64_t all_cells, int64_t points_count);

void calculate_cell_distances(struct distance_cell *dc, struct point_buffer *pb, int64_t max_x, int64_t max_y)
{
    for (int32_t i = 0; i < max_x; i++) {
        for (int32_t j = 0; j < max_y; j++) {
            for (int32_t p_idx = 0; p_idx < pb->position; p_idx++) {
                int32_t px = pb->ptr[p_idx].x;
                int32_t py = pb->ptr[p_idx].y;
                int dist = abs(px - i) + abs(py - j);

                int32_t dc_idx = j * max_x + i;
                dc[dc_idx].total_distance += dist;
                if (dc[dc_idx].min_distance > dist) {
                    dc[dc_idx].min_distance = dist;
                    dc[dc_idx].is_alone = 1;
                    dc[dc_idx].alone_id = p_idx;
                } else if (dc[dc_idx].min_distance == dist) {
                    dc[dc_idx].is_alone = 0;
                }
            }
        }
    }
}

int main()
{
    int32_t max_x = 0, max_y = 0;

    struct point_buffer pb;
    point_buffer_initialize(&pb, 8);
    struct point p;

    while (1) {
        if (scanf("%d", &p.x) == EOF) {
            break;
        }
        scanf("%*c");
        scanf("%d", &p.y);
        max_x = max_x < p.x ? p.x : max_x;
        max_y = max_y < p.y ? p.y : max_y;
        point_buffer_add_point(&pb, &p);
    }

    // account for a border
    max_x++;
    max_y++;

    struct distance_cell *dc = malloc(max_x * max_y * sizeof(struct distance_cell));

    for (int32_t i = 0; i < max_x; i++) {
        for (int32_t j = 0; j < max_y; j++) {
            int32_t dc_idx = j * max_x + i;
            dc[dc_idx].min_distance = INT_MAX;
            dc[dc_idx].total_distance = 0;
        }
    }

    calculate_cell_distances(dc, &pb, max_x, max_y);

    int32_t *point_area = calculate_point_areas(dc, max_x * max_y, pb.position);
    char *border_point = calculate_border_points(dc, max_x, max_y, pb.position);
    int32_t max_non_inf_area = 0;
    int32_t close_area = 0;
    for (int32_t p_idx = 0; p_idx < pb.position; p_idx++) {
        if (border_point[p_idx]) {
            continue;
        }
        max_non_inf_area = max_non_inf_area > point_area[p_idx] ? max_non_inf_area : point_area[p_idx];
    }

    for (int32_t i = 0; i < max_x * max_y; i++) {
        if (dc[i].total_distance < 10000) {
            close_area++;
        }
    }
    printf("part1: %d\n", max_non_inf_area);
    printf("part2: %d\n", close_area);

    free(point_area);
    free(border_point);
    free(dc);
    point_buffer_destroy(&pb);
}
