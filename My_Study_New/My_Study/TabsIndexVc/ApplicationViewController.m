//
//  ApplicationViewController.m
//  My_Study
//
//  Created by Zhiwei Han on 2022/6/27.
//  Copyright © 2022 HZW. All rights reserved.
//

#import "ApplicationViewController.h"

#import "EOCfamilly.h"
#import <objc/runtime.h>
#import "UIAlertUtil.h"
#import "IQViewModel+Eat.h"
#import "My_Study-Swift.h"
#import "LeftDrawerViewController.h"
#import "UIViewController+CWLateralSlide.h"
#import "RunLoopViewController.h"

#include <stdint.h>
#include <stdio.h>
#include <sanitizer/coverage_interface.h>
#import <dlfcn.h>
// 创建原子队列需要导入头文件
#import <libkern/OSAtomic.h>

#import "UIView+Create.h"
/** 可复制的label  */
#import "MMCopyLabel.h"
/** 点赞view  */
#import "GiveLikeView.h"


#pragma mark ------------------------------KVO底层原理------------------------------------
/**< 利用运行时,生成一个对象的子类,并生成子类的对象,替换原对象的isa指针,重写set方法 */

#define kChangeValueKey             @"name"


@interface ApplicationViewController ()

@property (nonatomic, strong) EOCfamilly *eocFamilly;

@property (nonatomic, strong) EOCfamilly *kvcEocFamilly;

@property (nonatomic, strong) UILabel *nameLabel;

@property (nonatomic, strong) GiveLikeView *giveLike;

@end

@implementation ApplicationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"应用";
    
    [self initRightNav];

    [self loadKVC];
    
    [self loadSubViews];
    
    /** 注册滑动手势 触发抽屉  */
    @pas_weakify_self
    [self cw_registerShowIntractiveWithEdgeGesture:NO transitionDirectionAutoBlock:^(CWDrawerTransitionDirection direction) {
        @pas_strongify_self
        if (direction == CWDrawerTransitionFromLeft) { // 左侧滑出
            [self clickBtn];
        } else if (direction == CWDrawerTransitionFromRight) { // 右侧滑出
            [self rightClick];
        }
    }];
    
}

- (void)initRightNav
{
    [super initRightNav];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(0, 0, PASFactor(44), PASFactor(30));
    [btn setTitle:@"试试看" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(clickBtn) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *btnItem = [[UIBarButtonItem alloc] initWithCustomView:btn];
    [self.navigationItem setRightBarButtonItem:btnItem];
}

/**
 *  swift  调用创建view
 */
- (void)createView
{
    NSLog(@"Swift 调用");
}


- (void)rightClick
{
    LeftDrawerViewController *leftVc = [LeftDrawerViewController new];
    CWLateralSlideConfiguration *conf = [CWLateralSlideConfiguration configurationWithDistance:0 maskAlpha:0.4 scaleY:0.8 direction:CWDrawerTransitionFromRight backImage:[UIImage imageNamed:@"icon_nav_back"]];
    [self cw_showDrawerViewController:leftVc animationType:CWDrawerAnimationTypeDefault configuration:conf];
}

- (void)clickBtn
{
    [Toast show:@"打开抽屉"];
    LeftDrawerViewController *leftVc = [LeftDrawerViewController new];
    [self cw_showDefaultDrawerViewController:leftVc];
    return;
//    [UIAlertUtil showAlertTitle:@"Lookin使用" message:nil cancelButtonTitle:@"取消" otherButtonTitles:@[@"导出当前UI结构",@"审查元素",@"3D视图"] actionBlock:^(NSInteger index)
//    {
//        switch (index) {
//            case 0:
//                NSLog(@"取消");
//                break;
//
//            case 1:
//                [[NSNotificationCenter defaultCenter] postNotificationName:@"Lookin_Export" object:nil];
//                break;
//
//            case 2:
//                [[NSNotificationCenter defaultCenter] postNotificationName:@"Lookin_2D" object:nil];
//                break;
//
//            case 3:
//                [[NSNotificationCenter defaultCenter] postNotificationName:@"Lookin_3D" object:nil];
//                break;
//
//            default:
//                break;
//        }
//
//    } superVC:self];
}


- (void)loadSubViews
{
    [self.view addSubview:self.nameLabel];
    
    NSLog(@"ScreenHeight = %f  DBL_EPSILON = %@",[[UIScreen mainScreen] bounds].size.height, @(DBL_EPSILON));
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.backgroundColor = [UIColor blueColor];
    label.textColor = [UIColor whiteColor];
    label.text = @"瞅一瞅";
    label.tag = 101;
    label.userInteractionEnabled = YES;
    [self.view addSubview:label];

    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.mas_left).offset(50);
        make.right.equalTo(self.view.mas_right).offset(-50);
        make.top.equalTo(self.view.mas_top).offset(150);
        make.height.mas_equalTo(200);
    }];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
    [label addGestureRecognizer:tap];
    
    
    MMCopyLabel *copyLabel = [[MMCopyLabel alloc] initWithFrame:CGRectMake(50, 360, 200, 50)];
    copyLabel.text = @"复制文本111";
    copyLabel.backgroundColor = UIColor.cyanColor;
    [self.view addSubview:copyLabel];
    
    
    BGView *subView = [[BGView alloc] initWithFrame:CGRectMake(100, 500, kMainScreenWidth - 200, 100)];
    subView.tag = 102;
    subView.backgroundColor = [UIColor blueColor];
