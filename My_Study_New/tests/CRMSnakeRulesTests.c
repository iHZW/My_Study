#include "../My_Study/TabsIndexVc/CRMSnakeRules.h"
#include <assert.h>
#include <stdio.h>

static void testMovementAndFood(void) {
    CRMSnakeGame game;
    CRMSnakeStart(&game, 42);
    assert(game.length == 4 && game.outcome == CRMSnakePlaying);
    assert(!CRMSnakeOccupies(&game, game.food));
    int head = game.body[0];
    game.food = 0;
    CRMSnakeStep(&game);
    assert(game.body[0] == head + 1 && game.length == 4);
    game.food = game.body[0] + 1;
    CRMSnakeStep(&game);
    assert(game.length == 5 && !CRMSnakeOccupies(&game, game.food));
}

static void testQueuedTurns(void) {
    CRMSnakeGame game;
    CRMSnakeStart(&game, 1);
    int head = game.body[0];
    game.food = 0;
    assert(!CRMSnakeTurn(&game, CRMSnakeLeft));
    assert(!CRMSnakeTurn(&game, CRMSnakeRight));
    assert(!CRMSnakeTurn(&game, -1));
    assert(!CRMSnakeTurn(&game, 4));
    assert(CRMSnakeTurn(&game, CRMSnakeUp));
    assert(!CRMSnakeTurn(&game, CRMSnakeDown));
    assert(CRMSnakeTurn(&game, CRMSnakeLeft));
    assert(!CRMSnakeTurn(&game, CRMSnakeDown));
    CRMSnakeStep(&game);
    assert(game.body[0] == head - CRMSnakeColumns && game.turnCount == 1);
    CRMSnakeStep(&game);
    assert(game.body[0] == head - CRMSnakeColumns - 1 && game.turnCount == 0);
}

static void testCollisions(void) {
    CRMSnakeGame game;
    CRMSnakeStart(&game, 1);
    game.body[0] = CRMSnakeColumns - 1;
    game.food = 0;
    CRMSnakeStep(&game);
    assert(game.outcome == CRMSnakeLost);
    CRMSnakeGame stopped = game;
    CRMSnakeStep(&game);
    assert(memcmp(&stopped, &game, sizeof(game)) == 0);
    assert(!CRMSnakeTurn(&game, CRMSnakeUp));

    game = (CRMSnakeGame){.body = {30, 31, 45, 44, 43, 29}, .length = 6, .food = 0, .direction = CRMSnakeDown};
    CRMSnakeStep(&game);
    assert(game.outcome == CRMSnakeLost);
    // 绕回旧尾格合法：尾部会在同一步移走。
    game = (CRMSnakeGame){.body = {30, 44, 43, 29}, .length = 4, .food = 0, .direction = CRMSnakeUp};
    assert(CRMSnakeTurn(&game, CRMSnakeLeft));
    CRMSnakeStep(&game);
    assert(game.outcome == CRMSnakePlaying && game.body[0] == 29 && game.length == 4);
}

static void testFullBoard(void) {
    CRMSnakeGame game = {.length = CRMSnakeCapacity - 1, .direction = CRMSnakeLeft, .random = 123};
    int index = 0;
    for (int row = 0; row < CRMSnakeRows; row++) {
        for (int offset = 0; offset < CRMSnakeColumns; offset++) {
            int column = row % 2 ? CRMSnakeColumns - 1 - offset : offset;
            int cell = row * CRMSnakeColumns + column;
            if (cell) game.body[index++] = cell;
        }
    }
    CRMSnakePlaceFood(&game);
    assert(game.food == 0);
    CRMSnakeStep(&game);
    assert(game.outcome == CRMSnakeWon && game.length == CRMSnakeCapacity && game.food == -1);
    CRMSnakeStart(&game, 0);
    assert(game.length == 4 && game.turnCount == 0 && game.outcome == CRMSnakePlaying);
}

static void testRandomGames(void) {
    for (uint32_t seed = 0; seed < 2000; seed++) {
        CRMSnakeGame game;
        CRMSnakeStart(&game, seed);
        uint32_t random = seed;
        for (int step = 0; step < 500 && game.outcome == CRMSnakePlaying; step++) {
            random = random * 1664525u + 1013904223u;
            CRMSnakeTurn(&game, (random >> 16) % 4);
            CRMSnakeStep(&game);
            assert(game.length >= 4 && game.length <= CRMSnakeCapacity);
            for (int i = 0; i < game.length; i++) {
                assert(game.body[i] >= 0 && game.body[i] < CRMSnakeCapacity);
                for (int j = 0; j < i; j++) assert(game.body[i] != game.body[j]);
            }
            if (game.outcome != CRMSnakeWon) assert(game.food >= 0 && game.food < CRMSnakeCapacity && !CRMSnakeOccupies(&game, game.food));
        }
    }
}

int main(void) {
    testMovementAndFood();
    testQueuedTurns();
    testCollisions();
    testFullBoard();
    testRandomGames();
    puts("通过：移动成长、方向缓冲、防掉头、撞墙撞身、旧尾格、满盘通关、重开及2000局随机测试。");
}
