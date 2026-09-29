//
//  TestBlock.m
//  My_Study
//
//  Created by hzw on 2022/9/19.
//  Copyright © 2022 HZW. All rights reserved.
//

#import "TestBlock.h"
//#import "MJClassInfo.h"
#import <objc/runtime.h>
#import <CoreLocation/CoreLocation.h>

/**
 * LLVM
 * OC --> 中间代码(.ll) --> 汇编 --> 机器语言
 */


#define WFAssert(condition, ...) \
if (!(condition)){ WFSafeLog(__FILE__, __FUNCTION__, __LINE__, __VA_ARGS__);} \

void WFSafeLog(const char* _Nullable file, const char* _Nullable func, int line, NSString* _Nullable fmt, ...)
{
    NSString *reason = @"";
    NSString *defaultStr = [NSString stringWithFormat:@"\nfile: %s\nfunc: %s\nline: %@", file, func, @(line)];
    va_list args;
    va_start(args, fmt);
    reason = [[NSString alloc] initWithFormat:fmt arguments:args];
    va_end(args);
    reason = [NSString stringWithFormat:@"%@\n%@", defaultStr, reason];
    
    @try {
        NSException *exception = [NSException exceptionWithName:@"WMSafeException" reason:reason userInfo:nil];
        @throw exception;
    } @catch (NSException *exception) {
        NSLog(@"exception = %@", exception);
//        [WMSafeProxy dealException:exception];
    }
}


/**
 * __使用命令行 将 TestBlock.m 文件转换为  TestBlock.cpp 文件  查看编译后的代码
 * 命令~ "  xcrun -sdk iphoneos clang -arch arm64 -rewrite-objc TestBlock.m  "
 * 当使用 下划线weak 时 会报错
 * 使用运行时命令就好了 "  xcrun -sdk iphoneos clang -arch arm64 -rewrite-objc -fobjc-arc -fobjc-runtime=ios-10.0 TestBlock.m  "
 * 这样同级目录下就会多一个 TestBlock.cpp 文件
 * __
 */

typedef void (^MyTestBlock)(NSInteger myAge);

//#define MyTallMask      1
//#define MyRichMask      2
//#define MyHandsameMask  3

//#define MyTallMask      0x00000001
//#define MyRichMask      0x00000010
//#define MyHandsameMask  0x00000100

#define MyTallMask      (1 << 0)
#define MyRichMask      (1 << 1)
#define MyHandsameMask  (1 << 2)

/** 全局变量  */
int myInt = 100;


@interface TestBlock ()
{
    char _tallRichHandsam;
    
    struct {
        /** 位域  设置  tall/rich/handsome 所占的大小  1位, 不设置的话默认 类型的大小  */
        char tall : 1;
        char rich : 1;
        char handsome : 1;
        
    } _tallRichHandsomeNew;
    
    
    /** 联合体/共用体  */
    union {
        char bits;
        struct {
            char tall : 1;
            char rich : 1;
            char handsome : 1;
        };
    } _tallRichHandsomeUnion;
    
}

@property (nonatomic, copy) MyTestBlock myTestBlock;

@property (nonatomic, copy) NSString *myName;

@end

@implementation TestBlock
//@dynamic age; // 不生成setter && getter 方法实现
//@synthesize age; // 自动生成 setter && getter 方法

- (instancetype)init
{
    if (self = [super init]) {
        _tallRichHandsam = 0x5;//0x00000101;
        
        
        
        self.myName = @"---myName";
        
        #pragma mark - 局部变量捕获 capture
        #pragma mark - 全局变量不会捕获 capture  全局直接访问

        /** 自动变量  */
        auto int myValue = 10;
        /** 静态变量  */
        static int myStaticValue = 30;
        
//        @pas_weakify_self
        __weak typeof(self) weakSelf = self;
        self.myTestBlock = ^(NSInteger myAge) {
            __strong typeof(weakSelf) strongSelf = weakSelf;
//            @pas_strongify_self
            NSLog(@"myValue = %@",@(myValue));
            NSLog(@"myAge = %@", @(myAge));
            NSLog(@"myStaticValue = %@", @(myStaticValue));
            NSLog(@"self.myName = %@", strongSelf.myName);
            /** 不会捕获全局变量myInt  */
            NSLog(@"myInt = %@", @(myInt));
            
            NSLog(@"%@", [strongSelf.myTestBlock class]);
        };
        myStaticValue = 40;
        self.myTestBlock(20);
        
        NSLog(@"%d---%d--%d", [self getTall], [self getRich], [self getHandsome]);
        
        [self handleStruct];
    }
    return self;
}


