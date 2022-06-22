//
//  MDLogSearchView.m
//  My_Study
//
//  Created by Zhiwei Han on 2022/6/19.
//  Copyright © 2022 HZW. All rights reserved.
//

#import "MDLogSearchView.h"
#import "ZWSDK.h"
#import "PASUIDefine.h"
#import "UIView+Frame.h"

@interface MDLogSearchView ()<UITextFieldDelegate>

@property (nonatomic, strong) NSString *searchName; /**< 搜索内容 */

@property (nonatomic, strong) UITextField *textField;

@property (nonatomic, strong) UIButton *cancelBtn;

@property (nonatomic, assign) BOOL isShowCancelBtn;

@end

@implementation MDLogSearchView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        
//        self.isShowCancelBtn = NO;
        self.backgroundColor = UIColorFromRGB(0xFFFFFF);
        [self addSubview:self.textField];
        [self addSubview:self.cancelBtn];
        
        [self.textField mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.mas_left).offset(kContentSideHorizSpace);
            make.top.equalTo(self.mas_top).offset(PASFactor(10));
            make.bottom.equalTo(self.mas_bottom).offset(-PASFactor(10));
//            make.width.mas_equalTo(CGRectGetWidth(self.frame) - kContentSideHorizSpace*2);
            make.right.equalTo(self.mas_right).offset(-kContentSideHorizSpace);
        }];
        
        /** 协助查看约束警告使用  */
        MASAttachKeys(self.textField)
        
        [self.cancelBtn mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.textField.mas_right).offset(kContentSideHorizSpace);
            make.top.bottom.equalTo(self);
            make.width.mas_equalTo(PASFactor(40));
//            make.right.equalTo(self.mas_right).offset(-kContentSideHorizSpace);
        }];
        
        MASAttachKeys(self.cancelBtn)

    }
    return self;
}

- (void)setIsShowCancelBtn:(BOOL)isShowCancelBtn
{
    _isShowCancelBtn = isShowCancelBtn;
    if (isShowCancelBtn) {
        [self searchBegin];
        self.cancelBtn.hidden = NO;
//        [self.cancelBtn mas_updateConstraints:^(MASConstraintMaker *make) {
//            make.width.mas_offset(PASFactor(40));
//        }];
        
        [self.textField mas_updateConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.mas_right).offset(-kContentSideHorizSpace*2 - PASFactor(40));
//            make.width.mas_equalTo(CGRectGetWidth(self.frame) - kContentSideHorizSpace*3 - PASFactor(40));
        }];
        
    }else{
        
        self.cancelBtn.hidden = YES;
        [self.textField mas_updateConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.mas_right).offset(-kContentSideHorizSpace);
//            make.width.mas_equalTo(CGRectGetWidth(self.frame) - kContentSideHorizSpace*2);

        }];
    }
}


- (UITextField *)textField
{
    if (!_textField) {
        _textField = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame))];
        _textField.textColor = UIColorFromRGB(0x333333);
        _textField.font = PASFacFont(14);
        _textField.backgroundColor = UIColorFromRGB(0xF5F5F5);
        [_textField setCornerRadius:8 borderWidth:.1 borderColor:[UIColor clearColor]];
        
        //文本框左视图
        UIView *leftView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, PASFactor(35), PASFactor(35))];
        leftView.backgroundColor = [UIColor clearColor];
        //添加图片
        UIImageView *headView = [[UIImageView alloc]initWithFrame:CGRectMake(20, 10, PASFactor(13), PASFactor(13))];
        headView.image = [UIImage imageNamed:@"icon_search"];
        [leftView addSubview:headView];
        headView.centerY = leftView.centerY;
        _textField.leftView = leftView;
        
        NSMutableAttributedString *placeholderString = [[NSMutableAttributedString alloc] initWithString:@"请输入搜索关键词" attributes:@{NSForegroundColorAttributeName : UIColorFromRGB(0x999999), NSFontAttributeName : PASFont(14)}];
        _textField.attributedPlaceholder = placeholderString;
//        _textField.placeholder = @"请输入搜索关键词";
//        [_textField setValue:UIColorFromRGB(0x999999) forKeyPath:@"_placeholderLabel.textColor"];
//        [_textField setValue:PASFacFont(14) forKeyPath:@"_placeholderLabel.font"];
        _textField.leftViewMode = UITextFieldViewModeAlways;
//        _textField.clearButtonMode = UITextFieldViewModeWhileEditing ;
        _textField.delegate = self;
        [_textField addTarget:self action:@selector(textFieldChange:) forControlEvents:UIControlEventEditingChanged];
    }
    return _textField;
}


- (UIButton *)cancelBtn
{
    if (!_cancelBtn) {
        _cancelBtn = [UIButton buttonWithFrame:CGRectZero target:self action:@selector(cancelAction:) title:@"取消" font:PASFacFont(15) titleColor:UIColorFromRGB(0x333333) bgImage:nil tag:0000121 block:nil];
        _cancelBtn.titleLabel.adjustsFontSizeToFitWidth = YES;
    }
    return _cancelBtn;
}

/**< 触发搜索 */
- (void)searchBegin
{
    __PASBI
}

/**< 点击取消按钮 */
- (void)cancelAction:(UIButton *)sender
{
    __PASBI
//    CMLogDebug(LogBusinessMarket, @"点击了取消");
    if (self.searchStatusBlock) {
        self.searchStatusBlock(SearchStatusTypeResign);
    }
    self.textField.text = @"";
    self.isShowCancelBtn = NO;
    [self.textField resignFirstResponder];
}

/**
 取消搜索
 */
- (void)cancelSearchStatus
{
    self.textField.text = @"";
    self.isShowCancelBtn = NO;
    [self.textField resignFirstResponder];
}


- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    // 输入空格不响应
    NSString *tem = [[string componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]componentsJoinedByString:@""];
    if (![string isEqualToString:tem]) {
        return NO;
    }
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (self.searchStatusBlock) {
        self.searchStatusBlock(SearchStatusTypeBecome);
    }
    if (!self.isShowCancelBtn) {
        self.isShowCancelBtn = YES;
    }
}


- (void)textFieldDidEndEditing:(UITextField *)textField reason:(UITextFieldDidEndEditingReason)reason
{
    
}

- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    self.searchName = @"";
    if (self.searchNameBlock) {
        self.searchNameBlock(self.searchName);
    }
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    return YES;
}

- (void)textFieldChange:(UITextField *)textField
{
    self.searchName = [DataFormatterFunc validStringValue:textField.text];
    if (self.searchNameBlock) {
        self.searchNameBlock(self.searchName);
    }
}

@end
