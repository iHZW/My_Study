//
//  SettingViewController.m
//  My_Study
//
//  Created by Zhiwei Han on 2022/6/30.
//  Copyright © 2022 HZW. All rights reserved.
//``

#import "ActionModel.h"
#import "AlertHead.h"
#import "CommonSelectedConfig.h"
#import "FileSelectManager.h"
#import "LoginViewController.h"
#import "PASIndicatorTableViewCell.h"
#import "PathConstants.h"
#import "PhotoActionSheetUtil.h"
#import "SSZipArchive.h"
#import "SettingViewController.h"
#import "SettingCRMViewController.h"
#import "CRMGameCenterViewController.h"
#import "ZWBaseTableView.h"
#import "ZWColorPickInfoWindow.h"
#import "ZWHttpNetworkData.h"
#import "ZWAppIconManager.h"
#import "zhThemeOperator.h"

/** 导入other城市选择器  */
#import "BRPickerView/BRPickerView.h"
#import "EHAddressCompHelper.h"

// 城市选择界面
#if __has_include(<JFCitySelector/JFCitySelector.h>)
#import <JFCitySelector/JFCitySelector.h>
#else
#import "JFCitySelector.h"
#endif

#import "ZWUserManager.h"

#import "MMShareManager.h"
#import "MMShareView.h"
#import "NSString+Tool.h"
#import "ZWOneKeyTextVC.h"

#pragma mark - 二维码头文件
#import "QQScanZXingViewController.h"
#import "StyleDIY.h"
#import "Global.h"
#import "ZWCommonWebPage.h"
#import "MMPushUtil.h"
#import "My_Study-Swift.h"
#import <UserNotifications/UserNotifications.h>

#define kSectionViewHeight 58
#define ZWNSLog(...) printf("%s\n", [[NSString stringWithFormat:__VA_ARGS__] UTF8String]);

static NSString * const CRMReminderIdentifierPrefix = @"crm.reminder.";
static NSString * const CRMAlarmKitRecordsKey = @"crm.alarmkit.records";
static NSString * const CRMReminderEventIDKey = @"reminder_event_id";
static NSString * const CRMReminderRepeatKey = @"reminder_repeat";

@interface CRMReminderItem : NSObject
@property (nonatomic, copy) NSString *identifier;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, strong) NSDate *date;
@property (nonatomic, assign) BOOL usesAlarmKit;
@property (nonatomic, assign) BOOL repeats;
@property (nonatomic, copy) NSArray<NSString *> *notificationIdentifiers;
@end

@implementation CRMReminderItem
@end

@interface CRMReminderViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>
@property (nonatomic, strong) UITextField *taskField;
@property (nonatomic, strong) UIDatePicker *datePicker;
@property (nonatomic, strong) UIButton *scheduleButton;
@property (nonatomic, strong) UISwitch *repeatSwitch;
@property (nonatomic, strong) UILabel *emptyLabel;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, copy) NSArray<CRMReminderItem *> *reminders;
@property (nonatomic, strong) CRMReminderItem *editingReminder;
@end

@implementation CRMReminderViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"未来提醒";
    self.view.backgroundColor = UIColorFromRGB(0xF4F7F5);
    [self buildReminderInterface];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.datePicker.minimumDate = [NSDate dateWithTimeIntervalSinceNow:60];
    [self reloadPendingReminders];
}

- (void)buildReminderInterface {
    UILabel *hint = [[UILabel alloc] init];
    hint.translatesAutoresizingMaskIntoConstraints = NO;
    if (@available(iOS 26.0, *)) {
        hint.text = @"iOS 26 将使用系统闹钟提醒，可突破静音和专注模式。";
    } else {
        hint.text = @"选择未来的日期和时间，到点后由系统通知提醒你。";
    }
    hint.font = [UIFont systemFontOfSize:13];
    hint.textColor = UIColorFromRGB(0x70827D);
    hint.numberOfLines = 0;
    [self.view addSubview:hint];

    self.taskField = [[UITextField alloc] init];
    self.taskField.translatesAutoresizingMaskIntoConstraints = NO;
    self.taskField.placeholder = @"要提醒我做什么？";
    self.taskField.font = [UIFont systemFontOfSize:16];
    self.taskField.backgroundColor = UIColor.whiteColor;
    self.taskField.layer.cornerRadius = 14;
    self.taskField.layer.borderWidth = 1;
    self.taskField.layer.borderColor = UIColorFromRGB(0xD8E5E0).CGColor;
    self.taskField.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.taskField.returnKeyType = UIReturnKeyDone;
    self.taskField.delegate = self;
    UIView *padding = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 14, 1)];
    self.taskField.leftView = padding;
    self.taskField.leftViewMode = UITextFieldViewModeAlways;
    [self.view addSubview:self.taskField];

    self.datePicker = [[UIDatePicker alloc] init];
    self.datePicker.translatesAutoresizingMaskIntoConstraints = NO;
    self.datePicker.datePickerMode = UIDatePickerModeDateAndTime;
    self.datePicker.locale = [NSLocale localeWithLocaleIdentifier:@"zh_CN"];
    self.datePicker.minimumDate = [NSDate dateWithTimeIntervalSinceNow:60];
    self.datePicker.maximumDate = [[NSCalendar currentCalendar] dateByAddingUnit:NSCalendarUnitYear value:5 toDate:NSDate.date options:0];
    self.datePicker.date = [NSDate dateWithTimeIntervalSinceNow:3600];
    if (@available(iOS 13.4, *)) self.datePicker.preferredDatePickerStyle = UIDatePickerStyleWheels;
    [self.view addSubview:self.datePicker];

    UIView *repeatContainer = [[UIView alloc] init];
    repeatContainer.translatesAutoresizingMaskIntoConstraints = NO;
    repeatContainer.backgroundColor = UIColor.whiteColor;
    repeatContainer.layer.cornerRadius = 12;
    [self.view addSubview:repeatContainer];

    UILabel *repeatLabel = [[UILabel alloc] init];
    repeatLabel.translatesAutoresizingMaskIntoConstraints = NO;
    repeatLabel.font = [UIFont systemFontOfSize:15 weight:UIFontWeightMedium];
    repeatLabel.textColor = UIColorFromRGB(0x294B46);
    repeatLabel.text = @"未查看时重复提醒";
    [repeatContainer addSubview:repeatLabel];

    self.repeatSwitch = [[UISwitch alloc] init];
    self.repeatSwitch.translatesAutoresizingMaskIntoConstraints = NO;
    self.repeatSwitch.on = NO;
    self.repeatSwitch.onTintColor = UIColorFromRGB(0x315F57);
    [repeatContainer addSubview:self.repeatSwitch];

    if (@available(iOS 26.0, *)) {
        repeatLabel.text = @"系统闹钟会持续响铃";
        self.repeatSwitch.hidden = YES;
    }

    self.scheduleButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.scheduleButton.translatesAutoresizingMaskIntoConstraints = NO;
    self.scheduleButton.backgroundColor = UIColorFromRGB(0x315F57);
    self.scheduleButton.layer.cornerRadius = 14;
    self.scheduleButton.titleLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightSemibold];
    [self.scheduleButton setTitle:@"安排提醒" forState:UIControlStateNormal];
    [self.scheduleButton setTitleColor:UIColor.whiteColor forState:UIControlStateNormal];
    [self.scheduleButton addTarget:self action:@selector(scheduleReminder) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.scheduleButton];

    UILabel *listTitle = [[UILabel alloc] init];
    listTitle.translatesAutoresizingMaskIntoConstraints = NO;
    listTitle.text = @"待提醒";
    listTitle.font = [UIFont systemFontOfSize:18 weight:UIFontWeightBold];
    listTitle.textColor = UIColorFromRGB(0x294B46);
    [self.view addSubview:listTitle];

    UITableViewStyle tableStyle = UITableViewStyleGrouped;
    if (@available(iOS 13.0, *)) tableStyle = UITableViewStyleInsetGrouped;
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:tableStyle];
    self.tableView.translatesAutoresizingMaskIntoConstraints = NO;
    self.tableView.backgroundColor = UIColor.clearColor;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.rowHeight = 64;
    [self.view addSubview:self.tableView];

    self.emptyLabel = [[UILabel alloc] init];
    self.emptyLabel.text = @"还没有待提醒事项";
    self.emptyLabel.textAlignment = NSTextAlignmentCenter;
    self.emptyLabel.textColor = UIColorFromRGB(0x8A9894);
    self.emptyLabel.font = [UIFont systemFontOfSize:14];
    self.tableView.backgroundView = self.emptyLabel;

    UILayoutGuide *safe = self.view.safeAreaLayoutGuide;
    [NSLayoutConstraint activateConstraints:@[
        [hint.topAnchor constraintEqualToAnchor:safe.topAnchor constant:18],
        [hint.leadingAnchor constraintEqualToAnchor:safe.leadingAnchor constant:20],
        [hint.trailingAnchor constraintEqualToAnchor:safe.trailingAnchor constant:-20],
        [self.taskField.topAnchor constraintEqualToAnchor:hint.bottomAnchor constant:12],
        [self.taskField.leadingAnchor constraintEqualToAnchor:hint.leadingAnchor],
        [self.taskField.trailingAnchor constraintEqualToAnchor:hint.trailingAnchor],
        [self.taskField.heightAnchor constraintEqualToConstant:50],
        [self.datePicker.topAnchor constraintEqualToAnchor:self.taskField.bottomAnchor constant:5],
        [self.datePicker.leadingAnchor constraintEqualToAnchor:hint.leadingAnchor],
        [self.datePicker.trailingAnchor constraintEqualToAnchor:hint.trailingAnchor],
        [self.datePicker.heightAnchor constraintEqualToConstant:150],
        [repeatContainer.topAnchor constraintEqualToAnchor:self.datePicker.bottomAnchor constant:4],
        [repeatContainer.leadingAnchor constraintEqualToAnchor:hint.leadingAnchor],
        [repeatContainer.trailingAnchor constraintEqualToAnchor:hint.trailingAnchor],
        [repeatContainer.heightAnchor constraintEqualToConstant:44],
        [repeatLabel.leadingAnchor constraintEqualToAnchor:repeatContainer.leadingAnchor constant:14],
        [repeatLabel.centerYAnchor constraintEqualToAnchor:repeatContainer.centerYAnchor],
        [self.repeatSwitch.trailingAnchor constraintEqualToAnchor:repeatContainer.trailingAnchor constant:-12],
        [self.repeatSwitch.centerYAnchor constraintEqualToAnchor:repeatContainer.centerYAnchor],
        [self.scheduleButton.topAnchor constraintEqualToAnchor:repeatContainer.bottomAnchor constant:8],
        [self.scheduleButton.leadingAnchor constraintEqualToAnchor:hint.leadingAnchor],
        [self.scheduleButton.trailingAnchor constraintEqualToAnchor:hint.trailingAnchor],
        [self.scheduleButton.heightAnchor constraintEqualToConstant:48],
        [listTitle.topAnchor constraintEqualToAnchor:self.scheduleButton.bottomAnchor constant:18],
        [listTitle.leadingAnchor constraintEqualToAnchor:hint.leadingAnchor],
        [self.tableView.topAnchor constraintEqualToAnchor:listTitle.bottomAnchor constant:2],
        [self.tableView.leadingAnchor constraintEqualToAnchor:safe.leadingAnchor],
        [self.tableView.trailingAnchor constraintEqualToAnchor:safe.trailingAnchor],
        [self.tableView.bottomAnchor constraintEqualToAnchor:self.view.bottomAnchor]
    ]];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (void)scheduleReminder {
    [self.view endEditing:YES];
    NSString *task = [self.taskField.text stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet];
    if (!task.length) {
        [self showMessage:@"请填写提醒事项" message:@"例如：提交周报、吃药或给家人打电话。"];
        return;
    }
    if ([self.datePicker.date timeIntervalSinceNow] < 30) {
        [self showMessage:@"时间需要在未来" message:@"请选择至少 1 分钟后的日期和时间。"];
        return;
    }

    self.scheduleButton.enabled = NO;
    self.tableView.userInteractionEnabled = NO;
    if (@available(iOS 26.0, *)) {
        [self scheduleSystemAlarmWithTask:task date:self.datePicker.date];
        return;
    }

    __weak typeof(self) weakSelf = self;
    UNUserNotificationCenter *center = UNUserNotificationCenter.currentNotificationCenter;
    [center requestAuthorizationWithOptions:(UNAuthorizationOptionAlert | UNAuthorizationOptionSound | UNAuthorizationOptionBadge)
                          completionHandler:^(BOOL granted, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!granted || error) {
                weakSelf.scheduleButton.enabled = YES;
                weakSelf.tableView.userInteractionEnabled = YES;
                [weakSelf showNotificationSettings:error];
                return;
            }
            [weakSelf addReminderWithTask:task date:weakSelf.datePicker.date repeats:weakSelf.repeatSwitch.isOn];
        });
    }];
}

