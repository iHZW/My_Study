//
//  AlertView.m
//  CRM
//
//  Created by js on 2020/2/20.
//  Copyright © 2020 js. All rights reserved.
//

#import "AlertView.h"
#import "UIView+SVG.h"
#import "HTMLLabel.h"
#import "NSString+Adaptor.h"
#import "UIColor+Ext.h"
#import "NSObject+RACPropertySubscribing.h"

@interface AlertActionCell()<UIGestureRecognizerDelegate>
@end
@implementation AlertActionCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self){
        [self initUI];
    }
    return self;
}

- (void)initUI{
    _titleLabel = [[UILabel alloc] init];
    _titleLabel.textAlignment = NSTextAlignmentCenter;
    _titleLabel.font = PASFontWithName(kPFRegularFontName, 17);
    [self addSubview:self.titleLabel];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self.contentView.mas_centerY);
        make.leading.equalTo(@16);
        make.trailing.equalTo(@-16);
    }];
}

@end

@interface AlertView()<UIGestureRecognizerDelegate,UITableViewDataSource,UITableViewDelegate>
@property (nonatomic, strong, readwrite) UIView *contentView;
@property (nonatomic, strong) UIImageView *bgImageView;
@property (nonatomic, strong) UIView *topView;
@property (nonatomic, strong) UIView *centerView;
@property (nonatomic, strong) UIView *bottomView;


@property (nonatomic, assign) CGFloat lastTranslationY;
@end

@implementation AlertView

- (void)dealloc{
    NSLog(@"AlertView dealloc");
    [LogUtil debug:@"AlertView释放" flag:self.title context:self];
}

#pragma mark - Properties

- (UIView *)contentView{
    if (!_contentView){
        _contentView = [[UIView alloc] init];
        _contentView.backgroundColor = [UIColor whiteColor];
    }
    return _contentView;
}

- (UIImageView *)bgImageView{
    if (!_bgImageView){
        _bgImageView = [[UIImageView alloc] init];
        _bgImageView.contentMode = UIViewContentModeScaleAspectFill;
        _bgImageView.image = [UIImage svg_imageNamed:@"bg_login" scaleToFitInside:CGSizeMake(94.5, 97.5)];
    }
    return _bgImageView;
}

