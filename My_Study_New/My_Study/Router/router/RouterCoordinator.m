#import "RouterCoordinator.h"
#import "ModuleContainer.h"
#import "BaseRouterAction.h"
#import "UIApplication+Ext.h"
#import "UIViewController+ZW.h"
#import "NSObject+Params.h"
#import "ZWTabBarController.h"

@implementation RouterCoordinator
#pragma mark - RouterNavigateDelegate
- (void)doAction:(RouterParam *)param {
    NSObject *cls = [self commonActionRouter:param];
    if ([cls isKindOfClass:BaseRouterAction.class]) {
        [(BaseRouterAction *)cls doAction];
        param.navigationResult = @"行为已执行";
    } else {
        [self failRoute:param message:@"行为路由目标不存在或类型无效"];
    }
}

- (void)navigateTo:(RouterParam *)param {
    UIViewController *source = [self currentViewController:param];
    if (!source || (!param.usesPreparedDestination && (source.isBeingDismissed || source.isBeingPresented || source.transitionCoordinator))) {
        [self failRoute:param message:@"导航上下文不存在或正在切换页面"];
        return;
    }
    // 栈顶为同一路由且参数相同则复用，避免连续点击堆叠页面。
    if (!param.usesPreparedDestination && [source.routerParamObject.destURL isEqualToString:param.destURL]
        && [source.routerParams isEqualToDictionary:param.params]) {
        param.navigationResult = @"复用栈顶";
        return;
    }
    UIViewController *cls = [self commonRouter:param];
    if (!cls) {
        [self failRoute:param message:@"页面路由目标不存在或类型无效"];
        return;
    }
    if ([cls isKindOfClass:UIViewController.class]) {
        NSDictionary *extraParam = [param.params objectForKey:kExtraParamKey];

        BOOL animated = param.navigationAnimated ? param.navigationAnimated.boolValue : YES;
        BOOL modifyedAni = param.navigationAnimated != nil;
        BOOL hideNavigationBar = NO;

        if (extraParam){
            if ([extraParam.allKeys containsObject:@"anim"]){
                animated = [[extraParam objectForKey:@"anim"] boolValue];
                modifyedAni = YES;
            }
        }

        if ([[cls class] respondsToSelector:@selector(ss_constantParams)]){
            NSDictionary *dict = [[cls class] ss_constantParams];
            if (dict) {
                if (!modifyedAni){
                    animated = [[dict objectForKey:@"animated"] boolValue];
                }

                hideNavigationBar = [[dict objectForKey:@"hideNavigationBar"] boolValue];
            }
        }

        UIViewController *currentViewController = [self currentViewController:param];
        cls.disableAnimatePush = !animated;
        if (!param.usesPreparedDestination) cls.hideNavigationBar = hideNavigationBar;
        if ([currentViewController isKindOfClass:[UINavigationController class]]){
            [(UINavigationController *)currentViewController pushViewController:cls animated:animated];
            param.navigationResult = @"已提交 push";
        } else if (currentViewController.navigationController) {
            [currentViewController.navigationController pushViewController:cls animated:animated];
            param.navigationResult = @"已提交 push";
        } else {
            [self failRoute:param message:@"当前页面没有导航控制器"];
        }
    }
}

- (void)presentTo:(RouterParam *)param {
    UIViewController *source = [self currentViewController:param];
    if (!source || (!param.usesPreparedDestination && (source.isBeingDismissed || source.isBeingPresented || source.transitionCoordinator))) {
        [self failRoute:param message:@"导航上下文不存在或正在切换页面"];
        return;
    }
    // 栈顶为同一路由且参数相同则复用，避免连续点击堆叠页面。
    if (!param.usesPreparedDestination && [source.routerParamObject.destURL isEqualToString:param.destURL]
        && [source.routerParams isEqualToDictionary:param.params]) {
        param.navigationResult = @"复用栈顶";
        return;
    }
    UIViewController *cls = [self commonRouter:param];
    if (!cls) {
        [self failRoute:param message:@"页面路由目标不存在或类型无效"];
        return;
    }
    if (param.usesPreparedDestination) {
        void (^completion)(void) = param.presentationCompletion;
        param.presentationCompletion = nil;
        param.navigationResult = @"已提交 present";
        [source presentViewController:cls animated:param.navigationAnimated.boolValue completion:^{
            if (completion) completion();
        }];
        return;
    }
    if ([cls isKindOfClass:[UIViewController class]]) {
        BOOL animated = YES;
        BOOL hideNavigationBar = NO;
        if ([[cls class] respondsToSelector:@selector(ss_constantParams)]) {
            NSDictionary *dict = [[cls class] ss_constantParams];
            animated = [[DataFormatterFunc numberValueForKey:@"animated" ofDict:dict] boolValue];
            hideNavigationBar = [[DataFormatterFunc numberValueForKey:@"hideNavigationBar" ofDict:dict] boolValue];
        }

        UIViewController *currentViewController = [self currentViewController:param];
        cls.modalPresentationStyle = UIModalPresentationFullScreen;
        if (!param.usesPreparedDestination) cls.hideNavigationBar = hideNavigationBar;

        ZWNavigationController *navVC = [[ZWNavigationController alloc] initWithRootViewController:cls];
        navVC.modalPresentationStyle = UIModalPresentationFullScreen;
        if ([param.params.allKeys containsObject:@"modalPresentationStyle"]) {
            NSNumber *modalPresentationStyle = [param.params objectForKey:@"modalPresentationStyle"];
            if ([modalPresentationStyle respondsToSelector:@selector(integerValue)]) {
                navVC.modalPresentationStyle = [modalPresentationStyle integerValue];
            }
        }
        param.navigationResult = @"已提交 present";
        [currentViewController presentViewController:navVC animated:animated completion:nil];
    }

}

