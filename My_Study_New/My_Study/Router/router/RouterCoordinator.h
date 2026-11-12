#import <UIKit/UIKit.h>
#import "RouterNavigateDelegate.h"
#import "RouterParam.h"

NS_ASSUME_NONNULL_BEGIN
/// 集中管理 UIKit 导航上下文与页面生命周期，业务模块无需操作导航栈。
@interface RouterCoordinator : NSObject <RouterNavigateDelegate>
@end
NS_ASSUME_NONNULL_END