#pragma mark - Alert
- (CGFloat)maxAlertContentWidth{
    CGFloat width = kMainScreenWidth - 48 * 2;
    
    return width;
}
- (void)drawAlertUI{
    self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.4];
    [self addSubview:self.contentView];
    
    self.bgImageView.frame = CGRectMake([self maxAlertContentWidth] - 94.5, 0, 94.5, 97.5);;
    [self.contentView addSubview:self.bgImageView];
    
    
    UIFont *titleFont = self.titleFont ?: PASFont(17);
    UIFont *messageFont = self.messageFont ?: PASFont(17);
    UIFont *buttonTextFont = PASFont(16);

    CGFloat contentWidth = [self maxAlertContentWidth];
    CGFloat horizonMargin = 24;
    CGFloat verticalMargin = 24;
    CGFloat maxTextHeight = kMainScreenHeight / 2 - 4 * verticalMargin - 50;
    UIView *lastView = nil;
    
    if (self.customTopViewBlock){
        UIView *topView = self.customTopViewBlock();
        CGRect frame = CGRectMake(0, 0, topView.frame.size.width, topView.frame.size.height);
        topView.frame = frame;
        self.topView = topView;
        lastView = self.topView;
        [self.contentView addSubview:lastView];
    } else {
        if (self.title.length > 0){
            CGSize maxSize = CGSizeMake(contentWidth - 2 * horizonMargin, maxTextHeight);
            CGSize size = [NSString getSizeWithText:self.title font:titleFont width:maxSize.width];
            CGRect frame = CGRectMake(0, verticalMargin, contentWidth, size.height);
            self.topView = [[UIView alloc] initWithFrame:frame];
            
            frame = CGRectMake(horizonMargin, 0, size.width, size.height);
            UILabel *label = [[UILabel alloc] initWithFrame:frame];
            label.numberOfLines = 0;
            label.font = titleFont;
            label.textColor = [UIColor colorFromHexCode:@"#CCCCCC"];
            label.text = self.title;
            [self.topView addSubview:label];

            lastView = self.topView;
            [self.contentView addSubview:lastView];
        }
    }
    
    if (self.showClose) {
        UIButton *button  = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(contentWidth - 36, -8, 20, 20);
        [button setImage:[UIImage imageNamed:@"icon_pop_close"] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(closeButton) forControlEvents:UIControlEventTouchUpInside];
        [self.topView addSubview:button];
    }
    
    if (self.customCenterViewBlock){
        UIView *centerView = self.customCenterViewBlock();
        CGRect frame = CGRectMake(centerView.frame.origin.x, CGRectGetMaxY(lastView.frame), centerView.frame.size.width, centerView.frame.size.height);
        centerView.frame = frame;
        self.centerView = centerView;
        lastView = self.centerView;
        [self.contentView addSubview:lastView];
    } else {
        if (self.message.length > 0){
            HTMLLabel *htmlLabel = [[HTMLLabel alloc] initWithFrame:CGRectMake(horizonMargin, 0, contentWidth - 2 * horizonMargin, CGFLOAT_MAX)];
            htmlLabel.text = self.message;
            htmlLabel.font = messageFont;
            CGSize textSize = [htmlLabel sizeThatFits:CGSizeMake(CGRectGetWidth(htmlLabel.frame), INFINITY)];
            htmlLabel.height = textSize.height;

            @pas_weakify_self
            htmlLabel.htmlTagClickHandler = ^(NSString *url, NSString *text) {
                @pas_strongify_self
                BlockSafeRun(self.htmlTagClickHandler, url, text);
            };
            
            UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, contentWidth, MIN(textSize.height, maxTextHeight))];
            scrollView.contentSize = CGSizeMake(contentWidth, textSize.height);
            [scrollView addSubview:htmlLabel];
            
            CGFloat originY = lastView ? CGRectGetMaxY(lastView.frame) + 16 : verticalMargin;
            CGRect frame = CGRectMake(0, originY, contentWidth, MIN(textSize.height, maxTextHeight));
            self.centerView = [[UIView alloc] initWithFrame:frame];
            [self.centerView addSubview:scrollView];
            
            lastView = self.centerView;
            [self.contentView addSubview:lastView];
        }
    }
    
    if (self.customBottomViewBlock){
        UIView *bottomView = self.customBottomViewBlock();
        CGRect frame = CGRectMake(0, CGRectGetMaxY(lastView.frame), bottomView.frame.size.width, bottomView.frame.size.height);
        bottomView.frame = frame;
        self.bottomView = bottomView;
        lastView = self.bottomView;
        [self.contentView addSubview:lastView];
    } else {
        if (self.actions.count > 0){
            CGFloat buttonHeight = 40;
            CGFloat scale = kMainScreenWidth / 375;
            //固定间距22, 按钮等分宽度
            CGFloat actionMargin = 22;
            CGFloat totalWidth = contentWidth - 2 * horizonMargin;
            
            NSInteger actionCount = self.actions.count;
            CGFloat buttonWidth = self.actions.count == 1 ? 140 * scale : (totalWidth - (actionCount -1) * actionMargin) / actionCount;
            
            CGFloat buttonStartX = (self.actions.count == 1 ? (contentWidth - buttonWidth ) / 2.0 : 0)
                                    + (self.actions.count == 1 ? 0 : horizonMargin);
            
            CGFloat buttonHorizonMargin = actionMargin;
            //self.actions.count == 1 ? 0 : ((contentWidth - buttonWidth * self.actions.count - horizonMargin * 2) / self.actions.count - 1);
            
            if (actionCount == 1){
                buttonStartX = (contentWidth - buttonWidth ) / 2.0;
                buttonHorizonMargin = 0;
            } else{
                buttonStartX = horizonMargin;
//                buttonHorizonMargin = (contentWidth - buttonWidth * self.actions.count - horizonMargin * 2) / (self.actions.count - 1);
            }
            CGFloat originY = lastView ? CGRectGetMaxY(lastView.frame) + 28 : verticalMargin;
            CGRect frame = CGRectMake(0, originY, contentWidth, buttonHeight);
            self.bottomView = [[UIView alloc] initWithFrame:frame];
            for (NSUInteger i = 0; i < self.actions.count; i++){
                AlertAction *action = [self.actions objectAtIndex:i];
                CGFloat originX = buttonStartX + buttonWidth * i + i * buttonHorizonMargin;
                CGRect frame = CGRectMake(originX, 0, buttonWidth, buttonHeight);
                UIButton *button = [[UIButton alloc] initWithFrame:frame];
                button.backgroundColor = action.backgroudColor;
                button.titleLabel.font = buttonTextFont;
                [button setTitleColor:action.textColor forState:UIControlStateNormal];
                [button setTitle:action.title forState:UIControlStateNormal];
                button.layer.cornerRadius = 4;
                button.layer.masksToBounds = YES;
                button.tag = 1000 + i;
                [button addTarget:self action:@selector(tapButton:) forControlEvents:UIControlEventTouchUpInside];
                [self.bottomView addSubview:button];
            }
            lastView = self.bottomView;
            [self.contentView addSubview:lastView];
            
            frame = CGRectMake(0, CGRectGetMaxY(lastView.frame), contentWidth, verticalMargin);
            UIView *bottomMarginView = [[UIView alloc] initWithFrame:frame];
            bottomMarginView.backgroundColor = [UIColor whiteColor];
            lastView = bottomMarginView;
            [self.contentView addSubview:lastView];
        }
    }
    
    CGFloat contentViewHeight = CGRectGetMaxY(lastView.frame);
    CGRect frame = CGRectMake(48, (kMainScreenHeight - contentViewHeight ) / 2, [self maxAlertContentWidth], contentViewHeight);
    self.contentView.frame = frame;
}

