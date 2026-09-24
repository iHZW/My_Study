#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonDigest.h>
#import <React/RCTBridgeModule.h>
#import "LXCrypto.h"

@interface LXCryptoModule : NSObject <RCTBridgeModule>
@end

@implementation LXCryptoModule

RCT_EXPORT_MODULE(CryptoModule)

+ (BOOL)requiresMainQueueSetup { return NO; }

RCT_REMAP_METHOD(generateRsaKey, generateRsaKeyWithResolver:(RCTPromiseResolveBlock)resolve
                 rejecter:(RCTPromiseRejectBlock)reject) {
  NSDictionary *keys = LXGenerateRSAKey();
  if (keys) resolve(keys);
  else reject(@"rsa_key_generation_failed", @"RSA 密钥生成失败", nil);
}

RCT_REMAP_METHOD(rsaEncrypt, rsaEncrypt:(NSString *)text key:(NSString *)key padding:(NSString *)padding
                 resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
  NSString *result = LXRSA(text, key, padding, YES);
  if (result.length) resolve(result);
  else reject(@"rsa_encrypt_failed", @"RSA 加密失败", nil);
}

RCT_REMAP_METHOD(rsaDecrypt, rsaDecrypt:(NSString *)text key:(NSString *)key padding:(NSString *)padding
                 resolver:(RCTPromiseResolveBlock)resolve rejecter:(RCTPromiseRejectBlock)reject) {
  NSString *result = LXRSA(text, key, padding, NO);
  if (result.length) resolve(result);
  else reject(@"rsa_decrypt_failed", @"RSA 解密失败", nil);
}

RCT_EXPORT_BLOCKING_SYNCHRONOUS_METHOD(rsaEncryptSync:(NSString *)text key:(NSString *)key
                                       padding:(NSString *)padding) {
  return LXRSA(text, key, padding, YES);
}

RCT_EXPORT_BLOCKING_SYNCHRONOUS_METHOD(rsaDecryptSync:(NSString *)text key:(NSString *)key
                                       padding:(NSString *)padding) {
  return LXRSA(text, key, padding, NO);
}

RCT_REMAP_METHOD(aesEncrypt, aesEncrypt:(NSString *)text key:(NSString *)key iv:(NSString *)iv
                 mode:(NSString *)mode resolver:(RCTPromiseResolveBlock)resolve
                 rejecter:(RCTPromiseRejectBlock)reject) {
  NSString *result = LXAES(text, key, iv, mode, YES);
  if (result.length) resolve(result);
  else reject(@"aes_encrypt_failed", @"AES 加密失败", nil);
}

RCT_REMAP_METHOD(aesDecrypt, aesDecrypt:(NSString *)text key:(NSString *)key iv:(NSString *)iv
                 mode:(NSString *)mode resolver:(RCTPromiseResolveBlock)resolve
                 rejecter:(RCTPromiseRejectBlock)reject) {
  NSString *result = LXAES(text, key, iv, mode, NO);
  if (result.length) resolve(result);
  else reject(@"aes_decrypt_failed", @"AES 解密失败", nil);
}

RCT_EXPORT_BLOCKING_SYNCHRONOUS_METHOD(aesEncryptSync:(NSString *)text key:(NSString *)key
                                       iv:(NSString *)iv mode:(NSString *)mode) {
  return LXAES(text, key, iv, mode, YES);
}

RCT_EXPORT_BLOCKING_SYNCHRONOUS_METHOD(aesDecryptSync:(NSString *)text key:(NSString *)key
                                       iv:(NSString *)iv mode:(NSString *)mode) {
  return LXAES(text, key, iv, mode, NO);
}

RCT_REMAP_METHOD(sha1, sha1:(NSString *)input resolver:(RCTPromiseResolveBlock)resolve
                 rejecter:(RCTPromiseRejectBlock)reject) {
  NSData *data = [input dataUsingEncoding:NSUTF8StringEncoding];
  unsigned char digest[CC_SHA1_DIGEST_LENGTH];
  CC_SHA1(data.bytes, (CC_LONG)data.length, digest);
  NSMutableString *result = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
  for (NSUInteger i = 0; i < CC_SHA1_DIGEST_LENGTH; i++) [result appendFormat:@"%02x", digest[i]];
  resolve(result);
}

@end