- (void)handleStruct
{
    /** 面试题  */
    //    MJPerson : NSObject
    //    NSLog(@"%d", [[NSObject class] isKindOfClass:[NSObject class]]);
    //    NSLog(@"%d", [[NSObject class] isMemberOfClass:[NSObject class]]);
    //    NSLog(@"%d", [[MJPerson class] isKindOfClass:[MJPerson class]]);
    //    NSLog(@"%d", [[MJPerson class] isMemberOfClass:[MJPerson class]]);
    //
    //    // 1 0 0 0
    
    /**
     * 结构体内存地址从小到大排列   isa (低) ==> 高(其他成员)
     * 控制器内存排列是  从  上(高)==>下(低),  所以写在上边的代码会存储在  高地址中
     * self.name    通过self 找到name  内存中其实是找到结构体里的isa指针 然后往高处找到name
     */
    id cls = [TestBlock class];
    void *objc = &cls;
    [(__bridge id)objc methodName];
}


#pragma mark - getter && setter
- (BOOL)getTall
{
    return !!(_tallRichHandsam & MyTallMask);
}

- (void)setTall:(BOOL)tail
{
    if (tail) {
//        0x00000101 | 0x00000001 ==> 0x00000101;
//        _tallRichHandsam = (_tallRichHandsam | MyTallMask);
        _tallRichHandsam |= MyTallMask;
    } else {
        /** ~ 去反(  0x00000001    去反之后为 0下0x1111110) */
        /** 0x00000101 & 0x1111110 ==>  0x00000100 */
//        _tallRichHandsam = (_tallRichHandsam & ~MyTallMask);
        _tallRichHandsam &= ~MyTallMask;
    }
}

- (BOOL)getRich
{
    return !!(_tallRichHandsam & MyRichMask);
}

- (void)setRich:(BOOL)rich
{
    if (rich) {
        _tallRichHandsam |= MyRichMask;
    } else{
        _tallRichHandsam &= ~MyRichMask;
    }
}

- (BOOL)getHandsome
{
//    return !!(_tallRichHandsam & MyHandsameMask);
    
    return _tallRichHandsomeNew.handsome;
}

- (void)setHandsome:(BOOL)handsome
{
//    if (handsome) {
//        _tallRichHandsam |= MyHandsameMask;
//    } else {
//        _tallRichHandsam &= ~MyHandsameMask;
//    }
    
    _tallRichHandsomeNew.handsome = handsome;
}



struct method_t {
    SEL sel;
    char *types;
    IMP imp;
};

- (void)myOther
{
    NSLog(@"%s", __func__);
}

/** 添加一个c语言方法  */
void myOtherC(id self, SEL _cmd)
{
    NSLog(@"myOtherC--%@--%@", self, NSStringFromSelector(_cmd));
}

#pragma mark - 动态方法解析  resolveInstanceMethod/resolveClassMethod
+ (BOOL)resolveInstanceMethod:(SEL)sel
{
    if (sel == @selector(text)) {
        /** 方案一  */
        struct method_t *otherMethod = (struct method_t *)class_getInstanceMethod(self, @selector(myOther));
        NSLog(@"%p %s %p", otherMethod->sel, otherMethod->types,  otherMethod->imp);
        /** 给类对象添加一个方法  */
        class_addMethod(self, otherMethod->sel, otherMethod->imp, otherMethod->types);
        
        
        /** 方案二  */
        class_addMethod(self, @selector(myOther), (IMP)myOtherC, "v16@0:8");
        
        return YES;
    }
    
    return [super resolveInstanceMethod:sel];
}