#pragma mark - UIGestureRecognizerDelegate
-(void)panGestureRecognize:(UIPanGestureRecognizer *)recognize{
    [self handleActionSheetPanGestureStateChange:recognize.state];
}

#pragma mark - ActionSheet

- (void)drawActionSheetUI{
    self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:0.4];
    [self addSubview:self.contentView];
    
    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(actionSheetPanGesture:)];
    panGesture.delegate = self;
    [self addGestureRecognizer:panGesture];
    
    UIFont *titleFont = self.titleFont ?: PASFont(17);
    UIFont *messageFont = self.messageFont ?: PASFont(12);
    

    CGFloat contentWidth = kMainScreenWidth;
    CGFloat maxTextHeight = kMainScreenHeight / 2;
    
    UIView *lastView = nil;
    CGRect frame = CGRectZero;
    if (self.customTopViewBlock){
        UIView *topView = self.customTopViewBlock();
        CGRect frame = CGRectMake(0, 0, topView.frame.size.width, topView.frame.size.height);
        topView.frame = frame;
        self.topView = topView;
        lastView = self.topView;
        [self.contentView addSubview:lastView];
    } else {
        
        frame = CGRectMake(0, 0, contentWidth, 20);
        self.topView = [[UIView alloc] initWithFrame:frame];
        [self.contentView addSubview:self.topView];
        
        CGFloat indicatorContainerWidth = 60;
        CGFloat indicatorWidth = 32;
        frame = CGRectMake((contentWidth - indicatorContainerWidth) / 2, 0, indicatorContainerWidth, 20);
        UIView *indicatorContainerView = [[UIView alloc] initWithFrame:frame];
        [self.topView addSubview:indicatorContainerView];
        
        frame = CGRectMake((indicatorContainerWidth - indicatorWidth) / 2.0, 8, indicatorWidth, 4);
        UIView *indicatorView = [[UIView alloc] initWithFrame:frame];
        indicatorView.backgroundColor = [UIColor colorFromHexCode:@"#DFDFDF"];
        indicatorView.layer.cornerRadius = 2;
        indicatorView.layer.masksToBounds = YES;
        
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(indicatorViewTap:)];
        [indicatorContainerView addGestureRecognizer:tap];
        [indicatorContainerView addSubview:indicatorView];
        lastView = indicatorContainerView;
        if (self.title.length > 0){
            CGSize maxSize = CGSizeMake(contentWidth, maxTextHeight);
            CGSize size = [NSString getSizeWithText:self.title font:titleFont width:maxSize.width];
            CGRect frame = CGRectMake(0, 20, contentWidth, size.height);
            UILabel *label = [[UILabel alloc] initWithFrame:frame];
            label.textAlignment = NSTextAlignmentCenter;
            label.numberOfLines = 0;
            label.font = titleFont;
            label.textColor = [UIColor colorFromHexCode:@"#333333"];
            label.text = self.title;
            [self.topView addSubview:label];

            lastView = label;
        }
        
        if (self.message.length > 0){
              CGSize maxSize = CGSizeMake(contentWidth, maxTextHeight);
            CGSize size = [NSString getSizeWithText:self.message font:messageFont width:maxSize.width];
              CGRect frame = CGRectMake(0, CGRectGetMaxY(lastView.frame) + 5, contentWidth, size.height);
              UILabel *label = [[UILabel alloc] initWithFrame:frame];
              label.textAlignment = NSTextAlignmentCenter;
              label.numberOfLines = 0;
              label.font = messageFont;
              label.textColor = [UIColor colorFromHexCode:@"#888888"];
              label.text = self.message;
              [self.topView addSubview:label];
              lastView = label;
        }
        
        
        if (self.title.length == 0 && self.message.length == 0){
            frame = CGRectMake(0, 0, contentWidth, CGRectGetMaxY(lastView.frame) - 2);
        } else {
            frame = CGRectMake(0, 0, contentWidth, CGRectGetMaxY(lastView.frame) + 16);
        }
        self.topView.frame = frame;
        lastView = self.topView;
    }
    
    if (self.customCenterViewBlock){
        UIView *centerView = self.customCenterViewBlock();
        CGRect frame = CGRectMake(centerView.frame.origin.x, CGRectGetMaxY(lastView.frame), centerView.frame.size.width, centerView.frame.size.height);
        centerView.frame = frame;
        self.centerView = centerView;
        lastView = self.centerView;
        [self.contentView addSubview:lastView];
    } else {
        CGFloat rowHeight = 55;
        CGFloat listMaxHeight = kMainScreenHeight - kSysStatusBarHeight - SafeAreaBottomAreaHeight - CGRectGetHeight(self.topView.frame) - 80 - 50;
        CGFloat tableContentHeight = rowHeight * self.actions.count;
        
        CGFloat tableHeight = MIN(listMaxHeight,tableContentHeight);
        frame = CGRectMake(0, CGRectGetMaxY(lastView.frame), contentWidth, tableHeight);
        self.centerView = [[UIView alloc] initWithFrame:frame];
        [self.contentView addSubview:self.centerView];
        frame = CGRectMake(0, 0, contentWidth, tableHeight);
        UITableView *tableView = [[UITableView alloc] initWithFrame:frame style:UITableViewStylePlain];
        tableView.separatorColor = [UIColor colorFromHexCode:@"EDEDED"];
        [tableView registerClass:[AlertActionCell class] forCellReuseIdentifier:@"AlertActionCell"];
        tableView.rowHeight = rowHeight;
        tableView.delegate = self;
        tableView.dataSource = self;
        tableView.bounces = tableContentHeight > tableHeight;
        if (@available(iOS 15.0, *)) {
            tableView.sectionHeaderTopPadding = 0;
        }
        [self.centerView addSubview:tableView];
        lastView = self.centerView;
        
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 1, 0.5)];
        // 江青山--去掉顶部线
