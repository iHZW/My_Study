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

#include <stdint.h>
#include <stdio.h>
#include <sanitizer/coverage_interface.h>
#import <dlfcn.h>
// 创建原子队列需要导入头文件
#import <libkern/OSAtomic.h>

#import "AlertHead.h"
#import "AlertDefaultCustomCenterView.h"
#import "NSString+Adaptor.h"

#import "HTMLLabel.h"

#import "ZWCommonWebPage.h"
#import "UIApplication+Ext.h"

#pragma mark ------------------------------KVO底层原理------------------------------------
/**< 利用运行时,生成一个对象的子类,并生成子类的对象,替换原对象的isa指针,重写set方法 */

#define kChangeValueKey             @"name"


@interface ApplicationViewController ()<HTMLLabelDelegate>

@property (nonatomic, strong) EOCfamilly *eocFamilly;

@property (nonatomic, strong) EOCfamilly *kvcEocFamilly;

@property (nonatomic, strong) UILabel *nameLabel;

@property (nonatomic, weak) AlertView *privacyAlertView;

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

#pragma mark - Clang
void __sanitizer_cov_trace_pc_guard_init(uint32_t *start,
                                                    uint32_t *stop) {
    static uint64_t N;  // Counter for the guards.
    if (start == stop || *start) return;  // Initialize only once.
    printf("INIT: %p %p\n", start, stop);
    for (uint32_t *x = start; x < stop; x++)
        *x = ++N;  // Guards should start from 1.
}

// 定义原子队列
static OSQueueHead symbolist = OS_ATOMIC_QUEUE_INIT;
// 定义符号结构体
typedef struct {
    void *pc;
    void *next;
} SYNode;

void __sanitizer_cov_trace_pc_guard(uint32_t *guard) {
    void *PC = __builtin_return_address(0);

    SYNode *node = malloc(sizeof(SYNode));
    // 结构体指针指向 SYNode 结构体(pc属性赋值PC,next赋值NULL)
    *node = (SYNode){PC,NULL};
    // 结构体入栈:参数1:链表地址,参数2:存入的节点、参数3:offsetof(类型,参数2的属性)
    OSAtomicEnqueue(&symbolist, node, offsetof(SYNode, next));
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    return;
    NSMutableArray<NSString *> * symbolNames = [NSMutableArray array];
    while (YES) {
        SYNode *node = OSAtomicDequeue(&symbolist, offsetof(SYNode, next));
        if (node == NULL) {
            break;
        }
        Dl_info info;
        dladdr(node->pc, &info);
        // 转OC字符串
        NSString *name = @(info.dli_sname);
        // 非OC方法添加下划线"_"再加入到数组中
        BOOL isObjc = [name hasPrefix:@"+["] || [name hasPrefix:@"-["];
        NSString * symbolName = isObjc ? name : [@"_" stringByAppendingString:name];
        //去重
        if (![symbolNames containsObject:symbolName]) {
            [symbolNames addObject:symbolName];
        }
    }
    // 反向遍历数组
    //symbolNames = (NSMutableArray<NSString *> *)[[symbolNames reverseObjectEnumerator] allObjects];
    //NSLog(@"%@",symbolNames);

// 反向遍历迭代器
    NSEnumerator *em = [symbolNames reverseObjectEnumerator];
    NSMutableArray *funcs = [NSMutableArray arrayWithCapacity:symbolNames.count];
    NSString *name;
    while (name = [em nextObject]) {
        // 已包含的符号不再入组
        if (![funcs containsObject:name]) {
            [funcs addObject:name];
        }
    }
    // 因为是在touchBegan这个方法中实现的功能,但我们启动优化并不需要touchBegan方法,因此去掉
    [funcs removeObject:[NSString stringWithFormat:@"%s", __func__ ]];
    
    
    // 将数组转换为string字符串
    NSString *funcStr = [funcs componentsJoinedByString:@"\n"];
    NSString *filePath = [NSTemporaryDirectory() stringByAppendingString:@"/pagefault.order"];
    NSData *file = [funcStr dataUsingEncoding:NSUTF8StringEncoding];
    BOOL result = [[NSFileManager defaultManager] createFileAtPath:filePath contents:file attributes:nil];
    if (result) {
        NSLog(@"%@",filePath);
    }else{
        NSLog(@"文件写入出错");
    }
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
//    [self cw_showDrawerViewController:leftVc animationType:0 configuration:nil];
    return;
    [UIAlertUtil showAlertTitle:@"Lookin使用" message:nil cancelButtonTitle:@"取消" otherButtonTitles:@[@"导出当前UI结构",@"审查元素",@"3D视图"] actionBlock:^(NSInteger index)
    {
        switch (index) {
            case 0:
                NSLog(@"取消");
                break;
                
            case 1:
                [[NSNotificationCenter defaultCenter] postNotificationName:@"Lookin_Export" object:nil];

                break;
                
            case 2:
                [[NSNotificationCenter defaultCenter] postNotificationName:@"Lookin_2D" object:nil];
                break;
                
            case 3:
                [[NSNotificationCenter defaultCenter] postNotificationName:@"Lookin_3D" object:nil];
                break;
                
            default:
                break;
        }
        
    } superVC:self];
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
    
}