/**
 *  通知切换tabbar
 *
 *  @param param    路由参数
 */
- (void)tabTo:(RouterParam *)param {
    if (param.tabSelectionIndex && [param.context isKindOfClass:UITabBarController.class]) {
        UITabBarController *tabs = param.context;
        NSUInteger index = param.tabSelectionIndex.unsignedIntegerValue;
        if (index >= tabs.viewControllers.count) { [self failRoute:param message:@"Tab 索引越界"]; return; }
        if ([tabs isKindOfClass:ZWTabBarController.class]) [(ZWTabBarController *)tabs applySelectedIndexFromRouter:index];
        else tabs.selectedIndex = index;
        param.navigationResult = @"Tab 切换完成";
        return;
    }
    param.navigationResult = @"已发送 Tab 切换";
    [[NSNotificationCenter defaultCenter] postNotificationName:TABBAR_SELECT_NOTICE object:param];

}


/**
 *  获取路由跳转页面
 *
 *  @param param    路由参数RouterParam
 *  @return  路由跳转界面
 */
- (id)commonRouter:(RouterParam *)param{
    NSString *clsName = param.destURL;
    if (clsName.length == 0){
        [LogUtil debug:@"路由类名为空" flag:nil context:self];
        return nil;
    }

    Class cls = NSClassFromString(clsName);
    if (cls == nil){
        [LogUtil debug:@"路由类名对应类不存在" flag:nil context:self];
        return nil;
    }

    if ([param.originUrl hasPrefix:@"member/manage/detail"]) {
        id memberID = param.params[@"memberId"];
        if (![memberID isKindOfClass:NSNumber.class] || [memberID integerValue] <= 0) return nil;
    }
    NSObject *instance = param.preparedDestination ?: [[cls alloc] init];
    // 目标会持有请求，因此请求不能继续持有目标实例。
    param.preparedDestination = nil;
    if (![instance isKindOfClass:UIViewController.class]){
        [LogUtil debug:@"路由类不是页面" flag:nil context:self];
        return nil;
    }
    if (!param.usesPreparedDestination && [param.params[@"title"] isKindOfClass:NSString.class]) {
        ((UIViewController *)instance).title = param.params[@"title"];
    }
    if (!param.usesPreparedDestination && [param.params[@"hidesBottomBarWhenPushed"] respondsToSelector:@selector(boolValue)]) {
        ((UIViewController *)instance).hidesBottomBarWhenPushed = [param.params[@"hidesBottomBarWhenPushed"] boolValue];
    }
    instance.routerParams = param.params;
    instance.routerParamObject = param;
    return instance;
}


/**
 *  获取行为路由
 *
 *  @param param    路由参数
 *  @return 行为路由
 */
- (id)commonActionRouter:(RouterParam *)param{
    NSString *clsName = param.destURL;
    if (clsName.length == 0){
        [LogUtil debug:@"路由类名为空" flag:nil context:self];
        return nil;
    }

    Class cls = NSClassFromString(clsName);
    if (cls == nil){
        [LogUtil debug:@"路由类名对应类不存在" flag:nil context:self];
        return nil;
    }

    NSObject *instance = [[cls alloc] init];
    if (![instance isKindOfClass:BaseRouterAction.class]){
        [LogUtil debug:@"行为路由不支持" flag:nil context:self];
        return nil;
    }
    instance.routerParams = param.params;
    instance.routerParamObject = param;
    return instance;
}

/**
 *  获取当前控制器
 *
 *  @param param    路由参数
 *  @return  当前控制器
 *
 */
- (void)failRoute:(RouterParam *)param message:(NSString *)message {
    if (param.failBlock) param.failBlock([Router errorWithCode:RouterErrorUnavailable message:message]);
}

- (UIViewController *)currentViewController:(RouterParam *)param{
    UIViewController *currentViewController = nil;
    if (param.context && [param.context isKindOfClass:[UIViewController class]]){
        currentViewController = param.usesPreparedDestination ? param.context : [UIApplication displayViewController:param.context ignorePresent:NO];
    } else {
        // 无显式上下文时仅在唯一活跃场景中解析，避免跨窗口误跳。
        if (@available(iOS 13.0, *)) {
            NSMutableArray<UIWindowScene *> *scenes = [NSMutableArray array];
            for (UIScene *scene in UIApplication.sharedApplication.connectedScenes) {
                if (scene.activationState == UISceneActivationStateForegroundActive
                    && [scene isKindOfClass:UIWindowScene.class]) [scenes addObject:(UIWindowScene *)scene];
            }
            if (scenes.count > 1) return nil;
            for (UIWindow *window in scenes.firstObject.windows) {
                if (window.isKeyWindow) return [UIApplication displayViewController:window.rootViewController ignorePresent:NO];
            }
        }
        currentViewController = [UIApplication displayViewController];
    }
    return currentViewController;
}

@end
