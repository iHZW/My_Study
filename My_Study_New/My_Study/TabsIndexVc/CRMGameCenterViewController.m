//
//  CRMGameCenterViewController.m
//  My_Study
//
//  休闲小游戏集合。
//

#import "CRMGameCenterViewController.h"
#import "CRMAnimalMatchRules.h"
#import "CRMSnakeRules.h"
#import "CRMSoccerMotion.h"
#import "CRMDigimonAtlasViewController.h"

static UIColor *GameColor(NSUInteger hex) {
    return [UIColor colorWithRed:((hex >> 16) & 0xff) / 255.0
                           green:((hex >> 8) & 0xff) / 255.0
                            blue:(hex & 0xff) / 255.0 alpha:1];
}

static UILabel *GameLabel(NSString *text, CGFloat size, UIFontWeight weight, UIColor *color) {
    UILabel *label = [[UILabel alloc] init];
    label.text = text;
    label.font = [UIFont systemFontOfSize:size weight:weight];
    label.textColor = color;
    label.numberOfLines = 0;
    return label;
}

static UIButton *GameButton(NSString *title, UIColor *background, UIColor *foreground) {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:foreground forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont systemFontOfSize:15 weight:UIFontWeightSemibold];
    button.backgroundColor = background;
    button.layer.cornerRadius = 14;
    button.contentEdgeInsets = UIEdgeInsetsMake(11, 14, 11, 14);
    return button;
}

static UIButton *GameCircleButton(NSString *title, CGFloat diameter, CGFloat fontSize) {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    button.translatesAutoresizingMaskIntoConstraints = NO;
    button.backgroundColor = UIColor.whiteColor;
    button.layer.cornerRadius = diameter / 2;
    button.layer.borderWidth = 1;
    button.layer.borderColor = GameColor(0xD5E4DF).CGColor;
    button.layer.shadowColor = [UIColor colorWithWhite:0.18 alpha:1].CGColor;
    button.layer.shadowOpacity = 0.16;
    button.layer.shadowOffset = CGSizeMake(0, 4);
    button.layer.shadowRadius = 7;
    button.titleLabel.font = [UIFont systemFontOfSize:fontSize weight:UIFontWeightSemibold];
    button.titleLabel.numberOfLines = 2;
    button.titleLabel.textAlignment = NSTextAlignmentCenter;
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:GameColor(0x355B54) forState:UIControlStateNormal];
    [button.widthAnchor constraintEqualToConstant:diameter].active = YES;
    [button.heightAnchor constraintEqualToConstant:diameter].active = YES;
    return button;
}

static void GameShowMessage(UIViewController *controller, NSString *title, NSString *message) {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleDefault handler:nil]];
    [controller presentViewController:alert animated:YES completion:nil];
}

#pragma mark - 游戏页面公共布局

@interface CRMGameController : ZWBaseViewController

@property (nonatomic, strong) UILabel *statusLabel;
@property (nonatomic, strong) UIView *boardView;
@property (nonatomic, strong) UIStackView *actions;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) NSLayoutConstraint *boardWidthConstraint;
@property (nonatomic, strong) NSLayoutConstraint *statusTrailingConstraint;
@property (nonatomic, assign) CGFloat maximumBoardWidth;
@property (nonatomic, assign) CGFloat boardAspect;
@property (nonatomic, assign) BOOL usesCompactLayout;
@property (nonatomic, assign) BOOL savedPopGestureEnabled;
@property (nonatomic, assign) BOOL hasSavedPopGestureState;

- (void)setupTitle:(NSString *)title subtitle:(NSString *)subtitle board:(UIView *)board aspect:(CGFloat)aspect maximumWidth:(CGFloat)maximumWidth;
- (void)setupCompactLayoutWithBoard:(UIView *)board aspect:(CGFloat)aspect maximumWidth:(CGFloat)maximumWidth;
- (UIButton *)addAction:(NSString *)title selector:(SEL)selector;

@end

#pragma mark - 数独

@interface CRMSudokuBoard : UIView
@property (nonatomic, strong) NSArray<UIView *> *majorLines;
- (void)bringLinesToFront;
@end

@implementation CRMSudokuBoard

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        NSMutableArray<UIView *> *lines = [NSMutableArray arrayWithCapacity:8];
        for (NSInteger index = 0; index < 8; index++) {
            UIView *line = [[UIView alloc] init];
            line.backgroundColor = GameColor(0x9EB9AE);
            line.userInteractionEnabled = NO;
            [self addSubview:line];
            [lines addObject:line];
        }
        self.majorLines = lines;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat side = CGRectGetWidth(self.bounds);
    for (NSInteger index = 0; index < 4; index++) {
        CGFloat position = MIN(side - 2, index * side / 3);
        self.majorLines[index].frame = CGRectMake(position, 0, 2, side);
        self.majorLines[index + 4].frame = CGRectMake(0, position, side, 2);
    }
}

- (void)bringLinesToFront {
    for (UIView *line in self.majorLines) [self bringSubviewToFront:line];
}
@end

@interface CRMSudokuController : CRMGameController
@property (nonatomic, strong) NSMutableArray<NSNumber *> *values;
@property (nonatomic, strong) NSArray<NSNumber *> *solution;
@property (nonatomic, strong) NSArray<NSNumber *> *fixed;
@property (nonatomic, strong) NSMutableArray<UIButton *> *cells;
@property (nonatomic, assign) NSInteger selectedCell;
@end

@implementation CRMSudokuController

- (void)viewDidLoad {
    [super viewDidLoad];
    CRMSudokuBoard *board = [[CRMSudokuBoard alloc] init];
    board.backgroundColor = GameColor(0xFFFFFF);
    [self setupTitle:@"数独" subtitle:@"每行、每列和每宫都填入 1 到 9" board:board aspect:1 maximumWidth:380];
    self.cells = [NSMutableArray arrayWithCapacity:81];
    UIStackView *grid = [[UIStackView alloc] init];
    grid.axis = UILayoutConstraintAxisVertical;
    grid.distribution = UIStackViewDistributionFillEqually;
    grid.translatesAutoresizingMaskIntoConstraints = NO;
    [board addSubview:grid];
    [NSLayoutConstraint activateConstraints:@[
        [grid.topAnchor constraintEqualToAnchor:board.topAnchor],
        [grid.leadingAnchor constraintEqualToAnchor:board.leadingAnchor],
        [grid.trailingAnchor constraintEqualToAnchor:board.trailingAnchor],
        [grid.bottomAnchor constraintEqualToAnchor:board.bottomAnchor]
    ]];
    for (NSInteger row = 0; row < 9; row++) {
        UIStackView *rowView = [[UIStackView alloc] init];
        rowView.axis = UILayoutConstraintAxisHorizontal;
        rowView.distribution = UIStackViewDistributionFillEqually;
        [grid addArrangedSubview:rowView];
        for (NSInteger column = 0; column < 9; column++) {
            NSInteger index = row * 9 + column;
            UIButton *cell = [UIButton buttonWithType:UIButtonTypeSystem];
            cell.tag = index;
            cell.titleLabel.font = [UIFont systemFontOfSize:20 weight:UIFontWeightSemibold];
            cell.layer.borderWidth = 0.35;
            cell.layer.borderColor = GameColor(0xD5E0DB).CGColor;
            [cell addTarget:self action:@selector(selectCell:) forControlEvents:UIControlEventTouchUpInside];
            [rowView addArrangedSubview:cell];
            [self.cells addObject:cell];
        }
    }
    [board bringLinesToFront];

    UIStackView *pad = [[UIStackView alloc] init];
    pad.axis = UILayoutConstraintAxisHorizontal;
    pad.distribution = UIStackViewDistributionFillEqually;
    pad.spacing = 3;
    [self.actions addArrangedSubview:pad];
    [pad.widthAnchor constraintEqualToAnchor:self.actions.widthAnchor].active = YES;
    for (NSInteger number = 1; number <= 9; number++) {
        UIButton *button = GameButton([NSString stringWithFormat:@"%ld", (long)number], GameColor(0xE5EEEA), GameColor(0x355B54));
        button.tag = number;
        button.contentEdgeInsets = UIEdgeInsetsZero;
        [button.heightAnchor constraintEqualToConstant:40].active = YES;
        [button addTarget:self action:@selector(inputNumber:) forControlEvents:UIControlEventTouchUpInside];
        [pad addArrangedSubview:button];
    }
    UIButton *erase = [self addAction:@"擦除选中格" selector:@selector(eraseSelected)];
    erase.backgroundColor = GameColor(0xF0EAE1);
    [self addAction:@"换一题" selector:@selector(restart)];
    self.actions.axis = UILayoutConstraintAxisVertical;
    [self restart];
}

- (void)restart {
    NSString *puzzle = @"530070000600195000098000060800060003400803001700020006060000280000419005000080079";
    NSString *answer = @"534678912672195348198342567859761423426853791713924856961537284287419635345286179";
    NSInteger shift = arc4random_uniform(9);
    NSMutableArray *givens = [NSMutableArray arrayWithCapacity:81];
    NSMutableArray *solution = [NSMutableArray arrayWithCapacity:81];
    for (NSInteger index = 0; index < 81; index++) {
        NSInteger clue = [puzzle characterAtIndex:index] - '0';
        NSInteger solved = [answer characterAtIndex:index] - '0';
        [givens addObject:@(clue ? (clue + shift - 1) % 9 + 1 : 0)];
        [solution addObject:@((solved + shift - 1) % 9 + 1)];
    }
    self.fixed = [givens copy];
    self.values = [givens mutableCopy];
    self.solution = [solution copy];
    self.selectedCell = -1;
    [self refresh];
}

- (void)selectCell:(UIButton *)sender {
    self.selectedCell = sender.tag;
    [self refresh];
}

- (void)inputNumber:(UIButton *)sender {
    if (self.selectedCell < 0 || self.fixed[self.selectedCell].integerValue) return;
    self.values[self.selectedCell] = @(sender.tag);
    [self refresh];
    if ([self.values isEqualToArray:self.solution]) GameShowMessage(self, @"数独完成", @"所有数字都填对了！");
}

- (void)eraseSelected {
    if (self.selectedCell < 0 || self.fixed[self.selectedCell].integerValue) return;
    self.values[self.selectedCell] = @0;
    [self refresh];
}

- (BOOL)hasConflictAt:(NSInteger)index {
    NSInteger value = self.values[index].integerValue;
    if (!value) return NO;
    NSInteger row = index / 9, column = index % 9;
    for (NSInteger i = 0; i < 81; i++) {
        if (i == index || self.values[i].integerValue != value) continue;
        if (i / 9 == row || i % 9 == column || (i / 27 == row / 3 && i % 9 / 3 == column / 3)) return YES;
    }
    return NO;
}

- (void)refresh {
    NSInteger filled = 0, conflicts = 0;
    for (NSInteger index = 0; index < 81; index++) {
        NSInteger value = self.values[index].integerValue;
        if (value) filled++;
        BOOL conflict = [self hasConflictAt:index];
        if (conflict) conflicts++;
        UIButton *cell = self.cells[index];
        [cell setTitle:value ? [NSString stringWithFormat:@"%ld", (long)value] : @"" forState:UIControlStateNormal];
        [cell setTitleColor:conflict ? GameColor(0xC76258) : (self.fixed[index].integerValue ? GameColor(0x263A3B) : GameColor(0x487A70)) forState:UIControlStateNormal];
        cell.backgroundColor = index == self.selectedCell ? GameColor(0xCDE5D9) : ((index / 9 / 3 + index % 9 / 3) % 2 ? GameColor(0xF4F8F5) : UIColor.whiteColor);
    }
    self.statusLabel.text = conflicts ? [NSString stringWithFormat:@"已填 %ld/81 · 有冲突的数字", (long)filled] : [NSString stringWithFormat:@"已填 %ld/81 · 点选空格后输入", (long)filled];
}
@end

#pragma mark - 俄罗斯方块

static const NSInteger CRMShapes[7][4][2] = {
    {{0,1},{1,1},{2,1},{3,1}}, {{1,0},{2,0},{1,1},{2,1}},
    {{1,0},{0,1},{1,1},{2,1}}, {{1,0},{2,0},{0,1},{1,1}},
    {{0,0},{1,0},{1,1},{2,1}}, {{0,0},{0,1},{1,1},{2,1}},
    {{2,0},{0,1},{1,1},{2,1}}
};

static NSUInteger CRMShapeColors[7] = {0x71B8BD, 0xEBC67C, 0xAF9ACB, 0x88BD9B, 0xD98F89, 0x8AA5CA, 0xDEA878};

@interface CRMTetrisBoard : UIView
@property (nonatomic, strong) NSArray<NSNumber *> *cells;
@property (nonatomic, assign) NSInteger pieceX;
@property (nonatomic, assign) NSInteger pieceY;
@property (nonatomic, assign) NSInteger pieceType;
@property (nonatomic, assign) NSInteger rotation;
@property (nonatomic, assign) BOOL active;
@end

@implementation CRMTetrisBoard

- (void)drawRect:(CGRect)rect {
    [GameColor(0x263A3B) setFill];
    UIRectFill(rect);
    CGFloat size = MIN(rect.size.width / 10, rect.size.height / 20);
    for (NSInteger row = 0; row < 20; row++) {
        for (NSInteger column = 0; column < 10; column++) {
            NSInteger value = self.cells[row * 10 + column].integerValue;
            CGRect block = CGRectMake(column * size + 1.5, row * size + 1.5, size - 3, size - 3);
            [GameColor(value ? CRMShapeColors[value - 1] : 0x314848) setFill];
            [[UIBezierPath bezierPathWithRoundedRect:block cornerRadius:3] fill];
        }
    }
    if (!self.active) return;
    [GameColor(CRMShapeColors[self.pieceType]) setFill];
    for (NSInteger i = 0; i < 4; i++) {
        NSInteger x = CRMShapes[self.pieceType][i][0], y = CRMShapes[self.pieceType][i][1];
        for (NSInteger turn = 0; turn < self.rotation; turn++) { NSInteger next = 3 - y; y = x; x = next; }
        CGRect block = CGRectMake((self.pieceX + x) * size + 1.5, (self.pieceY + y) * size + 1.5, size - 3, size - 3);
        [[UIBezierPath bezierPathWithRoundedRect:block cornerRadius:3] fill];
    }
}
@end

@interface CRMTetrisNextView : UIView
@property (nonatomic, assign) NSInteger pieceType;
@end

@implementation CRMTetrisNextView

- (void)drawRect:(CGRect)rect {
    NSDictionary *attributes = @{
        NSFontAttributeName: [UIFont systemFontOfSize:9 weight:UIFontWeightSemibold],
        NSForegroundColorAttributeName: GameColor(0xBFD3CC)
    };
    [@"下一块" drawAtPoint:CGPointMake(6, 15) withAttributes:attributes];

    NSInteger minX = 4, maxX = 0, minY = 4, maxY = 0;
    for (NSInteger index = 0; index < 4; index++) {
        NSInteger x = CRMShapes[self.pieceType][index][0];
        NSInteger y = CRMShapes[self.pieceType][index][1];
        minX = MIN(minX, x); maxX = MAX(maxX, x);
        minY = MIN(minY, y); maxY = MAX(maxY, y);
    }
    CGFloat cellSize = 7;
    CGFloat shapeWidth = (maxX - minX + 1) * cellSize;
    CGFloat shapeHeight = (maxY - minY + 1) * cellSize;
    CGFloat originX = CGRectGetWidth(rect) - 7 - shapeWidth;
    CGFloat originY = (CGRectGetHeight(rect) - shapeHeight) / 2;
    [GameColor(CRMShapeColors[self.pieceType]) setFill];
    for (NSInteger index = 0; index < 4; index++) {
        NSInteger x = CRMShapes[self.pieceType][index][0] - minX;
        NSInteger y = CRMShapes[self.pieceType][index][1] - minY;
        CGRect block = CGRectMake(originX + x * cellSize + 0.5,
                                  originY + y * cellSize + 0.5,
                                  cellSize - 1,
                                  cellSize - 1);
        [[UIBezierPath bezierPathWithRoundedRect:block cornerRadius:1.5] fill];
    }
}

@end

@interface CRMTetrisController : CRMGameController
@property (nonatomic, strong) NSMutableArray<NSNumber *> *cells;
@property (nonatomic, strong) CRMTetrisBoard *gameBoard;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, assign) NSInteger pieceX;
@property (nonatomic, assign) NSInteger pieceY;
@property (nonatomic, assign) NSInteger pieceType;
@property (nonatomic, assign) NSInteger rotation;
@property (nonatomic, assign) NSInteger score;
@property (nonatomic, assign) NSInteger lines;
@property (nonatomic, assign) BOOL paused;
@property (nonatomic, assign) BOOL gameOver;
@property (nonatomic, assign) NSInteger nextPieceType;
@property (nonatomic, strong) CRMTetrisNextView *nextPreview;
@property (nonatomic, strong) NSTimer *inputRepeatTimer;
@property (nonatomic, assign) NSInteger repeatedDirection;
@end

@implementation CRMTetrisController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.gameBoard = [[CRMTetrisBoard alloc] init];
    [self setupCompactLayoutWithBoard:self.gameBoard aspect:2 maximumWidth:245];
    self.nextPreview = [[CRMTetrisNextView alloc] init];
    self.nextPreview.backgroundColor = GameColor(0x314848);
    self.nextPreview.layer.cornerRadius = 11;
    self.nextPreview.layer.masksToBounds = YES;
    self.nextPreview.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.nextPreview];
    self.statusTrailingConstraint.active = NO;
    self.statusTrailingConstraint = [self.statusLabel.trailingAnchor constraintEqualToAnchor:self.nextPreview.leadingAnchor constant:-6];
    self.statusTrailingConstraint.active = YES;
    [NSLayoutConstraint activateConstraints:@[
        [self.nextPreview.trailingAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.trailingAnchor constant:-14],
        [self.nextPreview.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor constant:4],
        [self.nextPreview.widthAnchor constraintEqualToConstant:76],
        [self.nextPreview.heightAnchor constraintEqualToConstant:42]
    ]];
    self.actions.axis = UILayoutConstraintAxisVertical;
    self.actions.alignment = UIStackViewAlignmentCenter;
    self.actions.distribution = UIStackViewDistributionFill;
    self.actions.spacing = 10;
    [self.actions addArrangedSubview:[self buildDpad]];
    UIStackView *tools = [self actionRow:@[@"一键落下", @"暂停 / 继续", @"新游戏"] selectors:@[@"hardDrop", @"togglePause", @"restart"]];
    [self.actions addArrangedSubview:tools];
    [tools.widthAnchor constraintEqualToAnchor:self.actions.widthAnchor].active = YES;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pauseForBackground) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [self restart];
}

