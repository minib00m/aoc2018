#include <stdio.h>
#include <stdint.h>
#include <stdlib.h>

struct marble_node
{
    struct marble_node *prev;
    struct marble_node *next;
    int64_t value;
};

struct marble_node *create_first_two_marbles()
{
    struct marble_node *marble1 = malloc(sizeof(struct marble_node));
    struct marble_node *marble2 = malloc(sizeof(struct marble_node));
    marble1->next = marble2;
    marble1->prev = marble2;
    marble1->value = 0;
    marble2->next = marble1;
    marble2->prev = marble1;
    marble2->value = 1;
    return marble2;
}

struct marble_node *insert_marble_after(struct marble_node *marble, int64_t new_value)
{
    struct marble_node *new_marble = malloc(sizeof(struct marble_node));
    new_marble->next = marble->next;
    new_marble->prev = marble;
    new_marble->value = new_value;
    marble->next->prev = new_marble;
    marble->next = new_marble;
    return new_marble;
}

void destroy_marbles(struct marble_node *head)
{
    struct marble_node *next_node;
    head->prev->next = NULL; // break the cycle
    while (head->next != NULL) {
        next_node = head->next;
        free(head);
        head = next_node;
    }
    free(head);
}

int64_t remove_marble_at(struct marble_node **remove_head)
{
    struct marble_node *head = *remove_head;
    head->next->prev = head->prev;
    head->prev->next = head->next;
    int64_t removed_value = head->value;
    struct marble_node *new_head = head->next;
    free(head);
    *remove_head = new_head;
    return removed_value;
}

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
