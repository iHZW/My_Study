//
//  ViewController.m
//  My_Study
//
//  Created by HZW on 2019/5/22.
//  Copyright © 2019 HZW. All rights reserved.
//

#import "ViewController.h"
#import "EOCfamilly.h"
#import <objc/runtime.h>

//#import "NSObjec+IQDataBinding.h"

#pragma mark ------------------------------KVO底层原理------------------------------------
/**< 利用运行时,生成一个对象的子类,并生成子类的对象,替换原对象的isa指针,重写set方法 */


#define kChangeValueKey             @"name"

@interface ViewController ()

@property (nonatomic, strong) EOCfamilly *eocFamilly;

@property (nonatomic, strong) EOCfamilly *kvcEocFamilly;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
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
    // Do any additional setup after loading the view.
    
}


#pragma mark ------------------------------测试KVC------------------------------------
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