- (UIStackView *)actionRow:(NSArray<NSString *> *)titles selectors:(NSArray<NSString *> *)selectors {
    UIStackView *row = [[UIStackView alloc] init];
    row.axis = UILayoutConstraintAxisHorizontal;
    row.distribution = UIStackViewDistributionFillEqually;
    row.spacing = 8;
    for (NSInteger index = 0; index < titles.count; index++) {
        UIButton *button = GameButton(titles[index], GameColor(0xE5EEEA), GameColor(0x355B54));
        button.contentEdgeInsets = UIEdgeInsetsMake(10, 2, 10, 2);
        [button addTarget:self action:NSSelectorFromString(selectors[index]) forControlEvents:UIControlEventTouchUpInside];
        [row addArrangedSubview:button];
    }
    return row;
}

- (UIButton *)dpadButton:(NSString *)title selector:(SEL)selector diameter:(CGFloat)diameter background:(UIColor *)background foreground:(UIColor *)foreground fontSize:(CGFloat)fontSize {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:foreground forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont systemFontOfSize:fontSize weight:UIFontWeightSemibold];
    button.backgroundColor = background;
    button.layer.cornerRadius = diameter / 2;
    [button addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
    button.translatesAutoresizingMaskIntoConstraints = NO;
    [button.widthAnchor constraintEqualToConstant:diameter].active = YES;
    [button.heightAnchor constraintEqualToConstant:diameter].active = YES;
    return button;
}

// 圆形方向键：上下左右环绕分布，中间是变换（旋转）按钮。
- (UIView *)buildDpad {
    UIView *dpad = [[UIView alloc] init];
    dpad.translatesAutoresizingMaskIntoConstraints = NO;
    [dpad.heightAnchor constraintEqualToConstant:168].active = YES;
    [dpad.widthAnchor constraintEqualToAnchor:dpad.heightAnchor].active = YES;

    UIView *disc = [[UIView alloc] init];
    disc.backgroundColor = GameColor(0xE4EDE9);
    disc.layer.cornerRadius = 84;
    disc.layer.borderWidth = 1;
    disc.layer.borderColor = GameColor(0xD1E0DA).CGColor;
    disc.translatesAutoresizingMaskIntoConstraints = NO;
    [dpad addSubview:disc];
    [NSLayoutConstraint activateConstraints:@[
        [disc.topAnchor constraintEqualToAnchor:dpad.topAnchor],
        [disc.leadingAnchor constraintEqualToAnchor:dpad.leadingAnchor],
        [disc.trailingAnchor constraintEqualToAnchor:dpad.trailingAnchor],
        [disc.bottomAnchor constraintEqualToAnchor:dpad.bottomAnchor]
    ]];

    // 中间：变换
    UIButton *rotate = [self dpadButton:@"⟳" selector:@selector(rotatePiece) diameter:58 background:GameColor(0x355D55) foreground:UIColor.whiteColor fontSize:24];
    rotate.layer.shadowColor = [UIColor colorWithWhite:0.2 alpha:1].CGColor;
    rotate.layer.shadowOpacity = 0.3;
    rotate.layer.shadowOffset = CGSizeMake(0, 5);
    rotate.layer.shadowRadius = 9;
    [dpad addSubview:rotate];
    [rotate.centerXAnchor constraintEqualToAnchor:dpad.centerXAnchor].active = YES;
    [rotate.centerYAnchor constraintEqualToAnchor:dpad.centerYAnchor].active = YES;

    // 上下左右
    UIButton *up = [self dpadButton:@"▲" selector:@selector(rotatePiece) diameter:44 background:UIColor.whiteColor foreground:GameColor(0x355B54) fontSize:17];
    UIButton *down = [self dpadButton:@"▼" selector:@selector(softDrop) diameter:44 background:UIColor.whiteColor foreground:GameColor(0x355B54) fontSize:17];
    UIButton *left = [self dpadButton:@"◀" selector:@selector(moveLeft) diameter:44 background:UIColor.whiteColor foreground:GameColor(0x355B54) fontSize:17];
    UIButton *right = [self dpadButton:@"▶" selector:@selector(moveRight) diameter:44 background:UIColor.whiteColor foreground:GameColor(0x355B54) fontSize:17];
    up.tag = 1;
    down.tag = 2;
    left.tag = 3;
    right.tag = 4;
    for (UIButton *button in @[up, down, left, right]) {
        button.layer.borderWidth = 1;
        button.layer.borderColor = GameColor(0xDCE8E3).CGColor;
        UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleDirectionLongPress:)];
        longPress.minimumPressDuration = 0.22;
        longPress.cancelsTouchesInView = YES;
        [button addGestureRecognizer:longPress];
        [dpad addSubview:button];
    }
    [NSLayoutConstraint activateConstraints:@[
        [up.centerXAnchor constraintEqualToAnchor:dpad.centerXAnchor],
        [up.centerYAnchor constraintEqualToAnchor:dpad.centerYAnchor constant:-56],
        [down.centerXAnchor constraintEqualToAnchor:dpad.centerXAnchor],
        [down.centerYAnchor constraintEqualToAnchor:dpad.centerYAnchor constant:56],
        [left.centerYAnchor constraintEqualToAnchor:dpad.centerYAnchor],
        [left.centerXAnchor constraintEqualToAnchor:dpad.centerXAnchor constant:-56],
        [right.centerYAnchor constraintEqualToAnchor:dpad.centerYAnchor],
        [right.centerXAnchor constraintEqualToAnchor:dpad.centerXAnchor constant:56]
    ]];
    return dpad;
}

- (void)performDirection:(NSInteger)direction {
    switch (direction) {
        case 1: [self rotatePiece]; break;
        case 2: [self softDrop]; break;
        case 3: [self moveLeft]; break;
        case 4: [self moveRight]; break;
        default: break;
    }
}

- (void)repeatDirection:(NSTimer *)timer {
    if (timer != self.inputRepeatTimer) return;
    [self performDirection:self.repeatedDirection];
}

- (void)stopDirectionRepeat {
    [self.inputRepeatTimer invalidate];
    self.inputRepeatTimer = nil;
    self.repeatedDirection = 0;
}

- (void)handleDirectionLongPress:(UILongPressGestureRecognizer *)gesture {
    if (gesture.state == UIGestureRecognizerStateBegan) {
        [self stopDirectionRepeat];
        self.repeatedDirection = gesture.view.tag;
        [self performDirection:self.repeatedDirection];
        self.inputRepeatTimer = [NSTimer scheduledTimerWithTimeInterval:0.09
                                                                 target:self
                                                               selector:@selector(repeatDirection:)
                                                               userInfo:nil
                                                                repeats:YES];
    } else if (gesture.state == UIGestureRecognizerStateEnded ||
               gesture.state == UIGestureRecognizerStateCancelled ||
               gesture.state == UIGestureRecognizerStateFailed) {
        [self stopDirectionRepeat];
    }
}

- (void)dealloc {
    [self stopDirectionRepeat];
    [self.timer invalidate];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self startTimer];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self stopDirectionRepeat];
    [self.timer invalidate];
    self.timer = nil;
}

- (void)pauseForBackground {
    [self stopDirectionRepeat];
    self.paused = YES;
    [self.timer invalidate];
    self.timer = nil;
    [self refresh];
}

- (void)startTimer {
    if (self.timer || self.paused || self.gameOver || !self.isViewLoaded || !self.view.window) return;
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.55 target:self selector:@selector(tick) userInfo:nil repeats:YES];
}

- (void)restart {
    [self stopDirectionRepeat];
    [self.timer invalidate];
    self.timer = nil;
    self.cells = [NSMutableArray arrayWithCapacity:200];
    for (NSInteger index = 0; index < 200; index++) [self.cells addObject:@0];
    self.score = 0;
    self.lines = 0;
    self.paused = NO;
    self.gameOver = NO;
    self.nextPieceType = arc4random_uniform(7);
    [self spawnPiece];
    [self refresh];
    [self startTimer];
}

- (void)spawnPiece {
    self.pieceType = self.nextPieceType;
    self.nextPieceType = arc4random_uniform(7);
    self.pieceX = 3;
    self.pieceY = 0;
    self.rotation = 0;
    if (![self canPlaceX:self.pieceX y:self.pieceY rotation:0]) {
        self.gameOver = YES;
        [self.timer invalidate];
        self.timer = nil;
        GameShowMessage(self, @"游戏结束", [NSString stringWithFormat:@"本局得分 %ld，消除了 %ld 行。", (long)self.score, (long)self.lines]);
    }
}

- (BOOL)canPlaceX:(NSInteger)originX y:(NSInteger)originY rotation:(NSInteger)rotation {
    for (NSInteger i = 0; i < 4; i++) {
        NSInteger x = CRMShapes[self.pieceType][i][0], y = CRMShapes[self.pieceType][i][1];
        for (NSInteger turn = 0; turn < rotation; turn++) { NSInteger next = 3 - y; y = x; x = next; }
        x += originX; y += originY;
        if (x < 0 || x >= 10 || y >= 20 || (y >= 0 && self.cells[y * 10 + x].integerValue)) return NO;
    }
    return YES;
}

- (void)moveLeft { if (!self.paused && !self.gameOver && [self canPlaceX:self.pieceX - 1 y:self.pieceY rotation:self.rotation]) { self.pieceX--; [self refresh]; } }
- (void)moveRight { if (!self.paused && !self.gameOver && [self canPlaceX:self.pieceX + 1 y:self.pieceY rotation:self.rotation]) { self.pieceX++; [self refresh]; } }
- (void)softDrop { if (!self.paused && !self.gameOver) [self tick]; }

- (void)rotatePiece {
    if (self.paused || self.gameOver) return;
    if (self.pieceType == 1) return;
    NSInteger next = (self.rotation + 1) % 4;
    for (NSNumber *offset in @[@0, @(-1), @1, @(-2), @2]) {
        if ([self canPlaceX:self.pieceX + offset.integerValue y:self.pieceY rotation:next]) {
            self.pieceX += offset.integerValue;
            self.rotation = next;
            [self refresh];
            return;
        }
    }
}

- (void)hardDrop {
    if (self.paused || self.gameOver) return;
    while ([self canPlaceX:self.pieceX y:self.pieceY + 1 rotation:self.rotation]) { self.pieceY++; self.score += 2; }
    [self lockPiece];
}

- (void)togglePause {
    if (self.gameOver) return;
    self.paused = !self.paused;
    if (self.paused) { [self.timer invalidate]; self.timer = nil; }
    else [self startTimer];
    [self refresh];
}

- (void)tick {
    if (self.paused || self.gameOver) return;
    if ([self canPlaceX:self.pieceX y:self.pieceY + 1 rotation:self.rotation]) self.pieceY++;
    else [self lockPiece];
    [self refresh];
}

- (void)lockPiece {
    for (NSInteger i = 0; i < 4; i++) {
        NSInteger x = CRMShapes[self.pieceType][i][0], y = CRMShapes[self.pieceType][i][1];
        for (NSInteger turn = 0; turn < self.rotation; turn++) { NSInteger next = 3 - y; y = x; x = next; }
        NSInteger row = self.pieceY + y, column = self.pieceX + x;
        if (row >= 0 && row < 20) self.cells[row * 10 + column] = @(self.pieceType + 1);
    }
    NSInteger cleared = 0;
    for (NSInteger row = 19; row >= 0; row--) {
        BOOL full = YES;
        for (NSInteger column = 0; column < 10; column++) if (!self.cells[row * 10 + column].integerValue) full = NO;
        if (!full) continue;
        for (NSInteger current = row; current > 0; current--)
            for (NSInteger column = 0; column < 10; column++) self.cells[current * 10 + column] = self.cells[(current - 1) * 10 + column];
        for (NSInteger column = 0; column < 10; column++) self.cells[column] = @0;
        cleared++;
        row++;
    }
    self.lines += cleared;
    NSInteger rewards[] = {0, 100, 300, 500, 800};
    self.score += rewards[MIN(cleared, 4)];
    [self spawnPiece];
    [self refresh];
}

- (void)refresh {
    self.gameBoard.cells = self.cells;
    self.gameBoard.pieceX = self.pieceX;
    self.gameBoard.pieceY = self.pieceY;
    self.gameBoard.pieceType = self.pieceType;
    self.gameBoard.rotation = self.rotation;
    self.gameBoard.active = !self.gameOver;
    [self.gameBoard setNeedsDisplay];
    self.nextPreview.pieceType = self.nextPieceType;
    [self.nextPreview setNeedsDisplay];
    self.statusLabel.text = self.gameOver ? @"游戏结束 · 点新游戏再来一局" : (self.paused ? @"已暂停" : [NSString stringWithFormat:@"得分 %ld  ·  消除 %ld 行", (long)self.score, (long)self.lines]);
}
@end

@implementation CRMGameController

+ (NSDictionary *)ss_constantParams {
    return @{@"hideNavigationBar": @(YES)};
}

