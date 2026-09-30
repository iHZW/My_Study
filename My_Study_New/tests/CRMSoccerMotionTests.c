#include "../My_Study/TabsIndexVc/CRMSoccerMotion.h"
#include <assert.h>
#include <stdio.h>

int main(void) {
    assert(CRMSoccerGroundY < 1 && CRMSoccerContactY < CRMSoccerGroundY);
    assert(CRMSoccerContactY > 0.84);
    // 下落的球跨过新的脚部接球线，必须位于人物接球范围内。
    assert(CRMSoccerCrossesPlayer(0.90, 0.92, 0.02, 0.5, 0.5, 0.5, 0.14));
    assert(!CRMSoccerCrossesPlayer(0.90, 0.92, 0.02, -0.5, 0.5, 0.5, 0.14));
    assert(!CRMSoccerCrossesPlayer(0.90, 0.92, 0.02, 0.5, 0.7, 0.5, 0.14));
    assert(!CRMSoccerCrossesPlayer(0.94, 0.96, 0.02, 0.5, 0.5, 0.5, 0.14));
    assert(!CRMSoccerCrossesPlayer(0.82, 0.85, 0.02, 0.5, 0.5, 0.5, 0.14));
    // 每一关的接球范围和不同棋盘尺寸下的真实足球半径。
    for (int level = 1; level <= 5; level++) {
        double halfWidth = 0.145 - (level - 1) * 0.012;
        for (int width = 220; width <= 430; width += 10) {
            double radiusY = 0.028 / 1.38;
            double boundary = CRMSoccerContactY - radiusY;
            assert(CRMSoccerCrossesPlayer(boundary - 0.005, boundary + 0.005, radiusY, 0.7, 0.5 + halfWidth - 0.0001, 0.5, halfWidth));
            assert(!CRMSoccerCrossesPlayer(boundary - 0.005, boundary + 0.005, radiusY, 0.7, 0.5 + halfWidth + 0.0001, 0.5, halfWidth));
            assert(CRMSoccerGroundY * width * 1.38 + 4 < width * 1.38);
        }
    }
    double last = 1;
    for (int frame = 0; frame <= 30; frame++) {
        double strength = CRMSoccerKickStrength(CRMSoccerKickDuration - frame / 60.0);
        assert(strength >= 0 && strength <= last);
        last = strength;
    }
    assert(CRMSoccerKickStrength(CRMSoccerKickDuration) == 1);
    assert(CRMSoccerKickStrength(0) == 0 && CRMSoccerKickStrength(-1) == 0);
    for (int frame = 0; frame < 360; frame++) {
        double phase = frame * 3.141592653589793 / 180;
        CRMSoccerLegPose a = CRMSoccerRunningLeg(phase, 0, true, 0, 30, 16);
        CRMSoccerLegPose b = CRMSoccerRunningLeg(phase, 1, true, 0, 30, 16);
        assert(fabs(a.footX + b.footX) < 0.00001);
        assert(a.footY <= 0 && a.footY >= -15 && b.footY <= 0 && b.footY >= -15);
        assert(fabs(hypot(a.kneeX, a.kneeY - a.hipY) - 18) < 0.00001);
        assert(fabs(hypot(a.footX - a.kneeX, a.footY - a.kneeY) - 18) < 0.00001);
        CRMSoccerLegPose kick = CRMSoccerRunningLeg(phase, 1, true, 1, 30, 16);
        assert(fabs(kick.footX - 30) < 0.00001 && fabs(kick.footY + 16) < 0.00001);
    }
    puts("通过：站位下移、五关接球范围、下落跨线判定、防重复反弹及踢腿收回。");
}