- (void)scheduleSystemAlarmWithTask:(NSString *)task date:(NSDate *)date API_AVAILABLE(ios(26.0)) {
    __weak typeof(self) weakSelf = self;
    [[CRMAlarmKitBridge shared] scheduleAlarmWithTitle:task date:date completion:^(NSString *identifier, NSError *error) {
        weakSelf.scheduleButton.enabled = YES;
        weakSelf.tableView.userInteractionEnabled = YES;
        if (error || !identifier.length) {
            [weakSelf showAlarmKitError:error];
            return;
        }
        [weakSelf saveAlarmKitRecordWithIdentifier:identifier title:task date:date];
        if (weakSelf.editingReminder) [weakSelf cancelReminderStorage:weakSelf.editingReminder];
        BOOL wasEditing = weakSelf.editingReminder != nil;
        [weakSelf resetReminderEditor];
        [weakSelf reloadPendingRemindersAfterUpdate];
        [weakSelf showMessage:(wasEditing ? @"系统闹钟已修改" : @"系统闹钟已安排") message:[weakSelf formattedDate:date]];
    }];
}

- (void)addReminderWithTask:(NSString *)task date:(NSDate *)date repeats:(BOOL)repeats {
    NSString *eventID = NSUUID.UUID.UUIDString;
    NSArray<NSNumber *> *minuteOffsets = repeats ? @[@0, @3, @6, @10] : @[@0];
    dispatch_group_t group = dispatch_group_create();
    NSMutableArray<NSString *> *scheduledIdentifiers = [NSMutableArray array];
    __block NSError *scheduleError = nil;

    [minuteOffsets enumerateObjectsUsingBlock:^(NSNumber *offset, NSUInteger index, BOOL *stop) {
        UNMutableNotificationContent *content = [[UNMutableNotificationContent alloc] init];
        content.title = index == 0 ? @"事项提醒" : @"事项再次提醒";
        content.body = task;
        content.sound = UNNotificationSound.defaultSound;
        content.threadIdentifier = [@"crm.reminders." stringByAppendingString:eventID];
        content.userInfo = @{@"type": @"scheduled_reminder",
                             CRMReminderEventIDKey: eventID,
                             CRMReminderRepeatKey: @(repeats)};
        if (@available(iOS 15.0, *)) content.interruptionLevel = UNNotificationInterruptionLevelTimeSensitive;

        NSDate *fireDate = [date dateByAddingTimeInterval:offset.integerValue * 60];
        NSCalendar *calendar = NSCalendar.currentCalendar;
        NSCalendarUnit units = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute;
        NSDateComponents *components = [calendar components:units fromDate:fireDate];
        components.calendar = calendar;
        components.timeZone = NSTimeZone.localTimeZone;
        UNCalendarNotificationTrigger *trigger = [UNCalendarNotificationTrigger triggerWithDateMatchingComponents:components repeats:NO];
        NSString *identifier = [NSString stringWithFormat:@"%@%@.%lu", CRMReminderIdentifierPrefix, eventID, (unsigned long)index];
        UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:identifier content:content trigger:trigger];

        dispatch_group_enter(group);
        [UNUserNotificationCenter.currentNotificationCenter addNotificationRequest:request withCompletionHandler:^(NSError *error) {
            @synchronized (scheduledIdentifiers) {
                if (error && !scheduleError) scheduleError = error;
                if (!error) [scheduledIdentifiers addObject:identifier];
            }
            dispatch_group_leave(group);
        }];
    }];

    __weak typeof(self) weakSelf = self;
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        weakSelf.scheduleButton.enabled = YES;
        weakSelf.tableView.userInteractionEnabled = YES;
        if (scheduleError) {
            [UNUserNotificationCenter.currentNotificationCenter removePendingNotificationRequestsWithIdentifiers:scheduledIdentifiers];
            [weakSelf showMessage:@"安排失败" message:scheduleError.localizedDescription ?: @"请稍后再试。"];
            return;
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            BOOL wasEditing = weakSelf.editingReminder != nil;
            if (weakSelf.editingReminder) [weakSelf cancelReminderStorage:weakSelf.editingReminder];
            [weakSelf resetReminderEditor];
            [weakSelf reloadPendingRemindersAfterUpdate];
            NSString *message = [weakSelf formattedDate:date];
            if (repeats) message = [message stringByAppendingString:@"\n未查看时将在 3、6、10 分钟后再次提醒。"];
            [weakSelf showMessage:(wasEditing ? @"提醒已修改" : @"提醒已安排") message:message];
        });
    });
}