- (void)tapAction:(UIGestureRecognizer *)sender
{
    NSInteger tagIndex = sender.view.tag;
    
    switch (tagIndex) {
        case 101:
        {
            /** AlertView  */
            [self showAlertView:YES];
        }
            break;
        case 102:
        {
            [self showAlertView:NO];
        }
            break;
        case 103:
        {
            /** 展示sheetAlert  */
            [self showAlertSheet];
        }
            break;
        default:
            break;
    }
    
    /** UIAlertUtil  */
//    [self showUIAlertUtil];
    
    /** PACustomAlertManage  */
//    UIView *view = [UIView viewForColor:[UIColor greenColor] withFrame:CGRectMake(0, 0, 200, 200)];
//    [PACustomAlertManage showAlertView:view bolShowNav:NO offseth:100];
    
    /** AlertView  */
//    [self showAlertView:YES];
}

- (void)showAlertSheet
{
    NSString *privacyStr = @"同意<a href='https://www.baidu.com'>《销氪用户协议》</a>、<a href='https://github.com/iHZW'>《销氪个人信息保护政策》</a>和<a href='https://github.com/iHZW/HZWDemo'>《HZWDemo》</a>";

    AlertView *alertView = [[AlertView alloc] init];
    alertView.title = @"温馨提示";
    alertView.actionType = ActionTypeActionSheet;
    alertView.message = @"";
    
    @weakify(alertView)
    alertView.customCenterViewBlock = ^UIView * _Nonnull{
        @strongify(alertView)
        UIView *bottomView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kMainScreenWidth, 127)];
        HTMLLabel *htmlLabel = [[HTMLLabel alloc] initWithFrame:CGRectMake(32, 10, kMainScreenWidth - 64, 60)];
        htmlLabel.numberOfLines = 0;
        htmlLabel.font = PASFont(12);
//        htmlLabel.textColor = UIColorFromRGB(0x999999);
        htmlLabel.text = privacyStr;
        htmlLabel.delegate = self;
        
        htmlLabel.htmlTagClickHandler = ^(NSString *url, NSString *text) {
            @strongify(alertView)
            [alertView hidden];
            ZWCommonWebPage *vc = [[ZWCommonWebPage alloc] init];
            vc.titleName = __String_Not_Nil(text);
            vc.url = __String_Not_Nil(url);
//            vc.modalPresentationStyle = UIModalPresentationOverFullScreen;
//            [self presentViewController:vc animated:YES completion:nil];
            [[UIApplication displayViewController].navigationController pushViewController:vc animated:YES];
//            [self.navigationController pushViewController:vc animated:YES];
        };
        
        CGSize textSize = [htmlLabel sizeThatFits:CGSizeMake(CGRectGetWidth(htmlLabel.frame), INFINITY)];
        htmlLabel.height = textSize.height;
        [bottomView addSubview:htmlLabel];
        
        UIButton *agreeBtn = [UIButton buttonWithFrame:CGRectMake(32, CGRectGetMaxY(htmlLabel.frame) + 20, kMainScreenWidth - 64, 50) title:@"同意并继续" font:PASFont(16) titleColor:UIColorFromRGB(0xFFFFFF) block:^{
            @strongify(alertView)
            [alertView hidden];
        }];
        [agreeBtn setCornerRadius:8];
        agreeBtn.backgroundColor = UIColorFromRGB(0x3F5FFD);
        [bottomView addSubview:agreeBtn];
        bottomView.frame = CGRectMake(0, 0, kMainScreenWidth, CGRectGetMaxY(agreeBtn.frame) + 20);
        return bottomView;
    };
    
    alertView.didHiddenBlock = ^{
        
    };
    [alertView show];
    self.privacyAlertView = alertView;
}

