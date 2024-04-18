//
//  UIViewController+TrackPoint.m
//  My_Study
//
//  Created by hzw on 2024/2/23.
//  Copyright © 2024 HZW. All rights reserved.
//

#import "UIViewController+TrackPoint.h"
#import <objc/runtime.h>

static char *lbp_viewController_open_time = "lbp_viewController_open_time";
static char *lbp_viewController_close_time = "lbp_viewController_close_time";

NSArray *subclassNames(NSString *className) {
    int numClasses = objc_getClassList(NULL, 0);

    if (numClasses <= 0) {
        return nil;
    }

    Class *classes = (Class *)malloc(sizeof(Class) * numClasses);
    numClasses = objc_getClassList(classes, numClasses);

    NSMutableArray *subclassNames = [NSMutableArray array];

    for (int i = 0; i < numClasses; i++) {
        Class superClass = classes[i];
        Class currentClass = superClass;

        while (currentClass != nil) {
            if (class_getSuperclass(currentClass) == NSClassFromString(className)) {
                [subclassNames addObject:NSStringFromClass(superClass)];
                break;
            }
            currentClass = class_getSuperclass(currentClass);
        }
    }

    free(classes);

    return [subclassNames copy];
}



@implementation UIViewController (TrackPoint)

// load 方法里面添加 dispatch_once 是为了防止手动调用 load 方法。
+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        @autoreleasepool {
            [[self class] lbp_swizzleMethod:@selector(viewWillAppear:) swizzledSelector:@selector(lbp_viewWillAppear:)];
            [[self class] lbp_swizzleMethod:@selector(viewWillDisappear:) swizzledSelector:@selector(lbp_viewWillDisappear:)];
        }
    });
    
    NSArray *subclasses = subclassNames(@"ZWBaseViewController");
    NSLog(@"Subclasses: %@", subclasses);
}


#pragma mark - public Method
+ (void)lbp_swizzleMethod:(SEL)originalSelector swizzledSelector:(SEL)swizzledSelector {
    class_swizzleInstanceMethod(self, originalSelector, swizzledSelector);
}

+ (void)lbp_swizzleClassMethod:(SEL)originalSelector swizzledSelector:(SEL)swizzledSelector {
    // 类方法实际上是储存在类对象的类(即元类)中，即类方法相当于元类的实例方法,所以只需要把元类传入，其他逻辑和交互实例方法一样。
    Class class2 = object_getClass(self);
    class_swizzleInstanceMethod(class2, originalSelector, swizzledSelector);
}

#pragma mark - private method

void class_swizzleInstanceMethod(Class class, SEL originalSEL, SEL replacementSEL) {
    /*
     Class class = [self class];
     //原有方法
     Method originalMethod = class_getInstanceMethod(class, originalSelector);
     //替换原有方法的新方法
     Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
     //先尝试給源SEL添加IMP，这里是为了避免源SEL没有实现IMP的情况
     BOOL didAddMethod = class_addMethod(class,originalSelector,
     method_getImplementation(swizzledMethod),
     method_getTypeEncoding(swizzledMethod));
     if (didAddMethod) {//添加成功：表明源SEL没有实现IMP，将源SEL的IMP替换到交换SEL的IMP
     class_replaceMethod(class,swizzledSelector,
     method_getImplementation(originalMethod),
     method_getTypeEncoding(originalMethod));
     } else {//添加失败：表明源SEL已经有IMP，直接将两个SEL的IMP交换即可
     method_exchangeImplementations(originalMethod, swizzledMethod);
     }
     */

    Method originMethod = class_getInstanceMethod(class, originalSEL);
    Method replaceMethod = class_getInstanceMethod(class, replacementSEL);

    if (class_addMethod(class, originalSEL, method_getImplementation(replaceMethod), method_getTypeEncoding(replaceMethod))) {
        class_replaceMethod(class, replacementSEL, method_getImplementation(originMethod), method_getTypeEncoding(originMethod));
    } else {
        method_exchangeImplementations(originMethod, replaceMethod);
    }
}

#pragma mark - add prop

- (void)setOpenTime:(NSDate *)openTime {
    objc_setAssociatedObject(self, &lbp_viewController_open_time, openTime, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSDate *)getOpenTime {
    return objc_getAssociatedObject(self, &lbp_viewController_open_time);
}

- (void)setCloseTime:(NSDate *)closeTime {
    objc_setAssociatedObject(self, &lbp_viewController_close_time, closeTime, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSDate *)getCloseTime {
    return objc_getAssociatedObject(self, &lbp_viewController_close_time);
}

- (void)lbp_viewWillAppear:(BOOL)animated {
    NSString *className = NSStringFromClass([self class]);
    NSString *refer = [NSString string];
    // TODO:TODO 是否只埋本地有url的page
    if ([self getPageUrl:className]) {
        // 设置打开时间
        [self setOpenTime:[NSDate dateWithTimeIntervalSinceNow:0]];
        if (self.navigationController) {
            if (self.navigationController.viewControllers.count >= 2) {
                // 获取当前vc 栈中 上一个VC
                UIViewController *referVC = self.navigationController.viewControllers[self.navigationController.viewControllers.count - 2];
                refer = [self getPageUrl:NSStringFromClass([referVC class])];
            }
        }
        if (!refer || refer.length == 0) {
            refer = @"unknown";
        }

//        [UserTrackDataCenter openPage:[self getPageUrl:className] fromPage:refer];
    }

    [self lbp_viewWillAppear:animated];
}

- (void)lbp_viewWillDisappear:(BOOL)animated {
    NSString *className = NSStringFromClass([self class]);
    if ([self getPageUrl:className]) {
        [self setCloseTime:[NSDate dateWithTimeIntervalSinceNow:0]];
//        [UserTrackDataCenter leavePage:[self getPageUrl:className] spendTime:[self p_calculationTimeSpend]];
        [self p_calculationTimeSpend];
    }
    [self lbp_viewWillDisappear:animated];
}

#pragma mark - private method

- (NSString *)p_calculationTimeSpend {
    if (![self getOpenTime] || ![self getCloseTime]) {
        return @"unknown";
    }
    NSTimeInterval aTimer = [[self getCloseTime] timeIntervalSinceDate:[self getOpenTime]];

    int hour = (int)(aTimer / 3600);

    int minute = (int)(aTimer - hour * 3600) / 60;

    int second = aTimer - hour * 3600 - minute * 60;

    return [NSString stringWithFormat:@"%d", second];
}

#pragma mark - 是否
- (NSString *)getPageUrl:(NSString *)className {
    return @"TestVc";
}

#pragma mark - 检查是否包含类
- (BOOL)checkedIncludeClassName:(NSString *)className {
    return NO;
}

#pragma mark - 获取所有包含的类名
- (NSArray *)getAllIncludeClassName {
    return @[@"",
             @"",
             @"",
             @""];
}

@end