- (instancetype)init {
    self = [super init];
    if (self) {
        self.hideNavigationBar = YES;
        self.hideTabbar = YES;
        self.hidesBottomBarWhenPushed = YES;
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    UIGestureRecognizer *popGesture = self.navigationController.interactivePopGestureRecognizer;
    if (!self.hasSavedPopGestureState) {
        self.savedPopGestureEnabled = popGesture.enabled;
        self.hasSavedPopGestureState = YES;
    }
    popGesture.enabled = NO;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    if (self.hasSavedPopGestureState) {
        self.navigationController.interactivePopGestureRecognizer.enabled = self.savedPopGestureEnabled;
        self.hasSavedPopGestureState = NO;
    }
}

- (void)setupTitle:(NSString *)title subtitle:(NSString *)subtitle board:(UIView *)board aspect:(CGFloat)aspect maximumWidth:(CGFloat)maximumWidth {
    self.view.backgroundColor = GameColor(0xF7F7F2);
    self.maximumBoardWidth = maximumWidth;
    self.boardAspect = aspect;
    self.usesCompactLayout = NO;
    self.boardView = board;
    self.boardView.translatesAutoresizingMaskIntoConstraints = NO;
    self.boardView.layer.cornerRadius = 20;
    self.boardView.layer.masksToBounds = YES;

    self.scrollView = [[UIScrollView alloc] init];
    self.scrollView.translatesAutoresizingMaskIntoConstraints = NO;
    self.scrollView.alwaysBounceVertical = YES;
    [self.view addSubview:self.scrollView];
    [NSLayoutConstraint activateConstraints:@[
        [self.scrollView.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor],
        [self.scrollView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.scrollView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [self.scrollView.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor]
    ]];

    UIStackView *content = [[UIStackView alloc] init];
    content.axis = UILayoutConstraintAxisVertical;
    content.alignment = UIStackViewAlignmentCenter;
    content.spacing = 16;
    content.translatesAutoresizingMaskIntoConstraints = NO;
    [self.scrollView addSubview:content];
    [NSLayoutConstraint activateConstraints:@[
        [content.topAnchor constraintEqualToAnchor:self.scrollView.topAnchor constant:16],
        [content.leadingAnchor constraintEqualToAnchor:self.scrollView.leadingAnchor constant:18],
        [content.trailingAnchor constraintEqualToAnchor:self.scrollView.trailingAnchor constant:-18],
        [content.bottomAnchor constraintEqualToAnchor:self.scrollView.bottomAnchor constant:-28],
        [content.widthAnchor constraintEqualToAnchor:self.scrollView.widthAnchor constant:-36]
    ]];

    UIView *heading = [[UIView alloc] init];
    heading.translatesAutoresizingMaskIntoConstraints = NO;
    [content addArrangedSubview:heading];
    [heading.widthAnchor constraintEqualToAnchor:content.widthAnchor].active = YES;
    [heading.heightAnchor constraintEqualToConstant:72].active = YES;
    UIButton *back = GameButton(@"‹", GameColor(0xE9ECE8), GameColor(0x243B39));
    back.titleLabel.font = [UIFont systemFontOfSize:29 weight:UIFontWeightRegular];
    back.translatesAutoresizingMaskIntoConstraints = NO;
    [back addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
    [heading addSubview:back];
    UILabel *titleLabel = GameLabel(title, 27, UIFontWeightBold, GameColor(0x243B39));
    titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [heading addSubview:titleLabel];
    [NSLayoutConstraint activateConstraints:@[
        [back.leadingAnchor constraintEqualToAnchor:heading.leadingAnchor],
        [back.topAnchor constraintEqualToAnchor:heading.topAnchor constant:4],
        [back.widthAnchor constraintEqualToConstant:46],
        [back.heightAnchor constraintEqualToConstant:46],
        [titleLabel.leadingAnchor constraintEqualToAnchor:back.trailingAnchor constant:14],
        [titleLabel.centerYAnchor constraintEqualToAnchor:back.centerYAnchor]
    ]];
    UILabel *subtitleLabel = GameLabel(subtitle, 13, UIFontWeightRegular, GameColor(0x798986));
    subtitleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [heading addSubview:subtitleLabel];
    [NSLayoutConstraint activateConstraints:@[
        [subtitleLabel.leadingAnchor constraintEqualToAnchor:heading.leadingAnchor],
        [subtitleLabel.trailingAnchor constraintEqualToAnchor:heading.trailingAnchor],
        [subtitleLabel.bottomAnchor constraintEqualToAnchor:heading.bottomAnchor]
    ]];

    self.statusLabel = GameLabel(@"", 16, UIFontWeightSemibold, GameColor(0x355B54));
    self.statusLabel.textAlignment = NSTextAlignmentCenter;
    [content addArrangedSubview:self.statusLabel];
    [content addArrangedSubview:board];
    self.boardWidthConstraint = [board.widthAnchor constraintEqualToConstant:maximumWidth];
    self.boardWidthConstraint.active = YES;
    [board.heightAnchor constraintEqualToAnchor:board.widthAnchor multiplier:aspect].active = YES;

    self.actions = [[UIStackView alloc] init];
    self.actions.axis = UILayoutConstraintAxisHorizontal;
    self.actions.distribution = UIStackViewDistributionFillEqually;
    self.actions.spacing = 9;
    [content addArrangedSubview:self.actions];
    [self.actions.widthAnchor constraintEqualToAnchor:content.widthAnchor].active = YES;
}

// 俄罗斯方块使用一屏紧凑布局：仅保留返回按钮与状态，不显示大标题和说明。
// 棋盘宽度会在 viewDidLayoutSubviews 中根据安全区剩余高度动态调整。
- (void)setupCompactLayoutWithBoard:(UIView *)board aspect:(CGFloat)aspect maximumWidth:(CGFloat)maximumWidth {
    self.view.backgroundColor = GameColor(0xF7F7F2);
    self.maximumBoardWidth = maximumWidth;
    self.boardAspect = aspect;
    self.usesCompactLayout = YES;
    self.boardView = board;
    self.boardView.translatesAutoresizingMaskIntoConstraints = NO;
    self.boardView.layer.cornerRadius = 18;
    self.boardView.layer.masksToBounds = YES;

    UILayoutGuide *safeArea = self.view.safeAreaLayoutGuide;
    UIButton *back = GameButton(@"‹", GameColor(0xE9ECE8), GameColor(0x243B39));
    back.titleLabel.font = [UIFont systemFontOfSize:28 weight:UIFontWeightRegular];
    back.contentEdgeInsets = UIEdgeInsetsZero;
    back.translatesAutoresizingMaskIntoConstraints = NO;
    [back addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:back];

    self.statusLabel = GameLabel(@"", 15, UIFontWeightSemibold, GameColor(0x355B54));
    self.statusLabel.textAlignment = NSTextAlignmentCenter;
    self.statusLabel.adjustsFontSizeToFitWidth = YES;
    self.statusLabel.minimumScaleFactor = 0.8;
    self.statusLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.statusLabel];
    [self.view addSubview:self.boardView];

    self.actions = [[UIStackView alloc] init];
    self.actions.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.actions];

    self.boardWidthConstraint = [self.boardView.widthAnchor constraintEqualToConstant:maximumWidth];
    self.boardWidthConstraint.priority = UILayoutPriorityDefaultHigh;
    self.boardWidthConstraint.active = YES;
    self.statusTrailingConstraint = [self.statusLabel.trailingAnchor constraintEqualToAnchor:safeArea.trailingAnchor constant:-14];
    [NSLayoutConstraint activateConstraints:@[
        [back.leadingAnchor constraintEqualToAnchor:safeArea.leadingAnchor constant:14],
        [back.topAnchor constraintEqualToAnchor:safeArea.topAnchor constant:4],
        [back.widthAnchor constraintEqualToConstant:42],
        [back.heightAnchor constraintEqualToConstant:42],

        [self.statusLabel.leadingAnchor constraintEqualToAnchor:back.trailingAnchor constant:8],
        self.statusTrailingConstraint,
        [self.statusLabel.centerYAnchor constraintEqualToAnchor:back.centerYAnchor],

        [self.boardView.topAnchor constraintEqualToAnchor:back.bottomAnchor constant:6],
        [self.boardView.centerXAnchor constraintEqualToAnchor:safeArea.centerXAnchor],
        [self.boardView.heightAnchor constraintEqualToAnchor:self.boardView.widthAnchor multiplier:aspect],
        [self.boardView.leadingAnchor constraintGreaterThanOrEqualToAnchor:safeArea.leadingAnchor constant:16],
        [self.boardView.trailingAnchor constraintLessThanOrEqualToAnchor:safeArea.trailingAnchor constant:-16],

        [self.actions.topAnchor constraintEqualToAnchor:self.boardView.bottomAnchor constant:10],
        [self.actions.leadingAnchor constraintEqualToAnchor:safeArea.leadingAnchor constant:18],
        [self.actions.trailingAnchor constraintEqualToAnchor:safeArea.trailingAnchor constant:-18],
        [self.actions.bottomAnchor constraintLessThanOrEqualToAnchor:safeArea.bottomAnchor constant:-6]
    ]];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    CGFloat widthLimit = CGRectGetWidth(self.view.bounds) - 36;
    if (!self.usesCompactLayout) {
        self.boardWidthConstraint.constant = MIN(self.maximumBoardWidth, MAX(220, widthLimit));
        return;
    }

    UIEdgeInsets safeInsets = self.view.safeAreaInsets;
    CGFloat safeHeight = CGRectGetHeight(self.view.bounds) - safeInsets.top - safeInsets.bottom;
    CGFloat actionsHeight = [self.actions systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
    // 顶部返回区 46、棋盘与控制区间距 16、底部留白 6。
    CGFloat boardHeightLimit = safeHeight - 46 - 16 - actionsHeight - 6;
    CGFloat heightLimitedWidth = floor(boardHeightLimit / MAX(self.boardAspect, 1));
    CGFloat targetWidth = MIN(self.maximumBoardWidth, MIN(widthLimit, heightLimitedWidth));
    self.boardWidthConstraint.constant = MAX(150, targetWidth);
}

- (UIButton *)addAction:(NSString *)title selector:(SEL)selector {
    UIButton *button = GameButton(title, GameColor(0xE5EEEA), GameColor(0x355B54));
    [button addTarget:self action:selector forControlEvents:UIControlEventTouchUpInside];
    [self.actions addArrangedSubview:button];
    return button;
}

@end

#pragma mark - 五子棋

static const NSInteger CRMGomokuColumns = 15;
static const NSInteger CRMGomokuRows = 21;
static const NSInteger CRMGomokuCellCount = 315;

@interface CRMGomokuBoard : UIView
@property (nonatomic, strong) NSArray<NSNumber *> *cells;
@property (nonatomic, copy) void (^tapCell)(NSInteger row, NSInteger column);
@property (nonatomic, assign) NSInteger lastMoveIndex;
@property (nonatomic, strong) CAShapeLayer *lastMoveHaloLayer;
@end

@implementation CRMGomokuBoard

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _lastMoveIndex = -1;
        _lastMoveHaloLayer = [CAShapeLayer layer];
        _lastMoveHaloLayer.fillColor = UIColor.clearColor.CGColor;
        _lastMoveHaloLayer.strokeColor = GameColor(0x86D7F5).CGColor;
        _lastMoveHaloLayer.lineWidth = 3;
        _lastMoveHaloLayer.shadowColor = GameColor(0xBDEEFF).CGColor;
        _lastMoveHaloLayer.shadowRadius = 7;
        _lastMoveHaloLayer.shadowOpacity = 0.95;
        _lastMoveHaloLayer.shadowOffset = CGSizeZero;
        [self.layer addSublayer:_lastMoveHaloLayer];
    }
    return self;
}

- (void)setLastMoveIndex:(NSInteger)lastMoveIndex {
    if (_lastMoveIndex == lastMoveIndex) return;
    _lastMoveIndex = lastMoveIndex;
    [self.lastMoveHaloLayer removeAllAnimations];
    [self setNeedsLayout];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if (self.lastMoveIndex < 0 || self.lastMoveIndex >= CRMGomokuCellCount) {
        self.lastMoveHaloLayer.hidden = YES;
        return;
    }

    CGFloat gridWidth = self.bounds.size.width - 36;
    CGFloat step = gridWidth / (CRMGomokuColumns - 1);
    CGFloat gridHeight = step * (CRMGomokuRows - 1);
    CGFloat gridTop = (self.bounds.size.height - gridHeight) / 2;
    NSInteger row = self.lastMoveIndex / CRMGomokuColumns;
    NSInteger column = self.lastMoveIndex % CRMGomokuColumns;
    CGPoint center = CGPointMake(18 + step * column, gridTop + step * row);
    CGFloat haloDiameter = step * 1.08;
    CGRect haloRect = CGRectMake(center.x - haloDiameter / 2,
                                 center.y - haloDiameter / 2,
                                 haloDiameter,
                                 haloDiameter);
    self.lastMoveHaloLayer.frame = self.bounds;
    self.lastMoveHaloLayer.path = [UIBezierPath bezierPathWithOvalInRect:haloRect].CGPath;
    self.lastMoveHaloLayer.hidden = NO;

    if (![self.lastMoveHaloLayer animationForKey:@"crm_last_move_pulse"]) {
        CABasicAnimation *opacity = [CABasicAnimation animationWithKeyPath:@"opacity"];
        opacity.fromValue = @0.25;
        opacity.toValue = @1.0;
        opacity.duration = 0.7;
        opacity.autoreverses = YES;
        opacity.repeatCount = HUGE_VALF;
        opacity.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];

        CABasicAnimation *lineWidth = [CABasicAnimation animationWithKeyPath:@"lineWidth"];
        lineWidth.fromValue = @1.5;
        lineWidth.toValue = @4.0;
        lineWidth.duration = opacity.duration;
        lineWidth.autoreverses = YES;
        lineWidth.repeatCount = HUGE_VALF;
        lineWidth.timingFunction = opacity.timingFunction;

        [self.lastMoveHaloLayer addAnimation:opacity forKey:@"crm_last_move_pulse"];
        [self.lastMoveHaloLayer addAnimation:lineWidth forKey:@"crm_last_move_width"];
    }
}

- (void)drawRect:(CGRect)rect {
    [[UIColor colorWithRed:0.91 green:0.79 blue:0.59 alpha:1] setFill];
    UIRectFill(rect);
    CGFloat horizontalInset = 18;
    CGFloat gridWidth = rect.size.width - 2 * horizontalInset;
    CGFloat step = gridWidth / (CRMGomokuColumns - 1);
    CGFloat gridHeight = step * (CRMGomokuRows - 1);
    CGFloat gridTop = (rect.size.height - gridHeight) / 2;
    CGFloat stoneSize = step * 0.82;
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetStrokeColorWithColor(context, GameColor(0x9C8664).CGColor);
    CGContextSetLineWidth(context, 0.7);
    for (NSInteger index = 0; index < CRMGomokuRows; index++) {
        CGFloat y = gridTop + step * index;
        CGContextMoveToPoint(context, horizontalInset, y);
        CGContextAddLineToPoint(context, rect.size.width - horizontalInset, y);
    }
    for (NSInteger index = 0; index < CRMGomokuColumns; index++) {
        CGFloat x = horizontalInset + step * index;
        CGContextMoveToPoint(context, x, gridTop);
        CGContextAddLineToPoint(context, x, gridTop + gridHeight);
    }
    CGContextStrokePath(context);
    for (NSInteger row = 0; row < CRMGomokuRows; row++) {
        for (NSInteger column = 0; column < CRMGomokuColumns; column++) {
            NSInteger value = self.cells[row * CRMGomokuColumns + column].integerValue;
            if (!value) continue;
            CGFloat centerX = horizontalInset + step * column;
            CGFloat centerY = gridTop + step * row;
            CGRect stone = CGRectMake(centerX - stoneSize / 2, centerY - stoneSize / 2, stoneSize, stoneSize);
            UIColor *stoneColor = value == 1 ? GameColor(0x263A3B) : GameColor(0xFCFAF2);
            [stoneColor setFill];
            [[UIBezierPath bezierPathWithOvalInRect:stone] fill];
            if (value == 2) {
                [GameColor(0xD2CBB8) setStroke];
                [[UIBezierPath bezierPathWithOvalInRect:stone] stroke];
            }
        }
    }
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    CGPoint point = [touches.anyObject locationInView:self];
    CGFloat gridWidth = self.bounds.size.width - 36;
    CGFloat step = gridWidth / (CRMGomokuColumns - 1);
    CGFloat gridHeight = step * (CRMGomokuRows - 1);
    CGFloat gridTop = (self.bounds.size.height - gridHeight) / 2;
    NSInteger column = lround((point.x - 18) / step);
    NSInteger row = lround((point.y - gridTop) / step);
    if (row >= 0 && row < CRMGomokuRows && column >= 0 && column < CRMGomokuColumns && self.tapCell) self.tapCell(row, column);
}
@end

@interface CRMGomokuController : CRMGameController
@property (nonatomic, strong) NSMutableArray<NSNumber *> *cells;
@property (nonatomic, strong) NSMutableArray<NSNumber *> *history;
@property (nonatomic, strong) CRMGomokuBoard *gameBoard;
@property (nonatomic, strong) UIButton *modeButton;
@property (nonatomic, assign) NSInteger currentPlayer;
@property (nonatomic, assign) BOOL finished;
@property (nonatomic, assign) BOOL versusComputer;
@property (nonatomic, assign) BOOL computerThinking;
@property (nonatomic, assign) NSUInteger gameGeneration;
@end

@implementation CRMGomokuController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.gameBoard = [[CRMGomokuBoard alloc] init];
    [self setupTitle:@"五子棋" subtitle:@"支持人机对战和双人对弈 · 五子连珠获胜" board:self.gameBoard aspect:1.40 maximumWidth:390];
    __weak typeof(self) weakSelf = self;
    self.gameBoard.tapCell = ^(NSInteger row, NSInteger column) { [weakSelf placeAtRow:row column:column]; };
    self.modeButton = [self addAction:@"人机模式" selector:@selector(toggleMode)];
    [self addAction:@"悔一步" selector:@selector(undoMove)];
    [self addAction:@"重新开始" selector:@selector(restart)];
    self.versusComputer = YES;
    [self restart];
}

- (void)restart {
    self.gameGeneration++;
    self.cells = [NSMutableArray arrayWithCapacity:CRMGomokuCellCount];
    for (NSInteger index = 0; index < CRMGomokuCellCount; index++) [self.cells addObject:@0];
    self.history = [NSMutableArray array];
    self.currentPlayer = 1;
    self.finished = NO;
    self.computerThinking = NO;
    [self refresh];
}

- (void)refresh {
    self.gameBoard.cells = self.cells;
    self.gameBoard.lastMoveIndex = self.history.lastObject ? self.history.lastObject.integerValue : -1;
    [self.gameBoard setNeedsDisplay];
    [self.modeButton setTitle:self.versusComputer ? @"人机模式" : @"双人模式" forState:UIControlStateNormal];
    if (self.finished) {
        self.statusLabel.text = @"对局结束";
    } else if (self.versusComputer) {
        self.statusLabel.text = self.computerThinking ? @"电脑正在思考…" : @"你执黑棋 · 请落子";
    } else {
        self.statusLabel.text = self.currentPlayer == 1 ? @"● 轮到黑棋" : @"○ 轮到白棋";
    }
}

- (void)placeAtRow:(NSInteger)row column:(NSInteger)column {
    if (self.versusComputer && (self.currentPlayer == 2 || self.computerThinking)) return;
    if (![self commitMoveAtRow:row column:column player:self.currentPlayer]) return;
    if (self.versusComputer && !self.finished) [self scheduleComputerMove];
}

- (BOOL)commitMoveAtRow:(NSInteger)row column:(NSInteger)column player:(NSInteger)player {
    NSInteger index = row * CRMGomokuColumns + column;
    if (self.finished || self.cells[index].integerValue) return NO;
    self.cells[index] = @(player);
    [self.history addObject:@(index)];
    BOOL won = [self hasFiveAtRow:row column:column player:player];
    if (won || self.history.count == CRMGomokuCellCount) {
        self.finished = YES;
        self.computerThinking = NO;
        [self refresh];
        NSString *message = nil;
        if (won && self.versusComputer) message = player == 1 ? @"恭喜你获胜！" : @"电脑获胜，再来一局吧！";
        else if (won) message = player == 1 ? @"黑棋获胜！" : @"白棋获胜！";
        else message = @"棋盘已满，再来一局吧。";
        GameShowMessage(self, won ? @"对局结束" : @"平局", message);
    } else {
        self.currentPlayer = 3 - player;
        [self refresh];
    }
    return YES;
}

- (BOOL)hasFiveAtRow:(NSInteger)row column:(NSInteger)column player:(NSInteger)player {
    return [self countFromRow:row column:column player:player deltaRow:1 deltaColumn:0] >= 5 ||
           [self countFromRow:row column:column player:player deltaRow:0 deltaColumn:1] >= 5 ||
           [self countFromRow:row column:column player:player deltaRow:1 deltaColumn:1] >= 5 ||
           [self countFromRow:row column:column player:player deltaRow:1 deltaColumn:-1] >= 5;
}

- (NSInteger)countFromRow:(NSInteger)row column:(NSInteger)column player:(NSInteger)player deltaRow:(NSInteger)dr deltaColumn:(NSInteger)dc {
    NSInteger count = 1;
    for (NSInteger direction = -1; direction <= 1; direction += 2) {
        NSInteger r = row + dr * direction, c = column + dc * direction;
        while (r >= 0 && r < CRMGomokuRows && c >= 0 && c < CRMGomokuColumns && self.cells[r * CRMGomokuColumns + c].integerValue == player) {
            count++;
            r += dr * direction;
            c += dc * direction;
        }
    }
    return count;
}

