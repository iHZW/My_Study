// 直接验证应用使用的规则，无需模拟器或第三方测试依赖。
#include "../My_Study/TabsIndexVc/CRMAnimalMatchRules.h"
#include <assert.h>
#include <stdio.h>

static CRMAnimalGame flatGame(const int *kinds, int count) {
    CRMAnimalGame game = {0};
    game.count = game.remaining = count;
    for (int i = 0; i < count; i++) {
        game.cards[i].x = i * 2;
        game.cards[i].kind = kinds[i];
    }
    return game;
}

static void testSlotBoundaries(void) {
    int rescueKinds[] = {0, 0, 1, 1, 2, 0, 1, 2, 2};
    CRMAnimalGame game = flatGame(rescueKinds, 9);
    for (int i = 0; i < 5; i++) {
        assert(CRMAnimalSelect(&game, i));
        assert(CRMAnimalSettle(&game) == 0);
    }
    assert(game.trayCount == 5);
    assert(CRMAnimalSelect(&game, 5));
    assert(game.trayCount == 6);
    assert(!CRMAnimalSelect(&game, 6));
    assert(CRMAnimalSettle(&game) == 3);
    assert(game.trayCount == 3 && game.outcome == CRMAnimalPlaying);
    for (int i = 6; i < 9; i++) { assert(CRMAnimalSelect(&game, i)); CRMAnimalSettle(&game); }
    assert(game.outcome == CRMAnimalWon && game.trayCount == 0);
    assert(!CRMAnimalSelect(&game, 0));
    assert(CRMAnimalSettle(&game) == 0);

    int failureKinds[] = {0, 0, 1, 1, 2, 2, 3};
    game = flatGame(failureKinds, 7);
    for (int i = 0; i < 6; i++) { assert(CRMAnimalSelect(&game, i)); CRMAnimalSettle(&game); }
    assert(game.outcome == CRMAnimalLost && game.trayCount == 6);
    assert(!CRMAnimalSelect(&game, 6));
}

static void testCoverAndInput(void) {
    int kinds[] = {0, 0, 0};
    CRMAnimalGame game = flatGame(kinds, 3);
    game.cards[1].x = 0.32;
    game.cards[1].layer = 1;
    assert(!CRMAnimalIsOpen(&game, 0));
    assert(!CRMAnimalSelect(&game, 0));
    assert(!CRMAnimalSelect(&game, -1));
    assert(!CRMAnimalSelect(&game, 3));
    assert(CRMAnimalSelect(&game, 1));
    assert(CRMAnimalIsOpen(&game, 0));
    assert(!CRMAnimalSelect(&game, 0));
    CRMAnimalSettle(&game);
    assert(!CRMAnimalSelect(&game, 1));
    assert(CRMAnimalSelect(&game, 0));
    CRMAnimalSettle(&game);
    assert(CRMAnimalSelect(&game, 2));
    assert(CRMAnimalSettle(&game) == 3 && game.outcome == CRMAnimalWon);
}

static void testGeneratedGames(void) {
    for (int level = 1; level <= 2; level++) {
        for (uint32_t seed = 0; seed < 2000; seed++) {
            CRMAnimalGame game;
            CRMAnimalStart(&game, level, seed);
            assert(game.count == (level == 1 ? 18 : 90));
            int layerCounts[6] = {0}, blocked = 0;
            const int expectedEasy[] = {12, 6};
            const int expectedHard[] = {22, 19, 16, 14, 11, 8};
            for (int i = 0; i < game.count; i++) {
                CRMAnimalCard card = game.cards[i];
                assert(card.x >= 0 && card.y >= 0 && card.x + 1 <= 6.65 && card.y + 1 <= 6.69);
                layerCounts[card.layer]++;
                if (!CRMAnimalIsOpen(&game, i)) blocked++;
                for (int j = 0; j < i; j++) {
                    CRMAnimalCard other = game.cards[j];
                    if (card.layer == other.layer) assert(fabs(card.x - other.x) >= 1 || fabs(card.y - other.y) >= 1);
                }
            }
            assert(blocked > 0);
            for (int layer = 0; layer < (level == 1 ? 2 : 6); layer++) {
                assert(layerCounts[layer] == (level == 1 ? expectedEasy[layer] : expectedHard[layer]));
            }
            int kinds[CRMAnimalKinds] = {0};
            for (int i = 0; i < game.count; i++) kinds[game.cards[i].kind]++;
            for (int i = 0; i < (level == 1 ? 3 : 8); i++) assert(kinds[i] > 0 && kinds[i] % 3 == 0);
            for (int step = 0; step < game.count; step++) {
                assert(CRMAnimalIsOpen(&game, game.solution[step]));
                assert(CRMAnimalSelect(&game, game.solution[step]));
                CRMAnimalSettle(&game);
                assert(game.trayCount < CRMAnimalSlots && game.outcome != CRMAnimalLost);
            }
            assert(game.outcome == CRMAnimalWon && game.remaining == 0 && game.trayCount == 0);
            // 重开必须清掉结束状态、待结算状态及旧槽位。
            CRMAnimalStart(&game, level, seed);
            assert(game.outcome == CRMAnimalPlaying && !game.pending && game.trayCount == 0);
            for (int i = 0; i < game.count; i++) assert(!game.cards[i].removed);
        }
    }
}

static void testRandomPlay(void) {
    for (uint32_t seed = 1; seed <= 1000; seed++) {
        CRMAnimalGame game;
        CRMAnimalStart(&game, seed % 2 + 1, seed);
        uint32_t random = seed;
        int cleared = 0, steps = 0;
        while (game.outcome == CRMAnimalPlaying) {
            int open[CRMAnimalMaxCards], count = 0;
            for (int i = 0; i < game.count; i++) if (CRMAnimalIsOpen(&game, i)) open[count++] = i;
            assert(count > 0 && steps++ < game.count);
            assert(CRMAnimalSelect(&game, open[CRMAnimalRandom(&random, count)]));
            cleared += CRMAnimalSettle(&game);
            assert(game.remaining + game.trayCount + cleared == game.count);
            assert(game.trayCount <= CRMAnimalSlots);
            int kinds[CRMAnimalKinds] = {0};
            for (int i = 0; i < game.trayCount; i++) {
                assert(++kinds[game.cards[game.tray[i]].kind] < 3);
                for (int j = 0; j < i; j++) assert(game.tray[i] != game.tray[j]);
            }
        }
    }
}

static void testLayoutVariety(void) {
    CRMAnimalGame first, second;
    CRMAnimalStart(&first, 2, 123);
    CRMAnimalStart(&second, 2, 456);
    bool different = false;
    for (int i = 0; i < first.count; i++) {
        if (first.cards[i].x != second.cards[i].x || first.cards[i].y != second.cards[i].y) different = true;
    }
    assert(different);
}

int main(void) {
    testSlotBoundaries();
    testCoverAndInput();
    testGeneratedGames();
    testRandomPlay();
    testLayoutVariety();
    puts("通过：4000 个可解初局、1000 次随机游玩、遮挡、重复输入、六格优先消除、失败、通关及重开。");
    return 0;
}
