#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXPORT NSString *LXAES(NSString *input, NSString *key, NSString *iv,
                                  NSString *mode, BOOL encrypt);
FOUNDATION_EXPORT NSString *LXRSA(NSString *input, NSString *key, NSString *padding,
                                  BOOL encrypt);
FOUNDATION_EXPORT NSDictionary<NSString *, NSString *> * _Nullable LXGenerateRSAKey(void);

NS_ASSUME_NONNULL_END
