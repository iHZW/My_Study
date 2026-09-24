#import <Foundation/Foundation.h>
#import "../LXMusicNative/LXCrypto.h"

int main(void) {
  @autoreleasepool {
    NSData *plain = [@"洛雪 iOS 加密验证" dataUsingEncoding:NSUTF8StringEncoding];
    NSString *input = [plain base64EncodedStringWithOptions:0];
    NSString *key = [[@"0123456789abcdef" dataUsingEncoding:NSUTF8StringEncoding]
        base64EncodedStringWithOptions:0];
    NSString *iv = [[@"fedcba9876543210" dataUsingEncoding:NSUTF8StringEncoding]
        base64EncodedStringWithOptions:0];
    NSString *encrypted = LXAES(input, key, iv, @"AES/CBC/PKCS7Padding", YES);
    NSCAssert([LXAES(encrypted, key, iv, @"AES/CBC/PKCS7Padding", NO)
                  isEqualToString:@"洛雪 iOS 加密验证"], @"AES 往返失败");
    NSDictionary<NSString *, NSString *> *keys = LXGenerateRSAKey();
    NSCAssert(keys != nil, @"RSA 密钥生成失败");
    NSString *ciphertext = LXRSA(input, keys[@"publicKey"],
                                 @"RSA/ECB/OAEPWithSHA1AndMGF1Padding", YES);
    NSCAssert([LXRSA(ciphertext, keys[@"privateKey"],
                     @"RSA/ECB/OAEPWithSHA1AndMGF1Padding", NO)
                  isEqualToString:@"洛雪 iOS 加密验证"], @"RSA 往返失败");
    NSLog(@"LXCrypto 冒烟测试通过");
  }
  return 0;
}
