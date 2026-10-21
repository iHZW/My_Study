#import "CRMBabyStore.h"


static void BabyZip16(NSMutableData *data, uint16_t value) {
    uint8_t bytes[] = {(uint8_t)value, (uint8_t)(value >> 8)}; [data appendBytes:bytes length:2];
}
static void BabyZip32(NSMutableData *data, uint32_t value) {
    uint8_t bytes[] = {(uint8_t)value, (uint8_t)(value >> 8), (uint8_t)(value >> 16), (uint8_t)(value >> 24)}; [data appendBytes:bytes length:4];
}
static uint32_t BabyZipCRC(uint32_t crc, const uint8_t *bytes, NSUInteger count) {
    static uint32_t table[256]; static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        for (uint32_t i = 0; i < 256; i++) {
            uint32_t value = i; for (NSUInteger bit = 0; bit < 8; bit++) value = (value >> 1) ^ ((value & 1) ? 0xedb88320 : 0);
            table[i] = value;
        }
    });
    for (NSUInteger i = 0; i < count; i++) crc = table[(crc ^ bytes[i]) & 255] ^ (crc >> 8);
    return crc;
}

static NSError *BabyError(NSString *message) {
    return [NSError errorWithDomain:@"CRMBabyTime" code:1 userInfo:@{NSLocalizedDescriptionKey: message}];
}

NSInteger CRMBabyPregnancyDays(NSDate *dueDate, NSDate *today) {
    NSCalendar *calendar = NSCalendar.currentCalendar;
    NSInteger remaining = [calendar components:NSCalendarUnitDay fromDate:[calendar startOfDayForDate:today] toDate:[calendar startOfDayForDate:dueDate] options:0].day;
    return 280 - remaining;
}

NSString *CRMBabyStageTitle(NSDictionary *profile, NSDate *today) {
    NSNumber *birth = profile[@"birthDate"];
    if (birth) {
        NSDate *date = [NSDate dateWithTimeIntervalSince1970:birth.doubleValue];
        NSCalendar *calendar = NSCalendar.currentCalendar;
        NSInteger days = [calendar components:NSCalendarUnitDay fromDate:[calendar startOfDayForDate:date] toDate:[calendar startOfDayForDate:today] options:0].day;
        return [NSString stringWithFormat:@"来到我们身边的第 %ld 天", (long)MAX(1, days + 1)];
    }
    if (!profile[@"dueDate"]) return @"从今天开始，陪你慢慢长大";
    NSInteger days = CRMBabyPregnancyDays([NSDate dateWithTimeIntervalSince1970:[profile[@"dueDate"] doubleValue]], today);
    if (days < 0) return @"请检查预产期设置";
    if (days > 294) return @"请更新预产期或记录出生日期";
    return [NSString stringWithFormat:@"孕 %ld 周 + %ld 天", (long)(days / 7), (long)(days % 7)];
}

@interface CRMBabyStore ()
@property (nonatomic, readwrite, strong) NSURL *directory;
@property (nonatomic, readwrite, strong) NSDictionary *snapshot;
@property (nonatomic, readwrite, strong) NSError *loadError;
@end

