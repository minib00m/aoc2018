#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>

struct marble_node
{
    struct marble_node *prev;
    struct marble_node *next;
    int64_t value;
};

struct marble_node *create_first_two_marbles();

struct marble_node *insert_marble_after(struct marble_node *marble, int64_t new_value);

void destroy_marbles(struct marble_node *head);

int64_t remove_marble_at(struct marble_node **remove_head);

int64_t calculate_winning_score(int64_t no_players, int64_t last_marble)
{
    struct marble_node *marble_head = create_first_two_marbles();

    int64_t *scores = calloc(no_players + 1, sizeof(int64_t));
    for (int64_t i = 2; i < last_marble; i++) {
        if (i % 23 == 0) {
            for (int64_t j = 0; j < 7; j++) {
                marble_head = marble_head->prev;
            }
            int64_t removed_value = remove_marble_at(&marble_head);
            scores[i % no_players] += removed_value + i;
        } else {
            marble_head = insert_marble_after(marble_head->next, i);
        }
    }

    int64_t max_score = 0;
    for (int64_t i = 0; i < no_players; i++) {
        max_score = max_score > scores[i] ? max_score : scores[i];
    }

    destroy_marbles(marble_head);
    free(scores);
    return max_score;
}

int main()
{
    int64_t no_players;
    int64_t last_marble;
    scanf("%ld players; last marble is worth %ld points", &no_players, &last_marble);
    printf("Part1, answer: %ld\n", calculate_winning_score(no_players, last_marble));
    printf("Part2, answer: %ld\n", calculate_winning_score(no_players, last_marble * 100));
}
