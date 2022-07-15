//
//  RSAEncryption.h
//  TZYJ_IPhone
//
//  Created by Howard on 15/9/8.
//
//

#import <Foundation/Foundation.h>
#include "openssl/rsa.h"
#include "openssl/pem.h"
#include "openssl/err.h"


/**
 *  RSA密钥类型
 */
typedef NS_ENUM(NSInteger, RSAKeyType) {
    /**
     *  公钥类型
     */
    RSAKeyTypePublic,
    /**
     *  私钥类型
     */
    RSAKeyTypePrivate
};

/**
 *  RSA Padding 模式
 */
typedef NS_ENUM(NSInteger, RSA_PADDING_TYPE) {
    /**
     *  不填充
     */
    RSA_PADDING_TYPE_NONE       = RSA_NO_PADDING,
    /**
     *  PKCS1填充模式
     */
    RSA_PADDING_TYPE_PKCS1      = RSA_PKCS1_PADDING,
    /**
     *  SSLV23填充模式
     */
    // default
    RSA_PADDING_TYPE_SSLV23     = RSA_SSLV23_PADDING
};

/**
 *  证书类型
 */
typedef NS_ENUM(NSInteger, CertFormatType) {
    /**
     *  DER类型
     */
    CertFormat_DER,
    /**
     *  PEM类型
     */
    CertFormat_PEM,
    /**
     *  P12证书类型
     */
    CertFormat_P12,
};


@interface RSAEncryption : NSObject

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
+ (RSA *)importRSAKeyWithType:(RSAKeyType)type keyFilePath:(NSString *)keyFilePath certType:(CertFormatType)certType password:(NSString *)password;

/**
 *  保存(PEM证书类型)RSA公钥内容到本地路径
 *
 *  @param keyContent RSA公钥证书
 *  @param filePath   保存路径
 *
 *  @return 返回保存操作状态(YES:成功 NO:失败)
 */
+ (BOOL)savePublicKeyPEM:(NSString *)keyContent filePath:(NSString *)filePath;

/**
 *  保存RSA私钥内容到本地路径
 *
 *  @param keyContent RSA私钥证书
 *  @param filePath   保存路径
 *
 *  @return 返回保存操作状态(YES:成功 NO:失败)
 */
+ (BOOL)savePrivateKeyPEM:(NSString *)keyContent filePath:(NSString *)filePath;

/**
 *  保存RSA PEM证书内容到本地路径
 *
 *  @param keyContent RSA PEM证书内容
 *  @param filePath   保存路径
 *
 *  @return 返回保存操作状态(YES:成功 NO:失败)
 */
+ (BOOL)saveKeyPEMCert:(NSString *)keyContent filePath:(NSString *)filePath;

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
                password:(NSString *)password;

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
             paddingType:(RSA_PADDING_TYPE)paddingType;

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
                password:(NSString *)password;

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
             paddingType:(RSA_PADDING_TYPE)paddingType;

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
                             paddingType:(RSA_PADDING_TYPE)paddingType;

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
                               paddingType:(RSA_PADDING_TYPE)paddingType;

@end