- (void)reloadPendingReminders {
    __weak typeof(self) weakSelf = self;
    [UNUserNotificationCenter.currentNotificationCenter getPendingNotificationRequestsWithCompletionHandler:^(NSArray<UNNotificationRequest *> *requests) {
        NSMutableDictionary<NSString *, CRMReminderItem *> *grouped = [NSMutableDictionary dictionary];
        for (UNNotificationRequest *request in requests) {
            if (![request.identifier hasPrefix:CRMReminderIdentifierPrefix]) continue;
            NSString *eventID = request.content.userInfo[CRMReminderEventIDKey] ?: request.identifier;
            CRMReminderItem *item = grouped[eventID];
            NSDate *fireDate = [(UNCalendarNotificationTrigger *)request.trigger nextTriggerDate];
            if (!item) {
                item = [[CRMReminderItem alloc] init];
                item.identifier = eventID;
                item.title = request.content.body;
                item.date = fireDate;
                item.repeats = [request.content.userInfo[CRMReminderRepeatKey] boolValue];
                item.notificationIdentifiers = @[];
                grouped[eventID] = item;
            } else if (fireDate && [fireDate compare:item.date] == NSOrderedAscending) {
                item.date = fireDate;
            }
            item.notificationIdentifiers = [item.notificationIdentifiers arrayByAddingObject:request.identifier];
        }
        NSMutableArray<CRMReminderItem *> *filtered = [grouped.allValues mutableCopy];
        [filtered addObjectsFromArray:[weakSelf alarmKitReminderItems]];
        [filtered sortUsingComparator:^NSComparisonResult(CRMReminderItem *left, CRMReminderItem *right) {
            return [(left.date ?: NSDate.distantFuture) compare:(right.date ?: NSDate.distantFuture)];
        }];
        dispatch_async(dispatch_get_main_queue(), ^{
            weakSelf.reminders = filtered;
            weakSelf.emptyLabel.hidden = filtered.count > 0;
            [weakSelf.tableView reloadData];
        });
    }];
}

- (void)reloadPendingRemindersAfterUpdate {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self reloadPendingReminders];
    });
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section { return self.reminders.count; }

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier = @"CRMReminderCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
    CRMReminderItem *item = self.reminders[indexPath.row];
    cell.textLabel.text = item.title;
    cell.textLabel.font = [UIFont systemFontOfSize:15 weight:UIFontWeightSemibold];
    NSString *channel = item.usesAlarmKit ? @" · 系统闹钟" : (item.repeats ? @" · 连续提醒" : @" · 通知提醒");
    cell.detailTextLabel.text = [[self formattedDate:item.date] stringByAppendingString:channel];
    cell.detailTextLabel.textColor = UIColorFromRGB(0x6F827D);
    if (@available(iOS 13.0, *)) {
        cell.imageView.image = [UIImage systemImageNamed:@"bell.fill"];
        cell.imageView.tintColor = UIColorFromRGB(0x315F57);
    }
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    CRMReminderItem *item = self.reminders[indexPath.row];
    self.editingReminder = item;
    self.taskField.text = item.title;
    self.datePicker.date = item.date;
    self.repeatSwitch.on = item.repeats;
    [self.scheduleButton setTitle:@"保存修改" forState:UIControlStateNormal];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消编辑"
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self
                                                                             action:@selector(cancelEditingReminder)];
    [self.taskField becomeFirstResponder];
}

- (void)cancelEditingReminder {
    [self.view endEditing:YES];
    [self resetReminderEditor];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath { return YES; }

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle != UITableViewCellEditingStyleDelete) return;
    CRMReminderItem *item = self.reminders[indexPath.row];
    [self cancelReminderStorage:item];
    if (self.editingReminder == item) [self resetReminderEditor];
    NSMutableArray *updated = [self.reminders mutableCopy];
    [updated removeObjectAtIndex:indexPath.row];
    self.reminders = updated;
    self.emptyLabel.hidden = updated.count > 0;
    [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

- (void)cancelReminderStorage:(CRMReminderItem *)item {
    if (item.usesAlarmKit) {
        if (@available(iOS 26.0, *)) {
            [[CRMAlarmKitBridge shared] cancelAlarmWithIdentifier:item.identifier completion:^(NSError *error) {
                if (error) NSLog(@"取消系统闹钟失败：%@", error.localizedDescription);
            }];
        }
        [self removeAlarmKitRecordWithIdentifier:item.identifier];
        return;
    }
    NSArray *identifiers = item.notificationIdentifiers.count ? item.notificationIdentifiers : @[item.identifier];
    [UNUserNotificationCenter.currentNotificationCenter removePendingNotificationRequestsWithIdentifiers:identifiers];
}

- (void)resetReminderEditor {
    self.editingReminder = nil;
    self.taskField.text = @"";
    self.datePicker.minimumDate = [NSDate dateWithTimeIntervalSinceNow:60];
    self.datePicker.date = [NSDate dateWithTimeIntervalSinceNow:3600];
    self.repeatSwitch.on = NO;
    [self.scheduleButton setTitle:@"安排提醒" forState:UIControlStateNormal];
    self.navigationItem.rightBarButtonItem = nil;
}

- (void)saveAlarmKitRecordWithIdentifier:(NSString *)identifier title:(NSString *)title date:(NSDate *)date {
    NSMutableArray *records = [[[NSUserDefaults standardUserDefaults] arrayForKey:CRMAlarmKitRecordsKey] mutableCopy] ?: [NSMutableArray array];
    [records addObject:@{@"identifier": identifier, @"title": title, @"date": date}];
    [[NSUserDefaults standardUserDefaults] setObject:records forKey:CRMAlarmKitRecordsKey];
}

- (NSArray<CRMReminderItem *> *)alarmKitReminderItems {
    NSArray *records = [[NSUserDefaults standardUserDefaults] arrayForKey:CRMAlarmKitRecordsKey] ?: @[];
    NSMutableArray<CRMReminderItem *> *items = [NSMutableArray array];
    NSMutableArray *validRecords = [NSMutableArray array];
    for (NSDictionary *record in records) {
        NSString *identifier = record[@"identifier"];
        NSString *title = record[@"title"];
        NSDate *date = record[@"date"];
        if (!identifier.length || !title.length || ![date isKindOfClass:NSDate.class] || [date timeIntervalSinceNow] < -60) continue;
        CRMReminderItem *item = [[CRMReminderItem alloc] init];
        item.identifier = identifier;
        item.title = title;
        item.date = date;
        item.usesAlarmKit = YES;
        [items addObject:item];
        [validRecords addObject:record];
    }
    if (validRecords.count != records.count) {
        [[NSUserDefaults standardUserDefaults] setObject:validRecords forKey:CRMAlarmKitRecordsKey];
    }
    return items;
}

- (void)removeAlarmKitRecordWithIdentifier:(NSString *)identifier {
    NSArray *records = [[NSUserDefaults standardUserDefaults] arrayForKey:CRMAlarmKitRecordsKey] ?: @[];
    NSPredicate *predicate = [NSPredicate predicateWithBlock:^BOOL(NSDictionary *record, NSDictionary *bindings) {
        return ![record[@"identifier"] isEqualToString:identifier];
    }];
    [[NSUserDefaults standardUserDefaults] setObject:[records filteredArrayUsingPredicate:predicate] forKey:CRMAlarmKitRecordsKey];
}

- (void)showAlarmKitError:(NSError *)error {
    NSString *message = error.localizedDescription ?: @"请在系统设置中允许本 App 创建闹钟。";
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"无法创建系统闹钟" message:message preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    [alert addAction:[UIAlertAction actionWithTitle:@"前往设置" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [UIApplication.sharedApplication openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString] options:@{} completionHandler:nil];
    }]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (NSString *)formattedDate:(NSDate *)date {
    if (!date) return @"时间未知";
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.locale = [NSLocale localeWithLocaleIdentifier:@"zh_CN"];
    formatter.dateFormat = @"yyyy年M月d日 EEEE HH:mm";
    return [formatter stringFromDate:date];
}

- (void)showNotificationSettings:(NSError *)error {
    NSString *message = error.localizedDescription ?: @"请在系统设置中允许通知，否则无法按时提醒。";
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"需要通知权限" message:message preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    [alert addAction:[UIAlertAction actionWithTitle:@"前往设置" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [UIApplication.sharedApplication openURL:[NSURL URLWithString:UIApplicationOpenSettingsURLString] options:@{} completionHandler:nil];
    }]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)showMessage:(NSString *)title message:(NSString *)message {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"好的" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

@end

@interface CRMSettingCardCell : UITableViewCell
@property (nonatomic, strong) UIView *cardView;
@property (nonatomic, strong) UILabel *iconLabel;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *detailLabel;
- (void)configureWithTitle:(NSString *)title detail:(NSString *)detail icon:(NSString *)icon;
@end

@implementation CRMSettingCardCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        self.backgroundColor = UIColor.clearColor;
        self.contentView.backgroundColor = UIColor.clearColor;
        self.selectionStyle = UITableViewCellSelectionStyleNone;

        _cardView = [[UIView alloc] init];
        _cardView.backgroundColor = UIColor.whiteColor;
        _cardView.layer.cornerRadius = 16;
        _cardView.layer.shadowColor = [UIColor colorWithWhite:0 alpha:0.06].CGColor;
        _cardView.layer.shadowOpacity = 1;
        _cardView.layer.shadowRadius = 8;
        _cardView.layer.shadowOffset = CGSizeMake(0, 3);
        [self.contentView addSubview:_cardView];

        _iconLabel = [[UILabel alloc] init];
        _iconLabel.textAlignment = NSTextAlignmentCenter;
        _iconLabel.font = [UIFont systemFontOfSize:21];
        _iconLabel.backgroundColor = UIColorFromRGB(0xE9F3EF);
        _iconLabel.layer.cornerRadius = 12;
        _iconLabel.layer.masksToBounds = YES;
        [_cardView addSubview:_iconLabel];

        _titleLabel = [[UILabel alloc] init];
        _titleLabel.font = [UIFont systemFontOfSize:15 weight:UIFontWeightSemibold];
        _titleLabel.textColor = UIColorFromRGB(0x294B46);
        [_cardView addSubview:_titleLabel];

        _detailLabel = [[UILabel alloc] init];
        _detailLabel.font = [UIFont systemFontOfSize:11];
        _detailLabel.textColor = UIColorFromRGB(0x87938F);
        [_cardView addSubview:_detailLabel];

        UILabel *arrow = [[UILabel alloc] init];
        arrow.text = @"›";
        arrow.font = [UIFont systemFontOfSize:25 weight:UIFontWeightLight];
        arrow.textColor = UIColorFromRGB(0x91AAA5);
        [_cardView addSubview:arrow];

        [_cardView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.contentView).offset(18);
            make.right.equalTo(self.contentView).offset(-18);
            make.top.equalTo(self.contentView).offset(4);
            make.bottom.equalTo(self.contentView).offset(-4);
        }];
        [_iconLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.cardView).offset(14);
            make.centerY.equalTo(self.cardView);
            make.width.height.mas_equalTo(44);
        }];
        [arrow mas_makeConstraints:^(MASConstraintMaker *make) {
            make.right.equalTo(self.cardView).offset(-16);
            make.centerY.equalTo(self.cardView);
        }];
        [_titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(self.iconLabel.mas_right).offset(13);
            make.right.equalTo(arrow.mas_left).offset(-8);
            make.bottom.equalTo(self.cardView.mas_centerY).offset(-2);
        }];
        [_detailLabel mas_makeConstraints:^(MASConstraintMaker *make) {
            make.left.right.equalTo(self.titleLabel);
            make.top.equalTo(self.cardView.mas_centerY).offset(4);
        }];
    }
    return self;
}

