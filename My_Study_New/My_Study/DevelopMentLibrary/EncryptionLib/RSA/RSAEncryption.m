//
//  RSAEncryption.m
//  TZYJ_IPhone
//
//  Created by Howard on 15/9/8.
//
//

#import "RSAEncryption.h"
#import "NSString+Base64.h"
#import "NSData+Base64.h"
#include "openssl/pkcs12.h"


#define BUFFSIZE  1024


@interface RSAEncryption ()

+ (NSInteger)getBlockSizeWithRSA_PADDING_TYPE:(RSA *)_rsa paddingType:(RSA_PADDING_TYPE)padding_type;

+ (NSArray *)seperateStringByLen:(NSString *)content len:(int)len;

@end


@implementation RSAEncryption

#pragma mark - private's method
+ (NSInteger)getBlockSizeWithRSA_PADDING_TYPE:(RSA *)_rsa paddingType:(RSA_PADDING_TYPE)padding_type
{
    NSInteger len = RSA_size(_rsa);
    
    if (padding_type == RSA_PADDING_TYPE_PKCS1 || padding_type == RSA_PADDING_TYPE_SSLV23) {
        len -= 11;
    }
    
    return len;
}

+ (NSArray *)seperateStringByLen:(NSString *)content len:(int)len
{
    NSArray *retVal = nil;
    if (len > 0)
    {
        NSInteger cntLen  = [content length];
        NSInteger offset  = cntLen % len == 0 ? 0 : 1;
        NSInteger count   = cntLen / len + offset;
        
        NSMutableArray *keyArr = [NSMutableArray array];
        
        if (cntLen / len > 0)
        {
            for (NSInteger i = 0; i < count; i++)
            {
                [keyArr addObject:[[content substringFromIndex:i * len] substringToIndex:MIN(len, cntLen-i*len)]];
            }
            
            retVal = keyArr;
        }
        else
            retVal  = [NSArray arrayWithObjects:content, nil];
    }
    
    return retVal;
}

/**
 *  导入DER类型RSA
 *
 *  @param type        RSA密钥类型
 *  @param keyFilePath RSA密钥路径
 *
 *  @return 返回RSA对象
 */
+ (RSA *)importRSAKeyWithDER:(RSAKeyType)type keyFilePath:(NSString *)keyFilePath
{
    FILE *file;
    RSA *_rsa;
    file = fopen([keyFilePath UTF8String], "rb");
    
    if (NULL != file)
    {
        if (RSAKeyTypePublic == type)
        {
            _rsa = d2i_RSAPublicKey_fp(file, NULL);
            assert(_rsa != NULL);
        }
        else
        {
            _rsa = d2i_RSAPrivateKey_fp(file, NULL);
            assert(_rsa != NULL);
        }
        
        fclose(file);
        
        return _rsa;
    }
    
    return NULL;
}

/**
 *  导入P12类型RSA
 *
 *  @param keyFilePath RSA密钥路径
 *  @param password    P12文件密码
 *
 *  @return 返回RSA对象
 */
+ (RSA *)importRSAKeyWithP12:(NSString *)keyFilePath password:(NSString *)password
{
    FILE *file;
    RSA *_rsa = NULL;
    file = fopen([keyFilePath UTF8String], "rb");
    
    if (NULL != file)
    {
        PKCS12 *p12         = NULL;
        X509 * userCert     = NULL;
        EVP_PKEY *pkey      = NULL;
        STACK_OF(X509) * ca = NULL;
        char *pwd           = [password length] > 0 ? (char *)[password UTF8String] : "";
        
        p12 = d2i_PKCS12_fp(file, NULL);                // 得到p12结构
        PKCS12_parse(p12, pwd, &pkey, &userCert, &ca);  // 得到X509结构
        
        if (pkey)
        {
            _rsa = pkey->pkey.rsa;
        }
        
        fclose(file);
        EVP_PKEY_free(pkey);
        X509_free(userCert);
        sk_X509_free(ca);
    }
    
    return _rsa;
}

/**
 *  导入PEM类型RSA密钥
 *
 *  @param type        RSA密钥类型
 *  @param keyFilePath RSA密钥路径
 *
 *  @return 返回RSA对象
 */