//    subView.backgroundColor = [UIColor greenColor];
    [self.view addSubview:subView];
    
    UITapGestureRecognizer *tap1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
    [subView addGestureRecognizer:tap1];
    
    CustomerView *view = [[CustomerView alloc] initWithFrame:CGRectMake(100, 400, kMainScreenWidth - 200, 50)];
    view.tag = 103;
    [self.view addSubview:view];
    
    UITapGestureRecognizer *tap2 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapAction:)];
    [view addGestureRecognizer:tap2];
    
    
    /** 带点击效果的按钮  */
    UIButton *tapBtn = [[UIButton alloc] buildButtonWithTitle:@"测试带点击效果的UIView" frame:CGRectZero cornerRadius:8 target:self action:@selector(btnAction) block:^(UIButton * _Nonnull btn) {
        btn.tag = 104;
        btn.titleLabel.numberOfLines = 0;
        btn.backgroundColor = UIColorFromRGB(0x87CEFA);
//        btn.layer.shadowColor = UIColor.redColor.CGColor;
//        btn.layer.shadowOpacity = 2.0;
//        btn.layer.shadowOffset = CGSizeMake(10, 10);
        
//        CGMutablePathRef path = CGPathCreateMutable();
////        CGRect rect = CGRectInset(CGRectMake(0, 0, 100, 60), 30, 30);
////        CGPathCloseSubpath(path);
//
        // 如果设置了 shadowPath  就不会导致离屏渲染
//        btn.layer.shadowPath = path;
        
//        CGPathRelease(path);
    }];
    
    [self.view addSubview:tapBtn];
    
    [tapBtn mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.mas_left).offset(kContentSideHorizSpace);
        make.size.mas_equalTo(CGSizeMake(200, 60));
        make.top.equalTo(self.view.mas_top).offset(80);
    }];
    
    self.giveLike = [[GiveLikeView alloc] initWithFrame:CGRectMake(260, 360, 60, 60)];
    self.giveLike.likeDuration = 0.5;
    self.giveLike.zanFillColor = [UIColor redColor];
    self.giveLike.backgroundColor = [UIColor cyanColor];
    [self.view addSubview:self.giveLike];
    
//    [self.giveLike mas_makeConstraints:^(MASConstraintMaker *make) {
//        make.left.equalTo(self.view.mas_left).offset(kContentSideHorizSpace*2);
//        make.size.mas_equalTo(CGSizeMake(60, 60));
//        make.top.equalTo(self.view.mas_top).offset(0);
//    }];
}

- (void)btnAction
{
    /** 跳转测试  */
    RunLoopViewController *vc = [RunLoopViewController new];
    [self.navigationController pushViewController:vc animated:YES];
    
    
}