struct class_method_t {
    SEL sel;
    char *types;
    IMP imp;
};

+ (void)classText
{
    NSLog(@"%s", __func__);
}


void myClassOtherC (id self, SEL _cmd)
{
    NSLog(@"myClassOtherC--%@--%@", self, NSStringFromSelector(_cmd));
}

+ (BOOL)resolveClassMethod:(SEL)sel
{
    if (sel == @selector(text)) {
        class_addMethod(object_getClass(self), @selector(classText), (IMP)myClassOtherC, "v16@0:8");
        
        struct class_method_t *method_t = (struct class_method_t *)class_getClassMethod(object_getClass(self), @selector(classText));
        class_addMethod(object_getClass(self), sel, method_t->imp, method_t->types);
        
    }
    return [super resolveClassMethod:sel];
}


#pragma mark - 消息转发 选择转发目标
- (id)forwardingTargetForSelector:(SEL)aSelector
{
    if (aSelector == @selector(text)){
        /** 创建一个对象来处理  */
        return nil;
    }
    return [super forwardingTargetForSelector:aSelector];
}

/**
 * 方法签名
 * 返回值类型,参数类型
 */
- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector
{
    /** 可以响应就执行 父类的方法签名  */
    if ([self respondsToSelector:aSelector]) {
        return [super methodSignatureForSelector:aSelector];
    }
    /** 这里注册一个方法就不会crash了  */
    return [NSMethodSignature signatureWithObjCTypes:"v@:"];
}

/**
 * NSInvocation 封装了一个方法调用,包括:方法调用者,方法,方法参数,
 * @param anInvocation 调用
 */
- (void)forwardInvocation:(NSInvocation *)anInvocation
{
    /** 测试GCDGroup  */
//    [[self class] testGCDGroup];
    
    WFAssert(NO, @"%@----%@ 方法未实现", anInvocation.target, NSStringFromSelector(anInvocation.selector));
//    anInvocation.target  方法调用者
//    anInvocation.selector  方法名
//    [anInvocation getArgument:NULL atIndex:0];
}


- (void)doesNotRecognizeSelector:(SEL)aSelector
{
    WFAssert(NO, @"%@ 方法没有实现", NSStringFromSelector(aSelector));
}




+ (id)forwardingTargetForSelector:(SEL)aSelector
{
    return nil;
}