- (void)configureWithTitle:(NSString *)title detail:(NSString *)detail icon:(NSString *)icon {
    self.titleLabel.text = title;
    self.detailLabel.text = detail;
    self.iconLabel.text = icon;
}

- (void)setHighlighted:(BOOL)highlighted animated:(BOOL)animated {
    [super setHighlighted:highlighted animated:animated];
    [UIView animateWithDuration:0.15 animations:^{
        self.cardView.alpha = highlighted ? 0.82 : 1;
        self.cardView.transform = highlighted ? CGAffineTransformMakeScale(0.98, 0.98) : CGAffineTransformIdentity;
    }];
}

@end

@interface SettingViewController () <UITableViewDelegate, UITableViewDataSource, JFCSTableViewControllerDelegate, EHAddressCompHelperDelegate>

/** other城市选择器  */
@property (nonatomic, strong) EHAddressCompHelper *addressHelper;

@property (nonatomic, strong) NSMutableArray *shareArray;

@property (nonatomic, strong) UILabel *bottomLabel;

@end

@implementation SettingViewController

+ (UIViewController *)futureReminderViewController {
    return [[CRMReminderViewController alloc] init];
}

- (void)initExtendedData {
    [super initExtendedData];

    self.dataArray       = [NSMutableArray arrayWithArray:[self getDataArray]];
    self.style           = UITableViewStylePlain;
    self.tableCellClass  = [CRMSettingCardCell class];
    self.heightForHeader = 58;
    self.cellHeight      = 76;
    self.title           = @"设置";
}

- (void)loadUIData {
    [super loadUIData];

    self.view.backgroundColor = UIColorFromRGB(0xF4F7F5);
    self.tableView.backgroundColor = UIColorFromRGB(0xF4F7F5);
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.tableHeaderView = [self getHeaderView];
    self.tableView.tableFooterView = self.bottomLabel;
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.left.right.equalTo(self.view);
        make.bottom.equalTo(self.view.mas_bottom).offset(-SafeAreaBottomAreaHeight);
    }];

    @pas_weakify_self
        self.cellConfigBlock = ^(NSIndexPath *_Nonnull indexPath, CRMSettingCardCell *cell) {
        @pas_strongify_self
        NSArray *sectionItems = PASArrayAtIndex(self.dataArray, indexPath.section);
        ActionModel *model = PASArrayAtIndex(sectionItems, indexPath.row);
        [cell configureWithTitle:TransToString(model.title)
                           detail:[self descriptionForAction:model.actionName]
                             icon:[self iconForAction:model.actionName section:indexPath.section]];
    };

    self.cellClickBlock = ^(NSIndexPath *_Nonnull indexPath, id _Nonnull cell) {
        @pas_strongify_self
            ActionModel *model = self.dataArray[indexPath.section][indexPath.row];
        NSString *selectAction = model.actionName;
        if (selectAction.length > 0) {
            SEL seletor = NSSelectorFromString(selectAction);
            ((void (*)(id, SEL))objc_msgSend)(self, seletor);
        }
    };
}

- (void)onShowTotalVersion {
    NSString *version = NSString.eh_appBuildVersion;
    //    NSString *month =  [version substringWithRange:NSMakeRange(0, 2)];
    //    NSString *day = [version substringWithRange:NSMakeRange(2, 2)];
    //    NSString *hour = [version substringWithRange:NSMakeRange(4, 2)];
    //    NSString *minute = [version substringWithRange:NSMakeRange(6, 2)];
    //    NSString *second = [version substringWithRange:NSMakeRange(8, 2)];
    //    NSString *formatVersion = [NSString stringWithFormat:@"%@-%@ %@:%@:%@", month, day, hour, minute, second];
    //    self.bottomLabel.text = [NSString stringWithFormat:@"版本v%@ 日期 %@",NSString.eh_mainVersion, formatVersion];

    NSString *dateFormat    = @"MM-dd HH:mm:ss";
    NSDate *resultDate      = [NSDate br_dateFromString:version dateFormat:@"MMddHHmmss"];
    NSString *formatTime    = [NSDate br_stringFromDate:resultDate dateFormat:dateFormat];
    NSString *resultVersion = formatTime.length > 0
        ? [NSString stringWithFormat:@"My Study  ·  v%@  ·  %@", NSString.eh_mainVersion, formatTime]
        : [NSString stringWithFormat:@"My Study  ·  v%@", NSString.eh_mainVersion];
    NSLog(@"formatTime = %@", formatTime);
    self.bottomLabel.text = TransToString(resultVersion);
}

#pragma mark -  Lazy loading
/** 懒加载地址选择器  */
- (EHAddressCompHelper *)addressHelper {
    if (!_addressHelper) {
        _addressHelper          = [[EHAddressCompHelper alloc] init];
        _addressHelper.delegate = self;
    }
    return _addressHelper;
}