- (NSInteger)lineScoreAtRow:(NSInteger)row column:(NSInteger)column player:(NSInteger)player deltaRow:(NSInteger)dr deltaColumn:(NSInteger)dc {
    NSInteger count = 1;
    NSInteger openEnds = 0;
    for (NSInteger direction = -1; direction <= 1; direction += 2) {
        NSInteger r = row + dr * direction, c = column + dc * direction;
        while (r >= 0 && r < CRMGomokuRows && c >= 0 && c < CRMGomokuColumns && self.cells[r * CRMGomokuColumns + c].integerValue == player) {
            count++;
            r += dr * direction;
            c += dc * direction;
        }
        if (r >= 0 && r < CRMGomokuRows && c >= 0 && c < CRMGomokuColumns && self.cells[r * CRMGomokuColumns + c].integerValue == 0) openEnds++;
    }
    if (count >= 5) return 1000000;
    if (count == 4) return openEnds == 2 ? 100000 : (openEnds == 1 ? 20000 : 0);
    if (count == 3) return openEnds == 2 ? 8000 : (openEnds == 1 ? 1200 : 0);
    if (count == 2) return openEnds == 2 ? 500 : (openEnds == 1 ? 100 : 0);
    return openEnds == 2 ? 20 : 5;
}

- (NSInteger)positionScoreAtRow:(NSInteger)row column:(NSInteger)column player:(NSInteger)player {
    static const NSInteger directions[4][2] = {{1, 0}, {0, 1}, {1, 1}, {1, -1}};
    NSInteger score = 0;
    for (NSInteger index = 0; index < 4; index++) {
        score += [self lineScoreAtRow:row
                              column:column
                              player:player
                            deltaRow:directions[index][0]
                         deltaColumn:directions[index][1]];
    }
    return score;
}

- (NSInteger)bestComputerMove {
    NSInteger bestIndex = -1;
    NSInteger bestScore = NSIntegerMin;
    for (NSInteger row = 0; row < CRMGomokuRows; row++) {
        for (NSInteger column = 0; column < CRMGomokuColumns; column++) {
            NSInteger index = row * CRMGomokuColumns + column;
            if (self.cells[index].integerValue) continue;
            NSInteger attack = [self positionScoreAtRow:row column:column player:2];
            NSInteger defense = [self positionScoreAtRow:row column:column player:1];
            // 必胜点优先，其次必须封堵玩家的成五点。
            NSInteger score = attack >= 1000000 ? 3000000 : (defense >= 1000000 ? 2000000 : attack * 2 + defense * 3);
            score += CRMGomokuRows - labs(row - (CRMGomokuRows - 1) / 2) - labs(column - (CRMGomokuColumns - 1) / 2);
            if (score > bestScore || (score == bestScore && arc4random_uniform(2) == 0)) {
                bestScore = score;
                bestIndex = index;
            }
        }
    }
    return bestIndex;
}

- (void)scheduleComputerMove {
    self.computerThinking = YES;
    [self refresh];
    NSUInteger generation = self.gameGeneration;
    __weak typeof(self) weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.28 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        __strong typeof(weakSelf) self = weakSelf;
        if (!self || generation != self.gameGeneration || self.finished || !self.versusComputer || self.currentPlayer != 2) return;
        NSInteger index = [self bestComputerMove];
        self.computerThinking = NO;
        if (index >= 0) [self commitMoveAtRow:index / CRMGomokuColumns column:index % CRMGomokuColumns player:2];
        else [self refresh];
    });
}

- (void)toggleMode {
    self.versusComputer = !self.versusComputer;
    [self restart];
}

- (void)undoMove {
    if (!self.history.count) return;
    self.gameGeneration++;
    NSInteger removeCount = self.versusComputer && self.history.count >= 2 && !self.computerThinking ? 2 : 1;
    while (removeCount-- > 0 && self.history.count) {
        NSInteger index = self.history.lastObject.integerValue;
        self.cells[index] = @0;
        [self.history removeLastObject];
    }
    self.currentPlayer = self.versusComputer ? 1 : (self.history.count % 2 == 0 ? 1 : 2);
    self.finished = NO;
    self.computerThinking = NO;
    [self refresh];
}
@end

#pragma mark - 数字拼图

@interface CRMPuzzleController : CRMGameController
@property (nonatomic, strong) NSMutableArray<NSNumber *> *tiles;
@property (nonatomic, strong) NSMutableArray<UIButton *> *tileButtons;
@property (nonatomic, copy) NSArray<NSString *> *puzzleImageNames;
@property (nonatomic, copy) NSArray<NSString *> *puzzleImageAssetNames;
@property (nonatomic, copy) NSArray<UIImage *> *tileImageCache;
@property (nonatomic, assign) NSInteger currentImageIndex;
@property (nonatomic, assign) NSInteger moves;
@property (nonatomic, assign) BOOL finished;
@end

@implementation CRMPuzzleController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.puzzleImageNames = @[@"森林小狐", @"海岸灯塔", @"山谷热气球", @"亚古兽", @"加布兽"];
    self.puzzleImageAssetNames = @[@"puzzle_fox", @"puzzle_lighthouse", @"puzzle_balloon",
                                   @"puzzle_agumon", @"puzzle_gabumon"];
    self.currentImageIndex = [[NSUserDefaults standardUserDefaults] integerForKey:@"CRMPuzzleSelectedImage"];
    if (self.currentImageIndex < 0 || self.currentImageIndex >= self.puzzleImageAssetNames.count) {
        self.currentImageIndex = 0;
    }
    UIView *board = [[UIView alloc] init];
    board.backgroundColor = GameColor(0xDCE7E3);
    [self setupTitle:@"图片拼图" subtitle:@"滑动图片块，拼出完整画面" board:board aspect:1 maximumWidth:360];
    UIStackView *grid = [[UIStackView alloc] init];
    grid.axis = UILayoutConstraintAxisVertical;
    grid.distribution = UIStackViewDistributionFillEqually;
    grid.spacing = 7;
    grid.translatesAutoresizingMaskIntoConstraints = NO;
    [board addSubview:grid];
    [NSLayoutConstraint activateConstraints:@[
        [grid.topAnchor constraintEqualToAnchor:board.topAnchor constant:7],
        [grid.leadingAnchor constraintEqualToAnchor:board.leadingAnchor constant:7],
        [grid.trailingAnchor constraintEqualToAnchor:board.trailingAnchor constant:-7],
        [grid.bottomAnchor constraintEqualToAnchor:board.bottomAnchor constant:-7]
    ]];
    self.tileButtons = [NSMutableArray array];
    for (NSInteger row = 0; row < 3; row++) {
        UIStackView *rowView = [[UIStackView alloc] init];
        rowView.axis = UILayoutConstraintAxisHorizontal;
        rowView.distribution = UIStackViewDistributionFillEqually;
        rowView.spacing = 7;
        [grid addArrangedSubview:rowView];
        for (NSInteger column = 0; column < 3; column++) {
            NSInteger index = row * 3 + column;
            UIButton *button = GameButton(@"", GameColor(0xFFFFFF), GameColor(0x315D56));
            button.tag = index;
            button.clipsToBounds = YES;
            button.imageView.contentMode = UIViewContentModeScaleAspectFill;
            [button addTarget:self action:@selector(tileTapped:) forControlEvents:UIControlEventTouchUpInside];
            [rowView addArrangedSubview:button];
            [self.tileButtons addObject:button];
        }
    }
    [self addAction:@"切换图片" selector:@selector(showImagePicker)];
    [self addAction:@"重新打乱" selector:@selector(restart)];
    [self restart];
}

- (UIImage *)tileImageForValue:(NSInteger)value {
    if (value < 1 || value > 9) return nil;
    if (self.tileImageCache.count == 9) return self.tileImageCache[value - 1];

    UIImage *source = [UIImage imageNamed:self.puzzleImageAssetNames[self.currentImageIndex]];
    if (!source.CGImage) return nil;
    size_t width = CGImageGetWidth(source.CGImage);
    size_t height = CGImageGetHeight(source.CGImage);
    size_t tileWidth = width / 3;
    size_t tileHeight = height / 3;
    NSMutableArray<UIImage *> *images = [NSMutableArray arrayWithCapacity:9];
    for (NSInteger sourceIndex = 0; sourceIndex < 9; sourceIndex++) {
        CGRect cropRect = CGRectMake((sourceIndex % 3) * tileWidth,
                                     (sourceIndex / 3) * tileHeight,
                                     sourceIndex % 3 == 2 ? width - tileWidth * 2 : tileWidth,
                                     sourceIndex / 3 == 2 ? height - tileHeight * 2 : tileHeight);
        CGImageRef croppedImage = CGImageCreateWithImageInRect(source.CGImage, cropRect);
        if (!croppedImage) return nil;
        [images addObject:[UIImage imageWithCGImage:croppedImage
                                              scale:source.scale
                                        orientation:source.imageOrientation]];
        CGImageRelease(croppedImage);
    }
    self.tileImageCache = images;
    return self.tileImageCache[value - 1];
}

- (void)showImagePicker {
    UIAlertController *picker = [UIAlertController alertControllerWithTitle:@"选择拼图"
                                                                    message:@"选择后会重新打乱当前拼图"
                                                             preferredStyle:UIAlertControllerStyleActionSheet];
    __weak typeof(self) weakSelf = self;
    [self.puzzleImageNames enumerateObjectsUsingBlock:^(NSString *name, NSUInteger index, BOOL *stop) {
        NSString *title = index == self.currentImageIndex ? [NSString stringWithFormat:@"✓ %@", name] : name;
        [picker addAction:[UIAlertAction actionWithTitle:title style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            weakSelf.currentImageIndex = index;
            weakSelf.tileImageCache = nil;
            [[NSUserDefaults standardUserDefaults] setInteger:index forKey:@"CRMPuzzleSelectedImage"];
            [weakSelf restart];
        }]];
    }];
    [picker addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    picker.popoverPresentationController.sourceView = self.view;
    picker.popoverPresentationController.sourceRect = CGRectMake(CGRectGetMidX(self.view.bounds),
                                                                  CGRectGetMaxY(self.view.bounds) - 80, 1, 1);
    [self presentViewController:picker animated:YES completion:nil];
}

- (void)restart {
    self.tiles = [@[@1, @2, @3, @4, @5, @6, @7, @8, @0] mutableCopy];
    NSInteger empty = 8, previous = -1;
    // 从完成状态执行合法移动，始终生成可解的拼图。
    for (NSInteger turn = 0; turn < 120; turn++) {
        NSMutableArray<NSNumber *> *neighbors = [NSMutableArray array];
        NSInteger row = empty / 3, column = empty % 3;
        if (row > 0) [neighbors addObject:@(empty - 3)];
        if (row < 2) [neighbors addObject:@(empty + 3)];
        if (column > 0) [neighbors addObject:@(empty - 1)];
        if (column < 2) [neighbors addObject:@(empty + 1)];
        [neighbors removeObject:@(previous)];
        NSInteger next = neighbors[arc4random_uniform((uint32_t)neighbors.count)].integerValue;
        [self.tiles exchangeObjectAtIndex:empty withObjectAtIndex:next];
        previous = empty;
        empty = next;
    }
    BOOL solved = YES;
    for (NSInteger index = 0; index < 8; index++) if (self.tiles[index].integerValue != index + 1) solved = NO;
    if (solved) [self.tiles exchangeObjectAtIndex:8 withObjectAtIndex:7];
    self.moves = 0;
    self.finished = NO;
    [self refresh];
}

- (void)refresh {
    self.statusLabel.text = [NSString stringWithFormat:@"%@ · 已移动 %ld 步",
                             self.puzzleImageNames[self.currentImageIndex], (long)self.moves];
    for (NSInteger index = 0; index < 9; index++) {
        NSInteger value = self.tiles[index].integerValue;
        UIButton *button = self.tileButtons[index];
        button.enabled = value != 0;
        [button setTitle:@"" forState:UIControlStateNormal];
        NSInteger displayedValue = value != 0 ? value : (self.finished ? 9 : 0);
        [button setBackgroundImage:displayedValue ? [self tileImageForValue:displayedValue] : nil
                         forState:UIControlStateNormal];
        button.backgroundColor = displayedValue ? UIColor.whiteColor : UIColor.clearColor;
    }
}

- (void)tileTapped:(UIButton *)sender {
    if (self.finished) return;
    NSInteger index = sender.tag;
    NSInteger empty = [self.tiles indexOfObject:@0];
    if (labs(index / 3 - empty / 3) + labs(index % 3 - empty % 3) != 1) return;
    [self.tiles exchangeObjectAtIndex:index withObjectAtIndex:empty];
    self.moves++;
    [self refresh];
    BOOL solved = YES;
    for (NSInteger i = 0; i < 8; i++) if (self.tiles[i].integerValue != i + 1) solved = NO;
    if (solved) {
        self.finished = YES;
        [self refresh];
        GameShowMessage(self, @"拼图完成", [NSString stringWithFormat:@"太棒了！共用了 %ld 步。", (long)self.moves]);
    }
}
@end

#pragma mark - 三车道赛车

@interface CRMRacingBoard : UIView
@property (nonatomic, assign) NSInteger playerLane;
@property (nonatomic, assign) NSInteger carStyle;
@property (nonatomic, assign) CGFloat roadOffset;
@property (nonatomic, copy) NSArray<NSDictionary *> *obstacles;
@property (nonatomic, assign) BOOL gameOver;
@end

@implementation CRMRacingBoard

- (void)drawCarInRect:(CGRect)rect color:(UIColor *)color {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    // 阴影、轮胎和车身分层绘制，让小尺寸赛车仍有清晰轮廓。
    CGContextSetShadowWithColor(context, CGSizeMake(0, 3), 5, [UIColor colorWithWhite:0 alpha:0.28].CGColor);
    [GameColor(0x263A3B) setFill];
    CGFloat wheelWidth = rect.size.width * 0.16;
    UIRectFill(CGRectMake(CGRectGetMinX(rect) - 2, CGRectGetMinY(rect) + rect.size.height * 0.2, wheelWidth, rect.size.height * 0.22));
    UIRectFill(CGRectMake(CGRectGetMaxX(rect) - wheelWidth + 2, CGRectGetMinY(rect) + rect.size.height * 0.2, wheelWidth, rect.size.height * 0.22));
    UIRectFill(CGRectMake(CGRectGetMinX(rect) - 2, CGRectGetMaxY(rect) - rect.size.height * 0.34, wheelWidth, rect.size.height * 0.22));
    UIRectFill(CGRectMake(CGRectGetMaxX(rect) - wheelWidth + 2, CGRectGetMaxY(rect) - rect.size.height * 0.34, wheelWidth, rect.size.height * 0.22));
    UIBezierPath *body = [UIBezierPath bezierPathWithRoundedRect:CGRectInset(rect, rect.size.width * 0.08, 0)
                                                     cornerRadius:rect.size.width * 0.24];
    [color setFill];
    [body fill];
    CGContextRestoreGState(context);
    CGRect cabin = CGRectMake(CGRectGetMinX(rect) + rect.size.width * 0.23,
                              CGRectGetMinY(rect) + rect.size.height * 0.22,
                              rect.size.width * 0.54, rect.size.height * 0.34);
    [GameColor(0xDDF5FA) setFill];
    [[UIBezierPath bezierPathWithRoundedRect:cabin cornerRadius:7] fill];
    [UIColor.whiteColor setFill];
    [[UIBezierPath bezierPathWithOvalInRect:CGRectMake(CGRectGetMinX(rect) + 8, CGRectGetMinY(rect) + 8, 7, 7)] fill];
    [[UIBezierPath bezierPathWithOvalInRect:CGRectMake(CGRectGetMaxX(rect) - 15, CGRectGetMinY(rect) + 8, 7, 7)] fill];
}

- (void)drawObstacle:(NSDictionary *)obstacle laneRect:(CGRect)laneRect {
    CGFloat y = [obstacle[@"y"] doubleValue] * CGRectGetHeight(self.bounds);
    NSInteger type = [obstacle[@"type"] integerValue];
    CGRect rect = CGRectMake(CGRectGetMidX(laneRect) - laneRect.size.width * 0.25,
                             y, laneRect.size.width * 0.5, CGRectGetHeight(self.bounds) * 0.11);
    if (type == 0) {
        [GameColor(0xF08A62) setFill];
        UIBezierPath *cone = [UIBezierPath bezierPath];
        [cone moveToPoint:CGPointMake(CGRectGetMidX(rect), CGRectGetMinY(rect))];
        [cone addLineToPoint:CGPointMake(CGRectGetMaxX(rect) - 4, CGRectGetMaxY(rect))];
        [cone addLineToPoint:CGPointMake(CGRectGetMinX(rect) + 4, CGRectGetMaxY(rect))];
        [cone closePath];
        [cone fill];
        [UIColor.whiteColor setStroke]; cone.lineWidth = 5; [cone stroke];
    } else if (type == 1) {
        [GameColor(0xEBC762) setFill];
        [[UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:6] fill];
        [GameColor(0x9B6447) setStroke];
        UIBezierPath *stripe = [UIBezierPath bezierPath]; stripe.lineWidth = 6;
        [stripe moveToPoint:CGPointMake(CGRectGetMinX(rect) + 5, CGRectGetMinY(rect) + 5)];
        [stripe addLineToPoint:CGPointMake(CGRectGetMaxX(rect) - 5, CGRectGetMaxY(rect) - 5)];
        [stripe stroke];
    } else {
        [GameColor(0x293A42) setFill];
        [[UIBezierPath bezierPathWithOvalInRect:CGRectInset(rect, 3, rect.size.height * 0.18)] fill];
        [GameColor(0x4D6470) setFill];
        [[UIBezierPath bezierPathWithOvalInRect:CGRectInset(rect, rect.size.width * 0.27, rect.size.height * 0.34)] fill];
    }
}

