//
//  DrawPolygonVc.m
//  My_Study
//
//  Created by hzw on 2024/10/11.
//  Copyright © 2024 HZW. All rights reserved.
//

#import "DrawPolygonVc.h"
#import "PolygonView.h"

@interface DrawPolygonVc ()

@property (nonatomic, strong) PolygonView *polygonView;

@end

@implementation DrawPolygonVc

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.view addSubview:self.polygonView];
    
    [self.polygonView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.equalTo(self.view);
    }];
}


- (PolygonView *)polygonView {
    if (!_polygonView) {
        _polygonView = [[PolygonView alloc] initWithFrame:CGRectZero];
    }
    return _polygonView;
}


@end