- (NSArray *)getDataArray {
    NSArray *sec1Arr = @[[ActionModel initWithTitle:@"个人信息" actionName:@"accountInfoSetting"],
                         [ActionModel initWithTitle:@"账户与安全" actionName:@"accountsAndSecurity"],
                         [ActionModel initWithTitle:@"二维码扫描" actionName:@"scanningQRCode"]];

    NSArray *sec2Arr = @[[ActionModel initWithTitle:@"Alert提示框" actionName:@"alertViewAction"],
                         [ActionModel initWithTitle:@"单选页面" actionName:@"selectedPageAction"],
                         [ActionModel initWithTitle:@"切换皮肤" actionName:@"changeTheme"],
                         [ActionModel initWithTitle:@"切换App图标" actionName:@"changeAppIcon"],
                         [ActionModel initWithTitle:@"文件选择" actionName:@"fileSelect"],
                         [ActionModel initWithTitle:@"拍照/相册/文件" actionName:@"photoFileSelect"],
                         [ActionModel initWithTitle:@"城市选择器" actionName:@"citySelect"],
                         [ActionModel initWithTitle:@"另一种城市选择器" actionName:@"otherCitySelect"],
                         [ActionModel initWithTitle:@"地址微调" actionName:@"changeAddressTrim"],
                         [ActionModel initWithTitle:@"视频" actionName:@"jumpSJVideoPage"],
                         [ActionModel initWithTitle:@"文字转语音" actionName:@"textToSpeechPage"],
                         [ActionModel initWithTitle:@"多边形拖拽" actionName:@"drawPolygonView"],

    ];

    NSArray *sec3Arr = @[[ActionModel initWithTitle:@"打开首页底部广告" actionName:@"testShowWindow"],
                         [ActionModel initWithTitle:@"CRM演示界面" actionName:@"jumpCRMViewController"],
                         [ActionModel initWithTitle:@"VipVideo" actionName:@"vipVideo"],
                         [ActionModel initWithTitle:@"陀螺仪测试界面 ~ 球" actionName:@"testBallViewContorller"],
                         [ActionModel initWithTitle:@"自定义Swiper组件" actionName:@"testSwiperComponent"],
                         [ActionModel initWithTitle:@"小游戏乐园" actionName:@"showGameCenter"]];

    NSArray *sec4Arr = @[[ActionModel initWithTitle:@"清除缓存" actionName:@"cleanCacheData"],
                         [ActionModel initWithTitle:@"意见反馈" actionName:@"feedBackDetailInfo"],
                         [ActionModel initWithTitle:@"关于" actionName:@"aboutDetailInfo"]];

    NSArray *sec5Arr = @[[ActionModel initWithTitle:@"用户隐私协议" actionName:@"go2PrivicyAgreement"],
                         [ActionModel initWithTitle:@"交易风险提示" actionName:@"go2TradeRiskTip"],
                         [ActionModel initWithTitle:@"未来提醒" actionName:@"scheduledReminder"]];

    return @[sec1Arr, sec2Arr, sec3Arr, sec4Arr, sec5Arr];
}

- (NSString *)descriptionForAction:(NSString *)action {
    static NSDictionary<NSString *, NSString *> *descriptions;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        descriptions = @{
            @"accountInfoSetting": @"个人资料与分享体验", @"accountsAndSecurity": @"账户相关设置",
            @"scanningQRCode": @"使用相机识别二维码", @"alertViewAction": @"提示弹窗样式预览",
            @"selectedPageAction": @"查看单选列表交互", @"changeTheme": @"选择喜欢的界面主题",
            @"changeAppIcon": @"更换桌面上的应用图标", @"fileSelect": @"从设备中选择文件",
            @"photoFileSelect": @"拍照或导入照片与文件", @"citySelect": @"搜索并选择城市",
            @"otherCitySelect": @"体验另一种城市选择方式", @"changeAddressTrim": @"调整地址信息",
            @"jumpSJVideoPage": @"体验视频播放页面", @"textToSpeechPage": @"将输入文字转换为语音",
            @"drawPolygonView": @"自由拖拽多边形", @"testShowWindow": @"展示首页悬浮信息",
            @"jumpCRMViewController": @"浏览 CRM 示例页面", @"vipVideo": @"打开网页浏览页面",
            @"testBallViewContorller": @"体验陀螺仪小球", @"testSwiperComponent": @"查看轮播组件",
            @"showGameCenter": @"赛车、拼图与更多小游戏", @"cleanCacheData": @"释放本地缓存空间",
            @"feedBackDetailInfo": @"告诉我们你的建议", @"aboutDetailInfo": @"查看应用信息",
            @"go2PrivicyAgreement": @"了解隐私保护说明", @"go2TradeRiskTip": @"查看风险提示内容",
            @"scheduledReminder": @"在未来指定日期和时间提醒事项"
        };
    });
    return descriptions[action] ?: @"打开功能页面";
}

- (NSString *)iconForAction:(NSString *)action section:(NSInteger)section {
    static NSDictionary<NSString *, NSString *> *icons;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        icons = @{
            @"accountInfoSetting": @"👤", @"accountsAndSecurity": @"🔐", @"scanningQRCode": @"▣",
            @"changeTheme": @"🎨", @"changeAppIcon": @"✨", @"fileSelect": @"📁",
            @"photoFileSelect": @"📷", @"citySelect": @"📍", @"otherCitySelect": @"🗺",
            @"jumpSJVideoPage": @"▶", @"textToSpeechPage": @"♫", @"showGameCenter": @"🎮",
            @"cleanCacheData": @"🧹", @"feedBackDetailInfo": @"✉", @"aboutDetailInfo": @"ⓘ",
            @"go2PrivicyAgreement": @"🔒", @"scheduledReminder": @"⏰"
        };
    });
    NSArray<NSString *> *fallbacks = @[@"◈", @"⚙", @"✦", @"◇", @"☷"];
    return icons[action] ?: fallbacks[MIN(section, fallbacks.count - 1)];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return kSectionViewHeight;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    NSArray<NSString *> *titles = @[@"账户与安全", @"外观与实用工具", @"体验与探索", @"应用服务", @"隐私与通知"];
    UIView *sectionHeader = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(tableView.bounds), kSectionViewHeight)];
    sectionHeader.backgroundColor = UIColorFromRGB(0xF4F7F5);
    UILabel *title = [[UILabel alloc] init];
    title.text = titles[MIN(section, titles.count - 1)];
    title.font = [UIFont systemFontOfSize:18 weight:UIFontWeightBold];
    title.textColor = UIColorFromRGB(0x294B46);
    [sectionHeader addSubview:title];
    [title mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.equalTo(sectionHeader).offset(20);
        make.bottom.equalTo(sectionHeader).offset(-10);
    }];
    return sectionHeader;
}

- (UIView *)getHeaderView {
    CGFloat width = CGRectGetWidth(UIScreen.mainScreen.bounds);
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, 160)];
    UIView *hero = [[UIView alloc] initWithFrame:CGRectMake(18, 14, width - 36, 132)];
    hero.backgroundColor = UIColorFromRGB(0x315F57);
    hero.layer.cornerRadius = 22;
    hero.layer.masksToBounds = YES;
    [headerView addSubview:hero];

    UILabel *eyebrow = [[UILabel alloc] initWithFrame:CGRectMake(22, 19, width - 80, 18)];
    eyebrow.text = @"MY STUDY  ·  PREFERENCES";
    eyebrow.textColor = [UIColor colorWithWhite:1 alpha:0.68];
    eyebrow.font = [UIFont systemFontOfSize:11 weight:UIFontWeightSemibold];
    [hero addSubview:eyebrow];

    UILabel *title = [[UILabel alloc] initWithFrame:CGRectMake(22, 46, width - 80, 34)];
    title.text = @"让使用更顺手";
    title.textColor = UIColor.whiteColor;
    title.font = [UIFont systemFontOfSize:25 weight:UIFontWeightBold];
    [hero addSubview:title];

    UILabel *subtitle = [[UILabel alloc] initWithFrame:CGRectMake(22, 91, width - 80, 21)];
    subtitle.text = @"外观、账户和常用工具，都可以在这里找到。";
    subtitle.textColor = [UIColor colorWithWhite:1 alpha:0.82];
    subtitle.font = [UIFont systemFontOfSize:12];
    [hero addSubview:subtitle];
    return headerView;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];

    //    [self.tableView reloadData];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self onShowTotalVersion];

    [self.tableView reloadData];
}

#pragma mark - action
/**
 *  个人信息
 */
- (void)accountInfoSetting {
    ZWUserManager *user     = [ZWUserManager sharedInstance];
    user.name               = @"user";
    ZWUserManager *manager  = [[ZWUserManager alloc] init];
    manager.age             = 32;
    ZWUserManager *manager1 = [ZWUserManager new];
    manager1.gender         = 1;
    ZWUserManager *manager2 = [ZWUserManager copy];
    manager2.nichName       = @"manager2";
    NSLog(@"\nuser = %p\nmanager = %p\nmanager1 = %p\nmanager2 = %p", user, manager, manager1, manager2);

    [self __testShareView];
}

