//
//  Amatino Swift
//  AMCryptography.m
//
//  author: hugh@amatino.io
//

#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonCrypto.h>
#import "AMCryptography.h"

@implementation AMSignature

+ (NSString *)sha512:(NSString *)apiKey data:(NSString *)dataToHash {

    const char *ckey = [apiKey cStringUsingEncoding:NSASCIIStringEncoding];
    const char *cdata = [dataToHash cStringUsingEncoding:NSASCIIStringEncoding];

    unsigned char chmac[CC_SHA512_DIGEST_LENGTH];

    CCHmac(kCCHmacAlgSHA512, ckey, strlen(ckey), cdata, strlen(cdata), chmac);

    NSData *hmac = [[NSData alloc] initWithBytes:chmac length:sizeof(chmac)];
    NSString *signature = [hmac base64EncodedStringWithOptions:0];

    return signature;
}

@end