+ (RSA *)importRSAKeyWithPEM:(RSAKeyType)type keyFilePath:(NSString *)keyFilePath
{
    FILE *file;
    RSA *_rsa;
    file = fopen([keyFilePath UTF8String], "rb");
    
    if (NULL != file)
    {
        if (RSAKeyTypePublic == type)
        {
            //            d2i_PrivateKey_fp(<#FILE *fp#>, <#EVP_PKEY **a#>)
            _rsa = PEM_read_RSA_PUBKEY(file, NULL, NULL, NULL);
            assert(_rsa != NULL);
        }
        else
        {
            _rsa = PEM_read_RSAPrivateKey(file, NULL, NULL, NULL);
            assert(_rsa != NULL);
        }
        
        fclose(file);
        
        return _rsa;
    }
    
    return NULL;
}

#pragma mark - public's method
/**
 *  导入指定证书类型RSA密钥
 *
 *  @param type        RSA密钥类型
 *  @param keyFilePath RSA密钥路径
 *  @param certType    证书类型
 *  @param password    密码(针对P12证书类型)
 *
 *  @return 返回RSA对象
 */
+ (RSA *)importRSAKeyWithType:(RSAKeyType)type keyFilePath:(NSString *)keyFilePath certType:(CertFormatType)certType password:(NSString *)password
{
    RSA *_rsa = NULL;
    
    switch (certType) {
        case CertFormat_PEM:
        {
            _rsa = [RSAEncryption importRSAKeyWithPEM:type keyFilePath:keyFilePath];
        }
            break;
        case CertFormat_DER:
        {
            _rsa = [RSAEncryption importRSAKeyWithDER:type keyFilePath:keyFilePath];
        }
            break;
        case CertFormat_P12:
        {
            _rsa = [RSAEncryption importRSAKeyWithP12:keyFilePath password:password];
        }
            break;
            
        default:
            break;
            
    }
    
    return _rsa;
}

/**
 *  保存RSA公钥内容到本地路径
 *
 *  @param keyContent RSA公钥证书
 *  @param filePath   保存路径
 *
 *  @return 返回保存操作状态(YES:成功 NO:失败)
 */
+ (BOOL)savePublicKeyPEM:(NSString *)keyContent filePath:(NSString *)filePath
{
    BOOL bRet = NO;
    NSArray *keyArr = [[self class] seperateStringByLen:keyContent len:64];
    
    if (keyArr)
    {
        NSString *publicKeyStr = @"-----BEGIN PUBLIC KEY-----\n";
        for (int i = 0; i < [keyArr count]; i++)
        {
            publicKeyStr = [publicKeyStr stringByAppendingString:[NSString stringWithFormat:@"%@\n", [keyArr objectAtIndex:i]]];
        }
        publicKeyStr = [publicKeyStr stringByAppendingString:@"-----END PUBLIC KEY-----"];
        
        bRet = [publicKeyStr writeToFile:filePath atomically:YES encoding:NSASCIIStringEncoding error:nil];
    }
    
    return bRet;
}

/**
 *  保存RSA私钥内容到本地路径
 *
 *  @param keyContent RSA私钥证书
 *  @param filePath   保存路径
 *
 *  @return 返回保存操作状态(YES:成功 NO:失败)
 */
+ (BOOL)savePrivateKeyPEM:(NSString *)keyContent filePath:(NSString *)filePath
{
    BOOL bRet = NO;
    NSArray *keyArr = [[self class] seperateStringByLen:keyContent len:64];
    
    if (keyArr)
    {
        NSString *publicKeyStr = @"-----BEGIN RSA PRIVATE KEY-----\n";
        for (int i = 0; i < [keyArr count]; i++)
        {
            publicKeyStr = [publicKeyStr stringByAppendingString:[NSString stringWithFormat:@"%@\n", [keyArr objectAtIndex:i]]];
        }
        publicKeyStr = [publicKeyStr stringByAppendingString:@"-----END RSA PRIVATE KEY----------"];
        
        bRet = [publicKeyStr writeToFile:filePath atomically:YES encoding:NSASCIIStringEncoding error:nil];
    }
    
    return bRet;
}

