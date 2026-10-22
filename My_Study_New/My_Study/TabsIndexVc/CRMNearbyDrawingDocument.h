#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
/// 画布使用归一化坐标；所有设备按同一个 3:4 比例显示，避免拉伸。
@interface CRMNearbyDrawingDocument : NSObject
@property (nonatomic, readonly) NSUInteger revision;
@property (nonatomic, readonly) NSArray<NSDictionary *> *strokes;
@property (nonatomic, readonly) NSUInteger pointCount;
- (BOOL)applyOperation:(NSDictionary *)operation;
- (NSDictionary *)snapshot;
- (BOOL)loadSnapshot:(NSDictionary *)snapshot;
@end
NS_ASSUME_NONNULL_END