//        lineView.backgroundColor = [UIColor colorFromHexCode:@"EDEDED"];
        tableView.tableHeaderView = lineView;
    }
    
    if (self.customBottomViewBlock){
        UIView *bottomView = self.customBottomViewBlock();
        CGRect frame = CGRectMake(0, CGRectGetMaxY(lastView.frame), bottomView.frame.size.width, bottomView.frame.size.height);
        bottomView.frame = frame;
        self.bottomView = bottomView;
        lastView = self.bottomView;
        [self.contentView addSubview:lastView];
    } else {
        if (self.footerAction){
            frame = CGRectMake(0,CGRectGetMaxY(lastView.frame), contentWidth, 70);
            self.bottomView = [[UIView alloc] initWithFrame:frame];
            [self.contentView addSubview:self.bottomView];
            
            frame = CGRectMake(0,0, contentWidth, 10);
            UIView *spaceView = [[UIView alloc] initWithFrame:frame];
            spaceView.backgroundColor = [UIColor colorFromHexCode:@"#F6F6F6"];
            [self.bottomView addSubview:spaceView];
           
            frame = CGRectMake(0,10, contentWidth, 60);
            UIButton *button = [[UIButton alloc] initWithFrame:frame];
            button.backgroundColor = self.footerAction.backgroudColor;
            button.titleLabel.font = PASFont(17);
            [button setTitleColor:self.footerAction.textColor forState:UIControlStateNormal];
            [button setTitle:self.footerAction.title forState:UIControlStateNormal];
            [button addTarget:self action:@selector(footerActionButton:) forControlEvents:UIControlEventTouchUpInside];
            [self.bottomView addSubview:button];
            lastView = self.bottomView;
        }
    }
    
    [self.contentView bringSubviewToFront:self.topView];
    
    CGFloat contentViewHeight = CGRectGetMaxY(lastView.frame) + SafeAreaBottomAreaHeight;
    frame = CGRectMake(0,kMainScreenHeight - contentViewHeight, contentWidth, contentViewHeight);
    self.contentView.frame = frame;
}