- (void)drawRect:(CGRect)rect {
    [GameColor(0x8ACB82) setFill]; UIRectFill(rect);
    CGFloat roadX = rect.size.width * 0.08, roadWidth = rect.size.width * 0.84;
    CGRect road = CGRectMake(roadX, 0, roadWidth, rect.size.height);
    [GameColor(0x46575C) setFill]; UIRectFill(road);
    [GameColor(0xF6E8B1) setFill];
    UIRectFill(CGRectMake(roadX + 4, 0, 4, rect.size.height));
    UIRectFill(CGRectMake(CGRectGetMaxX(road) - 8, 0, 4, rect.size.height));
    CGFloat laneWidth = roadWidth / 3.0;
    for (NSInteger divider = 1; divider <= 2; divider++) {
        CGFloat x = roadX + laneWidth * divider;
        for (CGFloat y = self.roadOffset - 48; y < rect.size.height; y += 58) {
            [UIColor.whiteColor setFill];
            [[UIBezierPath bezierPathWithRoundedRect:CGRectMake(x - 2, y, 4, 31) cornerRadius:2] fill];
        }
    }
    for (NSDictionary *obstacle in self.obstacles) {
        NSInteger lane = [obstacle[@"lane"] integerValue];
        [self drawObstacle:obstacle laneRect:CGRectMake(roadX + laneWidth * lane, 0, laneWidth, rect.size.height)];
    }
    NSArray *colors = @[GameColor(0xF36F5B), GameColor(0x55A9D6), GameColor(0xF1C453), GameColor(0x9B7BC4)];
    CGRect playerRect = CGRectMake(roadX + laneWidth * self.playerLane + laneWidth * 0.25,
                                   rect.size.height * 0.77, laneWidth * 0.5, rect.size.height * 0.14);
    [self drawCarInRect:playerRect color:colors[self.carStyle % colors.count]];
    if (self.gameOver) {
        [[UIColor colorWithWhite:0 alpha:0.38] setFill]; UIRectFill(rect);
        NSDictionary *attributes = @{NSFontAttributeName: [UIFont systemFontOfSize:28 weight:UIFontWeightBold],
                                     NSForegroundColorAttributeName: UIColor.whiteColor};
        NSString *text = @"碰撞啦！";
        CGSize size = [text sizeWithAttributes:attributes];
        [text drawAtPoint:CGPointMake((rect.size.width - size.width) / 2, rect.size.height * 0.44) withAttributes:attributes];
    }
}
@end

@interface CRMRacingController : CRMGameController
@property (nonatomic, strong) CRMRacingBoard *gameBoard;
@property (nonatomic, strong) NSMutableArray<NSMutableDictionary *> *obstacles;
@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, assign) NSInteger playerLane;
@property (nonatomic, assign) NSInteger carStyle;
@property (nonatomic, assign) NSInteger score;
@property (nonatomic, assign) NSInteger level;
@property (nonatomic, assign) NSInteger ticksUntilSpawn;
@property (nonatomic, assign) BOOL gameOver;
@end

@implementation CRMRacingController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.gameBoard = [[CRMRacingBoard alloc] init];
    [self setupCompactLayoutWithBoard:self.gameBoard aspect:1.48 maximumWidth:345];
    self.actions.axis = UILayoutConstraintAxisHorizontal;
    self.actions.alignment = UIStackViewAlignmentCenter;
    self.actions.distribution = UIStackViewDistributionEqualSpacing;
    UIButton *left = GameCircleButton(@"◀", 62, 21);
    UIButton *right = GameCircleButton(@"▶", 62, 21);
    UIButton *change = GameCircleButton(@"换车", 62, 13);
    UIButton *restart = GameCircleButton(@"重来", 62, 13);
    [left addTarget:self action:@selector(moveLeft) forControlEvents:UIControlEventTouchUpInside];
    [right addTarget:self action:@selector(moveRight) forControlEvents:UIControlEventTouchUpInside];
    [change addTarget:self action:@selector(changeCar) forControlEvents:UIControlEventTouchUpInside];
    [restart addTarget:self action:@selector(restart) forControlEvents:UIControlEventTouchUpInside];
    for (UIButton *button in @[left, change, restart, right]) [self.actions addArrangedSubview:button];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pauseGame) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [self restart];
}

- (void)viewDidAppear:(BOOL)animated { [super viewDidAppear:animated]; [self startTimer]; }
- (void)viewWillDisappear:(BOOL)animated { [super viewWillDisappear:animated]; [self pauseGame]; }
- (void)dealloc { [self.timer invalidate]; [[NSNotificationCenter defaultCenter] removeObserver:self]; }
- (void)startTimer {
    if (self.timer || self.gameOver || !self.view.window) return;
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 / 30.0 target:self selector:@selector(tick) userInfo:nil repeats:YES];
}
- (void)pauseGame { [self.timer invalidate]; self.timer = nil; }

- (void)restart {
    [self pauseGame];
    self.playerLane = 1; self.score = 0; self.level = 1; self.ticksUntilSpawn = 20; self.gameOver = NO;
    self.obstacles = [NSMutableArray array];
    [self refresh]; [self startTimer];
}
- (void)moveLeft { if (!self.gameOver && self.playerLane > 0) { self.playerLane--; [self refresh]; } }
- (void)moveRight { if (!self.gameOver && self.playerLane < 2) { self.playerLane++; [self refresh]; } }
- (void)changeCar { self.carStyle = (self.carStyle + 1) % 4; [self refresh]; }

- (void)tick {
    if (self.gameOver) return;
    self.level = MIN(6, 1 + self.score / 450);
    CGFloat speed = 0.0095 + (self.level - 1) * 0.0018;
    for (NSMutableDictionary *obstacle in self.obstacles) obstacle[@"y"] = @([obstacle[@"y"] doubleValue] + speed);
    for (NSDictionary *obstacle in self.obstacles) {
        CGFloat y = [obstacle[@"y"] doubleValue];
        if ([obstacle[@"lane"] integerValue] == self.playerLane && y > 0.69 && y < 0.91) {
            self.gameOver = YES; [self pauseGame]; [self refresh];
            GameShowMessage(self, @"赛车结束", [NSString stringWithFormat:@"安全行驶了 %ld 米，再试一次吧！", (long)self.score]);
            return;
        }
    }
    NSIndexSet *expired = [self.obstacles indexesOfObjectsPassingTest:^BOOL(NSDictionary *item, NSUInteger idx, BOOL *stop) {
        return [item[@"y"] doubleValue] > 1.08;
    }];
    self.score += expired.count * 25 + 1;
    [self.obstacles removeObjectsAtIndexes:expired];
    if (--self.ticksUntilSpawn <= 0) {
        NSInteger firstLane = arc4random_uniform(3);
        [self.obstacles addObject:[@{@"lane": @(firstLane), @"y": @(-0.14), @"type": @(arc4random_uniform(3))} mutableCopy]];
        // 第三级开始偶尔出现并排双障碍，但始终保留一条可通行车道。
        if (self.level >= 3 && arc4random_uniform(100) < 22 + self.level * 4) {
            NSInteger secondLane = (firstLane + 1 + arc4random_uniform(2)) % 3;
            [self.obstacles addObject:[@{@"lane": @(secondLane), @"y": @(-0.14), @"type": @(arc4random_uniform(3))} mutableCopy]];
        }
        self.ticksUntilSpawn = MAX(17, 43 - self.level * 4);
    }
    self.gameBoard.roadOffset = fmod(self.gameBoard.roadOffset + 7, 58);
    [self refresh];
}
- (void)refresh {
    self.gameBoard.playerLane = self.playerLane;
    self.gameBoard.carStyle = self.carStyle;
    self.gameBoard.obstacles = [self.obstacles copy];
    self.gameBoard.gameOver = self.gameOver;
    [self.gameBoard setNeedsDisplay];
    self.statusLabel.text = self.gameOver ? @"发生碰撞 · 点击重来重新出发" : [NSString stringWithFormat:@"第 %ld 级 · 行驶 %ld 米", (long)self.level, (long)self.score];
}
@end

#pragma mark - 足球打砖块

static const NSInteger CRMSoccerBrickRows = 7;
static const NSInteger CRMSoccerBrickColumns = 7;

@interface CRMSoccerBreakoutBoard : UIView
@property (nonatomic, copy) NSArray<NSNumber *> *bricks;
@property (nonatomic, assign) CGPoint ball;
@property (nonatomic, assign) CGFloat playerX;
@property (nonatomic, assign) CGFloat playerHalfWidth;
@property (nonatomic, assign) BOOL gameOver;
@property (nonatomic, assign) CGFloat runPhase;
@property (nonatomic, assign) NSInteger facing;
@property (nonatomic, assign) BOOL running;
@property (nonatomic, assign) CGFloat kickRemaining;
@property (nonatomic, assign) CGFloat kickOffset;
@end

@implementation CRMSoccerBreakoutBoard
- (void)drawSidePlayerAtScale:(CGFloat)scale height:(CGFloat)height {
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGFloat kick = CRMSoccerKickStrength(self.kickRemaining);
    CGFloat direction = kick > 0.05 ? (self.kickOffset < 0 ? -1 : 1) : (self.facing < 0 ? -1 : 1);
    CGContextSaveGState(context);
    CGContextScaleCTM(context, direction, 1);
    CGFloat phase = self.runPhase, bob = self.running ? -2.5 * fabs(sin(phase)) : 0;
    UIColor *ink = GameColor(0x203540), *blue = GameColor(0x3269B0), *skin = GameColor(0xF5C6A2);
    // 两条腿交替经历支撑、蹬地、屈膝回收，膝盖由两节等长骨骼解算。
    for (NSInteger limb = 0; limb < 2; limb++) {
        CRMSoccerLegPose pose = CRMSoccerRunningLeg(phase, (int)limb, self.running, kick,
                                                    fabs(self.kickOffset) * self.bounds.size.width / scale,
                                                    (CRMSoccerGroundY - CRMSoccerContactY) * height / scale);
        CGFloat footX = pose.footX, footY = pose.footY;
        CGPoint hip = CGPointMake(0, pose.hipY), knee = CGPointMake(pose.kneeX, pose.kneeY);
        CGContextSaveGState(context); CGContextSetAlpha(context, limb ? 1 : 0.65);
        UIBezierPath *leg = [UIBezierPath bezierPath]; leg.lineWidth = 7; leg.lineCapStyle = kCGLineCapRound;
        [leg moveToPoint:hip]; [leg addLineToPoint:knee]; [skin setStroke]; [leg stroke];
        [leg removeAllPoints]; [leg moveToPoint:knee]; [leg addLineToPoint:CGPointMake(footX, footY - 3)];
        [UIColor.whiteColor setStroke]; [leg stroke];
        [blue setFill]; [[UIBezierPath bezierPathWithOvalInRect:CGRectMake(knee.x - 3.5, knee.y - 2, 7, 4)] fill];
        [ink setFill]; [[UIBezierPath bezierPathWithRoundedRect:CGRectMake(footX - 4, footY - 4, 14, 7) cornerRadius:3] fill];
        CGContextRestoreGState(context);
    }
    CGContextTranslateCTM(context, 0, -28 + bob);
    CGContextRotateCTM(context, self.running ? 0.18 : -0.08 * kick);
    // 远侧手臂在身体后方，近侧手臂在前方，肩髋轮廓随前倾一起转动。
    for (NSInteger armIndex = 0; armIndex < 2; armIndex++) {
        if (armIndex == 1) {
            [blue setFill]; [[UIBezierPath bezierPathWithRoundedRect:CGRectMake(-9, -5, 18, 12) cornerRadius:4] fill];
            [UIColor.whiteColor setFill]; [[UIBezierPath bezierPathWithRoundedRect:CGRectMake(-9, -31, 19, 29) cornerRadius:6] fill];
            [blue setFill]; UIRectFill(CGRectMake(-7, -30, 15, 3));
            // 镜像身体时把号码单独反向补偿，避免左跑时出现镜像文字。
            CGContextSaveGState(context); CGContextScaleCTM(context, direction, 1);
            [@"10" drawAtPoint:CGPointMake(-6, -18) withAttributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:10], NSForegroundColorAttributeName:blue}];
            CGContextRestoreGState(context);
            [skin setFill];
            UIBezierPath *face = [UIBezierPath bezierPathWithOvalInRect:CGRectMake(-7, -55, 22, 26)]; [face fill];
            UIBezierPath *nose = [UIBezierPath bezierPath]; [nose moveToPoint:CGPointMake(11, -46)];
            [nose addLineToPoint:CGPointMake(19, -41)]; [nose addLineToPoint:CGPointMake(12, -39)]; [nose closePath]; [nose fill];
            [ink setFill];
            UIBezierPath *hair = [UIBezierPath bezierPath];
            [hair moveToPoint:CGPointMake(-6, -32)]; [hair addLineToPoint:CGPointMake(-14, -44)];
            [hair addLineToPoint:CGPointMake(-11, -49)]; [hair addLineToPoint:CGPointMake(-20, -54)];
            [hair addLineToPoint:CGPointMake(-9, -53)]; [hair addLineToPoint:CGPointMake(-11, -61)];
            [hair addLineToPoint:CGPointMake(-2, -57)]; [hair addLineToPoint:CGPointMake(7, -62)];
            [hair addLineToPoint:CGPointMake(5, -57)];
            [hair addQuadCurveToPoint:CGPointMake(16, -46) controlPoint:CGPointMake(20, -57)];
            [hair addLineToPoint:CGPointMake(7, -49)]; [hair addLineToPoint:CGPointMake(5, -42)];
            [hair addLineToPoint:CGPointMake(1, -49)]; [hair addLineToPoint:CGPointMake(-3, -40)];
            [hair closePath]; [hair fill];
            [skin setFill]; [[UIBezierPath bezierPathWithOvalInRect:CGRectMake(-4, -43, 6, 8)] fill];
            [UIColor.whiteColor setFill]; [[UIBezierPath bezierPathWithOvalInRect:CGRectMake(8, -46, 5, 7)] fill];
            [ink setFill]; [[UIBezierPath bezierPathWithOvalInRect:CGRectMake(11, -44, 2, 4)] fill];
            UIBezierPath *mouth = [UIBezierPath bezierPath]; mouth.lineWidth = 1;
            [mouth moveToPoint:CGPointMake(9, -35)]; [mouth addLineToPoint:CGPointMake(14, -36)]; [ink setStroke]; [mouth stroke];
        }
        CGFloat swing = self.running ? sin(phase + armIndex * M_PI) * 0.85 : (armIndex ? -0.4 : 0.4);
        swing -= kick * 0.5;
        CGPoint shoulder = CGPointMake(0, -25);
        CGPoint elbow = CGPointMake(shoulder.x + sin(swing) * 15, shoulder.y + cos(swing) * 15);
        CGPoint hand = CGPointMake(elbow.x + sin(swing - 1.25) * 12, elbow.y + cos(swing - 1.25) * 12);
        CGContextSaveGState(context); CGContextSetAlpha(context, armIndex ? 1 : 0.65);
        UIBezierPath *arm = [UIBezierPath bezierPath]; arm.lineWidth = 6; arm.lineCapStyle = kCGLineCapRound;
        [arm moveToPoint:shoulder]; [arm addLineToPoint:elbow]; [arm addLineToPoint:hand]; [skin setStroke]; [arm stroke];
        [blue setFill]; [[UIBezierPath bezierPathWithOvalInRect:CGRectMake(-5, -29, 10, 9)] fill];
        CGContextRestoreGState(context);
    }
    CGContextRestoreGState(context);
}