@implementation CRMBabyStore
+ (instancetype)shared {
    static CRMBabyStore *store;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSURL *base = [NSFileManager.defaultManager URLsForDirectory:NSApplicationSupportDirectory inDomains:NSUserDomainMask].firstObject;
        store = [[self alloc] initWithDirectory:[base URLByAppendingPathComponent:@"BabyTime" isDirectory:YES]];
    });
    return store;
}
- (instancetype)initWithDirectory:(NSURL *)directory {
    if (self = [super init]) {
        _directory = directory;
        _snapshot = @{@"version": @1, @"profile": @{}, @"favorites": @[], @"entries": @[]};
        NSError *error;
        if (![NSFileManager.defaultManager createDirectoryAtURL:directory withIntermediateDirectories:YES attributes:nil error:&error]) {
            _loadError = error;
            return self;
        }
        NSURL *url = [directory URLByAppendingPathComponent:@"journal.json"];
        if ([NSFileManager.defaultManager fileExistsAtPath:url.path]) {
            NSData *data = [NSData dataWithContentsOfURL:url options:0 error:&error];
            NSDictionary *saved = data ? [NSJSONSerialization JSONObjectWithData:data options:0 error:&error] : nil;
            BOOL valid = [saved isKindOfClass:NSDictionary.class] && [saved[@"version"] isEqual:@1] &&
                [saved[@"profile"] isKindOfClass:NSDictionary.class] && [saved[@"favorites"] isKindOfClass:NSArray.class] &&
                [saved[@"entries"] isKindOfClass:NSArray.class];
            if (valid) {
                for (id value in saved[@"favorites"]) if (![value isKindOfClass:NSString.class]) valid = NO;
                for (id entry in saved[@"entries"]) {
                    if (![entry isKindOfClass:NSDictionary.class] || ![entry[@"id"] isKindOfClass:NSString.class] ||
                        ![entry[@"date"] isKindOfClass:NSNumber.class] || ![entry[@"text"] isKindOfClass:NSString.class] ||
                        (entry[@"file"] && ![entry[@"file"] isKindOfClass:NSString.class])) valid = NO;
                }
                for (NSString *key in @[@"dueDate", @"birthDate"]) {
                    if (saved[@"profile"][key] && ![saved[@"profile"][key] isKindOfClass:NSNumber.class]) valid = NO;
                }
                if (saved[@"profile"][@"nickname"] && ![saved[@"profile"][@"nickname"] isKindOfClass:NSString.class]) valid = NO;
            }
            if (valid) _snapshot = saved;
            else _loadError = error ?: BabyError(@"本地手记格式异常。原文件已保留，请先导出备份再处理，避免覆盖记录。");
        }
    }
    return self;
}
- (BOOL)commit:(NSDictionary *)snapshot error:(NSError **)error {
    if (self.loadError) { if (error) *error = self.loadError; return NO; }
    NSData *data = [NSJSONSerialization dataWithJSONObject:snapshot options:NSJSONWritingPrettyPrinted error:error];
    if (!data || ![data writeToURL:[self.directory URLByAppendingPathComponent:@"journal.json"] options:NSDataWritingAtomic error:error]) return NO;
    self.snapshot = snapshot;
    return YES;
}
- (BOOL)saveProfile:(NSDictionary *)profile error:(NSError **)error {
    NSNumber *birth = profile[@"birthDate"], *due = profile[@"dueDate"];
    if ((birth && (![birth isKindOfClass:NSNumber.class] || birth.doubleValue > NSDate.date.timeIntervalSince1970)) ||
        (due && (![due isKindOfClass:NSNumber.class] || CRMBabyPregnancyDays([NSDate dateWithTimeIntervalSince1970:due.doubleValue], NSDate.date) < 0 || CRMBabyPregnancyDays([NSDate dateWithTimeIntervalSince1970:due.doubleValue], NSDate.date) > 294))) {
        if (error) *error = BabyError(@"日期超出范围，请重新选择预产期或出生日期。"); return NO;
    }
    NSMutableDictionary *next = self.snapshot.mutableCopy;
    next[@"profile"] = profile.copy;
    return [self commit:next error:error];
}
- (BOOL)toggleFavorite:(NSString *)identifier error:(NSError **)error {
    NSMutableArray *favorites = [self.snapshot[@"favorites"] mutableCopy];
    if ([favorites containsObject:identifier]) [favorites removeObject:identifier];
    else [favorites addObject:identifier];
    NSMutableDictionary *next = self.snapshot.mutableCopy;
    next[@"favorites"] = favorites;
    return [self commit:next error:error];
}
- (BOOL)addEntry:(NSDictionary *)entry error:(NSError **)error {
    NSString *text = [entry[@"text"] stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet];
    if (!text.length && !entry[@"file"]) { if (error) *error = BabyError(@"写下一句话，或添加一张照片吧。"); return NO; }
    NSMutableDictionary *item = entry.mutableCopy;
    item[@"id"] = NSUUID.UUID.UUIDString;
    item[@"date"] = @(NSDate.date.timeIntervalSince1970);
    item[@"text"] = text ?: @"";
    NSMutableArray *entries = [self.snapshot[@"entries"] mutableCopy];
    [entries insertObject:item atIndex:0];
    NSMutableDictionary *next = self.snapshot.mutableCopy;
    next[@"entries"] = entries;
    return [self commit:next error:error];
}
- (BOOL)removeEntry:(NSString *)identifier error:(NSError **)error {
    NSMutableArray *entries = [self.snapshot[@"entries"] mutableCopy];
    NSUInteger index = [entries indexOfObjectPassingTest:^BOOL(NSDictionary *entry, NSUInteger idx, BOOL *stop) { return [entry[@"id"] isEqual:identifier]; }];
    if (index == NSNotFound) return YES;
    // 先原子提交索引；附件保留到备份中，避免删除共享附件或保存失败造成数据丢失。
    [entries removeObjectAtIndex:index];
    NSMutableDictionary *next = self.snapshot.mutableCopy;
    next[@"entries"] = entries;
    return [self commit:next error:error];
}
- (NSURL *)saveAttachment:(NSData *)data extension:(NSString *)extension error:(NSError **)error {
    if (self.loadError) { if (error) *error = self.loadError; return nil; }
    if (![@[@"jpg", @"m4a", @"mp3", @"wav", @"aac", @"caf", @"aiff"] containsObject:extension.lowercaseString]) {
        if (error) *error = BabyError(@"暂不支持此附件格式。"); return nil;
    }
    NSURL *url = [self.directory URLByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@", NSUUID.UUID.UUIDString, extension.lowercaseString]];
    return [data writeToURL:url options:NSDataWritingAtomic error:error] ? url : nil;
}
- (NSURL *)attachmentURL:(NSString *)filename {
    if (!filename.length || ![filename isEqualToString:filename.lastPathComponent] || [filename isEqualToString:@".."] || [filename isEqualToString:@"."]) return nil;
    NSURL *url = [self.directory URLByAppendingPathComponent:filename];
    return [NSFileManager.defaultManager fileExistsAtPath:url.path] ? url : nil;
}
- (NSURL *)exportArchive:(NSError **)error {
    NSURL *destination = [[NSURL fileURLWithPath:NSTemporaryDirectory() isDirectory:YES] URLByAppendingPathComponent:[NSString stringWithFormat:@"宝宝时光-%@.zip", NSUUID.UUID.UUIDString]];
    NSError *failure;
    NSArray<NSURL *> *files = [NSFileManager.defaultManager contentsOfDirectoryAtURL:self.directory includingPropertiesForKeys:@[NSURLIsRegularFileKey] options:NSDirectoryEnumerationSkipsHiddenFiles error:&failure];
    if (!files) { if (error) *error = failure; return nil; }
    NSOutputStream *output = [NSOutputStream outputStreamWithURL:destination append:NO]; [output open];
    __block uint64_t offset = 0;
    __block NSError *writeError;
    BOOL (^write)(NSData *) = ^BOOL(NSData *data) {
        const uint8_t *bytes = data.bytes; NSUInteger remaining = data.length;
        while (remaining) {
            NSInteger count = [output write:bytes maxLength:remaining];
            if (count <= 0) { writeError = output.streamError ?: BabyError(@"备份写入失败，请检查剩余空间。"); return NO; }
            bytes += count; remaining -= count; offset += count;
            if (offset > UINT32_MAX) { writeError = BabyError(@"备份超过 4 GB，请先分批导出附件。"); return NO; }
        }
        return YES;
    };
    NSMutableArray<NSDictionary *> *central = [NSMutableArray new];
    NSMutableArray *sources = [NSMutableArray new];
    BOOL hasJournal = NO;
    for (NSURL *url in files) {
        NSNumber *regular; [url getResourceValue:&regular forKey:NSURLIsRegularFileKey error:nil];
        if (!regular.boolValue) continue;
        if ([url.lastPathComponent isEqual:@"journal.json"]) hasJournal = YES;
        [sources addObject:@{@"name": url.lastPathComponent, @"url": url}];
    }
    if (!hasJournal) [sources addObject:@{@"name": @"journal.json", @"data": [NSJSONSerialization dataWithJSONObject:self.snapshot options:NSJSONWritingPrettyPrinted error:nil]}];
    if (sources.count > UINT16_MAX) { [output close]; if (error) *error = BabyError(@"附件数量过多，无法生成单个备份。"); return nil; }
    // ZIP 使用 UTF-8 文件名与数据描述符，逐块写入；不依赖系统目录上传服务。
    for (NSDictionary *source in sources) {
        NSData *name = [source[@"name"] dataUsingEncoding:NSUTF8StringEncoding];
        uint32_t start = (uint32_t)offset;
        NSMutableData *header = [NSMutableData new];
        BabyZip32(header, 0x04034b50); BabyZip16(header, 20); BabyZip16(header, 0x0808); BabyZip16(header, 0);
        BabyZip16(header, 0); BabyZip16(header, 0x21); BabyZip32(header, 0); BabyZip32(header, 0); BabyZip32(header, 0);
        BabyZip16(header, (uint16_t)name.length); BabyZip16(header, 0); [header appendData:name];
        if (!write(header)) break;
        NSInputStream *input = source[@"data"] ? [NSInputStream inputStreamWithData:source[@"data"]] : [NSInputStream inputStreamWithURL:source[@"url"]];
        [input open]; uint8_t buffer[65536]; uint64_t size = 0; uint32_t crc = UINT32_MAX;
        while (YES) {
            NSInteger count = [input read:buffer maxLength:sizeof(buffer)];
            if (count == 0) break;
            if (count < 0) { writeError = input.streamError ?: BabyError(@"附件读取失败，请重试。"); break; }
            size += count; crc = BabyZipCRC(crc, buffer, (NSUInteger)count);
            if (!write([NSData dataWithBytes:buffer length:(NSUInteger)count])) break;
        }
        [input close]; if (writeError) break;
        crc ^= UINT32_MAX;
        NSMutableData *descriptor = [NSMutableData new]; BabyZip32(descriptor, 0x08074b50); BabyZip32(descriptor, crc); BabyZip32(descriptor, (uint32_t)size); BabyZip32(descriptor, (uint32_t)size);
        if (!write(descriptor)) break;
        [central addObject:@{@"name": name, @"crc": @(crc), @"size": @(size), @"offset": @(start)}];
    }
    uint32_t centralStart = (uint32_t)offset;
    if (!writeError) for (NSDictionary *item in central) {
        NSData *name = item[@"name"]; NSMutableData *header = [NSMutableData new];
        BabyZip32(header, 0x02014b50); BabyZip16(header, 20); BabyZip16(header, 20); BabyZip16(header, 0x0808); BabyZip16(header, 0);
        BabyZip16(header, 0); BabyZip16(header, 0x21); BabyZip32(header, [item[@"crc"] unsignedIntValue]);
        BabyZip32(header, [item[@"size"] unsignedIntValue]); BabyZip32(header, [item[@"size"] unsignedIntValue]);
        BabyZip16(header, (uint16_t)name.length); BabyZip16(header, 0); BabyZip16(header, 0); BabyZip16(header, 0); BabyZip16(header, 0);
        BabyZip32(header, 0); BabyZip32(header, [item[@"offset"] unsignedIntValue]); [header appendData:name];
        if (!write(header)) break;
    }
    if (!writeError) {
        uint32_t centralSize = (uint32_t)offset - centralStart;
        NSMutableData *end = [NSMutableData new]; BabyZip32(end, 0x06054b50); BabyZip16(end, 0); BabyZip16(end, 0);
        BabyZip16(end, (uint16_t)central.count); BabyZip16(end, (uint16_t)central.count); BabyZip32(end, centralSize); BabyZip32(end, centralStart); BabyZip16(end, 0);
        write(end);
    }
    [output close];
    if (writeError) { if (error) *error = writeError; return nil; }
    return destination;
}
@end