- (NSMutableArray *)shareArray {
    if (!_shareArray) {
        _shareArray = [NSMutableArray array];
        [_shareArray addObject:MMPlatformNameSms];
        [_shareArray addObject:MMPlatformNameEmail];
        [_shareArray addObject:MMPlatformNameSina];
        [_shareArray addObject:MMPlatformNameWechat];
        [_shareArray addObject:MMPlatformNameQQ];
        [_shareArray addObject:MMPlatformNameAlipay];
    }
    return _shareArray;
}

- (void)__testShareView {
    MMShareView *shareView = [[MMShareView alloc] initWithItems:self.shareArray itemSize:CGSizeMake(80, 100) DisplayLine:NO];
    shareView              = [self addShareContent:shareView];
    shareView.itemSpace    = 10;
    @weakify(self)
        shareView.action = ^(MMShareItem *_Nonnull item) {
        @strongify(self)
        //        [self ];
    };
    [shareView showFromControlle:self];
}

// 添加分享的内容
- (MMShareView *)addShareContent:(MMShareView *)shareView {
    [shareView addText:@"分享测试"];
    [shareView addURL:[NSURL URLWithString:@"http://www.baidu.com"]];
    [shareView addImage:[UIImage imageNamed:@"share_alipay"]];

    return shareView;
}

- (void)shareSDK {
    ShareParam *shareParam = [ShareParam new];
    shareParam.desc        = @"测试说明";

    ShareObject *model = [[ShareObject alloc] init];
    model.name         = @"Wechat";
    model.shareParam   = shareParam;
    [MMShareManager shareObject:model complete:^(BOOL y, NSError *_Nullable error){
        //        [Toast show:error.localizedDescription];
    }];

    //    [ShareClient openMiniApp:<#(nonnull ShareObject *)#> complete:<#^(BOOL, NSError * _Nullable)completeBlock#>]
    //
    //    [ShareClient wxLogin:^(NSString * ret, NSError * error) {
    //        @strongify(self)
    //        if (!error){
    //            //[self showProgress];
    //            [self.loginViewModel wxLogin:ret];
    //        } else {
    //            [self startOneKeyAuth];
    //        }
    //    }];
}

/**
 *  账户与安全
 */
- (void)accountsAndSecurity {
}