- (void)drawRect:(CGRect)rect {
    [GameColor(0xDDF3F5) setFill]; UIRectFill(rect);
    [GameColor(0xBFE1C5) setFill]; UIRectFill(CGRectMake(0, rect.size.height * 0.72, rect.size.width, rect.size.height * 0.28));
    NSArray *colors = @[GameColor(0xEF7B6C), GameColor(0xF2C45E), GameColor(0x6FC5C2), GameColor(0x82A7D9), GameColor(0xA98BC5)];
    CGFloat gap = 4, margin = 12;
    CGFloat brickWidth = (rect.size.width - margin * 2 - gap * (CRMSoccerBrickColumns - 1)) / CRMSoccerBrickColumns;
    CGFloat brickHeight = rect.size.height * 0.057;
    for (NSInteger row = 0; row < CRMSoccerBrickRows; row++) {
        for (NSInteger column = 0; column < CRMSoccerBrickColumns; column++) {
            NSInteger index = row * CRMSoccerBrickColumns + column;
            if (!self.bricks[index].boolValue) continue;
            CGRect brick = CGRectMake(margin + column * (brickWidth + gap), rect.size.height * 0.07 + row * (brickHeight + gap), brickWidth, brickHeight);
            [colors[row % colors.count] setFill]; [[UIBezierPath bezierPathWithRoundedRect:brick cornerRadius:5] fill];
            [[UIColor colorWithWhite:1 alpha:0.35] setFill]; UIRectFill(CGRectMake(brick.origin.x + 4, brick.origin.y + 4, brick.size.width - 8, 3));
        }
    }
    CGFloat px = self.playerX * rect.size.width, groundY = rect.size.height * CRMSoccerGroundY;
    CGFloat scale = MIN(1.15, rect.size.width / 320.0);
    CGFloat kick = CRMSoccerKickStrength(self.kickRemaining);
    // 大空翼的南葛10号造型：黑发、白蓝球衣、蓝短裤、白长袜。
    // 肢体随实际位移摆动，触球后踢出的脚迅速伸出，再平滑收回。
    [[GameColor(0x315F57) colorWithAlphaComponent:0.16] setFill];
    [[UIBezierPath bezierPathWithOvalInRect:CGRectMake(px - 25 * scale, groundY - 2, 50 * scale, 7)] fill];
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    CGContextTranslateCTM(context, px, groundY);
    CGContextScaleCTM(context, scale, scale);
    if (self.running || kick > 0.01) {
        [self drawSidePlayerAtScale:scale height:rect.size.height];
    } else {
    UIColor *skin = GameColor(0xF5C6A2), *blue = GameColor(0x3269B0), *ink = GameColor(0x263A3B);
    for (NSInteger side = -1; side <= 1; side += 2) {
        CGFloat footX = side * 10, footY = 0;
        CGPoint knee = CGPointMake(side * 7, -13);
        UIBezierPath *leg = [UIBezierPath bezierPath];
        leg.lineWidth = 7; leg.lineCapStyle = kCGLineCapRound;
        [leg moveToPoint:CGPointMake(side * 7, -26)]; [leg addLineToPoint:knee];
        [skin setStroke]; [leg stroke];
        [leg removeAllPoints]; [leg moveToPoint:knee]; [leg addLineToPoint:CGPointMake(footX, footY - 3)];
        [UIColor.whiteColor setStroke]; [leg stroke];
        [ink setFill]; [[UIBezierPath bezierPathWithRoundedRect:CGRectMake(footX - 6, footY - 4, 14, 7) cornerRadius:3] fill];
    }
    for (NSInteger side = -1; side <= 1; side += 2) {
        UIBezierPath *arm = [UIBezierPath bezierPath]; arm.lineWidth = 6; arm.lineCapStyle = kCGLineCapRound;
        [arm moveToPoint:CGPointMake(side * 13, -48)];
        [arm addLineToPoint:CGPointMake(side * 22, -35)];
        [arm addLineToPoint:CGPointMake(side * 18, -30)];
        [skin setStroke]; [arm stroke];
    }
    [blue setFill]; [[UIBezierPath bezierPathWithRoundedRect:CGRectMake(-14, -32, 28, 12) cornerRadius:3] fill];
    [UIColor.whiteColor setFill]; [[UIBezierPath bezierPathWithRoundedRect:CGRectMake(-15, -55, 30, 27) cornerRadius:6] fill];
    [blue setFill];
    UIRectFill(CGRectMake(-17, -52, 5, 10)); UIRectFill(CGRectMake(12, -52, 5, 10));
    UIBezierPath *collar = [UIBezierPath bezierPath]; collar.lineWidth = 3;
    [collar moveToPoint:CGPointMake(-7, -55)]; [collar addLineToPoint:CGPointMake(0, -50)]; [collar addLineToPoint:CGPointMake(7, -55)]; [blue setStroke]; [collar stroke];
    [@"南葛" drawAtPoint:CGPointMake(-10, -48) withAttributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:9], NSForegroundColorAttributeName:blue}];
    [@"10" drawAtPoint:CGPointMake(-6, -38) withAttributes:@{NSFontAttributeName:[UIFont boldSystemFontOfSize:10], NSForegroundColorAttributeName:blue}];
    [skin setFill]; [[UIBezierPath bezierPathWithOvalInRect:CGRectMake(-13, -79, 26, 27)] fill];
    [ink setFill];
    UIBezierPath *hair = [UIBezierPath bezierPath];
    [hair moveToPoint:CGPointMake(-14, -62)];
    [hair addLineToPoint:CGPointMake(-18, -77)]; [hair addLineToPoint:CGPointMake(-11, -75)];
    [hair addLineToPoint:CGPointMake(-10, -85)]; [hair addLineToPoint:CGPointMake(-3, -81)];
    [hair addLineToPoint:CGPointMake(6, -86)]; [hair addLineToPoint:CGPointMake(5, -81)];
    [hair addCurveToPoint:CGPointMake(16, -67) controlPoint1:CGPointMake(19, -84) controlPoint2:CGPointMake(18, -74)];
    [hair addLineToPoint:CGPointMake(11, -60)]; [hair addLineToPoint:CGPointMake(9, -73)];
    [hair addLineToPoint:CGPointMake(2, -68)]; [hair addLineToPoint:CGPointMake(3, -77)];
    [hair addLineToPoint:CGPointMake(-5, -69)]; [hair addLineToPoint:CGPointMake(-5, -75)];
    [hair addLineToPoint:CGPointMake(-11, -68)];
    [hair closePath]; [hair fill];
    [UIColor.whiteColor setFill];
    for (NSInteger side = -1; side <= 1; side += 2) {
        [[UIBezierPath bezierPathWithOvalInRect:CGRectMake(side * 6 - 3, -68, 6, 7)] fill];
    }
    [ink setFill];
    for (NSInteger side = -1; side <= 1; side += 2) {
        [[UIBezierPath bezierPathWithOvalInRect:CGRectMake(side * 6 - 1, -66, 2.5, 4)] fill];
    }
    UIBezierPath *smile = [UIBezierPath bezierPath]; smile.lineWidth = 1;
    [smile moveToPoint:CGPointMake(-3, -57)]; [smile addQuadCurveToPoint:CGPointMake(4, -57) controlPoint:CGPointMake(0, -54)]; [ink setStroke]; [smile stroke];
    }
    CGContextRestoreGState(context);
    if (kick > 0) {
        [[UIColor.whiteColor colorWithAlphaComponent:kick * 0.75] setStroke];
        UIBezierPath *arc = [UIBezierPath bezierPathWithArcCenter:CGPointMake(px + self.kickOffset * rect.size.width, rect.size.height * CRMSoccerContactY) radius:12 + (1 - kick) * 16 startAngle:M_PI endAngle:M_PI * 2 clockwise:YES];
        arc.lineWidth = 2; [arc stroke];
    }
    CGPoint ball = CGPointMake(self.ball.x * rect.size.width, self.ball.y * rect.size.height);
    CGFloat radius = MIN(rect.size.width, rect.size.height) * 0.028;
    [UIColor.whiteColor setFill]; [[UIBezierPath bezierPathWithOvalInRect:CGRectMake(ball.x - radius, ball.y - radius, radius * 2, radius * 2)] fill];
    [GameColor(0x263A3B) setFill];
    for (NSInteger i = 0; i < 5; i++) {
        CGFloat angle = i * M_PI * 2 / 5 - M_PI_2;
        [[UIBezierPath bezierPathWithOvalInRect:CGRectMake(ball.x + cos(angle) * radius * 0.55 - radius * 0.2,
                                                           ball.y + sin(angle) * radius * 0.55 - radius * 0.2,
                                                           radius * 0.4, radius * 0.4)] fill];
    }
    if (self.gameOver) { [[UIColor colorWithWhite:0 alpha:0.28] setFill]; UIRectFill(rect); }
}
@end

@interface CRMSoccerBreakoutController : CRMGameController
@property (nonatomic, strong) CRMSoccerBreakoutBoard *gameBoard;
@property (nonatomic, strong) NSMutableArray<NSNumber *> *bricks;
@property (nonatomic, strong) NSTimer *gameTimer;
@property (nonatomic, assign) CGPoint ball;
@property (nonatomic, assign) CGVector velocity;
@property (nonatomic, assign) CGFloat playerX;
@property (nonatomic, assign) CGFloat playerHalfWidth;
@property (nonatomic, assign) NSInteger moveDirection;
@property (nonatomic, assign) NSInteger destroyed;
@property (nonatomic, assign) NSInteger brickTarget;
@property (nonatomic, assign) NSInteger level;
@property (nonatomic, assign) BOOL gameOver;
@property (nonatomic, assign) BOOL visible;
@end

@implementation CRMSoccerBreakoutController
- (void)viewDidLoad {
    [super viewDidLoad];
    self.gameBoard = [[CRMSoccerBreakoutBoard alloc] init];
    [self setupCompactLayoutWithBoard:self.gameBoard aspect:1.38 maximumWidth:350];
    self.actions.axis = UILayoutConstraintAxisHorizontal;
    self.actions.alignment = UIStackViewAlignmentCenter;
    self.actions.distribution = UIStackViewDistributionEqualSpacing;
    UIButton *left = [self movementButton:@"◀" direction:-1];
    UIButton *right = [self movementButton:@"▶" direction:1];
    [self.actions addArrangedSubview:left]; [self.actions addArrangedSubview:right];
    UIButton *restart = GameCircleButton(@"重来", 68, 14);
    [restart addTarget:self action:@selector(restart) forControlEvents:UIControlEventTouchUpInside];
    [self.actions insertArrangedSubview:restart atIndex:1];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pauseGame) name:UIApplicationWillResignActiveNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(startGameTimer) name:UIApplicationDidBecomeActiveNotification object:nil];
    [self restart];
}
- (UIButton *)movementButton:(NSString *)title direction:(NSInteger)direction {
    UIButton *button = GameCircleButton(title, 68, 22);
    button.tag = direction;
    [button addTarget:self action:@selector(startMoving:) forControlEvents:UIControlEventTouchDown];
    [button addTarget:self action:@selector(stopMoving:) forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchUpOutside | UIControlEventTouchCancel | UIControlEventTouchDragExit];
    return button;
}
- (void)viewDidAppear:(BOOL)animated { [super viewDidAppear:animated]; self.visible = YES; [self startGameTimer]; }
- (void)viewWillDisappear:(BOOL)animated { [super viewWillDisappear:animated]; self.visible = NO; [self pauseGame]; }
- (void)dealloc { [self.gameTimer invalidate]; [[NSNotificationCenter defaultCenter] removeObserver:self]; }
- (void)startGameTimer {
    if (self.gameTimer || self.gameOver || !self.visible || !self.view.window || UIApplication.sharedApplication.applicationState != UIApplicationStateActive) return;
    __weak typeof(self) weakSelf = self;
    self.gameTimer = [NSTimer timerWithTimeInterval:1.0 / 60.0 repeats:YES block:^(NSTimer *timer) { [weakSelf tick]; }];
    [[NSRunLoop mainRunLoop] addTimer:self.gameTimer forMode:NSRunLoopCommonModes];
}
- (void)pauseGame {
    [self.gameTimer invalidate]; self.gameTimer = nil;
    self.moveDirection = 0; self.gameBoard.running = NO; self.gameBoard.kickRemaining = 0;
    [self.gameBoard setNeedsDisplay];
}
- (void)startMoving:(UIButton *)sender {
    if (!self.gameTimer || self.gameOver) return;
    self.moveDirection = sender.tag; [self movePlayer];
}
- (void)stopMoving:(UIButton *)sender {
    if (sender.tag != self.moveDirection) return;
    self.moveDirection = 0; self.gameBoard.running = NO; [self.gameBoard setNeedsDisplay];
}
- (void)movePlayer {
    if (self.gameOver) return;
    CGFloat previous = self.playerX;
    self.playerX = MIN(1 - self.playerHalfWidth, MAX(self.playerHalfWidth, self.playerX + self.moveDirection * 0.012));
    self.gameBoard.running = fabs(self.playerX - previous) > 0.0001;
    if (self.gameBoard.running) {
        self.gameBoard.facing = self.moveDirection;
        self.gameBoard.runPhase = fmod(self.gameBoard.runPhase + fabs(self.playerX - previous) * 32, M_PI * 2);
    }
    [self refresh];
}
- (void)restart {
    self.level = 1;
    [self startLevel];
}
- (void)startLevel {
    [self pauseGame];
    NSInteger activeRows = MIN(CRMSoccerBrickRows, 3 + self.level);
    self.bricks = [NSMutableArray arrayWithCapacity:CRMSoccerBrickRows * CRMSoccerBrickColumns];
    self.brickTarget = 0;
    for (NSInteger row = 0; row < CRMSoccerBrickRows; row++) {
        for (NSInteger column = 0; column < CRMSoccerBrickColumns; column++) {
            BOOL active = row < activeRows;
            [self.bricks addObject:@(active)];
            if (active) self.brickTarget++;
        }
    }
    CGFloat speedScale = 1 + (self.level - 1) * 0.11;
    self.playerHalfWidth = MAX(0.09, 0.145 - (self.level - 1) * 0.012);
    self.playerX = 0.5; self.ball = CGPointMake(0.5, 0.76);
    self.gameBoard.runPhase = 0; self.gameBoard.facing = 1;
    self.velocity = CGVectorMake(0.34 * speedScale, -0.48 * speedScale);
    self.destroyed = 0; self.gameOver = NO; [self refresh]; [self startGameTimer];
}
- (CGRect)brickRectAtRow:(NSInteger)row column:(NSInteger)column {
    CGFloat gap = 4.0 / MAX(CGRectGetWidth(self.gameBoard.bounds), 1), margin = 12.0 / MAX(CGRectGetWidth(self.gameBoard.bounds), 1);
    CGFloat verticalGap = 4.0 / MAX(CGRectGetHeight(self.gameBoard.bounds), 1);
    CGFloat width = (1 - margin * 2 - gap * (CRMSoccerBrickColumns - 1)) / CRMSoccerBrickColumns;
    CGFloat height = 0.057;
    return CGRectMake(margin + column * (width + gap), 0.07 + row * (height + verticalGap), width, height);
}
- (void)tick {
    if (self.gameOver) return;
    CGFloat dt = 1.0 / 60.0;
    if (self.moveDirection) [self movePlayer];
    self.gameBoard.kickRemaining = MAX(0, self.gameBoard.kickRemaining - dt);
    CGPoint previous = self.ball;
    self.ball = CGPointMake(self.ball.x + self.velocity.dx * dt, self.ball.y + self.velocity.dy * dt);
    CGFloat radius = 0.028;
    CGFloat radiusY = radius * self.gameBoard.bounds.size.width / MAX(self.gameBoard.bounds.size.height, 1);
    if (self.ball.x < radius) { self.ball = CGPointMake(radius, self.ball.y); self.velocity = CGVectorMake(fabs(self.velocity.dx), self.velocity.dy); }
    if (self.ball.x > 1 - radius) { self.ball = CGPointMake(1 - radius, self.ball.y); self.velocity = CGVectorMake(-fabs(self.velocity.dx), self.velocity.dy); }
    if (self.ball.y < radiusY) { self.ball = CGPointMake(self.ball.x, radiusY); self.velocity = CGVectorMake(self.velocity.dx, fabs(self.velocity.dy)); }
    if (CRMSoccerCrossesPlayer(previous.y, self.ball.y, radiusY, self.velocity.dy, self.ball.x, self.playerX, self.playerHalfWidth)) {
        CGFloat offset = (self.ball.x - self.playerX) / self.playerHalfWidth;
        CGFloat speed = hypot(self.velocity.dx, self.velocity.dy);
        self.velocity = CGVectorMake(offset * speed * 0.9, -MAX(0.34, speed * (0.9 - fabs(offset) * 0.18)));
        self.ball = CGPointMake(self.ball.x, CRMSoccerContactY - radiusY);
        self.gameBoard.kickRemaining = CRMSoccerKickDuration;
        self.gameBoard.kickOffset = self.ball.x - self.playerX;
    }
    for (NSInteger index = 0; index < self.bricks.count; index++) {
        if (!self.bricks[index].boolValue) continue;
        CGRect brick = [self brickRectAtRow:index / CRMSoccerBrickColumns column:index % CRMSoccerBrickColumns];
        CGRect ballRect = CGRectMake(self.ball.x - radius, self.ball.y - radiusY, radius * 2, radiusY * 2);
        if (!CGRectIntersectsRect(brick, ballRect)) continue;
        self.bricks[index] = @NO; self.destroyed++;
        CGFloat horizontalHit = (self.ball.x - CGRectGetMidX(brick)) / (brick.size.width / 2);
        if (previous.x + radius <= CGRectGetMinX(brick) || previous.x - radius >= CGRectGetMaxX(brick)) {
            self.velocity = CGVectorMake(-self.velocity.dx + horizontalHit * 0.08, self.velocity.dy);
        } else {
            self.velocity = CGVectorMake(self.velocity.dx + horizontalHit * 0.12, -self.velocity.dy);
        }
        break;
    }
    if (self.destroyed == self.brickTarget) {
        self.gameOver = YES; [self pauseGame]; [self refresh];
        if (self.level < 5) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:@"第 %ld 关完成", (long)self.level]
                                                                           message:@"下一关盒子更多、球速更快，接球范围也会缩小。"
                                                                    preferredStyle:UIAlertControllerStyleAlert];
            __weak typeof(self) weakSelf = self;
            [alert addAction:[UIAlertAction actionWithTitle:@"进入下一关" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                weakSelf.level++;
                [weakSelf startLevel];
            }]];
            [self presentViewController:alert animated:YES completion:nil];
        } else {
            GameShowMessage(self, @"全部通关", @"太棒了！五个关卡的盒子全部被你击中了。");
        }
        return;
    }
    if (self.ball.y - radiusY > 1) {
        self.gameOver = YES; [self pauseGame]; [self refresh]; GameShowMessage(self, @"足球落地", [NSString stringWithFormat:@"本局击中了 %ld 个盒子。", (long)self.destroyed]); return;
    }
    [self refresh];
}
- (void)refresh {
    self.gameBoard.bricks = [self.bricks copy]; self.gameBoard.ball = self.ball;
    self.gameBoard.playerX = self.playerX; self.gameBoard.playerHalfWidth = self.playerHalfWidth; self.gameBoard.gameOver = self.gameOver;
    [self.gameBoard setNeedsDisplay];
    self.statusLabel.text = self.gameOver ? [NSString stringWithFormat:@"第 %ld 关结束 · 点击重来", (long)self.level] : [NSString stringWithFormat:@"第 %ld 关 · 已击中 %ld / %ld", (long)self.level, (long)self.destroyed, (long)self.brickTarget];
}
@end

#pragma mark - 动物叠叠消

@interface CRMAnimalMatchBoard : UIView {
@public
    CRMAnimalGame game;
}
@property (nonatomic, strong) NSMutableArray<UIButton *> *cardButtons;
@property (nonatomic, strong) NSArray<UIView *> *slots;
@property (nonatomic, strong) UILabel *heading;
@property (nonatomic, strong) UILabel *detail;
@property (nonatomic, strong) UILabel *trayLabel;
@property (nonatomic, strong) UILabel *hint;
@property (nonatomic, strong) UIProgressView *progress;
@property (nonatomic, copy) void (^changed)(void);
@property (nonatomic, assign) BOOL animating;
@property (nonatomic, assign) NSUInteger generation;
- (void)startLevel:(NSInteger)level;
@end