- (void)indicatorViewTap:(UIGestureRecognizer *)gesture{
    if (self.disableBgTap){
        return;
    }
    [self hidden];
}
#pragma mark - TableViewDelegate&DataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.actions.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    AlertAction *action = [self.actions objectAtIndex:indexPath.row];
    AlertActionCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AlertActionCell" forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.titleLabel.text = action.title;
    cell.titleLabel.textColor = action.textColor;
    BlockSafeRun(self.cellDidLoadBlock,cell);
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    AlertAction *action = [self.actions objectAtIndex:indexPath.row];
    BlockSafeRun(action.clickCallback);
    if (self.autoCloseClicked){
        [self hidden];
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    UIEdgeInsets inset;
    if (indexPath.row == self.actions.count - 1){
        inset = UIEdgeInsetsMake(0, kMainScreenWidth, 0, 0);
    } else {
        inset = UIEdgeInsetsMake(0, 0, 0, 0);
    }
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:inset];
    }
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:inset];
    }
    
    // Prevent the cell from inheriting the Table View's margin settings
    if ([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
        [cell setPreservesSuperviewLayoutMargins:NO];
    }
}

- (void)layoutSubviews{
    [super layoutSubviews];
    UIBezierPath *path = nil;
    if (self.actionType == ActionTypeAlert){
        path = [UIBezierPath bezierPathWithRoundedRect:self.contentView.bounds byRoundingCorners:UIRectCornerAllCorners cornerRadii:CGSizeMake(12, 12)];
    } else {
        path = [UIBezierPath bezierPathWithRoundedRect:self.contentView.bounds byRoundingCorners:UIRectCornerTopLeft | UIRectCornerTopRight cornerRadii:CGSizeMake(12, 12)];
    }
    
    CAShapeLayer *layer = [[CAShapeLayer alloc] init];
    layer.frame = self.contentView.bounds;
    layer.path = path.CGPath;
    self.contentView.layer.mask = layer;
    
}

#pragma mark - Methods

static AlertView *gAlertView = nil;
+ (void)updateCurrentAlertView:(AlertView *)alertView{
    gAlertView = alertView;
}

+ (AlertView *)currentAlertView{
    return gAlertView;
}

- (void)show{
    UIView *parentView = [UIApplication sharedApplication].keyWindow;
    [self showInView:parentView];
}

