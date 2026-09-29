//
//  UITableView+EHIndexView.m
//  NBCBTest
//
//  Created by hzw on 2022/11/17.
//

#import "UITableView+EHIndexView.h"
#import <objc/runtime.h>
#import "EHIndexView.h"

@interface EHWeakProxy : NSObject

@property (nonatomic, weak) id target;

@end

@implementation EHWeakProxy

@end


@interface UITableView () <EHIndexViewDelegate>

@property (nonatomic, strong) EHIndexView *eh_indexView;

@end


@implementation UITableView (EHIndexView)

#pragma mark - Swizzle Method

+ (void)load
{
    [self swizzledSelector:@selector(EHIndexView_layoutSubviews) originalSelector:@selector(layoutSubviews)];
}

+ (void)swizzledSelector:(SEL)swizzledSelector originalSelector:(SEL)originalSelector
{
    Class class = [self class];
    Method originalMethod = class_getInstanceMethod(class, originalSelector);
    Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
    BOOL didAddMethod =
    class_addMethod(class,
                    originalSelector,
                    method_getImplementation(swizzledMethod),
                    method_getTypeEncoding(swizzledMethod));
    if (didAddMethod) {
        class_replaceMethod(class,
                            swizzledSelector,
                            method_getImplementation(originalMethod),
                            method_getTypeEncoding(originalMethod));
    } else {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}

- (void)EHIndexView_layoutSubviews {
    [self EHIndexView_layoutSubviews];
    
    if (!self.eh_indexView) {
        return;
    }
    if (self.superview && !self.eh_indexView.superview) {
        [self.superview addSubview:self.eh_indexView];
    }
    else if (!self.superview && self.eh_indexView.superview) {
        [self.eh_indexView removeFromSuperview];
    }
    if (!CGRectEqualToRect(self.eh_indexView.frame, self.frame)) {
        self.eh_indexView.frame = self.frame;
    }
    [self.eh_indexView refreshCurrentSection];
}

#pragma mark - EHIndexViewDelegate

- (void)indexView:(EHIndexView *)indexView didSelectAtSection:(NSUInteger)section
{
    if (self.eh_indexViewDelegate && [self.delegate respondsToSelector:@selector(tableView:didSelectIndexViewAtSection:)]) {
        [self.eh_indexViewDelegate tableView:self didSelectIndexViewAtSection:section];
    }
}

- (NSUInteger)sectionOfIndexView:(EHIndexView *)indexView tableViewDidScroll:(UITableView *)tableView
{
    if (self.eh_indexViewDelegate && [self.delegate respondsToSelector:@selector(sectionOfTableViewDidScroll:)]) {
        return [self.eh_indexViewDelegate sectionOfTableViewDidScroll:self];
    } else {
        return EHIndexViewInvalidSection;
    }
}

#pragma mark - Public Methods

- (void)eh_refreshCurrentSectionOfIndexView {
    [self.eh_indexView refreshCurrentSection];
}

#pragma mark - Private Methods

- (EHIndexView *)createIndexView {
    EHIndexView *indexView = [[EHIndexView alloc] initWithTableView:self configuration:self.eh_indexViewConfiguration];
    indexView.translucentForTableViewInNavigationBar = self.eh_translucentForTableViewInNavigationBar;
    indexView.startSection = self.eh_startSection;
    indexView.delegate = self;
    return indexView;
}

#pragma mark - Getter and Setter

- (EHIndexView *)eh_indexView
{
    return objc_getAssociatedObject(self, @selector(eh_indexView));
}

- (void)setEh_indexView:(EHIndexView *)eh_indexView
{
    if (self.eh_indexView == eh_indexView) return;
    
    objc_setAssociatedObject(self, @selector(eh_indexView), eh_indexView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (EHIndexViewConfiguration *)eh_indexViewConfiguration
{
    EHIndexViewConfiguration *eh_indexViewConfiguration = objc_getAssociatedObject(self, @selector(eh_indexViewConfiguration));
    if (!eh_indexViewConfiguration) {
        eh_indexViewConfiguration = [EHIndexViewConfiguration configuration];
    }
    return eh_indexViewConfiguration;
}

- (void)setEh_indexViewConfiguration:(EHIndexViewConfiguration *)eh_indexViewConfiguration
{
    if (self.eh_indexViewConfiguration == eh_indexViewConfiguration) return;
    
    objc_setAssociatedObject(self, @selector(eh_indexViewConfiguration), eh_indexViewConfiguration, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (id<EHTableViewSectionIndexDelegate>)eh_indexViewDelegate
{
    EHWeakProxy *weakProxy = objc_getAssociatedObject(self, @selector(eh_indexViewDelegate));
    return weakProxy.target;
}

- (void)setEh_indexViewDelegate:(id<EHTableViewSectionIndexDelegate>)eh_indexViewDelegate
{
    if (self.eh_indexViewDelegate == eh_indexViewDelegate) return;
    
    EHWeakProxy *weakProxy = [EHWeakProxy new];
    weakProxy.target = eh_indexViewDelegate;
    objc_setAssociatedObject(self, @selector(eh_indexViewDelegate), weakProxy, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (BOOL)eh_translucentForTableViewInNavigationBar
{
    NSNumber *number = objc_getAssociatedObject(self, @selector(eh_translucentForTableViewInNavigationBar));
    return number.boolValue;
}

- (void)setEh_translucentForTableViewInNavigationBar:(BOOL)eh_translucentForTableViewInNavigationBar
{
    if (self.eh_translucentForTableViewInNavigationBar == eh_translucentForTableViewInNavigationBar) return;
    
    objc_setAssociatedObject(self, @selector(eh_translucentForTableViewInNavigationBar), @(eh_translucentForTableViewInNavigationBar), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    self.eh_indexView.translucentForTableViewInNavigationBar = eh_translucentForTableViewInNavigationBar;
}

- (NSArray<NSString *> *)eh_indexViewDataSource
{
    return objc_getAssociatedObject(self, @selector(eh_indexViewDataSource));
}

- (void)setEh_indexViewDataSource:(NSArray<NSString *> *)eh_indexViewDataSource
{
    if (self.eh_indexViewDataSource == eh_indexViewDataSource) return;
    objc_setAssociatedObject(self, @selector(eh_indexViewDataSource), eh_indexViewDataSource.copy, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    if (eh_indexViewDataSource.count > 0) {
        if (!self.eh_indexView) {
            self.eh_indexView = [self createIndexView];
            [self.superview addSubview:self.eh_indexView];
        }
        self.eh_indexView.dataSource = eh_indexViewDataSource.copy;
        self.eh_indexView.hidden = NO;
    }
    else {
        self.eh_indexView.hidden = YES;
    }
}

- (NSUInteger)eh_startSection {
    NSNumber *number = objc_getAssociatedObject(self, @selector(eh_startSection));
    return number.unsignedIntegerValue;
}

- (void)setEh_startSection:(NSUInteger)eh_startSection {
    if (self.eh_startSection == eh_startSection) return;
    
    objc_setAssociatedObject(self, @selector(eh_startSection), @(eh_startSection), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    self.eh_indexView.startSection = eh_startSection;
}


@end
