// 人物站位与接球判定共用参数，避免画面位置和碰撞线脱节。
#ifndef CRMSoccerMotion_h
#define CRMSoccerMotion_h
#include <stdbool.h>
#include <math.h>
static const double CRMSoccerGroundY = 0.965;
static const double CRMSoccerContactY = 0.93;
static const double CRMSoccerKickDuration = 0.26;
static inline bool CRMSoccerCrossesPlayer(double previousY, double currentY, double radiusY,
                                         double velocityY, double ballX, double playerX, double halfWidth) {
    return velocityY > 0 && previousY + radiusY <= CRMSoccerContactY &&
           currentY + radiusY >= CRMSoccerContactY && fabs(ballX - playerX) <= halfWidth;
}
static inline double CRMSoccerKickStrength(double remaining) {
    double progress = fmax(0, fmin(1, remaining / CRMSoccerKickDuration));
    return progress * progress;
}
typedef struct { double hipY, kneeX, kneeY, footX, footY; } CRMSoccerLegPose;
static inline CRMSoccerLegPose CRMSoccerRunningLeg(double phase, int limb, bool running,
                                                  double kick, double targetX, double contactHeight) {
    double cycle = phase + limb * 3.141592653589793;
    CRMSoccerLegPose pose = {0};
    pose.hipY = -28 - (running ? 2.5 * fabs(sin(phase)) : 0);
    pose.footX = running ? cos(cycle) * 18 : (limb ? 8 : -8);
    pose.footY = running ? -fmax(0, sin(cycle)) * 15 : 0;
    if (limb == 1) {
        pose.footX += (targetX - pose.footX) * kick;
        pose.footY += (-contactHeight - pose.footY) * kick;
    }
    double dx = pose.footX, dy = pose.footY - pose.hipY;
    double distance = fmax(0.01, hypot(dx, dy));
    double bend = sqrt(fmax(0, 18 * 18 - distance * distance / 4));
    pose.kneeX = pose.footX / 2 + dy / distance * bend;
    pose.kneeY = (pose.hipY + pose.footY) / 2 - dx / distance * bend;
    return pose;
}
#endif