- (void)showInView:(UIView *)parentView{
    [AlertView updateCurrentAlertView:self];
    
    if (parentView == nil){
        parentView = [UIApplication sharedApplication].keyWindow;
    }
    
    if (self.actionType == ActionTypeAlert){
        [self drawAlertUI];
    } else if (self.actionType == ActionTypeActionSheet) {
        [self drawActionSheetUI];
    }
    
    self.frame = parentView.bounds;
    [parentView addSubview:self];
    
    UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapBack:)];
    gesture.delegate = self;
    [self addGestureRecognizer:gesture];
    
    //显示动画
    if (self.actionType == ActionTypeActionSheet){
        CGRect frame = self.contentView.frame;
        
        CGRect startFrame = CGRectMake(frame.origin.x, self.frame.size.height, frame.size.width, frame.size.height);
        self.contentView.frame = startFrame;
        [UIView animateWithDuration:0.3 animations:^{
            self.contentView.frame = frame;
        }];
    }
}

- (void)moveToView:(UIView *)parentView{
    [parentView addSubview:self];
}


- (void)hidden{
    [self hidden:YES];
}

- (void)hidden:(BOOL)animated{
    [AlertView updateCurrentAlertView:nil];
    if (self.actionType == ActionTypeActionSheet){
        CGRect frame = self.contentView.frame;
        CGRect destFrame = CGRectMake(frame.origin.x, self.frame.size.height, frame.size.width, frame.size.height);
        if (animated){
            [UIView animateWithDuration:0.3 animations:^{
               self.contentView.frame = destFrame;
            } completion:^(BOOL finished) {
               [self removeFromSuperview];
            }];
        } else {
            [self removeFromSuperview];
        }
    } else {
        [self removeFromSuperview];
    }
    
    [self clear];
    BlockSafeRun(self.didHiddenBlock);
}

- (void)clear{
    self.actions = @[];
    self.footerAction = nil;
}

- (void)tapBack:(id)sender{
    if (!self.disableBgTap){
        [self hidden];
    }
}

- (void)tapButton:(id)sender{
    UIView *view = sender;
    NSInteger index = view.tag - 1000;
    AlertAction *action = [self.actions objectAtIndex:index];
    BlockSafeRun(action.clickCallback);
    if (self.autoCloseClicked){
        [self hidden];
    }
}

- (void)footerActionButton:(id)sender{
    AlertAction *action = self.footerAction;
    BlockSafeRun(action.clickCallback);
    if (self.autoCloseClicked){
        [self hidden];
    }
}

-(BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch{
    if ([gestureRecognizer isKindOfClass:UITapGestureRecognizer.class]){
        CGPoint touchPoint = [touch locationInView:self];
        if (CGRectContainsPoint(self.contentView.frame, touchPoint)){
           return NO;
        }
    }
   
    return YES;
}

- (void)actionSheetPanGesture:(UIPanGestureRecognizer *)gesture{
    if (gesture.state == UIGestureRecognizerStateChanged){
        CGPoint translation = [gesture translationInView:self];
        
        CGRect frame = self.contentView.frame;
        CGFloat destOriginY = frame.origin.y + (translation.y - self.lastTranslationY);
        frame.origin = CGPointMake(0, destOriginY);
        
        if (destOriginY + CGRectGetHeight(frame) >= kMainScreenHeight){
            self.contentView.frame = frame;
                   
            self.lastTranslationY = translation.y;
        }
    }
}


- (void)handleActionSheetPanGestureStateChange:(UIGestureRecognizerState)state{
    if (state == UIGestureRecognizerStateEnded){
        CGFloat contentHeight = CGRectGetHeight(self.contentView.frame);
        if (self.lastTranslationY >= contentHeight / 2.0 ){
            //移动距离大于一半
            [self hidden:YES];
        } else {
            //还原
            CGRect frame = CGRectMake(0, kMainScreenHeight - contentHeight, CGRectGetWidth(self.contentView.frame), contentHeight);
            [UIView animateWithDuration:0.3 animations:^{
                self.contentView.frame = frame;
            } completion:^(BOOL finished) {
                self.contentView.frame = frame;
            }];
            
        }
        self.lastTranslationY = 0;
    }
}

- (void)closeButton{
     [self hidden:YES];
}
@end
