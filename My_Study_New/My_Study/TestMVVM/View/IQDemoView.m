//
//  IQDemoView.m
//  My_Study
//
//  Created by HZW on 2019/5/27.
//  Copyright © 2019 HZW. All rights reserved.
//

#import "IQDemoView.h"
#import "IQViewModel.h"

#define kUserNameKey            @"userName"
#define kUserPwdKey             @"userPwd"

@interface IQDemoView ()<UITextFieldDelegate>

@property (nonatomic, strong) UITextField *userNameField;

@property (nonatomic, strong) UITextField *userPwdField;

@property (nonatomic, strong) IQViewModel *viewModel;

@end


@implementation IQDemoView





#pragma mark--Life Cycle--
- (void)dealloc
{
    /**< 移除监听 */
    [self.viewModel removeObserver:self forKeyPath:kUserNameKey];
    [self.viewModel removeObserver:self forKeyPath:kUserPwdKey];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self loadSubViews];
    }
    return self;
}

- (void)loadSubViews
{
    [self.contentView addSubview:self.userNameField];
    [self.contentView addSubview:self.userPwdField];
    
    self.userNameField.frame = CGRectMake(15, 10, 200, 40);
    self.userPwdField.frame = CGRectMake(15, 60, 200, 40);
    
}



- (void)updateViewWithViewModel:(IQViewModel *)viewModel
{
    self.viewModel = viewModel;

    /**< 添加ViewModel数据变动监听 */
    [self.viewModel addObserver:self forKeyPath:kUserNameKey options:NSKeyValueObservingOptionNew context:NULL];
    [self.viewModel addObserver:self forKeyPath:kUserPwdKey options:NSKeyValueObservingOptionNew context:NULL];
    
}


#pragma mark  --Delegate & KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:kUserNameKey]) {
        self.userNameField.text = change[NSKeyValueChangeNewKey];
    }else if ([keyPath isEqualToString:kUserPwdKey]){
        self.userPwdField.text = change[NSKeyValueChangeNewKey];
    }
}



- (void)textFieldDidEndEditing:(UITextField *)textField
{
    /**< 更新ViewModel */
    if (textField == self.userNameField) {
        self.userNameField.text = textField.text;
    }else if (textField == self.userPwdField){
        self.userPwdField.text = textField.text;
    }
    
    [self.viewModel updateViewModelWithName:self.userNameField.text withPwd:self.userPwdField.text];
}



#pragma mark--Getters & Setters--
- (UITextField *)userNameField {
    if (!_userNameField) {
        _userNameField = [[UITextField alloc]init];
        _userNameField.delegate = self;
    }
    return _userNameField;
}

- (UITextField *)userPwdField {
    if (!_userPwdField) {
        _userPwdField = [[UITextField alloc]init];
        _userPwdField.delegate = self;
    }
    return _userPwdField;
}






@end