- (void)tapAction:(UIGestureRecognizer *)sender
{
    NSInteger tagIndex = sender.view.tag;
    
    switch (tagIndex) {
        case 101:
        {
            [self test101];
        }
            break;
        case 102:
        {
            [ZWM.router executeURLNoCallBack:ZWRouterPageShortVideoPlayerViewController];
        }
            break;
        case 103:
        {

        }
            break;
        default:
            break;
    }
    
}

- (void)test101
{
//    dispatch_queue_t
//    dispatch_queue_create(const char *label, dispatch_queue_attr_t attr)
//    {
//        return _dispatch_lane_create_with_target(label, attr, DISPATCH_TARGET_QUEUE_DEFAULT, true);
//    }
    
//    dispatch_queue_attr_t userInitiatedAttr = dispatch_queue_attr_make_with_qos_class(DISPATCH_QUEUE_CONCURRENT,
                                                                                      
                                                                                     
    dispatch_queue_attr_t userInitiatedAttr = dispatch_queue_attr_make_with_qos_class(DISPATCH_QUEUE_CONCURRENT,QOS_CLASS_USER_INITIATED,-1);
    dispatch_queue_create_with_target("123", userInitiatedAttr, DISPATCH_TARGET_QUEUE_DEFAULT);
    UITapGestureRecognizer *tag = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(test101)];
    [self.view addGestureRecognizer:tag];
    
//    [UIGestureRecognizer aspect_hookSelector:@selector(initWithTarget:action:)
//                                 withOptions:AspectPositionAfter
//                                  usingBlock:^(id<AspectInfo> instance, id target, SEL action) {
//                                  } error:NULL];
    
    
}


- (void)showUIAlertUtil
{
    [UIAlertUtil showAlertTitle:@"温馨提示" message:@"确定删除吗?" cancelButtonTitle:@"取消" otherButtonTitles:@[@"确定"] actionBlock:^(NSInteger index) {
        
        switch (index) {
            case 0:
            {
                /** 取消  */
            }
                break;
            case 1:
            {
                /** 确定  */
            }
                break;
                
            default:
                break;
        }
    } superVC:self];
}


- (UILabel *)nameLabel
{
    if (!_nameLabel) {
        _nameLabel = [[UILabel alloc] init];
        _nameLabel.text = @"嘞好啊!!!";
        _nameLabel.font = PASFacFont(20);
    }
    return _nameLabel;
}


#pragma mark ------------------------------测试KVC------------------------------------

- (void)loadKVC
{
    /**< 证明类变了 before = EOCfamilly */
    //    NSLog(@"before = %s",object_getClassName(self.eocFamilly));
    
    /**< 证明是子类  before = (
     EOCfamilly
     ) */
    //    NSLog(@"before = %@", [ViewController findSubClass:[self.eocFamilly class]]);
    /**< 添加监听者 */
    [self.eocFamilly addObserver:self forKeyPath:kChangeValueKey options:NSKeyValueObservingOptionNew context:nil];
    
    /**< 证明类变了 after = NSKVONotifying_EOCfamilly*/
    //    NSLog(@"after = %s",object_getClassName(self.eocFamilly));
    
    /**< 证明是子类  after = (
     EOCfamilly,
     "NSKVONotifying_EOCfamilly"
     )*/
    NSLog(@"after = %@", [self.class findSubClass:[self.eocFamilly class]]);
    
    /**< 手动通知观察者 */
    //    [self.eocFamilly willChangeValueForKey:kChangeValueKey];
    self.eocFamilly.name = @"New_EocName";
    //    [self.eocFamilly didChangeValueForKey:kChangeValueKey];
    
    
    
    [self testKVC];
}


- (void)testKVC
{
    /**< 取值赋值 */
    NSString *name = [self.eocFamilly valueForKey:kChangeValueKey];
    /**< new = "New_EocName"  */
    [self.eocFamilly setValue:@"testName" forKey:kChangeValueKey];
    /**< new = testName */
    name = [self.eocFamilly valueForKey:kChangeValueKey];
    
    NSString *kvcName = [self.eocFamilly valueForKeyPath:@"spouse.name"];
    /**< kvcName = "Old_Spouse_EocName" */
//    [self.eocFamilly setValue:@"KVC_New_EocFamilly" forKeyPath:@"_kvcEocFamilly.name"];
    
    kvcName = [self.kvcEocFamilly valueForKey:kChangeValueKey];
    
}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
//    NSLog(@"change = %@",change);
}


