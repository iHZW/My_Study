#import "../My_Study/Business/BabyTime/CRMBabyStore.h"
#include <assert.h>

static NSDate *Day(NSString *value) {
    NSDateFormatter *format = [NSDateFormatter new]; format.dateFormat = @"yyyy-MM-dd"; format.locale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"]; format.timeZone = [NSTimeZone timeZoneWithName:@"America/Los_Angeles"];
    return [format dateFromString:value];
}
int main(void) {
    @autoreleasepool {
        // 按日历日计算，覆盖夏令时和闰年，避免固定秒数导致孕周偏一天。
        [NSTimeZone setDefaultTimeZone:[NSTimeZone timeZoneWithName:@"America/Los_Angeles"]];
        assert((CRMBabyPregnancyDays(Day(@"2026-12-03"), Day(@"2026-07-16")) == 140));
        assert((CRMBabyPregnancyDays(Day(@"2026-12-03"), Day(@"2026-07-17")) == 141));
        assert((CRMBabyPregnancyDays(Day(@"2024-03-10"), Day(@"2024-03-09")) == 279));
        assert((CRMBabyPregnancyDays(Day(@"2024-03-11"), Day(@"2024-03-10")) == 279));
        assert((CRMBabyPregnancyDays(Day(@"2024-03-01"), Day(@"2024-02-28")) == 278));
        NSDictionary *profile = @{@"dueDate": @(Day(@"2026-12-03").timeIntervalSince1970)};
        assert(([CRMBabyStageTitle(profile, Day(@"2026-07-16")) isEqualToString:@"孕 20 周 + 0 天"]));
        assert(([CRMBabyStageTitle(profile, Day(@"2026-12-04")) hasPrefix:@"孕"]));
        assert(([CRMBabyStageTitle(@{@"birthDate": @(Day(@"2026-07-16").timeIntervalSince1970)}, Day(@"2026-07-16")) containsString:@"第 1 天"]));
        assert(([CRMBabyStageTitle(@{}, NSDate.date) length] > 0));
        NSLog(@"通过：孕周、闰年、夏令时、预产期后不自动切换及出生首日。");

        NSURL *root = [[NSURL fileURLWithPath:NSTemporaryDirectory()] URLByAppendingPathComponent:NSUUID.UUID.UUIDString];
        CRMBabyStore *store = [[CRMBabyStore alloc] initWithDirectory:root];
        assert((!store.loadError));
        NSError *error;
        NSDate *due = [NSCalendar.currentCalendar dateByAddingUnit:NSCalendarUnitDay value:154 toDate:NSDate.date options:0];
        assert(([store saveProfile:@{@"dueDate": @(due.timeIntervalSince1970), @"nickname": @"小豆"} error:&error]));
        assert(([store toggleFavorite:@"hello" error:&error]));
        assert(([store.snapshot[@"favorites"] count] == 1));
        assert(([store toggleFavorite:@"hello" error:&error]));
        assert(([store.snapshot[@"favorites"] count] == 0));
        assert((![store addEntry:@{@"text": @" \n  "} error:&error]));
        assert(([store addEntry:@{@"text": @"  今天读了故事  ", @"type": @"text"} error:&error]));
        NSDictionary *first = [store.snapshot[@"entries"] firstObject];
        assert(([first[@"text"] isEqualToString:@"今天读了故事"]));
        assert(([first[@"id"] length]));
        CRMBabyStore *restarted = [[CRMBabyStore alloc] initWithDirectory:root];
        assert(([restarted.snapshot isEqualToDictionary:store.snapshot]));
        assert((![restarted saveProfile:@{@"birthDate": @([NSDate dateWithTimeIntervalSinceNow:86400].timeIntervalSince1970)} error:&error]));
        assert(([restarted.snapshot isEqualToDictionary:store.snapshot]));
        NSLog(@"通过：资料、收藏、空白过滤、手记原子保存、重启恢复及非法日期回滚。");

        NSMutableData *imageData = [NSMutableData dataWithLength:190000];
        memset(imageData.mutableBytes, 0x41, imageData.length);
        NSURL *attachment = [store saveAttachment:imageData extension:@"jpg" error:&error];
        assert((attachment && [store attachmentURL:attachment.lastPathComponent]));
        assert((![store attachmentURL:@"../journal.json"]));
        assert((![store attachmentURL:@".."]));
        assert((![store saveAttachment:[NSData data] extension:@"exe" error:&error]));
        assert(([store addEntry:@{@"type": @"photo", @"text": @"", @"file": attachment.lastPathComponent} error:&error]));
        assert(([store removeEntry:first[@"id"] error:&error]));
        assert(([store.snapshot[@"entries"] count] == 1));
        assert(([store attachmentURL:attachment.lastPathComponent]));
        NSLog(@"通过：附件保存、路径穿越防护、格式限制和单条移除。");

        NSURL *broken = [root URLByAppendingPathComponent:@"broken"];
        [NSFileManager.defaultManager createDirectoryAtURL:broken withIntermediateDirectories:YES attributes:nil error:nil];
        NSData *badData = [@"{bad json" dataUsingEncoding:NSUTF8StringEncoding];
        [badData writeToURL:[broken URLByAppendingPathComponent:@"journal.json"] atomically:YES];
        CRMBabyStore *bad = [[CRMBabyStore alloc] initWithDirectory:broken];
        assert((bad.loadError));
        assert((![bad addEntry:@{@"text": @"不能覆盖旧文件"} error:&error]));
        assert(([[NSData dataWithContentsOfURL:[broken URLByAppendingPathComponent:@"journal.json"]] isEqual:badData]));
        CRMBabyStore *unwritable = [[CRMBabyStore alloc] initWithDirectory:[NSURL fileURLWithPath:@"/dev/null/babytime"]];
        assert((unwritable.loadError));
        assert((![unwritable addEntry:@{@"text": @"失败时不更新内存"} error:&error]));
        assert(([unwritable.snapshot[@"entries"] count] == 0));
        NSLog(@"通过：损坏数据不覆盖、目录失败与保存失败回滚。");

        NSMutableSet *ids = [NSMutableSet new];
        assert((CRMBabyReadings().count >= 12));
        for (NSDictionary *reading in CRMBabyReadings()) {
            assert(([reading[@"body"] length] > 100 && [reading[@"source"] length]));
            assert((![ids containsObject:reading[@"id"]])); [ids addObject:reading[@"id"]];
        }
        assert((CRMBabyMelodies().count == 14));
        assert((CRMBabyPrenatalReadings().count >= 16));
        assert((CRMBabyConversationPrompts(NO).count > 0));
        assert((CRMBabyConversationPrompts(YES).count > 0));
        assert((CRMBabyWeekGuides().count == 23));
        for (NSInteger week = 18; week <= 40; week++) {
            NSDictionary *guide = CRMBabyWeekGuides()[(NSUInteger)(week - 18)];
            assert(([guide[@"week"] integerValue] == week));
            assert(([guide[@"prompt"] length] > 10));
        }
        for (NSDictionary *reading in CRMBabyPrenatalReadings()) {
            assert(([reading[@"body"] length] > 100));
            assert((![ids containsObject:reading[@"id"]]));
            [ids addObject:reading[@"id"]];
        }
        NSLog(@"通过：原创短文、两阶段聊天话题、23周陪伴主题与14段旋律目录。");
        NSURL *archive = [store exportArchive:&error];
        if (!archive) NSLog(@"备份失败：%@", error);
        assert((archive && [NSFileManager.defaultManager fileExistsAtPath:archive.path]));
        NSLog(@"通过：备份导出 %@", archive.path);
    }
}