+ (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector
{
    return [NSMethodSignature signatureWithObjCTypes:"v@:"];
}

+ (void)forwardInvocation:(NSInvocation *)anInvocation
{
    WFAssert(NO, @"%@----%@ 方法未实现", anInvocation.target, NSStringFromSelector(anInvocation.selector));
//    NSLog(@"%@----%@ 方法未实现", anInvocation.target, NSStringFromSelector(anInvocation.selector));
}

+ (void)doesNotRecognizeSelector:(SEL)aSelector
{
   
    NSLog(@"class---doesNotRecognizeSelector");
}


/**
 * [super class] 底层实现
 * 1: 消息接受者receive仍然是子类对象
 * 2: 从父类开始查找方法实现
 *
 * [super superclass] 底层实现原理
 * 1: 消息接受者是父类对象
 * 2: 从父类的父类开始查找方法实现
 */

#pragma mark - class/superclass 的底层实现
- (Class)class
{
    return object_getClass(self);
}

- (Class)superclass
{
    return  class_getSuperclass(object_getClass(self));
}


#pragma mark - isMemberOfClass / isKindOfClass 底层实现
//+ (BOOL)isMemberOfClass:(Class)aClass {
//    return object_getClass(self) == aClass;
//}
//
//- (BOOL)isMemberOfClass:(Class)aClass {
//    return [self class] == aClass;
//}
//
//+ (BOOL)isKindOfClass:(Class)aClass {
//    for (Class tcls = object_getClass((id)self); tcls; tcls = tcls->superclass) {
//        if (tcls == aClass) {
//            return YES;
//        }
//    }
//    return NO;
//}
//
//- (BOOL)isKindOfClass:(Class)aClass {
//    for (Class tcls = [self class]; tcls; tcls = tcls->superclass) {
//        if (tcls == aClass) {
//            return YES;
//        }
//    }
//    return NO;
//}


void eat (id self, SEL _cmd) {
    NSLog(@"%s", __func__);
}

- (void)testCreatClass
{
    // 创建一个类
    Class newClass = objc_allocateClassPair([NSObject class], "Dog", 0);
    // 添加成员变量
    class_addIvar(newClass, "_age", 4, 1, @encode(int));
    class_addIvar(newClass, "_name", 8, 1, @encode(NSString));
    // 添加属性
    class_addMethod(newClass, @selector(eat), (IMP)eat, "v@:");
    
    // 注册一个类
    objc_registerClassPair(newClass);
    
    //添加方法
    
    
    #pragma mark - 方法交换
    Method oldMethod = class_getInstanceMethod(self, @selector(sendAction:to:forEvent:));
    
    Method newMethod = class_getInstanceMethod(self, @selector(mj_sendAction:to:forEvent:));
    // 交换方法 (会清空缓存方法 cache)
    method_exchangeImplementations(oldMethod, oldMethod);
    
}

- (void)mj_sendAction:(SEL)action to:(id)targer forEvent:(UIEvent *)event
{
    NSLog(@"action: %@---targer: %@--event: %@", NSStringFromSelector(action), targer, event);
    
    [self mj_sendAction:action to:targer forEvent:event];
}


- (void)testGCD
{
    /**
     * DISPATCH_QUEUE_SERIAL 串行队列
     * DISPATCH_QUEUE_CONCURRENT 并发队列
     */
    dispatch_queue_t queue = dispatch_queue_create("myQueue", DISPATCH_QUEUE_CONCURRENT);
    
    /**
     * dispatch_sync / dispatch_async  同步和异步  只决定是否开启新的线程
     * dispatch_queue_t 的 串行队列/并发队列 决定任务的执行方式
     */
    
    /** 异步执行  */
    dispatch_async(queue, ^{
        
    });
    
    /** 同步执行  */
    dispatch_sync(queue, ^{
        
    });
    
 
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSLog(@"1");
        
//        NSLog(@"2");
        /** 往异步线程的RunLoop里添加一个定时器 ,  而子线程的RunLoop默认不启动 */
        [self performSelector:@selector(testLog2) withObject:nil afterDelay:.0];
        [[NSRunLoop currentRunLoop] addPort:[NSPort new] forMode:NSDefaultRunLoopMode];
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
        NSLog(@"3");
    });
}


- (void)testLog2
{
    NSLog(@"2");
}


+ (void)testGCDGroup
{
    dispatch_group_t group = dispatch_group_create();
    
    dispatch_queue_t queue = dispatch_queue_create("group", DISPATCH_QUEUE_CONCURRENT);
    
    dispatch_group_async(group, queue, ^{
        [self executeTask:@"task1"];
    });
    
    dispatch_group_async(group, queue, ^{
        [self executeTask:@"task2"];
    });
    
    /** 等前面的任务执行完毕后, 会自动执行这个任务  */
//    dispatch_group_notify(group, queue, ^{
//        dispatch_async(dispatch_get_main_queue(), ^{
//            [self executeTask:@"task3"];
//        });
//    });
    
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        [self executeTask:@"task3"];
    });
    
}

/**
 * 执行任务
 * @param taskName  任务名称
 */
+ (void)executeTask:(NSString *)taskName
{
    for (int i = 0; i < 10; i++) {
        NSLog(@"--%@--", taskName);
    }
}


- (void)testLocation
{
    CLLocationManager *manager;
    
    // 请求定位, 之后会让定位硬件断电
    [manager requestLocation];
    
    /** 需要后台定位, 设置和这个属性为YES,  当用户不移动的时候会自动停止为止更新   */
    manager.pausesLocationUpdatesAutomatically = YES;
}



@end