/**
 *  保存RSA PEM证书内容到本地路径
 *
 *  @param keyContent RSA PEM证书内容
 *  @param filePath   保存路径
 *
 *  @return 返回保存操作状态(YES:成功 NO:失败)
 */
+ (BOOL)saveKeyPEMCert:(NSString *)keyContent filePath:(NSString *)filePath
{
    BOOL bRet = [keyContent writeToFile:filePath atomically:YES encoding:NSASCIIStringEncoding error:nil];
    return bRet;
}

/**
 *  通过指定RSA密钥类型、填充模式、密钥路径、证书模式和证书密码(针对p12证书)，对指定字符串进行RSA加密处理
 *
 *  @param content     需要加密的字符串
 *  @param keyType     RSA密钥类型
 *  @param keyFilePath 密钥证书路径
 *  @param paddingType RSA加密填充模式
 *  @param certType    证书类型
 *  @param password    P12证书密码
 *
 *  @return 返回RSA加密后二进制数据
 */
+ (NSData *)encryptByRsa:(NSString*)content
             withKeyType:(RSAKeyType)keyType
             keyFilePath:(NSString *)keyFilePath
             paddingType:(RSA_PADDING_TYPE)paddingType
                 cerType:(CertFormatType)certType
                password:(NSString *)password
{
    RSA *_rsa = [RSAEncryption importRSAKeyWithType:keyType keyFilePath:keyFilePath certType:certType password:password];
    
    if (!_rsa)
        return nil;
    NSData *bRetVal = nil;
    
    int status;
    int length = (int)[content length];
    unsigned char input[length + 1];
    bzero(input, length + 1);
    int i = 0;
    
    for (; i < length; i++)
    {
        input[i] = [content characterAtIndex:i];
    }
    
    NSInteger flen = [[self class] getBlockSizeWithRSA_PADDING_TYPE:_rsa paddingType:paddingType];
    
    char *encData = (char*)malloc(flen);
    bzero(encData, flen);
    
    // 注意, RSA加密/解密的数据长度是有限制，例如512位的RSA就只能最多能加密解密64字节的数据
    // 如果采用RSA_NO_PADDING加密方式，512位的RSA就只能加密长度等于64的数据
    // 这个长度可以使用RSA_size()来获得
    
    switch (keyType) {
        case RSAKeyTypePublic:
            status = RSA_public_encrypt(length, (unsigned char*)input, (unsigned char*)encData, _rsa, paddingType);
            break;
            
        default:
            status = RSA_private_encrypt(length, (unsigned char*)input, (unsigned char*)encData, _rsa, paddingType);
            break;
    }
    
    if (status)
    {
        bRetVal = [NSData dataWithBytes:encData length:status];
    }
    
    free(encData);
    encData = NULL;
    
    // 谨记要释放RSA结构
    RSA_free(_rsa);
    _rsa = NULL;
    
    return bRetVal;
}

/**
 *  通过指定RSA密钥类型、填充模式、密钥路径，对指定字符串进行RSA加密处理
 *
 *  @param content     需要加密的字符串
 *  @param keyType     RSA密钥类型
 *  @param keyFilePath 密钥证书路径
 *  @param paddingType RSA加密填充模式
 *
 *  @return 返回RSA加密后二进制数据
 */
+ (NSData *)encryptByRsa:(NSString*)content
             withKeyType:(RSAKeyType)keyType
             keyFilePath:(NSString *)keyFilePath
             paddingType:(RSA_PADDING_TYPE)paddingType
{
    NSData *bRetVal = [[self class] encryptByRsa:content withKeyType:keyType keyFilePath:keyFilePath paddingType:paddingType cerType:CertFormat_PEM password:nil];
    
    return bRetVal;
}

/**
 *  指定RSA密钥类型、填充模式、密钥路径、证书模式和证书密码(针对p12证书)，对RSA加密后数据进行解密处理
 *
 *  @param content     解密的字符串二进制数据
 *  @param keyType     密钥类型
 *  @param keyFilePath 密钥证书路径
 *  @param paddingType RSA解密填充模式
 *  @param certType    证书类型
 *  @param password    P12证书密码
 *
 *
 *  @return 返回RSA解密后二进制数据
 */
