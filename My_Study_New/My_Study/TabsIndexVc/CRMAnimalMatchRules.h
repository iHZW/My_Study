// 动物堆叠三消规则：无 UIKit 依赖，界面和命令行测试共用。
#ifndef CRMAnimalMatchRules_h
#define CRMAnimalMatchRules_h

#include <stdbool.h>
#include <stdint.h>
#include <string.h>
#include <math.h>

enum { CRMAnimalMaxCards = 90, CRMAnimalSlots = 6, CRMAnimalKinds = 8 };
typedef enum { CRMAnimalPlaying, CRMAnimalWon, CRMAnimalLost } CRMAnimalOutcome;
typedef struct {
    double x, y;
    int layer, kind;
    bool removed;
} CRMAnimalCard;
typedef struct {
    CRMAnimalCard cards[CRMAnimalMaxCards];
    int solution[CRMAnimalMaxCards];
    int tray[CRMAnimalSlots];
    int count, trayCount, remaining, level;
    bool pending;
    CRMAnimalOutcome outcome;
} CRMAnimalGame;

static inline uint32_t CRMAnimalRandom(uint32_t *state, uint32_t bound) {
    *state ^= *state << 13;
    *state ^= *state >> 17;
    *state ^= *state << 5;
    return *state % bound;
}

static inline bool CRMAnimalIsOpen(const CRMAnimalGame *game, int index) {
    if (index < 0 || index >= game->count || game->cards[index].removed) return false;
    const CRMAnimalCard *card = &game->cards[index];
    for (int i = 0; i < game->count; i++) {
        const CRMAnimalCard *other = &game->cards[i];
        if (!other->removed && other->layer > card->layer &&
            fabs(other->x - card->x) < 1 && fabs(other->y - card->y) < 1) return false;
    }
    return true;
}

static inline void CRMAnimalStart(CRMAnimalGame *game, int level, uint32_t seed) {
    memset(game, 0, sizeof(*game));
    game->level = level == 1 ? 1 : 2;
    uint32_t random = seed ? seed : 1;
    int columns = 4;
    int rows = game->level == 1 ? 3 : 6;
    int layers = game->level == 1 ? 2 : 6;
    int kinds = game->level == 1 ? 3 : 8;
    const int easyCounts[] = {12, 6};
    const int hardCounts[] = {20, 17, 14, 12, 9, 6};
    for (int layer = 0; layer < layers; layer++) {
        // 每层使用不同的聚集中心和随机轮廓，不再把同一个矩形整层复制。
        double scores[24];
        bool selected[24] = {false};
        double centerX = 1.0 + CRMAnimalRandom(&random, 101) / 100.0;
        double centerY = (rows - 1) * 0.5 + (int)CRMAnimalRandom(&random, 101) / 100.0 - 0.5;
        for (int cell = 0; cell < columns * rows; cell++) {
            double dx = cell % columns - centerX;
            double dy = cell / columns - centerY;
            scores[cell] = dx * dx + dy * dy * 0.65 + CRMAnimalRandom(&random, 301) / 100.0;
        }
        int target = game->level == 1 ? easyCounts[layer] : hardCounts[layer];
        for (int chosen = 0; chosen < target; chosen++) {
            int best = -1;
            for (int cell = 0; cell < columns * rows; cell++) {
                if (!selected[cell] && (best < 0 || scores[cell] < scores[best])) best = cell;
            }
            selected[best] = true;
        }
        for (int row = 0; row < rows; row++) {
            for (int column = 0; column < columns; column++) {
                if (!selected[row * columns + column]) continue;
                CRMAnimalCard *card = &game->cards[game->count++];
                card->x = (game->level == 1 ? 0 : 1.05) + column * 1.06 + ((row + layer) % 2) * 0.28;
                card->y = row * 1.06 + (layer % 2) * 0.38;
                card->layer = layer;
            }
        }
        if (game->level == 2) {
            // 两侧的阶梯牌堆逐张揭开，作为主堆之外的取牌选择。
            // 与主堆留出间隔；同层卡片不会相互覆盖，视觉与点击规则一致。
            CRMAnimalCard *left = &game->cards[game->count++];
            left->x = 0;
            left->y = 3.9 + layer * 0.15;
            left->layer = layer;
            CRMAnimalCard *right = &game->cards[game->count++];
            right->x = 5.65;
            right->y = 3.0 + layer * 0.15;
            right->layer = layer;
        }
    }
    game->remaining = game->count;

    // 先生成符合遮挡关系的移除顺序，再为该顺序分配容量安全的牌型。
    // 因此随机化不会破坏初局至少存在一条通关路径的约束。
    for (int step = 0; step < game->count; step++) {
        int candidates[CRMAnimalMaxCards], count = 0;
        for (int i = 0; i < game->count; i++) {
            if (CRMAnimalIsOpen(game, i)) candidates[count++] = i;
        }
        int index = candidates[CRMAnimalRandom(&random, (uint32_t)count)];
        game->solution[step] = index;
        game->cards[index].removed = true;
    }
    int left[CRMAnimalKinds] = {0}, held[CRMAnimalKinds] = {0}, occupied = 0;
    for (int group = 0; group < game->count / 3; group++) left[group % kinds] += 3;
    for (int step = 0; step < game->count; step++) {
        int candidates[CRMAnimalKinds], count = 0, active = 0;
        for (int kind = 0; kind < kinds; kind++) if (held[kind]) active++;
        for (int kind = 0; kind < kinds; kind++) {
            if (!left[kind]) continue;
            // 入门关一次只收一种；挑战关允许交错收集，最多暂存五张。
            if (!held[kind] && active >= (game->level == 1 ? 1 : 3)) continue;
            if (occupied == CRMAnimalSlots - 1 && held[kind] != 2) continue;
            candidates[count++] = kind;
        }
        int kind = candidates[CRMAnimalRandom(&random, (uint32_t)count)];
        game->cards[game->solution[step]].kind = kind;
        left[kind]--;
        held[kind]++;
        occupied++;
        if (held[kind] == 3) { held[kind] = 0; occupied -= 3; }
    }
    for (int i = 0; i < game->count; i++) game->cards[i].removed = false;
}

