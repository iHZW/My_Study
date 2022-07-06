//
//  BlockViewController.m
//  My_Study
//
//  Created by HZW on 2021/8/28.
//  Copyright © 2021 HZW. All rights reserved.
//

#import "BlockViewController.h"
#import "IQViewModel+Eat.h"
#import <objc/runtime.h>
#import <objc/message.h>
#import "IQViewModel.h"
#import "UIView+Create.h"
#import "BlockSubViewController.h"
#import <malloc/malloc.h>

/** 测试MVP */
#import "TestPresenter.h"

/** 测试MVVM */
#import "MVVMViewModel.h"
#import "MVVMView.h"
#import "MVVMModel.h"

#define kTallMask  (1<<0)


typedef void(^IQBlock) (void);

@interface BlockViewController ()<MVVMViewDelegate>

@property (nonatomic, strong) TestPresenter *presenter;

@property (nonatomic, strong) MVVMViewModel *vm;

@property (nonatomic, strong) MVVMView *mvvmView;

@end

@implementation BlockViewController


void test(id self, SEL _cmd){
    NSLog(@"C语言的IMP----test");
}

void play(id self, SEL _cmd){
    NSLog(@"C语言的IMP---play");
}

//+ (void)load
//{
//    [super load];
//
//    Class cls = NSClassFromString(@"IQViewModel");
////    Class swizzledCls = NSClassFromString(@"BlockViewController");
//
//    SEL originalSel = @selector(test);
//    SEL swizzledSel = NSSelectorFromString(@"play");//@selector(play);
////    SEL swizzledNewSel = sel_registerName("play");
//    Method originalMethod = class_getInstanceMethod(cls, originalSel);
//    Method swizzledMethod = class_getInstanceMethod(cls, swizzledSel);
//
//    if (!originalMethod) {
//        class_addMethod(cls, originalSel, (IMP)test, "v16@0:8");
//        originalMethod = class_getInstanceMethod(cls, originalSel);
//    }
//
//    if (!swizzledMethod) {
//        class_addMethod(cls, swizzledSel, (IMP)play, "v16@0:8");
//        swizzledMethod = class_getInstanceMethod(cls, swizzledSel);
//    }
//
//    IMP originalIMP = method_getImplementation(originalMethod);
//    IMP swizzledIMP = method_getImplementation(swizzledMethod);
//
//    const char *originalType = method_getTypeEncoding(originalMethod);
//    const char *swizzledType = method_getTypeEncoding(swizzledMethod);
//
//    BOOL isAdd = class_addMethod(cls, originalSel, swizzledIMP, swizzledType);
//    if (isAdd) {
//        class_replaceMethod(cls, swizzledSel, originalIMP , originalType);
//    }else{
//        method_exchangeImplementations(originalMethod, swizzledMethod);
//    }
//
//}