- (EOCfamilly *)eocFamilly
{
    if (!_eocFamilly) {
        _eocFamilly = [[EOCfamilly alloc] init];
        _eocFamilly.name = @"Old_EocName";
        _eocFamilly.spouse = [[EOCfamilly alloc] init];
        _eocFamilly.spouse.name = @"Old_Spouse_EocName";
    }
    return _eocFamilly;
}

- (EOCfamilly *)kvcEocFamilly
{
    if (!_kvcEocFamilly) {
        _kvcEocFamilly = [[EOCfamilly alloc] init];
        _kvcEocFamilly.name = @"KVC_Old_EocName";
    }
    return _kvcEocFamilly;
}


+ (NSArray *)findSubClass:(Class)defaultClass
{
    int count = objc_getClassList(NULL,0);
    if (count <= 0)
    {
        return [NSArray array];
    }
    NSMutableArray *output = [NSMutableArray arrayWithObject:defaultClass];
    Class *classes = (Class *)malloc(sizeof(Class) * count);
    objc_getClassList(classes, count);

    for (int i = 0; i < count; i++) {
        if (defaultClass == class_getSuperclass(classes[i])) {
            [output addObject:classes[i]];
        }
    }
    return output;
}



#pragma mark - clang demo
void __sanitizer_cov_trace_pc_guard_init(uint32_t *start,
                                         uint32_t *stop) {
//    static uint64_t N;  // Counter for the guards.
//    if (start == stop || *start) return;  // Initialize only once.
//    printf("INIT: %p %p\n", start, stop);
//    for (uint32_t *x = start; x < stop; x++)
//        *x = ++N;  // Guards should start from 1.
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    NSMutableArray<NSString *> * symbolNames = [NSMutableArray array];
//    while (true) {
//        //offsetof 就是针对某个结构体找到某个属性相对这个结构体的偏移量
//        SymbolNode * node = OSAtomicDequeue(&symboList, offsetof(SymbolNode, next));
//        if (node == NULL) break;
//        Dl_info info;
//        dladdr(node->pc, &info);
//
//        NSString * name = @(info.dli_sname);
//
//        // 添加 _
//        BOOL isObjc = [name hasPrefix:@"+["] || [name hasPrefix:@"-["];
//        NSString * symbolName = isObjc ? name : [@"_" stringByAppendingString:name];
//
//        //去重
//        if (![symbolNames containsObject:symbolName]) {
//            [symbolNames addObject:symbolName];
//        }
//    }
//
//    //取反
//    NSArray * symbolAry = [[symbolNames reverseObjectEnumerator] allObjects];
//    NSLog(@"%@",symbolAry);
//
//    //将结果写入到文件
//    NSString * funcString = [symbolAry componentsJoinedByString:@"\n"];
//    NSString * filePath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"lb.order"];
//    NSData * fileContents = [funcString dataUsingEncoding:NSUTF8StringEncoding];
//    BOOL result = [[NSFileManager defaultManager] createFileAtPath:filePath contents:fileContents attributes:nil];
//    if (result) {
//        NSLog(@"%@",filePath);
//    }else{
//        NSLog(@"文件写入出错");
//    }
}

//原子队列
static OSQueueHead symboList = OS_ATOMIC_QUEUE_INIT;
//定义符号结构体
typedef struct{
    void * pc;
    void * next;
}SymbolNode;

void __sanitizer_cov_trace_pc_guard(uint32_t *guard) {
    //if (!*guard) return;  // Duplicate the guard check.

//    void *PC = __builtin_return_address(0);
//
//    SymbolNode * node = malloc(sizeof(SymbolNode));
//    *node = (SymbolNode){PC,NULL};
//
//    //入队
//    // offsetof 用在这里是为了入队添加下一个节点找到 前一个节点next指针的位置
//    OSAtomicEnqueue(&symboList, node, offsetof(SymbolNode, next));
}

@end