+ (NSData *)decryptByRsa:(NSData*)content
             withKeyType:(RSAKeyType)keyType
             keyFilePath:(NSString *)keyFilePath
             paddingType:(RSA_PADDING_TYPE)paddingType
                 cerType:(CertFormatType)certType
                password:(NSString *)password
{
    RSA *_rsa = [RSAEncryption importRSAKeyWithType:keyType keyFilePath:keyFilePath certType:certType password:password];
    if (!_rsa)
        return nil;
    
    NSData *bRetVal = nil;
    
    int status;
    
    NSData *data = content;
    int length = (int)[data length];
    
    NSInteger flen = [[self class] getBlockSizeWithRSA_PADDING_TYPE:_rsa paddingType:paddingType];
    char *decData = (char*)malloc(flen);
    bzero(decData, flen);
    
    switch (keyType) {
        case RSAKeyTypePublic:
            status = RSA_public_decrypt(length, (unsigned char*)[data bytes], (unsigned char*)decData, _rsa, paddingType);
            break;
            
        default:
            status = RSA_private_decrypt(length, (unsigned char*)[data bytes], (unsigned char*)decData, _rsa, paddingType);
            break;
    }
    
    if (status)
    {
        //        [NSString stringWithCString:decData encoding:NSASCIIStringEncoding];
        bRetVal = [NSData dataWithBytes:decData length:strlen(decData)];
    }
    
    free(decData);
    decData = NULL;
    
    RSA_free(_rsa);
    _rsa = NULL;
    
    return bRetVal;
}

/**
 *  对RSA加密后数据进行解密处理
 *
 *  @param content     解密的字符串二进制数据
 *  @param keyType     密钥类型
 *  @param keyFilePath 密钥证书路径
 *  @param paddingType RSA解密填充模式
 *
 *  @return 返回RSA解密后二进制数据
 */
+ (NSData *)decryptByRsa:(NSData*)content
             withKeyType:(RSAKeyType)keyType
             keyFilePath:(NSString *)keyFilePath
             paddingType:(RSA_PADDING_TYPE)paddingType
{
    NSData *bRetVal = [[self class] decryptByRsa:content withKeyType:keyType keyFilePath:keyFilePath paddingType:paddingType cerType:CertFormat_PEM password:nil];
    
    return bRetVal;
}

/**
 *  对加密字符串数据进行RSA加密并进行base64转码
 *
 *  @param content     要加密的字符串信息
 *  @param keyType     密钥类型
 *  @param keyFilePath 密钥证书路径
 *  @param paddingType RSA解密填充模式
 *
 *  @return 返回RSA加密后并进行base64转码处理
 */
+ (NSString *)encryptByRsaToBase64String:(NSString*)content
                             withKeyType:(RSAKeyType)keyType
                             keyFilePath:(NSString *)keyFilePath
                             paddingType:(RSA_PADDING_TYPE)paddingType
{
    NSData *retVal = [[self class] encryptByRsa:content withKeyType:keyType keyFilePath:keyFilePath paddingType:paddingType];
    return [retVal base64EncodedString];
}

/**
 *  对RSA加密后并转换base64加密数据进行解密处理
 *
 *  @param content     RSA加密后并进行base64转码后的密文信息
 *  @param keyType     密钥类型
 *  @param keyFilePath 密钥证书路径
 *  @param paddingType RSA解密填充模式
 *
 *  @return 返回RSA解密后的字符串数据
 */
+ (NSString *)decryptByRsaWithBase64String:(NSString*)content
                               withKeyType:(RSAKeyType)keyType
                               keyFilePath:(NSString *)keyFilePath
                               paddingType:(RSA_PADDING_TYPE)paddingType
{
    NSData *data = [content base64DecodedData];
    NSData *decryptData     = [[self class] decryptByRsa:data withKeyType:keyType keyFilePath:keyFilePath paddingType:paddingType];
    NSString *decryptStr    = [[NSString alloc] initWithData:decryptData encoding:NSUTF8StringEncoding];
   
#if !__has_feature(objc_arc)
    return [decodingStr autorelease];
#else
    return decryptStr;
#endif
}


@end
