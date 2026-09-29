#import "LXCrypto.h"
#import <CommonCrypto/CommonCryptor.h>
#import <Security/Security.h>

static NSData *LXDecodeBase64(NSString *value) {
  NSString *clean = [[value componentsSeparatedByCharactersInSet:
      [NSCharacterSet whitespaceAndNewlineCharacterSet]] componentsJoinedByString:@""];
  return [[NSData alloc] initWithBase64EncodedString:clean options:0];
}

NSString *LXAES(NSString *input, NSString *key, NSString *iv, NSString *mode, BOOL encrypt) {
  NSData *inputData = LXDecodeBase64(input);
  NSData *keyData = LXDecodeBase64(key);
  NSData *ivData = LXDecodeBase64(iv);
  if (!inputData || !keyData ||
      (keyData.length != 16 && keyData.length != 24 && keyData.length != 32)) return @"";
  BOOL cbc = [mode isEqualToString:@"AES/CBC/PKCS7Padding"];
  BOOL ecb = [mode isEqualToString:@"AES"] || [mode isEqualToString:@"AES/ECB/NoPadding"];
  if (!cbc && !ecb) return @"";

  uint8_t ivBytes[kCCBlockSizeAES128] = {0};
  if (ivData.length > 0) [ivData getBytes:ivBytes length:MIN(ivData.length, sizeof(ivBytes))];
  size_t capacity = inputData.length + kCCBlockSizeAES128;
  NSMutableData *output = [NSMutableData dataWithLength:capacity];
  size_t written = 0;
  // Android 的 Cipher.getInstance("AES") 默认使用 ECB + PKCS5/7 填充。
  CCOptions options = kCCOptionPKCS7Padding | (ecb ? kCCOptionECBMode : 0);
  CCCryptorStatus status = CCCrypt(encrypt ? kCCEncrypt : kCCDecrypt, kCCAlgorithmAES,
                                  options, keyData.bytes, keyData.length,
                                  cbc ? ivBytes : NULL, inputData.bytes, inputData.length,
                                  output.mutableBytes, output.length, &written);
  if (status != kCCSuccess) return @"";
  output.length = written;
  if (encrypt) return [output base64EncodedStringWithOptions:0];
  return [[NSString alloc] initWithData:output encoding:NSUTF8StringEncoding] ?: @"";
}

// 从 X.509 SubjectPublicKeyInfo 或 PKCS#8 中取出 RSA PKCS#1 内容。
static NSData *LXInnerRSAKey(NSData *encoded, BOOL publicKey) {
  const uint8_t *bytes = encoded.bytes;
  NSUInteger length = encoded.length;
  if (length < 8 || bytes[0] != 0x30) return nil;
  NSUInteger offset = 0;
  for (NSUInteger i = 0; i < 5 && offset < length; i++) {
    uint8_t tag = bytes[offset++];
    if (offset >= length) return nil;
    NSUInteger fieldLength = bytes[offset++];
    if (fieldLength & 0x80) {
      NSUInteger count = fieldLength & 0x7f;
      if (count == 0 || count > 4 || offset + count > length) return nil;
      fieldLength = 0;
      for (NSUInteger n = 0; n < count; n++) fieldLength = (fieldLength << 8) | bytes[offset++];
    }
    if (offset + fieldLength > length) return nil;
    if ((publicKey && tag == 0x03) || (!publicKey && tag == 0x04)) {
      NSUInteger skip = publicKey ? 1 : 0;
      if (fieldLength <= skip) return nil;
      return [encoded subdataWithRange:NSMakeRange(offset + skip, fieldLength - skip)];
    }
    if (tag == 0x30 && i == 0) continue;
    offset += fieldLength;
  }
  return nil;
}

static NSData *LXDERLength(NSUInteger length) {
  if (length < 128) {
    uint8_t byte = (uint8_t)length;
    return [NSData dataWithBytes:&byte length:1];
  }
  uint8_t bytes[5] = {0};
  NSUInteger count = 0;
  NSUInteger value = length;
  while (value > 0) {
    bytes[4 - count] = (uint8_t)(value & 0xff);
    value >>= 8;
    count++;
  }
  bytes[4 - count] = (uint8_t)(0x80 | count);
  return [NSData dataWithBytes:bytes + 4 - count length:count + 1];
}

static NSData *LXDERWrap(uint8_t tag, NSData *content) {
  NSMutableData *result = [NSMutableData dataWithBytes:&tag length:1];
  [result appendData:LXDERLength(content.length)];
  [result appendData:content];
  return result;
}

