//
//  ScanResultViewController.m
//  My_Study
//
//  Created by hzw on 2023/8/29.
//  Copyright © 2023 HZW. All rights reserved.
//

#import "ScanResultViewController.h"

@interface ScanResultViewController ()

@property(nonatomic, strong) UIImageView *scanImg;

@property(nonatomic, strong) UILabel *labelScanText;

@property(nonatomic, strong) UILabel *labelScanCodeType;

@end

@implementation ScanResultViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    if ([self respondsToSelector:@selector(setEdgesForExtendedLayout:)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    [self _setUI];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    if (!_imgScan) {
        _scanImg.backgroundColor = [UIColor grayColor];
    }

    _scanImg.image = _imgScan;
    _labelScanText.text = _strScan;
    _labelScanCodeType.text = [NSString stringWithFormat:@"码的类型:%@", _strCodeType];
}



#pragma mark - setUI
- (void)_setUI {
    [self.view addSubview:self.scanImg];
    [self.view addSubview:self.labelScanText];
    [self.view addSubview:self.labelScanCodeType];
    
    
    [self.scanImg mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(self.view);
        make.size.mas_equalTo(CGSizeMake(240, 248));
        make.top.equalTo(self.view.mas_top).offset(100);
    }];
    
    [self.labelScanText mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.scanImg.mas_bottom).offset(20);
        make.left.offset(kContentSideHorizSpace);
        make.right.offset(-kContentSideHorizSpace);
        make.height.mas_equalTo(30);
    }];
    
    
    [self.labelScanCodeType mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.labelScanText.mas_bottom).offset(20);
        make.left.offset(kContentSideHorizSpace);
        make.right.offset(-kContentSideHorizSpace);
        make.bottom.offset(-50);
    }];
    
}



#pragma mark -  Lazy loading
- (UIImageView *)scanImg {
    if (!_scanImg) {
        _scanImg = [[UIImageView alloc] init];
        _scanImg.contentMode = UIViewContentModeScaleAspectFit;
    }
    return _scanImg;
}

- (UILabel *)labelScanText {
    if (!_labelScanText) {
        _labelScanText = [UILabel labelWithFrame:CGRectZero text:@"" textColor:UIColorFromRGB(0x111111) font:PASFont(17)];
    }
    return _labelScanText;
}

- (UILabel *)labelScanCodeType {
    if (!_labelScanCodeType) {
        _labelScanCodeType = [UILabel labelWithFrame:CGRectZero text:@"" textColor:UIColorFromRGB(0x111111) font:PASFont(17)];
    }
    return _labelScanCodeType;
}

@end
