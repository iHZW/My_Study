//
//  DoraemonColorPickInfoView.m
//  DoraemonKit
//
//  Created by wenquan on 2018/12/3.
//

#import "DoraemonColorPickInfoView.h"
#import "DoraemonDefine.h"

@interface DoraemonColorPickInfoView () <UITextFieldDelegate>

@property (nonatomic, strong) UIView *colorView;
@property (nonatomic, strong) UILabel *colorValueLbl;
@property (nonatomic, strong) UIButton *closeBtn;

@property (nonatomic, strong) UITextField *textField;

@end

@implementation DoraemonColorPickInfoView

#pragma mark - Lifecycle

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit {
#if defined(__IPHONE_13_0) && (__IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_13_0)
    if (@available(iOS 13.0, *)) {
        self.backgroundColor = [UIColor colorWithDynamicProvider:^UIColor * _Nonnull(UITraitCollection * _Nonnull traitCollection) {
            if (traitCollection.userInterfaceStyle == UIUserInterfaceStyleLight) {
                return [UIColor whiteColor];
            } else {
                return [UIColor secondarySystemBackgroundColor];
            }
        }];
    } else {
#endif
        self.backgroundColor = [UIColor whiteColor];
#if defined(__IPHONE_13_0) && (__IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_13_0)
    }
#endif
    self.layer.cornerRadius = kDoraemonSizeFrom750_Landscape(8);
    self.layer.borderWidth = 1.;
    self.layer.borderColor = [UIColor doraemon_colorWithHex:0x999999 andAlpha:0.2].CGColor;
    
    [self addSubview:self.colorView];
    [self addSubview:self.colorValueLbl];
    [self addSubview:self.closeBtn];
    [self addSubview:self.textField];
}

- (void)traitCollectionDidChange:(UITraitCollection *)previousTraitCollection {
    [super traitCollectionDidChange:previousTraitCollection];
    // trait发生了改变
#if defined(__IPHONE_13_0) && (__IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_13_0)
    if (@available(iOS 13.0, *)) {
        if ([self.traitCollection hasDifferentColorAppearanceComparedToTraitCollection:previousTraitCollection]) {
            if (UITraitCollection.currentTraitCollection.userInterfaceStyle == UIUserInterfaceStyleDark) {
                [self.closeBtn setImage:[UIImage doraemon_xcassetImageNamed:@"doraemon_close_dark"] forState:UIControlStateNormal];
            } else {
                [self.closeBtn setImage:[UIImage doraemon_xcassetImageNamed:@"doraemon_close"] forState:UIControlStateNormal];
            }
        }
    }
#endif
}

#pragma mark - Layout

- (void)layoutSubviews {
    [super layoutSubviews];
    
    CGFloat colorWidth = kDoraemonSizeFrom750_Landscape(28);
    CGFloat colorHeight = kDoraemonSizeFrom750_Landscape(28);
    self.colorView.frame = CGRectMake(kDoraemonSizeFrom750_Landscape(32), (self.doraemon_height - colorHeight) / 2.0, colorWidth, colorHeight);
    
    CGFloat colorValueWidth = kDoraemonSizeFrom750_Landscape(150);
    self.colorValueLbl.frame = CGRectMake(self.colorView.doraemon_right + kDoraemonSizeFrom750_Landscape(20), 0, colorValueWidth, self.doraemon_height);
    
    CGFloat textFieldWidth = self.doraemon_width - kDoraemonSizeFrom750_Landscape(44) - kDoraemonSizeFrom750_Landscape(32) - self.colorValueLbl.doraemon_right - kDoraemonSizeFrom750_Landscape(5);
    self.textField.frame = CGRectMake(self.colorValueLbl.doraemon_right + kDoraemonSizeFrom750_Landscape(5), 0, textFieldWidth, self.doraemon_height);
    
    CGFloat closeWidth = kDoraemonSizeFrom750_Landscape(44);
    CGFloat closeHeight = kDoraemonSizeFrom750_Landscape(44);
    self.closeBtn.frame = CGRectMake(self.doraemon_width - closeWidth - kDoraemonSizeFrom750_Landscape(32), (self.doraemon_height - closeHeight) / 2.0, closeWidth, closeHeight);
}