/** 隐藏隐私协议弹框  */
- (void)hiddenPrivacyAlertView
{
    if (self.privacyAlertView) {
        [self.privacyAlertView hidden];
        self.privacyAlertView = nil;
    }
}

#pragma mark - HTMLLabelDelegate
//- (BOOL)HTMLLabel:(HTMLLabel *)label shouldOpenURL:(NSURL *)URL
//{
//    return NO;
//}

//- (void)HTMLLabel:(HTMLLabel *)label tappedLinkWithURL:(NSURL *)URL bounds:(CGRect)bounds
//{
//    [self hiddenPrivacyAlertView];
//    [ZWM.router executeURLNoCallBack:ZWDebugPageHome];
//}


- (void)showAlertView:(BOOL)isExistCenterView
{
    AlertView *alertView = [[AlertView alloc] init];
    alertView.title = @"温馨提示";
    if (isExistCenterView) {
        CGFloat popWidth = kMainScreenWidth - 48*2;
        NSString *titleName = kAlertDefaultTitleString;
        CGFloat titleHeight = [NSString getHeightWithText:titleName font:kAlertDefaultTitleFont width:popWidth - kAlertTitleLabelLeftSpace*2];
        NSString *msg = kAlertDefaultMsgString;
        CGFloat msgHeight = [NSString getHeightWithText:msg font:kAlertDefaultTitleFont width:popWidth - kAlertTitleLabelLeftSpace*2];
        
        CGFloat popHeight = 16 + titleHeight + 8 + msgHeight;
        alertView.customCenterViewBlock = ^UIView * _Nonnull{
            AlertDefaultCustomCenterView * pop = [[AlertDefaultCustomCenterView alloc] initWithFrame:CGRectMake(0, 0, popWidth, popHeight)];
            pop.titleName = titleName;
            pop.titleFont = kAlertDefaultTitleFont;
            pop.titleColor = UIColorFromRGB(0x333333);
            pop.msg = msg;
            pop.msgFont = kAlertDefaultMsgFont;
            pop.msgColor = UIColorFromRGB(0xFF4266);
            return pop;
        };
    } else {
        alertView.messageFont = PASFont(12);
        alertView.message = @"同意<a href='https://www.baidu.com'>《销氪用户协议》</a>、<a href='https://github.com/iHZW'>《销氪个人信息保护政策》</a>和<a href='https://github.com/iHZW/HZWDemo'>《HZWDemo》</a>";
//        @pas_weakify(alertView)
        @weakify(alertView)
        alertView.htmlTagClickHandler = ^(NSString * _Nonnull url, NSString * _Nonnull text) {
            @strongify(alertView)
            [alertView hidden];
            
            ZWCommonWebPage *vc = [[ZWCommonWebPage alloc] init];
            vc.titleName = __String_Not_Nil(text);
            vc.url = __String_Not_Nil(url);
//            vc.modalPresentationStyle = UIModalPresentationOverFullScreen;
//            [self presentViewController:vc animated:YES completion:nil];
            [self.navigationController pushViewController:vc animated:YES];
        };
    }

    @weakify(alertView)
    alertView.actions = @[
        [AlertAction defaultCancelAction:@"取消" clickCallback:^{
            @strongify(alertView)
            [alertView hidden];
        }],
        [AlertAction defaultConfirmAction:@"确认" clickCallback:^{
            @strongify(alertView)
            [alertView hidden];
        }]
    ];
    [alertView show];
}


/** 处理确认按钮点击  */
- (void)dealWithSureAction
{
    [self hiddenPrivacyAlertView];
    
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

@end
