// 贪吃蛇规则：独立于 UIKit，方便验证碰撞、转向和食物生成。
#ifndef CRMSnakeRules_h
#define CRMSnakeRules_h
#include <stdbool.h>
#include <stdint.h>
#include <string.h>

enum { CRMSnakeColumns = 14, CRMSnakeRows = 18, CRMSnakeCapacity = 252 };
typedef enum { CRMSnakeUp, CRMSnakeRight, CRMSnakeDown, CRMSnakeLeft } CRMSnakeDirection;
typedef enum { CRMSnakePlaying, CRMSnakeLost, CRMSnakeWon } CRMSnakeOutcome;
typedef struct {
    int body[CRMSnakeCapacity];
    int length, food, direction, turns[2], turnCount;
    uint32_t random;
    CRMSnakeOutcome outcome;
} CRMSnakeGame;

static inline bool CRMSnakeOccupies(const CRMSnakeGame *game, int cell) {
    for (int i = 0; i < game->length; i++) if (game->body[i] == cell) return true;
    return false;
}

static inline void CRMSnakePlaceFood(CRMSnakeGame *game) {
    int freeCells[CRMSnakeCapacity], count = 0;
    for (int cell = 0; cell < CRMSnakeCapacity; cell++) {
        if (!CRMSnakeOccupies(game, cell)) freeCells[count++] = cell;
    }
    if (!count) { game->food = -1; game->outcome = CRMSnakeWon; return; }
    // 从空格中直接抽取，接近满盘时也不会陷入随机重试循环。
    game->random ^= game->random << 13;
    game->random ^= game->random >> 17;
    game->random ^= game->random << 5;
    game->food = freeCells[game->random % count];
}

static inline void CRMSnakeStart(CRMSnakeGame *game, uint32_t seed) {
    memset(game, 0, sizeof(*game));
    game->length = 4;
    game->direction = CRMSnakeRight;
    game->random = seed ? seed : 1;
    int head = (CRMSnakeRows / 2) * CRMSnakeColumns + CRMSnakeColumns / 2;
    for (int i = 0; i < game->length; i++) game->body[i] = head - i;
    CRMSnakePlaceFood(game);
}

static inline bool CRMSnakeTurn(CRMSnakeGame *game, int direction) {
    if (game->outcome != CRMSnakePlaying || direction < 0 || direction > 3 || game->turnCount == 2) return false;
    int previous = game->turnCount ? game->turns[game->turnCount - 1] : game->direction;
    if (previous == direction || (previous + 2) % 4 == direction) return false;
    // 快速连续转弯按步执行，不能在一个移动周期内直接掉头。
    game->turns[game->turnCount++] = direction;
    return true;
}

static inline void CRMSnakeStep(CRMSnakeGame *game) {
    if (game->outcome != CRMSnakePlaying) return;
    if (game->turnCount) {
        game->direction = game->turns[0];
        game->turns[0] = game->turns[1];
        game->turnCount--;
    }
    const int dx[] = {0, 1, 0, -1}, dy[] = {-1, 0, 1, 0};
    int x = game->body[0] % CRMSnakeColumns + dx[game->direction];
    int y = game->body[0] / CRMSnakeColumns + dy[game->direction];
    if (x < 0 || x >= CRMSnakeColumns || y < 0 || y >= CRMSnakeRows) { game->outcome = CRMSnakeLost; return; }
    int next = y * CRMSnakeColumns + x;
    bool grows = next == game->food;
    // 不吃食物时尾格本步会腾出，允许蛇头走入旧尾格。
    for (int i = 0; i < game->length - (grows ? 0 : 1); i++) {
        if (game->body[i] == next) { game->outcome = CRMSnakeLost; return; }
    }
    if (grows) game->length++;
    for (int i = game->length - 1; i > 0; i--) game->body[i] = game->body[i - 1];
    game->body[0] = next;
    if (grows) CRMSnakePlaceFood(game);
}
#endif
