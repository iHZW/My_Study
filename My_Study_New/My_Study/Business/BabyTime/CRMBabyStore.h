#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
FOUNDATION_EXPORT NSString *CRMBabyStageTitle(NSDictionary *profile, NSDate *today);
FOUNDATION_EXPORT NSInteger CRMBabyPregnancyDays(NSDate *dueDate, NSDate *today);
FOUNDATION_EXPORT NSArray<NSDictionary *> *CRMBabyReadings(void);
FOUNDATION_EXPORT NSArray<NSDictionary *> *CRMBabyPrenatalReadings(void);
FOUNDATION_EXPORT NSArray<NSDictionary *> *CRMBabyPodcastLetters(void);
FOUNDATION_EXPORT NSArray<NSDictionary *> *CRMBabyWeekGuides(void);
FOUNDATION_EXPORT NSArray<NSDictionary *> *CRMBabyMelodies(void);
FOUNDATION_EXPORT NSArray<NSString *> *CRMBabyConversationPrompts(BOOL afterBirth);

@interface CRMBabyStore : NSObject
@property (nonatomic, readonly) NSURL *directory;
@property (nonatomic, readonly) NSDictionary *snapshot;
@property (nonatomic, readonly, nullable) NSError *loadError;
+ (instancetype)shared;
- (instancetype)initWithDirectory:(NSURL *)directory;
- (BOOL)saveProfile:(NSDictionary *)profile error:(NSError **)error;
- (BOOL)toggleFavorite:(NSString *)identifier error:(NSError **)error;
- (BOOL)addEntry:(NSDictionary *)entry error:(NSError **)error;
- (BOOL)removeEntry:(NSString *)identifier error:(NSError **)error;
- (nullable NSURL *)saveAttachment:(NSData *)data extension:(NSString *)extension error:(NSError **)error;
- (nullable NSURL *)attachmentURL:(NSString *)filename;
- (nullable NSURL *)exportArchive:(NSError **)error;
@end
NS_ASSUME_NONNULL_END