static NSData *LXExportRSAKey(SecKeyRef key, BOOL publicKey) {
  CFErrorRef error = NULL;
  NSData *pkcs1 = CFBridgingRelease(SecKeyCopyExternalRepresentation(key, &error));
  if (error) {
    NSLog(@"LXMusic RSA 密钥导出失败：%@", (__bridge NSError *)error);
    CFRelease(error);
  }
  if (!pkcs1) return nil;
  const uint8_t rsaAlgorithm[] = {0x30, 0x0d, 0x06, 0x09, 0x2a, 0x86, 0x48, 0x86,
                                  0xf7, 0x0d, 0x01, 0x01, 0x01, 0x05, 0x00};
  NSMutableData *body = [NSMutableData data];
  if (!publicKey) {
    const uint8_t version[] = {0x02, 0x01, 0x00};
    [body appendBytes:version length:sizeof(version)];
  }
  [body appendBytes:rsaAlgorithm length:sizeof(rsaAlgorithm)];
  if (publicKey) {
    NSMutableData *bitString = [NSMutableData dataWithLength:1];
    [bitString appendData:pkcs1];
    [body appendData:LXDERWrap(0x03, bitString)];
  } else {
    [body appendData:LXDERWrap(0x04, pkcs1)];
  }
  return LXDERWrap(0x30, body);
}

NSDictionary<NSString *, NSString *> *LXGenerateRSAKey(void) {
  NSDictionary *attributes = @{(id)kSecAttrKeyType: (id)kSecAttrKeyTypeRSA,
                               (id)kSecAttrKeySizeInBits: @2048,
                               (id)kSecPrivateKeyAttrs: @{(id)kSecAttrIsPermanent: @NO}};
  CFErrorRef error = NULL;
  SecKeyRef privateKey = SecKeyCreateRandomKey((__bridge CFDictionaryRef)attributes, &error);
  if (error) {
    NSLog(@"LXMusic RSA 密钥生成失败：%@", (__bridge NSError *)error);
    CFRelease(error);
  }
  if (!privateKey) return nil;
  SecKeyRef publicKey = SecKeyCopyPublicKey(privateKey);
  NSData *publicData = publicKey ? LXExportRSAKey(publicKey, YES) : nil;
  NSData *privateData = LXExportRSAKey(privateKey, NO);
  if (publicKey) CFRelease(publicKey);
  CFRelease(privateKey);
  if (!publicData || !privateData) return nil;
  return @{ @"publicKey": [publicData base64EncodedStringWithOptions:0],
            @"privateKey": [privateData base64EncodedStringWithOptions:0] };
}

NSString *LXRSA(NSString *input, NSString *key, NSString *padding, BOOL encrypt) {
  NSData *keyData = LXDecodeBase64(key);
  NSData *payload = LXDecodeBase64(input);
  if (!keyData || !payload) return @"";
  NSData *pkcs1 = LXInnerRSAKey(keyData, encrypt);
  if (!pkcs1) return @"";
  NSDictionary *attributes = @{(id)kSecAttrKeyType: (id)kSecAttrKeyTypeRSA,
                               (id)kSecAttrKeyClass: encrypt ? (id)kSecAttrKeyClassPublic : (id)kSecAttrKeyClassPrivate,
                               (id)kSecAttrKeySizeInBits: @2048};
  CFErrorRef error = NULL;
  SecKeyRef secKey = SecKeyCreateWithData((__bridge CFDataRef)pkcs1,
                                         (__bridge CFDictionaryRef)attributes, &error);
  if (error) CFRelease(error);
  if (!secKey) return @"";
  SecKeyAlgorithm algorithm = [padding isEqualToString:@"RSA/ECB/NoPadding"]
      ? kSecKeyAlgorithmRSAEncryptionRaw : kSecKeyAlgorithmRSAEncryptionOAEPSHA1;
  NSData *result = nil;
  if (SecKeyIsAlgorithmSupported(secKey, encrypt ? kSecKeyOperationTypeEncrypt : kSecKeyOperationTypeDecrypt,
                                 algorithm)) {
    result = encrypt
        ? CFBridgingRelease(SecKeyCreateEncryptedData(secKey, algorithm, (__bridge CFDataRef)payload, &error))
        : CFBridgingRelease(SecKeyCreateDecryptedData(secKey, algorithm, (__bridge CFDataRef)payload, &error));
  }
  if (error) CFRelease(error);
  CFRelease(secKey);
  if (!result) return @"";
  return encrypt ? [result base64EncodedStringWithOptions:0]
                 : ([[NSString alloc] initWithData:result encoding:NSUTF8StringEncoding] ?: @"");
}
