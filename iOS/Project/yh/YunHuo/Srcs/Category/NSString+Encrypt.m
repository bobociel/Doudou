//
//  NSString+Encrypt.m
//  LiCai
//
//  Created by yuyunfeng on 14-9-3.
//
//

#import <CommonCrypto/CommonDigest.h>
#import "NSString+Encrypt.h"

@implementation NSString (Encrypt)


- (NSString *) md5Encrypt
{
    const char *original_str = [self UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(original_str, strlen(original_str), result);
    NSMutableString *hash = [NSMutableString string];
    for (int i = 0; i < 16; i++)
        [hash appendFormat:@"%02X", result[i]];
    return [hash lowercaseString];
}

@end