#pragma mark - 二维码扫描
- (void)scanningQRCode {
    QQScanZXingViewController *vc = [QQScanZXingViewController new];
    vc.style = [StyleDIY qqStyle];
    vc.cameraInvokeMsg = @"相机启动中";
    vc.continuous = [Global sharedManager].continuous;
    vc.orientation = [StyleDIY videoOrientation];
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - 我的二维码
- (void)vipVideo {
    
    [self.navigationController pushViewController:[NSClassFromString(@"FindViewController") new] animated:YES];
}




/**
 *  Alert提示框
 */
- (void)alertViewAction {
    [ZWM.router executeURLNoCallBack:ZWRouterPageShowAlertViewController];
}

/**
 *  切换皮肤
 */
- (void)changeTheme {
    NSArray *themeAray = @[AppThemeLight, AppThemeNight, AppThemeStyle1, AppThemeStyle2, AppThemeStyle3];
    [UIAlertUtil showAlertTitle:@"切换皮肤" message:@"" cancelButtonTitle:@"取消" otherButtonTitles:themeAray alertControllerStyle:UIAlertControllerStyleActionSheet actionBlock:^(NSInteger index) {
        if (index > 0) {
            NSString *themeKey = PASArrayAtIndex(themeAray, index - 1);
            [zhThemeOperator changeThemeStyleWithKey:themeKey];
        }
    } superVC:self];
}

/**
 *  切换App图标
 */
- (void)changeAppIcon {
    ZWAppIconManager *manager = ZWAppIconManager.sharedManager;
    if (!manager.supportsAlternateIcons) {
        [self zw_showAppIconMessage:@"iOS 10.3 以下系统不支持切换App图标"];
        return;
    }

    NSString *modeText = manager.isAutoModeEnabled ? @"当前模式：跟随节日自动切换" : @"当前模式：手动选择图标";
    NSString *iconText = [NSString stringWithFormat:@"当前图标：%@", [manager titleForIconName:manager.currentIconName]];
    NSString *ruleText = [manager autoRuleDescriptionForDate:NSDate.date];
    NSString *message = [NSString stringWithFormat:@"%@\n%@\n%@", modeText, iconText, ruleText];
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"切换App图标"
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleActionSheet];

    @pas_weakify_self
    NSString *autoTitle = manager.isAutoModeEnabled ? @"重新按节日规则检查" : @"开启跟随节日自动切换";
    [alert addAction:[UIAlertAction actionWithTitle:autoTitle style:UIAlertActionStyleDefault handler:^(__unused UIAlertAction *_Nonnull action) {
        @pas_strongify_self
        [manager setAutoModeEnabled:YES completion:^(BOOL success, NSString *message, NSError *_Nullable error) {
            [self zw_showAppIconMessage:message];
        }];
    }]];

    if (manager.isAutoModeEnabled) {
        [alert addAction:[UIAlertAction actionWithTitle:@"关闭自动切换" style:UIAlertActionStyleDefault handler:^(__unused UIAlertAction *_Nonnull action) {
            @pas_strongify_self
            [manager setAutoModeEnabled:NO completion:^(BOOL success, NSString *message, NSError *_Nullable error) {
                [self zw_showAppIconMessage:message];
            }];
        }]];
    }

    NSString *currentIconName = manager.currentIconName ?: @"";
    [[manager iconOptions] enumerateObjectsUsingBlock:^(NSDictionary<NSString *, NSString *> *_Nonnull option, NSUInteger idx, BOOL *_Nonnull stop) {
        NSString *iconName = option[ZWAppIconOptionNameKey] ?: @"";
        NSString *title = option[ZWAppIconOptionTitleKey] ?: @"";
        NSString *showTitle = [currentIconName isEqualToString:iconName] ? [NSString stringWithFormat:@"%@ ✓", title] : title;
        UIAlertAction *action = [UIAlertAction actionWithTitle:showTitle style:UIAlertActionStyleDefault handler:^(__unused UIAlertAction *_Nonnull action) {
            @pas_strongify_self
            [manager setManualIconName:iconName.length > 0 ? iconName : nil title:title completion:^(BOOL success, NSString *message, NSError *_Nullable error) {
                [self zw_showAppIconMessage:message];
            }];
        }];
        [alert addAction:action];
    }];

    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    UIPopoverPresentationController *popover = alert.popoverPresentationController;
    if (popover) {
        popover.sourceView = self.view;
        popover.sourceRect = CGRectMake(CGRectGetMidX(self.view.bounds), CGRectGetMaxY(self.view.bounds) - 1, 1, 1);
        popover.permittedArrowDirections = 0;
    }
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)zw_showAppIconMessage:(NSString *)message {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"提示"
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"知道了" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

/**
 *  切换环境
 */
- (void)fileSelect {
    [ZWM.router executeURLNoCallBack:ZWRouterPageFileSelectViewController];
}

/**
 *  拍照/相册/文件
 */
- (void)photoFileSelect {
    @pas_weakify_self
        [PhotoActionSheetUtil showPhotoAlert:9 complete:^(NSArray<PHAssetModel *> *_Nonnull list) {
            @pas_strongify_self
                /* 判断是文件 */
                PHAssetModel *item = [list firstObject];
            if (item.isFile || !item) {
                [self dealWithFile:item];
                return;
            }
            NSMutableArray *paths = [NSMutableArray array];
            for (PHAssetModel *item in list) {
                [paths addObject:[item.originalPath substringFromIndex:7]];
            }
            NSLog(@"paths = %@", paths);
        } isShowFile:YES];
}

/**
 *  城市选择器
 */
- (void)citySelect {
    // 自定义配置...
    JFCSConfiguration *config = [[JFCSConfiguration alloc] init];
    // 关闭拼音搜索
    config.isPinyinSearch = NO;
    // 配置热门城市
    config.popularCitiesMutableArray = [self defealtPopularCities];
    // 配置浮窗类型为中心toast
    config.indexViewType = EHIndexViewStyleCenterToast;

    JFCSTableViewController *vc = [[JFCSTableViewController alloc] initWithConfiguration:config delegate:self];
    [self.navigationController pushViewController:vc animated:YES];
}

// 自定义热门城市
- (NSMutableArray<JFCSPopularCitiesModel *> *)defealtPopularCities {
    JFCSPopularCitiesModel *bjModel = [[JFCSPopularCitiesModel alloc] initWithName:@"北京" type:JFCSPopularCitiesTypeCity];
    JFCSPopularCitiesModel *shModel = [[JFCSPopularCitiesModel alloc] initWithName:@"上海" type:JFCSPopularCitiesTypeCity];
    JFCSPopularCitiesModel *gzModel = [[JFCSPopularCitiesModel alloc] initWithName:@"广州" type:JFCSPopularCitiesTypeCity];
    JFCSPopularCitiesModel *szModel = [[JFCSPopularCitiesModel alloc] initWithName:@"深圳" type:JFCSPopularCitiesTypeCity];
    JFCSPopularCitiesModel *hzModel = [[JFCSPopularCitiesModel alloc] initWithName:@"杭州" type:JFCSPopularCitiesTypeCity];
    return [NSMutableArray arrayWithObjects:bjModel, shModel, gzModel, szModel, hzModel, nil];
}

/**
 * 另一种城市选择器
 */
- (void)otherCitySelect {
    [self.addressHelper showAddressView];
}

/**
 *  地址微调
 */
- (void)changeAddressTrim {
    [ZWM.router executeURLNoCallBack:ZWRouterPageLocationTrimViewController];
}

/**
 * 视频
 */
- (void)jumpSJVideoPage {
    [ZWM.router executeURLNoCallBack:ZWRouterPageSJVideoController];
}

/**
 * 文字转语音
 */
- (void)textToSpeechPage {
    [ZWM.router executeURLNoCallBack:ZWRouterPageTextToSpeechViewController];
}

/**
 * 绘制多边形
 */
- (void)drawPolygonView {
    [ZWM.router executeURLNoCallBack:ZWRouterPageDrawPolygonViewController];
}

/**
 * CRM演示界面
 */
- (void)jumpCRMViewController {
    SettingCRMViewController *viewController = [[SettingCRMViewController alloc] init];
    [self.navigationController pushViewController:viewController animated:YES];
}


- (void)_testOpenDebugHml {
    NSString *hybridserverPath = [PathConstants gcdWebServerRootDirectory];
    NSString * webPath = [NSString stringWithFormat:@"%@/debug.html",hybridserverPath];
    NSURL *webUrl = [NSURL fileURLWithPath:webPath];
    
    ZWCommonWebPage *webPage = [[ZWCommonWebPage alloc] init];
    [webPage loadUrl:webUrl];
    
    [self.navigationController pushViewController:webPage animated:YES];
}

/**
 *  清除缓存
 */
- (void)cleanCacheData {
    BOOL isCrash = NO;
    /**
     *  try catch 异常捕获 局限性,只能捕获 数组越界 等异常 其他异常捕获不到
     */
    //    @try {
    //        NSMutableArray *data = [NSMutableArray array];
    //        //        id a = [data objectAtIndex:2];
    //        [data addObject:nil];
    //    } @catch (NSException *exception) {
    //        NSLog(@ "%s\n%@", __FUNCTION__, exception);
    //    } @finally {
    //    }
    //    NSLog(@"isCrash = %@", @(isCrash));

//        [self _testOpenDebugHml];
//    
//        return;
    
    NSString *copyFileName = @"demo";
    /** 复制本地demo.html到沙目录  */
    NSString *demoHtmlPath = [NSBundle.mainBundle pathForResource:copyFileName ofType:@"html"];
    NSString *toDemoHtmlPath = [NSString stringWithFormat:@"%@/%@.html", [PathConstants gcdWebServerRootDirectory], copyFileName];

    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSError *error;
    BOOL isSuccessOne = [fileManager copyItemAtPath:demoHtmlPath toPath:toDemoHtmlPath error:&error];
    
    
//    NSString *zipFileName = @"debug";
    NSString *zipFileName = @"dist";
    NSString *hybridserverPath = [PathConstants gcdWebServerRootDirectory];
    NSString *filePath = [NSBundle.mainBundle pathForResource:zipFileName ofType:@"zip"];
    NSString *preversionPath = [PathConstants preversionDirectory];
    NSString *downPath = [PathConstants downLoadDirectory];
    NSString *fileName = [NSString stringWithFormat:@"%@.zip", zipFileName];;
    NSString *toDownLoadPath = [NSString stringWithFormat:@"%@/%@", downPath, fileName];
    NSString *toPreversionPath = [NSString stringWithFormat:@"%@/%@", preversionPath, fileName];

    [SSZipArchive unzipFileAtPath:filePath toDestination:hybridserverPath progressHandler:^(NSString *_Nonnull entry, unz_file_info zipInfo, long entryNumber, long total) {

    } completionHandler:^(NSString *_Nonnull path, BOOL succeeded, NSError *_Nullable error) {
        if (succeeded) {
            NSFileManager *fileManager = [NSFileManager defaultManager];
            NSError *error;
            BOOL isSuccessOne = [fileManager copyItemAtPath:filePath toPath:toDownLoadPath error:&error];
            BOOL isSuccessTwo = [fileManager copyItemAtPath:filePath toPath:toPreversionPath error:&error];
            NSLog(@"isSuccessOne = %d\nisSuccessTwo = %d", isSuccessOne, isSuccessTwo);
        }
    }];

    [self _testDebugZip];
}

#pragma mark - 测试H5zip包
- (void)_testDebugZip {
    NSString *copyFileName = @"images";
    NSString *hybridserverPath = [PathConstants gcdWebServerRootDirectory];
    NSString *filePath = [NSBundle.mainBundle pathForResource:copyFileName ofType:@"zip"];
    NSString *preversionPath = [PathConstants preversionDirectory];
    NSString *downPath = [PathConstants downLoadDirectory];
    NSString *fileName = [NSString stringWithFormat:@"%@.zip", copyFileName];
    NSString *toDownLoadPath = [NSString stringWithFormat:@"%@/%@", downPath, fileName];
    NSString *toPreversionPath = [NSString stringWithFormat:@"%@/%@", preversionPath, fileName];

    [SSZipArchive unzipFileAtPath:filePath toDestination:hybridserverPath progressHandler:^(NSString *_Nonnull entry, unz_file_info zipInfo, long entryNumber, long total) {

    } completionHandler:^(NSString *_Nonnull path, BOOL succeeded, NSError *_Nullable error) {
        if (succeeded) {
            NSFileManager *fileManager = [NSFileManager defaultManager];
            NSError *error;
            BOOL isSuccessOne = [fileManager copyItemAtPath:filePath toPath:toDownLoadPath error:&error];
            BOOL isSuccessTwo = [fileManager copyItemAtPath:filePath toPath:toPreversionPath error:&error];
            NSLog(@"isSuccessOne = %d\nisSuccessTwo = %d", isSuccessOne, isSuccessTwo);
        }
    }];
}

/**
 *  意见反馈
 */
- (void)feedBackDetailInfo {
    NSString *hybridserverPath = [PathConstants gcdWebServerRootDirectory];
    NSString *downPath         = [PathConstants downLoadDirectory];
    NSString *preversionPath   = [PathConstants preversionDirectory];
    NSString *fileName         = @"safe.zip";
    NSString *filePath         = [NSString stringWithFormat:@"%@/%@", downPath, fileName];

    @weakify(self)
        [SSZipArchive unzipFileAtPath:filePath toDestination:hybridserverPath progressHandler:^(NSString *_Nonnull entry, unz_file_info zipInfo, long entryNumber, long total) {

        } completionHandler:^(NSString *_Nonnull path, BOOL succeeded, NSError *_Nullable error) {
            @strongify(self)
                NSLog(@"succeeded = %@", @(succeeded));
            if (succeeded) {
                NSFileManager *fileManager = [NSFileManager defaultManager];
                NSError *error;
                BOOL isSuccessOne = [fileManager removeItemAtPath:downPath error:&error];
                NSLog(@"isSuccessOne = %d", isSuccessOne);
            }
        }];
}

/**
 *  关于
 */
- (void)aboutDetailInfo {
    NSString *format = @"%@_1111_%.2f_3333";
    ZWDebugLog(format, @"0000", @"22222");
    NSString *formatStr = ZWDebugLogStr(format, @"666", 888.2);
    formatStr           = ZWFormatterUrl(format, @"777", 0.006);
    NSLog(@"formatStr = %@", formatStr);
    
    NSString *url = @"https://pages/subPkgsTax/taxClubDetail/index/?id=1005431829342217&news_section=undefined&pushTimeBbzl=1691673134079&openChannelBbzl=wechat&templateNameBbzl=%E5%85%B3%E4%BA%8E%E5%8D%B0%E8%8A%B1%E7%A8%8E%E4%B8%AD%E7%9A%84%E4%B9%B0%E5%8D%96%E5%90%88%E5%90%8C%EF%BC%8C%E9%87%87%E8%B4%AD%E7%9A%84%E5%95%86%E5%93%81%E7%AD%BE%E7%9A%84%E6%98%AF%E6%A1%86%E6%9E%B6%E5%90%88%E5%90%8C%EF%BC%8C%E7%84%B6%E5%90%8E%E9%87%87%E8%B4%AD%E5%AD%98%E5%9C%A8%E5%B9%B3%E9%94%80%E8%BF%94%E5%88%A9%EF%BC%8C%E6%98%AF%E5%90%A6%E5%9C%A8%E8%AE%A1%E7%A8%8E%E6%97%B6%E5%8F%AF%E6%89%A3%E5%87%8F%E7%9B%B8%E5%BA%94%E8%BF%94%E5%88%A9%E9%87%91%E9%A2%9D%EF%BC%9F&templateContentBbzl=%E6%A0%B9%E6%8D%AE%E3%80%8A%E5%8D%B0%E8%8A%B1%E7%A8%8E%E6%B3%95%E3%80%8B%E7%AC%AC%E4%BA%94%E6%9D%A1%26ldquo...%E5%BA%94%E7%A8%8E%E5%90%88%E5%90%8C%E7%9A%84%E8%AE%A1%E7%A8%8E%E4%BE%9D%E6%8D%AE%EF%BC%8C%E4%B8%BA%E5%90%88%E5%90%8C%E6%89%80%E5%88%97%E7%9A%84%E9%87%91%E9%A2%9D%EF%BC%8C%E4%B8%8D%E5%8C%85%E6%8B%AC%E5%88%97%E6%98%8E%E7%9A%84%E5%A2%9E%E5%80%BC%E7%A8%8E%E7%A8%8E%E6%AC%BE&rdquo...";
    NSURL *tempUrl = [NSURL URLWithString:url];
    NSLog(@"tempUrl = %@", tempUrl);

    //    LoginViewController *oneKeyLoginVc = [[LoginViewController alloc] init];
    //    oneKeyLoginVc.oneKeyLogin = YES;
    //    [self presentViewController:oneKeyLoginVc animated:YES completion:nil];
    //    [self.navigationController pushViewController:oneKeyLoginVc animated:YES];
}

static inline void ZWDebugLog(NSString *format, ...) {
    va_list args;
    va_start(args, format);
    NSString *message       = [[NSString alloc] initWithFormat:format arguments:args];
    NSString *hodoerMessage = [NSString stringWithFormat:@"\n------------WMRemoteLog外部打印:------------\n%@", message];
    ZWNSLog(@"abc");
    ZWNSLog(hodoerMessage, args);
    ZWNSLog(@"def");
    va_end(args);
}

static inline NSString *ZWDebugLogStr(NSString *format, ...) {
    NSString *resultStr = @"";
    va_list args;
    va_start(args, format);
    resultStr = [[NSString alloc] initWithFormat:format arguments:args];
    va_end(args);
    return resultStr;
}

/**
 *  用户隐私协议
 */
- (void)go2PrivicyAgreement {
}

- (void)dealWithFile:(PHAssetModel *)fileItem {
    if (fileItem) {
    }

    //    弱引用表
    //    NSMapTable
}

/**
 *  交易风险提示
 */
- (void)go2TradeRiskTip {
    [ZWM.router executeURLNoCallBack:ZWRouterRunLoopPermanentViewController];
}

/**
 *  单选界面
 */
- (void)selectedPageAction {
    NSMutableDictionary *mutDict = [NSMutableDictionary dictionary];
    mutDict[kIsLoadSureBtn]      = @(NO);
    mutDict[kDataList]           = @[@{kSelectName: @"111", @"type": @"1"},
                           @{kSelectName: @"222", @"type": @"2"},
                           @{kSelectName: @"333", @"type": @"3"},
                           @{kSelectName: @"444", @"type": @"4"}];
    mutDict[kSelectName]         = @"444";

    RouterParam *param = [RouterParam makeWith:ZWRouterPageChangeEnvViewController destURL:@"SelectedViewController" params:mutDict.copy type:RouterTypeNavigate context:nil success:^(NSDictionary *result) {
        if ([result isKindOfClass:NSDictionary.class]) {
            NSLog(@"result = %@", result);
        }
    } fail:^(NSError *error){

    }];

    [ZWM.router executeRouterParam:param];
}

/**
 *  打开首页底部广告
 */
- (void)testShowWindow {
    [[ZWColorPickInfoWindow shareInstance] showView];
    CALayer *layer        = [[CALayer alloc] init];
    layer.shouldRasterize = YES; // 可以光栅化
    layer.cornerRadius    = 10;
    layer.masksToBounds   = YES;
    //    layer.mask
}

/**
 *  陀螺仪测试界面 ~ 球
 */
- (void)testBallViewContorller {
    [ZWM.router executeURLNoCallBack:ZWRouterPageBallViewController];
}

/**
 * 自定义Swiper组件
 */
- (void)testSwiperComponent {
    [ZWM.router executeURLNoCallBack:ZWRouterPageCustomSwiperController];
}

/**
 * 小游戏乐园
 */
- (void)showGameCenter {
    CRMGameCenterViewController *controller = [[CRMGameCenterViewController alloc] init];
    [self.navigationController pushViewController:controller animated:YES];
}

/**
 *  未来事项提醒
 */
- (void)scheduledReminder {
    UIViewController *controller = [SettingViewController futureReminderViewController];
    [self.navigationController pushViewController:controller animated:YES];
}

/**
 * 测试推送
 */
- (void)push_test {
    [self pushLocalNotification:@"测试本地推送使用"];
}

- (void)pushLocalNotification:(NSString *)title {
    
    [MMPushUtil pushLocalNotification:title userInfo:@{@"payload" : @{}}];

    return;
    // 创建本地通知时，清理之前所有的本地通知，注意：根据App具体的功能自行修改
    // 清理所有本地通知，程序启动时清理，注意：根据App具体功能需求自行修改，如果App内有其他本地通知，更加需要注意是否要清理所有通知
    [[UIApplication sharedApplication] cancelAllLocalNotifications];

    NSString *gmid                   = nil;
    UILocalNotification *localNotify = [[UILocalNotification alloc] init];
    NSDate *pushDate                 = [NSDate dateWithTimeIntervalSinceNow:1];

    localNotify.fireDate                   = pushDate;
    localNotify.timeZone                   = [NSTimeZone defaultTimeZone];
    localNotify.repeatInterval             = kCFCalendarUnitDay;
    localNotify.soundName                  = UILocalNotificationDefaultSoundName;
    localNotify.alertBody                  = [NSString stringWithFormat:@"Payload : %@\ntime : %@", title, [self formateTime:[NSDate date]]];
    localNotify.alertAction                = NSLocalizedString(@"View Details", nil);
    NSArray *notifyArray                   = [[UIApplication sharedApplication] scheduledLocalNotifications];
    int count                              = (int)[notifyArray count];
    localNotify.applicationIconBadgeNumber = count + 1;
    // 备注：点击统计需要
    if (gmid != nil) {
        NSDictionary *userInfoDict = @{@"_gmid_": gmid};
        localNotify.userInfo       = userInfoDict;
    }
    [[UIApplication sharedApplication] scheduleLocalNotification:localNotify];
}

- (NSString *)formateTime:(NSDate *)date {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *dateTime = [formatter stringFromDate:date];
    return dateTime;
}

#pragma mark-- JFCSTableViewControllerDelegate

- (void)viewController:(JFCSTableViewController *)viewController didSelectCity:(JFCSBaseInfoModel *)model {
    // 选择城市后...
    NSLog(@"name %@ code %zd pinyin %@ alias %@ firstLetter %@", model.name, model.code, model.pinyin, model.alias, model.firstLetter);
    //    [self.cityBtn setTitle:model.name forState:UIControlStateNormal];
}

#pragma mark - EHAddressCompHelperDelegate
- (void)areaViewEndChange:(NSString *)text areaCode:(NSString *)areaCode {
    NSLog(@"text:%@ areaCode:%@", text, areaCode);
}

#pragma mark -  Lazy loading
- (UILabel *)bottomLabel {
    if (!_bottomLabel) {
        _bottomLabel = [UILabel labelWithFrame:CGRectMake(0, 0, kMainScreenWidth, 78) text:@"" textColor:UIColorFromRGB(0x9CA9A5)];
        _bottomLabel.textAlignment = NSTextAlignmentCenter;
        _bottomLabel.font = [UIFont systemFontOfSize:11];
        _bottomLabel.backgroundColor = UIColorFromRGB(0xF4F7F5);
    }
    return _bottomLabel;
}

@end
