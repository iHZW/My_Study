//
//  ViewController.m
//  My_Study
//
//  Created by HZW on 2019/5/22.
//  Copyright © 2019 HZW. All rights reserved.
//

#import "ViewController.h"
//#import "EOCfamilly.h"
#import "EOCfamilly.h"
#import <objc/runtime.h>
#import "UIAlertUtil.h"
#import "IQViewModel+Eat.h"
#import "My_Study-Swift.h"


//#import <CWLateralSlide/UIViewController+CWLateralSlide.h>


//#import "NSObjec+IQDataBinding.h"

#pragma mark ------------------------------KVO底层原理------------------------------------
/**< 利用运行时,生成一个对象的子类,并生成子类的对象,替换原对象的isa指针,重写set方法 */


#define kChangeValueKey             @"name"

@interface ViewController ()

@property (nonatomic, strong) EOCfamilly *eocFamilly;

@property (nonatomic, strong) EOCfamilly *kvcEocFamilly;

@property (nonatomic, strong) UILabel *nameLabel;

@end


@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    

    // Do any additional setup after loading the view.
    [self loadKVC];
    
    [self loadSubViews];
    
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

- (void)createView
{
    NSLog(@"Swift 调用");
}


- (void)clickBtn
{
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
    [self.view addSubview:label];
    
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(self.view.mas_left).offset(50);
        make.right.equalTo(self.view.mas_right).offset(-50);
        make.top.equalTo(self.view.mas_top).offset(150);
        make.height.mas_equalTo(200);
    }];
    
    BGView *subView = [[BGView alloc] initWithFrame:CGRectMake(100, 500, kMainScreenWidth - 200, 100)];
    
//    subView.backgroundColor = [UIColor greenColor];
    [self.view addSubview:subView];
    
    CustomerView *view = [[CustomerView alloc] initWithFrame:CGRectMake(100, 400, kMainScreenWidth - 200, 50)];
    [self.view addSubview:view];
    
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
    NSLog(@"after = %@", [ViewController findSubClass:[self.eocFamilly class]]);
    
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



-(BOOL)canBecomeFirstResponder {
    return YES;
}

//开始
-(void)motionBegan:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    NSLog(@"motionBegan");
}

//结束
-(void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    if (motion == UIEventSubtypeMotionShake) {
        NSLog(@"motionEnded");
        [self clickBtn];
    }
}

//摇晃取消
-(void)motionCancelled:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    
    
}


@end
