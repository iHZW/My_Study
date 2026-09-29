//
//  Two555ViewController.m
//  My_Study
//
//  Created by hzw on 2022/11/15.
//  Copyright © 2022 HZW. All rights reserved.
//

#import "Two555ViewController.h"

typedef void (^TestBlock)(NSInteger index, NSString *name);

typedef NS_ENUM(NSInteger, ENUMType) {
    ENUMTypeOne   = 1,        // 1
    ENUMTypeTwo   = 2,        // 2
    ENUMTypeThree = 100 << 1, //    3
};

typedef NS_ENUM(NSUInteger, UIBorderSideType) {
    UIBorderSideTypeAll    = 0,
    UIBorderSideTypeTop    = 1 << 0,
    UIBorderSideTypeLeft   = 1 << 1,
    UIBorderSideTypeRight  = 1 << 2,
    UIBorderSideTypeBottom = 1 << 3,
};

@interface Two555ViewController ()

@property (nonatomic, copy) TestBlock testBlock;

@end

@implementation Two555ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    int a = 5, b = 3, c = 10;
    NSString *name = @"";
    a += 1;
    b    = 2;
    c    = a + b;
    name = @"111";

    self.testBlock = ^(NSInteger index, NSString *name) {
        NSLog(@"idnex: %li--name:%@", index, name);
    };
    NSLog(@"a:%@--b:%@--c:%@", @(a), @(b), @(c));
    name = b == 2 ? @"222" : @"";
}

- (void)testOne:(NSString *)one
            two:(NSInteger)two
          three:(NSInteger)three {
    NSLog(@"---");
}

- (void)testOne:(NSString *)one two:(NSInteger)two {
    NSLog(@"---");
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    if (self.testBlock) {
        self.testBlock(100, @"100");
    }
}

@end