- (void)viewDidLoad {
    [super viewDidLoad];
    
//    self.presenter = [[TestPresenter alloc] initWithController:self];
    self.vm = [[MVVMViewModel alloc] init];
    
    @pas_weakify_self
    [self.vm initWithBlock:^(id  _Nullable data) {
        @pas_strongify_self
        NSLog(@"成功");
        MVVMModel *model = (MVVMModel *)data;
        self.mvvmView.name = model.name;
        self.mvvmView.imageName = model.imageName;
    } failBlock:^(id  _Nullable data) {
        NSLog(@"失败");
    }];
    [self.view addSubview:self.mvvmView];

    self.vm.mvvmModel.name = @"张三";
    self.vm.mvvmModel.imageName = @"mvp";
//    self.viewModel = [[MVVMViewModel alloc] initWithController:self];
    
//
//    NSObject *objcTest = [[NSObject alloc] init];
//    NSLog(@"%zd -- %zd", class_getInstanceSize([NSObject class]), malloc_size((__bridge void *)objcTest));
//
    
    
//    struct objc_super{
//       id self;
//       Class BlockViewController;
//    }
//    objc_msgSendSuper(objc_super, @selector(viewDidLoad));
    
    id cls = [IQViewModel class];
    
    void *objc = &cls;
    
    [(__bridge id)objc print];
    
    IQBlock block;
    {
        IQViewModel *model = [IQViewModel demoViewWithName:@"hzw" withPwd:@"123"];
        model.wf_name = @"wf_hzw";
        model.wf_count = 30;

        block = ^{
            NSLog(@"name = %@, count = %@", model.wf_name, @(model.wf_count));
//            NSLog(@"userName = %@, userPwd = %@", model.userName, model.userPwd);
        };
        
    }
    block();
    
    NSLog(@"-------------------");
    // Do any additional setup after loading the view.
    
    
//    UITextField *textField = [UITextField textFieldWithFrame:CGRectMake(60, 100, 200, 60) placeholder:@"请输入:" font:PASFacFont(18) textColor:[UIColor grayColor] bgImage:nil];
//    [self.view addSubview:textField];
    
    
    /** 获取一个类的所有成员变量 */
//    unsigned count;
//    Ivar *ivars = class_copyIvarList([UITextField class], &count);
//
//    for (int i = 0; i < count; i++) {
//        Ivar ivar = ivars[i];
//        NSLog(@"%s----%s", ivar_getName(ivar), ivar_getTypeEncoding(ivar));
//    }
//    free(ivars);
    
//    Method method_ = class_getInstanceMethod([NSObject class], @selector(init));
    
//    unsigned methodCount;
//    Method *methods = class_copyMethodList([NSObject class], &methodCount);
//    for (int i = 0; i < methodCount; i++) {
//        Method method = methods[i];
//        NSLog(@"method_name = %@", NSStringFromSelector(method_getName(method)));
//    }
//    free(methods);
    
//    objc_getClassList(Class  _Nonnull __unsafe_unretained * _Nullable buffer, <#int bufferCount#>)
    
//    unsigned classCount;
//    Class *class_s = objc_copyClassList(&classCount);
//    for (int i = 0; i < classCount; i++) {
//        Class class = class_s[i];
//        NSLog(@"class_name = %@", NSStringFromClass(class));
//    }
//    free(class_s);
    
    
    NSMutableArray *mutArray = [NSMutableArray array];
    Class *class_s = NULL;
    int mutCount = objc_getClassList(class_s, 0);
    if (mutCount > 0) {
        class_s = (__unsafe_unretained Class *)malloc(sizeof(Class) * mutCount);
        mutCount = objc_getClassList(class_s, mutCount);
        
        for (int i = 0; i < mutCount; i++) {
            Class cls = class_s[i];
            NSString *cls_name = NSStringFromClass(cls);
            if (class_getSuperclass(cls) == [NSObject class]) {
                [mutArray addObject:cls_name];
            }
        }
//        NSLog(@"cls_array = %@", mutArray);
    }
    
//    textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:@"请输入:" attributes:@{NSForegroundColorAttributeName : [UIColor blueColor]}];
    
    /** 直接KVO,KVC获取修改 在iOS3之后就不能用了 */
//    [textField setValue:[UIColor redColor] forKeyPath:@"_placeholderLabel.textColor"];
//    UILabel *label = [textField valueForKey:@"_placeholderLabel"];
//    label.textColor = [UIColor yellowColor];
    
    /** 需要使用以下方法进行修改 */
//    Ivar ivar = class_getInstanceVariable([UITextField class], "_placeholderLabel");
//    UILabel *placeLabel = object_getIvar(textField, ivar);
//    placeLabel.textColor = [UIColor cyanColor];
    
}

//- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
//{
//     IQViewModel *model = [IQViewModel new];
//    [model test];
//
//    [self.navigationController pushViewController:[BlockSubViewController new] animated:YES];
//}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - mvvmViewDelegate
- (void)mvvmViewClickDelegate:(MVVMView *)mvpView
{
    NSLog(@"%s", __func__);
    
    self.vm.mvvmModel = [[MVVMModel alloc] initWithName:@"李四" imageName:@"1"];
    
//    [self.viewModel set];
//    self.viewModel.name = @"李四";
//    self.viewModel.imageName = @"mvp";
}


#pragma mark- 懒加载

- (MVVMView *)mvvmView
{
    if (!_mvvmView) {
        _mvvmView = [[MVVMView alloc] initWithViewModel:self.vm];
        _mvvmView.frame = CGRectMake(30, 100, kMainScreenWidth - 30*2, 400);
        _mvvmView.backgroundColor = [UIColor grayColor];
        _mvvmView.delegate = self;
    }
    return  _mvvmView;
}

@end