// 收集与结算分开，让界面先播放入槽动画。pending 阻止动画期间重复点击。
static inline bool CRMAnimalSelect(CRMAnimalGame *game, int index) {
    if (game->outcome != CRMAnimalPlaying || game->pending ||
        game->trayCount >= CRMAnimalSlots || !CRMAnimalIsOpen(game, index)) return false;
    int kind = game->cards[index].kind, insertion = game->trayCount;
    for (int i = 0; i < game->trayCount; i++) {
        if (game->cards[game->tray[i]].kind == kind) insertion = i + 1;
    }
    for (int i = game->trayCount; i > insertion; i--) game->tray[i] = game->tray[i - 1];
    game->tray[insertion] = index;
    game->trayCount++;
    game->cards[index].removed = true;
    game->remaining--;
    game->pending = true;
    return true;
}

static inline int CRMAnimalSettle(CRMAnimalGame *game) {
    if (!game->pending) return 0;
    int counts[CRMAnimalKinds] = {0}, matched = -1;
    for (int i = 0; i < game->trayCount; i++) {
        int kind = game->cards[game->tray[i]].kind;
        if (++counts[kind] == 3) matched = kind;
    }
    if (matched >= 0) {
        int kept = 0;
        for (int i = 0; i < game->trayCount; i++) {
            if (game->cards[game->tray[i]].kind != matched) game->tray[kept++] = game->tray[i];
        }
        game->trayCount = kept;
    }
    // 第六张能三消时不判负，必须先消除，再判断槽满或通关。
    game->pending = false;
    if (game->remaining == 0 && game->trayCount == 0) game->outcome = CRMAnimalWon;
    else if (game->trayCount == CRMAnimalSlots) game->outcome = CRMAnimalLost;
    return matched >= 0 ? 3 : 0;
}
#endif
