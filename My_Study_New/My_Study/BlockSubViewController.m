//
//  BlockSubViewController.m
//  My_Study
//
//  Created by HZW on 2021/9/1.
//  Copyright © 2021 HZW. All rights reserved.
//

#import "BlockSubViewController.h"

@interface BlockSubViewController ()

@end

@implementation BlockSubViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    NSMutableArray *mutArray = [NSMutableArray array];
    Class *class_s = NULL;
    int mutCount = objc_getClassList(class_s, 0);
    if (mutCount > 0) {
        class_s = (__unsafe_unretained Class *)malloc(sizeof(Class) * mutCount);
        mutCount = objc_getClassList(class_s, mutCount);
        
        for (int i = 0; i < mutCount; i++) {
            Class cls = class_s[i];
            NSString *cls_name = NSStringFromClass(cls);

        
            if ([class_getSuperclass(cls) isSubclassOfClass:[PASBaseViewController class]]) {
                [mutArray addObject:cls_name];
            }
                        
//            if (class_getSuperclass(cls) == [PASBaseViewController class]) {
//                [mutArray addObject:cls_name];
//            }
        }
        NSLog(@"cls_array = %@", mutArray);
    }
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