@implementation CRMAnimalMatchBoard

- (instancetype)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        self.backgroundColor = GameColor(0xE8EFE6);
        self.heading = GameLabel(@"动物叠叠消", 22, UIFontWeightBold, GameColor(0x294B46));
        self.detail = GameLabel(@"", 12, UIFontWeightMedium, GameColor(0x71867B));
        self.trayLabel = GameLabel(@"", 13, UIFontWeightSemibold, GameColor(0x355B54));
        self.hint = GameLabel(@"点亮色卡片 · 三张相同即可消除", 11, UIFontWeightMedium, GameColor(0x71867B));
        self.hint.textAlignment = NSTextAlignmentCenter;
        self.progress = [[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleDefault];
        self.progress.progressTintColor = GameColor(0x6D998A);
        self.progress.trackTintColor = GameColor(0xD5E1D5);
        for (UIView *view in @[self.heading, self.detail, self.trayLabel, self.hint, self.progress]) [self addSubview:view];
        NSMutableArray *slots = [NSMutableArray array];
        for (NSInteger i = 0; i < CRMAnimalSlots; i++) {
            UIView *slot = [[UIView alloc] init];
            slot.backgroundColor = GameColor(0xD5E1D5);
            slot.layer.cornerRadius = 10;
            slot.layer.borderWidth = 1;
            slot.layer.borderColor = GameColor(0xC4D4C8).CGColor;
            [self addSubview:slot];
            [slots addObject:slot];
        }
        self.slots = slots;
        self.cardButtons = [NSMutableArray array];
    }
    return self;
}

- (void)startLevel:(NSInteger)level {
    self.generation++;
    self.animating = NO;
    for (UIButton *button in self.cardButtons) [button removeFromSuperview];
    [self.cardButtons removeAllObjects];
    CRMAnimalStart(&game, (int)level, arc4random());
    NSArray *animals = @[@"🐑", @"🐱", @"🐶", @"🦊", @"🐰", @"🐼", @"🐸", @"🐻"];
    NSArray *names = @[@"绵羊", @"小猫", @"小狗", @"狐狸", @"兔子", @"熊猫", @"青蛙", @"小熊"];
    for (int i = 0; i < game.count; i++) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.tag = i;
        button.layer.cornerRadius = 9;
        button.layer.borderWidth = 1.5;
        button.layer.shadowColor = GameColor(0x355B54).CGColor;
        button.layer.shadowOffset = CGSizeMake(0, 3);
        button.layer.shadowRadius = 0;
        button.layer.shadowOpacity = 0.20;
        button.adjustsImageWhenHighlighted = NO;
        [button setTitle:animals[game.cards[i].kind] forState:UIControlStateNormal];
        button.accessibilityLabel = names[game.cards[i].kind];
        [button addTarget:self action:@selector(selectCard:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:button];
        [self.cardButtons addObject:button];
    }
    [self refresh];
    [self setNeedsLayout];
    if (self.changed) self.changed();
}

- (void)layoutSubviews {
    [super layoutSubviews];
    CGFloat width = self.bounds.size.width, height = self.bounds.size.height;
    self.heading.frame = CGRectMake(16, 14, width - 32, 28);
    self.detail.frame = CGRectMake(16, 45, width - 32, 20);
    self.progress.frame = CGRectMake(16, 72, width - 32, 3);
    CGFloat slotSize = MAX(1, (width - 32 - 25) / CRMAnimalSlots);
    CGFloat slotY = height - slotSize - 32;
    self.trayLabel.frame = CGRectMake(16, slotY - 28, width - 32, 22);
    self.hint.frame = CGRectMake(8, height - 25, width - 16, 19);
    for (NSInteger i = 0; i < self.slots.count; i++) {
        self.slots[i].frame = CGRectMake(16 + i * (slotSize + 5), slotY, slotSize, slotSize);
    }
    [self layoutCards];
}

- (void)layoutCards {
    if (!game.count) return;
    CGFloat maxX = 0, maxY = 0;
    for (int i = 0; i < game.count; i++) {
        maxX = MAX(maxX, game.cards[i].x + 1);
        maxY = MAX(maxY, game.cards[i].y + 1);
    }
    CGFloat availableHeight = MAX(1, self.trayLabel.frame.origin.y - 100);
    CGFloat size = MIN(72, MIN((self.bounds.size.width - 32) / maxX, availableHeight / maxY));
    CGFloat originX = (self.bounds.size.width - maxX * size) / 2;
    CGFloat originY = 88 + (availableHeight - maxY * size) / 2;
    for (int i = 0; i < game.count; i++) {
        UIButton *button = self.cardButtons[i];
        if (!game.cards[i].removed) {
            button.frame = CGRectMake(originX + game.cards[i].x * size, originY + game.cards[i].y * size, size, size);
            button.titleLabel.font = [UIFont systemFontOfSize:size * 0.57];
        }
    }
    for (int i = 0; i < game.trayCount; i++) {
        UIButton *button = self.cardButtons[game.tray[i]];
        button.frame = self.slots[i].frame;
        button.titleLabel.font = [UIFont systemFontOfSize:button.bounds.size.width * 0.60];
        [self bringSubviewToFront:button];
    }
}

- (void)refresh {
    self.detail.text = [NSString stringWithFormat:@"%@ · 剩余 %d / %d 张", game.level == 1 ? @"第一关 · 轻松入门" : @"第二关 · 森林挑战", game.remaining, game.count];
    self.trayLabel.text = [NSString stringWithFormat:@"收集盒  %d / 6%@", game.trayCount, game.trayCount >= 5 ? @"   · 小心，快满啦" : @"   · 三张一组"];
    self.trayLabel.textColor = game.trayCount >= 5 ? GameColor(0xAC684F) : GameColor(0x355B54);
    self.progress.progress = (float)(game.count - game.remaining - game.trayCount) / game.count;
    self.hint.text = game.outcome == CRMAnimalWon ? @"全部消除！小动物们都回家啦" : game.outcome == CRMAnimalLost ? @"收集盒满了，点击重来再挑战一次" : @"点亮色卡片 · 三张相同即可消除";
    for (int i = 0; i < game.count; i++) {
        UIButton *button = self.cardButtons[i];
        BOOL inTray = NO;
        for (int j = 0; j < game.trayCount; j++) if (game.tray[j] == i) inTray = YES;
        BOOL open = CRMAnimalIsOpen(&game, i);
        button.hidden = game.cards[i].removed && !inTray;
        button.backgroundColor = open || inTray ? GameColor(0xFFFDF6) : GameColor(0xADC0AE);
        button.layer.borderColor = (open || inTray ? GameColor(0xD8DDCD) : GameColor(0x9FB29F)).CGColor;
        button.titleLabel.alpha = open || inTray ? 1 : 0.38;
        // 被盖住的卡仍拦截触摸，避免点击穿透到更深层卡片。
        button.userInteractionEnabled = !inTray;
        button.accessibilityTraits = UIAccessibilityTraitButton | (open && !self.animating && game.outcome == CRMAnimalPlaying ? 0 : UIAccessibilityTraitNotEnabled);
        button.accessibilityHint = inTray ? @"已在收集盒中" : open ? @"轻点收集" : @"需先移走上方卡片";
    }
}

- (void)selectCard:(UIButton *)sender {
    if (self.animating || !CRMAnimalSelect(&game, (int)sender.tag)) return;
    self.animating = YES;
    NSUInteger generation = self.generation;
    [self refresh];
    UIImpactFeedbackGenerator *feedback = [[UIImpactFeedbackGenerator alloc] initWithStyle:UIImpactFeedbackStyleLight];
    [feedback impactOccurred];
    NSTimeInterval duration = UIAccessibilityIsReduceMotionEnabled() ? 0 : 0.22;
    __weak typeof(self) weakSelf = self;
    [UIView animateWithDuration:duration animations:^{
        [weakSelf layoutCards];
    } completion:^(BOOL finished) {
        typeof(self) self = weakSelf;
        if (!self || generation != self.generation) return;
        NSMutableArray<UIButton *> *previous = [NSMutableArray array];
        for (int i = 0; i < self->game.trayCount; i++) [previous addObject:self.cardButtons[self->game.tray[i]]];
        int cleared = CRMAnimalSettle(&self->game);
        NSMutableArray<UIButton *> *removed = [previous mutableCopy];
        for (int i = 0; i < self->game.trayCount; i++) [removed removeObject:self.cardButtons[self->game.tray[i]]];
        [UIView animateWithDuration:cleared ? duration : 0 animations:^{
            for (UIButton *button in removed) {
                button.alpha = 0;
                button.transform = CGAffineTransformMakeScale(0.6, 0.6);
            }
        } completion:^(BOOL finishedClearing) {
            typeof(self) self = weakSelf;
            if (!self || generation != self.generation) return;
            for (UIButton *button in removed) { button.transform = CGAffineTransformIdentity; button.alpha = 1; }
            self.animating = NO;
            [self refresh];
            [self setNeedsLayout];
            if (self.changed) self.changed();
        }];
    }];
}
@end

@interface CRMAnimalMatchController : CRMGameController
@property (nonatomic, strong) CRMAnimalMatchBoard *animalBoard;
@end

@implementation CRMAnimalMatchController
- (void)viewDidLoad {
    [super viewDidLoad];
    self.animalBoard = [[CRMAnimalMatchBoard alloc] init];
    [self setupCompactLayoutWithBoard:self.animalBoard aspect:1.55 maximumWidth:410];
    self.actions.axis = UILayoutConstraintAxisHorizontal;
    self.actions.distribution = UIStackViewDistributionEqualSpacing;
    for (NSArray *item in @[@[@"规则", NSStringFromSelector(@selector(showRules))], @[@"重来", NSStringFromSelector(@selector(restartLevel))], @[@"关卡", NSStringFromSelector(@selector(chooseLevel))]]) {
        UIButton *button = GameCircleButton(item[0], 62, 15);
        [button addTarget:self action:NSSelectorFromString(item[1]) forControlEvents:UIControlEventTouchUpInside];
        [self.actions addArrangedSubview:button];
    }
    __weak typeof(self) weakSelf = self;
    self.animalBoard.changed = ^{ [weakSelf updateGameStatus]; };
    [self.animalBoard startLevel:1];
}

- (void)showRules {
    GameShowMessage(self, @"动物叠叠消", @"只能选择未被上层遮挡的亮色卡片。\n\n收集盒只有 6 格，三张相同动物自动消除。第六张可以消除时继续，否则失败。\n\n清空所有卡片即可通关。第一关练手，第二关挑战！");
}

- (void)restartLevel {
    [self.animalBoard startLevel:self.animalBoard->game.level];
}

- (void)chooseLevel {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"选择关卡" message:@"第一关：18 张 · 3 种动物 · 错位双层\n第二关：90 张 · 8 种动物 · 六层不规则主堆＋双侧牌堆" preferredStyle:UIAlertControllerStyleAlert];
    __weak typeof(self) weakSelf = self;
    [alert addAction:[UIAlertAction actionWithTitle:@"第一关 · 轻松入门" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) { [weakSelf.animalBoard startLevel:1]; }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"第二关 · 森林挑战" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) { [weakSelf.animalBoard startLevel:2]; }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)updateGameStatus {
    CRMAnimalGame *state = &self.animalBoard->game;
    self.statusLabel.text = [NSString stringWithFormat:@"动物叠叠消 · 第 %d 关", state->level];
    // 动画完成时用户可能已经返回，避免从离屏控制器弹出结果。
    if (state->outcome == CRMAnimalPlaying || !self.view.window || self.presentedViewController) return;
    BOOL won = state->outcome == CRMAnimalWon;
    BOOL next = won && state->level == 1;
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:won ? @"通关啦！" : @"盒子装满啦" message:next ? @"热身完成，下一关有更多动物和更深的堆叠。" : won ? @"两关挑战完成！再来一局会生成新的牌局。" : @"六格内没有凑齐三张，换个收集顺序再试试。" preferredStyle:UIAlertControllerStyleAlert];
    __weak typeof(self) weakSelf = self;
    [alert addAction:[UIAlertAction actionWithTitle:next ? @"挑战第二关" : @"再来一局" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        if (next) [weakSelf.animalBoard startLevel:2];
        else [weakSelf restartLevel];
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"留在棋盘" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}
@end

#pragma mark - 贪吃蛇

@interface CRMSnakeBoard : UIView {
@public
    CRMSnakeGame game;
}
@property (nonatomic, copy) NSString *message;
@end

@implementation CRMSnakeBoard
- (void)drawRect:(CGRect)rect {
    [GameColor(0x294B46) setFill];
    UIRectFill(self.bounds);
    [@"🐍  森林漫游" drawInRect:CGRectMake(16, 12, self.bounds.size.width - 32, 24)
                  withAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:16 weight:UIFontWeightSemibold], NSForegroundColorAttributeName: GameColor(0xE5EEDB)}];
    CGFloat cell = MIN((self.bounds.size.width - 20) / CRMSnakeColumns, (self.bounds.size.height - 52) / CRMSnakeRows);
    CGFloat left = (self.bounds.size.width - CRMSnakeColumns * cell) / 2;
    CGFloat top = 42 + (self.bounds.size.height - 52 - CRMSnakeRows * cell) / 2;
    for (int row = 0; row < CRMSnakeRows; row++) {
        for (int column = 0; column < CRMSnakeColumns; column++) {
            [(row + column) % 2 ? GameColor(0x30564E) : GameColor(0x335A52) setFill];
            CGRect tile = CGRectMake(left + column * cell, top + row * cell, cell, cell);
            [[UIBezierPath bezierPathWithRoundedRect:CGRectInset(tile, 0.8, 0.8) cornerRadius:cell * 0.15] fill];
        }
    }
    if (game.food >= 0) {
        CGFloat x = left + (game.food % CRMSnakeColumns + 0.5) * cell;
        CGFloat y = top + (game.food / CRMSnakeColumns + 0.5) * cell;
        [GameColor(0xF2A080) setFill];
        [[UIBezierPath bezierPathWithOvalInRect:CGRectMake(x - cell * 0.33, y - cell * 0.28, cell * 0.66, cell * 0.61)] fill];
        [GameColor(0xC9DE92) setFill];
        [[UIBezierPath bezierPathWithOvalInRect:CGRectMake(x, y - cell * 0.43, cell * 0.26, cell * 0.16)] fill];
    }
    // 用圆角连接段画出连续身体，保留清晰的棋盘格定位。
    for (int i = game.length - 1; i >= 0; i--) {
        CGPoint center = CGPointMake(left + (game.body[i] % CRMSnakeColumns + 0.5) * cell,
                                     top + (game.body[i] / CRMSnakeColumns + 0.5) * cell);
        UIColor *color = i == 0 ? GameColor(0xE3EDAC) : i % 2 ? GameColor(0xA6CF9A) : GameColor(0xB9DCA1);
        [color setFill]; [color setStroke];
        if (i > 0) {
            CGPoint next = CGPointMake(left + (game.body[i - 1] % CRMSnakeColumns + 0.5) * cell,
                                      top + (game.body[i - 1] / CRMSnakeColumns + 0.5) * cell);
            UIBezierPath *link = [UIBezierPath bezierPath];
            [link moveToPoint:center]; [link addLineToPoint:next];
            link.lineWidth = cell * 0.67;
            link.lineCapStyle = kCGLineCapRound;
            [link stroke];
        }
        [[UIBezierPath bezierPathWithOvalInRect:CGRectMake(center.x - cell * 0.4, center.y - cell * 0.4, cell * 0.8, cell * 0.8)] fill];
        if (i == 0) {
            const int dx[] = {0, 1, 0, -1}, dy[] = {-1, 0, 1, 0};
            [GameColor(0x294B46) setFill];
            for (int side = -1; side <= 1; side += 2) {
                CGFloat x = center.x + cell * (0.16 * dx[game.direction] + side * 0.19 * dy[game.direction]);
                CGFloat y = center.y + cell * (0.16 * dy[game.direction] + side * 0.19 * dx[game.direction]);
                [[UIBezierPath bezierPathWithOvalInRect:CGRectMake(x - cell * 0.065, y - cell * 0.065, cell * 0.13, cell * 0.13)] fill];
            }
        }
    }
    if (self.message.length) {
        CGRect panel = CGRectMake(12, (self.bounds.size.height - 94) / 2, self.bounds.size.width - 24, 94);
        [[GameColor(0xF7F7F2) colorWithAlphaComponent:0.96] setFill];
        [[UIBezierPath bezierPathWithRoundedRect:panel cornerRadius:16] fill];
        NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
        style.alignment = NSTextAlignmentCenter;
        style.lineSpacing = 8;
        [self.message drawInRect:CGRectInset(panel, 6, 17) withAttributes:@{NSFontAttributeName: [UIFont systemFontOfSize:14 weight:UIFontWeightSemibold], NSForegroundColorAttributeName: GameColor(0x355B54), NSParagraphStyleAttributeName: style}];
    }
}
@end

@interface CRMSnakeController : CRMGameController
@property (nonatomic, strong) CRMSnakeBoard *snakeBoard;
@property (nonatomic, strong) NSTimer *snakeTimer;
@property (nonatomic, strong) UIButton *pauseButton;
@property (nonatomic, assign) BOOL started;
@property (nonatomic, assign) NSInteger bestScore;
@end