#pragma mark - textFieldDelegate

- (BOOL)checkInputWithType:(NSString *)string formatType:(NSString *)formatType
{
    NSCharacterSet *cs = [[NSCharacterSet characterSetWithCharactersInString:formatType] invertedSet];
    NSString *filtered = [[string componentsSeparatedByCharactersInSet:cs] componentsJoinedByString:@""];
    BOOL basic = [string isEqualToString:filtered];
    return basic;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString *result = [textField.text stringByReplacingCharactersInRange:range withString:string];
    NSString *rawText = [result stringByReplacingOccurrencesOfString:@" " withString:@""];
    BOOL isCan = YES;
    /** 判断输入的是十六进制颜色值  */
    BOOL isAble = [self checkInputWithType:string formatType:@"ABCDEFabcdef0123456789"];
    if (rawText.length > 8 || !isAble) {
        isCan = NO;
    }
    return isCan;
}

- (void)textFieldChange:(UITextField *)textField
{
    NSInteger length = textField.text.length;
    if (length == 3
        || length == 4
        || length == 6
        || length == 8)
    {
        [self setCurrentColor:textField.text];
    }
}

//- (void)textFieldDidChangeSelection:(UITextField *)textField
//{
//    if (textField.text.length >= 3) {
//        [self setCurrentColor:textField.text];
//    }
//}

#pragma mark - Public

- (void)setCurrentColor:(NSString *)hexColor{
    self.colorView.backgroundColor = [UIColor doraemon_colorWithHexString:hexColor];
    self.colorValueLbl.text = hexColor;
}

#pragma mark - Actions

- (void)closeBtnClicked:(id)sender {
    if ([self.delegate respondsToSelector:@selector(closeBtnClicked:onColorPickInfoView:)]) {
        [self.delegate closeBtnClicked:sender onColorPickInfoView:self];
    }
}

#pragma mark - Private
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    
    UITouch *touch = [touches anyObject];
    
    CGPoint currentPoint = [touch locationInView:self];
    // 获取上一个点
    CGPoint prePoint = [touch previousLocationInView:self];
    CGFloat offsetX = currentPoint.x - prePoint.x;
    CGFloat offsetY = currentPoint.y - prePoint.y;

    self.transform = CGAffineTransformTranslate(self.transform, offsetX, offsetY);
}


#pragma mark - Getter

- (UIView *)colorView {
    if (!_colorView) {
        _colorView = [[UIView alloc] init];
        _colorView.layer.borderWidth = 1.;
        _colorView.layer.borderColor = [UIColor doraemon_colorWithHex:0x999999 andAlpha:0.2].CGColor;
    }
    return _colorView;
}

- (UILabel *)colorValueLbl {
    if (!_colorValueLbl) {
        _colorValueLbl = [[UILabel alloc] init];
        _colorValueLbl.textColor = [UIColor doraemon_black_1];
        _colorValueLbl.font = [UIFont systemFontOfSize:kDoraemonSizeFrom750_Landscape(28)];
    }
    return _colorValueLbl;
}

- (UITextField *)textField
{
    if (!_textField) {
        _textField = [[UITextField alloc] initWithFrame:CGRectZero];
        _textField.placeholder = @"请输入色值";
        _textField.delegate = self;
        [_textField addTarget:self action:@selector(textFieldChange:) forControlEvents:UIControlEventEditingChanged];
    }
    return _textField;
}

- (UIButton *)closeBtn {
    if (!_closeBtn) {
        _closeBtn = [[UIButton alloc] init];
        UIImage *closeImage = [UIImage doraemon_xcassetImageNamed:@"doraemon_close"];
#if defined(__IPHONE_13_0) && (__IPHONE_OS_VERSION_MAX_ALLOWED >= __IPHONE_13_0)
        if (@available(iOS 13.0, *)) {
            if (UITraitCollection.currentTraitCollection.userInterfaceStyle == UIUserInterfaceStyleDark) {
                closeImage = [UIImage doraemon_xcassetImageNamed:@"doraemon_close_dark"];
            }
        }
#endif
        [_closeBtn setBackgroundImage:closeImage forState:UIControlStateNormal];
        [_closeBtn addTarget:self action:@selector(closeBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    return _closeBtn;
}

@end