@implementation CRMSnakeController
- (void)viewDidLoad {
    [super viewDidLoad];
    self.snakeBoard = [[CRMSnakeBoard alloc] init];
    [self setupCompactLayoutWithBoard:self.snakeBoard aspect:1.48 maximumWidth:380];
    self.actions.axis = UILayoutConstraintAxisHorizontal;
    self.actions.alignment = UIStackViewAlignmentCenter;
    self.actions.distribution = UIStackViewDistributionEqualSpacing;
    UIButton *restart = GameCircleButton(@"重来", 52, 14);
    [restart addTarget:self action:@selector(restartSnake) forControlEvents:UIControlEventTouchUpInside];
    [self.actions addArrangedSubview:restart];
    UIView *pad = [[UIView alloc] init];
    pad.backgroundColor = GameColor(0xE5EEEA);
    pad.layer.cornerRadius = 74;
    [pad.widthAnchor constraintEqualToConstant:148].active = YES;
    [pad.heightAnchor constraintEqualToConstant:148].active = YES;
    [self.actions addArrangedSubview:pad];
    NSArray *titles = @[@"▲", @"▶", @"▼", @"◀"];
    NSArray *names = @[@"向上", @"向右", @"向下", @"向左"];
    const CGFloat positions[4][2] = {{52, 0}, {104, 52}, {52, 104}, {0, 52}};
    for (NSInteger i = 0; i < 4; i++) {
        UIButton *button = GameCircleButton(titles[i], 44, 18);
        button.tag = i;
        button.accessibilityLabel = names[i];
        // 按下立即转向；保持方向会自动前进，无需长按重复发送。
        [button addTarget:self action:@selector(turnSnake:) forControlEvents:UIControlEventTouchDown];
        [pad addSubview:button];
        [button.leadingAnchor constraintEqualToAnchor:pad.leadingAnchor constant:positions[i][0]].active = YES;
        [button.topAnchor constraintEqualToAnchor:pad.topAnchor constant:positions[i][1]].active = YES;
        UISwipeGestureRecognizer *swipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(swipeSnake:)];
        const UISwipeGestureRecognizerDirection directions[] = {UISwipeGestureRecognizerDirectionUp, UISwipeGestureRecognizerDirectionRight, UISwipeGestureRecognizerDirectionDown, UISwipeGestureRecognizerDirectionLeft};
        swipe.direction = directions[i];
        [self.snakeBoard addGestureRecognizer:swipe];
    }
    UILabel *icon = GameLabel(@"🐍", 26, UIFontWeightRegular, GameColor(0x355B54));
    icon.frame = CGRectMake(52, 52, 44, 44);
    icon.textAlignment = NSTextAlignmentCenter;
    [pad addSubview:icon];
    self.pauseButton = GameCircleButton(@"开始", 52, 14);
    [self.pauseButton addTarget:self action:@selector(toggleSnake) forControlEvents:UIControlEventTouchUpInside];
    [self.actions addArrangedSubview:self.pauseButton];
    self.bestScore = [[NSUserDefaults standardUserDefaults] integerForKey:@"CRMGameSnakeBestScore"];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(pauseSnake) name:UIApplicationWillResignActiveNotification object:nil];
    [self restartSnake];
}

- (void)viewWillDisappear:(BOOL)animated { [super viewWillDisappear:animated]; [self pauseSnake]; }
- (void)dealloc { [self.snakeTimer invalidate]; [[NSNotificationCenter defaultCenter] removeObserver:self]; }

- (void)restartSnake {
    [self.snakeTimer invalidate]; self.snakeTimer = nil;
    self.started = NO;
    CRMSnakeStart(&self.snakeBoard->game, arc4random());
    [self refreshSnake];
}

- (NSTimeInterval)snakeInterval {
    return MAX(0.09, 0.28 - ((self.snakeBoard->game.length - 4) / 3) * 0.02);
}

- (void)startSnakeTimer {
    if (self.snakeTimer || !self.view.window || UIApplication.sharedApplication.applicationState != UIApplicationStateActive || self.snakeBoard->game.outcome != CRMSnakePlaying) return;
    self.started = YES;
    __weak typeof(self) weakSelf = self;
    self.snakeTimer = [NSTimer timerWithTimeInterval:[self snakeInterval] repeats:YES block:^(NSTimer *timer) { [weakSelf tickSnake]; }];
    self.snakeTimer.tolerance = 0.008;
    [[NSRunLoop mainRunLoop] addTimer:self.snakeTimer forMode:NSRunLoopCommonModes];
    [self refreshSnake];
}

- (void)pauseSnake {
    [self.snakeTimer invalidate]; self.snakeTimer = nil;
    self.snakeBoard->game.turnCount = 0;
    [self refreshSnake];
}

- (void)toggleSnake {
    if (self.snakeBoard->game.outcome != CRMSnakePlaying) { [self restartSnake]; return; }
    if (self.snakeTimer) [self pauseSnake];
    else [self startSnakeTimer];
}

- (void)turnSnake:(UIButton *)sender {
    if (self.snakeTimer) CRMSnakeTurn(&self.snakeBoard->game, (int)sender.tag);
}

- (void)swipeSnake:(UISwipeGestureRecognizer *)swipe {
    if (!self.snakeTimer) return;
    int direction = swipe.direction == UISwipeGestureRecognizerDirectionUp ? CRMSnakeUp : swipe.direction == UISwipeGestureRecognizerDirectionDown ? CRMSnakeDown : swipe.direction == UISwipeGestureRecognizerDirectionLeft ? CRMSnakeLeft : CRMSnakeRight;
    CRMSnakeTurn(&self.snakeBoard->game, direction);
}

- (void)tickSnake {
    CRMSnakeStep(&self.snakeBoard->game);
    NSInteger score = self.snakeBoard->game.length - 4;
    if (score > self.bestScore) {
        self.bestScore = score;
        [[NSUserDefaults standardUserDefaults] setInteger:score forKey:@"CRMGameSnakeBestScore"];
    }
    if (self.snakeBoard->game.outcome != CRMSnakePlaying) {
        [self pauseSnake];
    } else if (fabs(self.snakeTimer.timeInterval - [self snakeInterval]) > 0.001) {
        [self.snakeTimer invalidate]; self.snakeTimer = nil;
        [self startSnakeTimer];
    }
    [self refreshSnake];
}

- (void)refreshSnake {
    CRMSnakeGame *state = &self.snakeBoard->game;
    self.statusLabel.text = [NSString stringWithFormat:@"贪吃蛇 · %d 分 · 最佳 %ld\n速度 %d 级", state->length - 4, (long)self.bestScore, MIN(11, 1 + (state->length - 4) / 3)];
    NSString *message = nil;
    if (state->outcome == CRMSnakeLost) message = @"撞到了！再来一局吧\n点击重来，重新出发";
    else if (state->outcome == CRMSnakeWon) message = @"满盘通关！\n森林小蛇已经长大啦";
    else if (!self.started) message = @"准备出发 · 点击开始\n方向键或滑动棋盘控制";
    else if (!self.snakeTimer) message = @"已暂停\n点击继续，回到森林";
    self.snakeBoard.message = message;
    [self.pauseButton setTitle:state->outcome != CRMSnakePlaying ? @"新局" : self.snakeTimer ? @"暂停" : self.started ? @"继续" : @"开始" forState:UIControlStateNormal];
    [self.snakeBoard setNeedsDisplay];
}
@end

#pragma mark - 游戏集合入口

@interface CRMGameCenterViewController ()
@property (nonatomic, strong) UIScrollView *scrollView;
@end

@implementation CRMGameCenterViewController

- (instancetype)init {
    self = [super init];
    if (self) {
        self.hideNavigationBar = YES;
        self.hideTabbar = YES;
        self.hidesBottomBarWhenPushed = YES;
    }
    return self;
}

+ (NSDictionary *)ss_constantParams {
    return @{@"hideNavigationBar": @(YES)};
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = GameColor(0xF7F7F2);
    self.scrollView = [[UIScrollView alloc] init];
    self.scrollView.translatesAutoresizingMaskIntoConstraints = NO;
    self.scrollView.alwaysBounceVertical = YES;
    [self.view addSubview:self.scrollView];
    [NSLayoutConstraint activateConstraints:@[
        [self.scrollView.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor],
        [self.scrollView.leadingAnchor constraintEqualToAnchor:self.view.leadingAnchor],
        [self.scrollView.trailingAnchor constraintEqualToAnchor:self.view.trailingAnchor],
        [self.scrollView.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor]
    ]];

    UIStackView *content = [[UIStackView alloc] init];
    content.axis = UILayoutConstraintAxisVertical;
    content.spacing = 18;
    content.translatesAutoresizingMaskIntoConstraints = NO;
    [self.scrollView addSubview:content];
    [NSLayoutConstraint activateConstraints:@[
        [content.topAnchor constraintEqualToAnchor:self.scrollView.topAnchor constant:20],
        [content.leadingAnchor constraintEqualToAnchor:self.scrollView.leadingAnchor constant:20],
        [content.trailingAnchor constraintEqualToAnchor:self.scrollView.trailingAnchor constant:-20],
        [content.bottomAnchor constraintEqualToAnchor:self.scrollView.bottomAnchor constant:-30],
        [content.widthAnchor constraintEqualToAnchor:self.scrollView.widthAnchor constant:-40]
    ]];

    UIStackView *topRow = [[UIStackView alloc] init];
    topRow.axis = UILayoutConstraintAxisHorizontal;
    topRow.alignment = UIStackViewAlignmentCenter;
    topRow.spacing = 12;
    [content addArrangedSubview:topRow];
    [topRow.widthAnchor constraintEqualToAnchor:content.widthAnchor].active = YES;
    UIButton *back = GameButton(@"‹", GameColor(0xE9ECE8), GameColor(0x243B39));
    back.titleLabel.font = [UIFont systemFontOfSize:29 weight:UIFontWeightRegular];
    [back.widthAnchor constraintEqualToConstant:46].active = YES;
    [back.heightAnchor constraintEqualToConstant:46].active = YES;
    [back addTarget:self action:@selector(goBack) forControlEvents:UIControlEventTouchUpInside];
    [topRow addArrangedSubview:back];
    UILabel *eyebrow = GameLabel(@"PLAY & RELAX", 12, UIFontWeightBold, GameColor(0x6D998A));
    [topRow addArrangedSubview:eyebrow];
    UILabel *title = GameLabel(@"小游戏乐园", 32, UIFontWeightBold, GameColor(0x243B39));
    [content addArrangedSubview:title];
    content.spacing = 11;
    UILabel *intro = GameLabel(@"给忙碌的日常，留一点轻松时刻。", 15, UIFontWeightRegular, GameColor(0x798986));
    [content addArrangedSubview:intro];
    [content setCustomSpacing:23 afterView:intro];

    UIView *hero = [[UIView alloc] init];
    hero.backgroundColor = GameColor(0x355D55);
    hero.layer.cornerRadius = 24;
    [content addArrangedSubview:hero];
    [hero.widthAnchor constraintEqualToAnchor:content.widthAnchor].active = YES;
    [hero.heightAnchor constraintEqualToConstant:165].active = YES;
    UILabel *heroIcon = GameLabel(@"✦", 74, UIFontWeightLight, GameColor(0xE8CFA2));
    heroIcon.translatesAutoresizingMaskIntoConstraints = NO;
    [hero addSubview:heroIcon];
    UILabel *heroTitle = GameLabel(@"随时开玩", 24, UIFontWeightBold, UIColor.whiteColor);
    heroTitle.translatesAutoresizingMaskIntoConstraints = NO;
    [hero addSubview:heroTitle];
    UILabel *heroDetail = GameLabel(@"八款经典小游戏\n从一局开始，放松一下。", 14, UIFontWeightRegular, GameColor(0xD8E6DF));
    heroDetail.translatesAutoresizingMaskIntoConstraints = NO;
    [hero addSubview:heroDetail];
    [NSLayoutConstraint activateConstraints:@[
        [heroTitle.leadingAnchor constraintEqualToAnchor:hero.leadingAnchor constant:22],
        [heroTitle.topAnchor constraintEqualToAnchor:hero.topAnchor constant:30],
        [heroDetail.leadingAnchor constraintEqualToAnchor:heroTitle.leadingAnchor],
        [heroDetail.topAnchor constraintEqualToAnchor:heroTitle.bottomAnchor constant:10],
        [heroIcon.trailingAnchor constraintEqualToAnchor:hero.trailingAnchor constant:-24],
        [heroIcon.centerYAnchor constraintEqualToAnchor:hero.centerYAnchor]
    ]];

    UILabel *section = GameLabel(@"挑一个喜欢的", 20, UIFontWeightBold, GameColor(0x243B39));
    [content addArrangedSubview:section];
    [content setCustomSpacing:15 afterView:hero];
    [content setCustomSpacing:15 afterView:section];

    NSArray<NSArray<NSString *> *> *items = @[
        @[@"五子棋", @"双人对弈 · 连成五子", @"●", @"DDECE3"],
        @[@"数字拼图", @"移动方块 · 排好顺序", @"▦", @"F3E9D9"],
        @[@"数独", @"静心思考 · 填满九宫", @"9", @"E8E5F2"],
        @[@"俄罗斯方块", @"旋转下落 · 消除整行", @"▣", @"E7EDF2"],
        @[@"三车道赛车", @"左右换道 · 躲避障碍", @"🏎", @"F5E4D8"],
        @[@"足球打砖块", @"长按移动 · 反弹射门", @"⚽", @"DDECF2"],
        @[@"动物叠叠消", @"羊了个羊玩法 · 两关挑战", @"🐑", @"E3ECD9"],
        @[@"贪吃蛇", @"收集果实 · 灵活转弯", @"🐍", @"DBEBDD"]
    ];
    for (NSInteger row = 0; row < (items.count + 1) / 2; row++) {
        UIStackView *cards = [[UIStackView alloc] init];
        cards.axis = UILayoutConstraintAxisHorizontal;
        cards.distribution = UIStackViewDistributionFillEqually;
        cards.spacing = 12;
        [content addArrangedSubview:cards];
        [cards.widthAnchor constraintEqualToAnchor:content.widthAnchor].active = YES;
        [cards.heightAnchor constraintEqualToConstant:182].active = YES;
        for (NSInteger column = 0; column < 2; column++) {
            NSInteger index = row * 2 + column;
            [cards addArrangedSubview:index < items.count ? [self cardWithInfo:items[index] index:index] : [[UIView alloc] init]];
        }
    }
    [content addArrangedSubview:GameLabel(@"收藏图鉴", 20, UIFontWeightBold, GameColor(0x243B39))];
    UIButton *atlas = GameButton(@"数码宝贝图集  ›\n千余位伙伴 · 搜索与等级筛选", GameColor(0x355D55), UIColor.whiteColor);
    atlas.titleLabel.numberOfLines = 2;
    atlas.titleLabel.font = [UIFont systemFontOfSize:18 weight:UIFontWeightSemibold];
    atlas.titleLabel.textAlignment = NSTextAlignmentLeft;
    atlas.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    atlas.contentEdgeInsets = UIEdgeInsetsMake(16, 22, 16, 22);
    [atlas.heightAnchor constraintGreaterThanOrEqualToConstant:94].active = YES;
    [atlas addTarget:self action:@selector(openAtlas) forControlEvents:UIControlEventTouchUpInside];
    [content addArrangedSubview:atlas];
    UILabel *footer = GameLabel(@"每一局，都是自己的节奏。", 13, UIFontWeightRegular, GameColor(0x9AA8A3));
    footer.textAlignment = NSTextAlignmentCenter;
    [content addArrangedSubview:footer];
}

- (UIView *)cardWithInfo:(NSArray<NSString *> *)info index:(NSInteger)index {
    UIButton *card = [UIButton buttonWithType:UIButtonTypeCustom];
    unsigned int hex = 0;
    [[NSScanner scannerWithString:info[3]] scanHexInt:&hex];
    card.backgroundColor = GameColor(hex);
    card.layer.cornerRadius = 22;
    card.tag = index;
    [card addTarget:self action:@selector(openGame:) forControlEvents:UIControlEventTouchUpInside];
    UILabel *icon = GameLabel(info[2], 34, UIFontWeightBold, GameColor(0x355D55));
    icon.translatesAutoresizingMaskIntoConstraints = NO;
    [card addSubview:icon];
    UILabel *name = GameLabel(info[0], 19, UIFontWeightBold, GameColor(0x263A3B));
    name.translatesAutoresizingMaskIntoConstraints = NO;
    [card addSubview:name];
    UILabel *detail = GameLabel(info[1], 11, UIFontWeightRegular, GameColor(0x71817B));
    detail.translatesAutoresizingMaskIntoConstraints = NO;
    [card addSubview:detail];
    [NSLayoutConstraint activateConstraints:@[
        [icon.leadingAnchor constraintEqualToAnchor:card.leadingAnchor constant:18],
        [icon.topAnchor constraintEqualToAnchor:card.topAnchor constant:15],
        [name.leadingAnchor constraintEqualToAnchor:icon.leadingAnchor],
        [name.trailingAnchor constraintLessThanOrEqualToAnchor:card.trailingAnchor constant:-8],
        [name.bottomAnchor constraintEqualToAnchor:detail.topAnchor constant:-5],
        [detail.leadingAnchor constraintEqualToAnchor:icon.leadingAnchor],
        [detail.trailingAnchor constraintLessThanOrEqualToAnchor:card.trailingAnchor constant:-8],
        [detail.bottomAnchor constraintEqualToAnchor:card.bottomAnchor constant:-18]
    ]];
    return card;
}

- (void)openGame:(UIButton *)sender {
    UIViewController *controller = nil;
    switch (sender.tag) {
        case 0: controller = [[CRMGomokuController alloc] init]; break;
        case 1: controller = [[CRMPuzzleController alloc] init]; break;
        case 2: controller = [[CRMSudokuController alloc] init]; break;
        case 3: controller = [[CRMTetrisController alloc] init]; break;
        case 4: controller = [[CRMRacingController alloc] init]; break;
        case 5: controller = [[CRMSoccerBreakoutController alloc] init]; break;
        case 6: controller = [[CRMAnimalMatchController alloc] init]; break;
        case 7: controller = [[CRMSnakeController alloc] init]; break;
        default: return;
    }
    [self.navigationController pushViewController:controller animated:YES];
}

- (void)openAtlas {
    [self.navigationController pushViewController:[[CRMDigimonAtlasViewController alloc] init] animated:YES];
}

@end
