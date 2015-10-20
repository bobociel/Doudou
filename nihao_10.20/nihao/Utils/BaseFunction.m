//
//  BaseFunction.m
//  nihao
//
//  Created by HelloWorld on 5/26/15.
//  Copyright (c) 2015 jiazhong. All rights reserved.
//

#import "BaseFunction.h"
#import "Constants.h"
#include <netinet/in.h>
#import <SystemConfiguration/SystemConfiguration.h>
#import "sys/sysctl.h"
#import <CommonCrypto/CommonDigest.h>
#import <MJRefresh/MJRefresh.h>
#import "GTMNSString+URLArguments.h"

@implementation BaseFunction

#pragma mark - 图片调整

//调整图片至指定大小，等比缩放
+(UIImage *)scaleImage:(UIImage *)image toScale:(float)scaleSize
{
    UIGraphicsBeginImageContext(CGSizeMake(image.size.width * scaleSize, image.size.height * scaleSize));
    [image drawInRect:CGRectMake(0, 0, image.size.width * scaleSize, image.size.height * scaleSize)];
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return scaledImage;
}

//调整图片至指定大小，以CGSize与图片的最小比例值进行等比缩放
+(UIImage *)scaleImage:(UIImage *)image toSize:(CGSize)scaleSize
{
    float w = scaleSize.width / image.size.width;
    float h = scaleSize.height / image.size.height;
    float x = w > h ? h : w;
    
    UIGraphicsBeginImageContext(CGSizeMake(image.size.width * x, image.size.height * x));
    [image drawInRect:CGRectMake(0, 0, image.size.width * x, image.size.height * x)];
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return scaledImage;
}


//调整图片至指定大小，以CGSize与图片的最小比例值进行等比缩放
+(UIImage *)scaleImage:(NSString *)imageName toFixed:(CGSize)scaleSize
{
    UIImage *image = [UIImage imageNamed:imageName];
    return [self scaleImage:image toSize:scaleSize];
}

//调整图片至指定大小
+(UIImage *)makeImageSize: (NSString *)imageName toFixed:(CGSize)scaleSize
{
    UIImage *image = [UIImage imageNamed:imageName];
    UIImage *scaledImage = [self makeImageSize:image fixed:scaleSize];
    return scaledImage;
}

//调整图片至指定大小
+(UIImage *)makeImageSize: (UIImage *)image fixed:(CGSize)scaleSize
{
    UIGraphicsBeginImageContext(scaleSize);
    [image drawInRect:CGRectMake(0, 0, scaleSize.width, scaleSize.height)];
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return scaledImage;
}

/**
 *  保存图片到本地
 **/
+(void) saveImageToLocal:(UIImage *)image forKey:(NSString *)key
{
    NSUserDefaults *userDef = [NSUserDefaults standardUserDefaults];
    [userDef setObject:UIImagePNGRepresentation(image) forKey:key];
}

/**
 *  截屏
 **/
+ (UIImage *) getScreenToImage:(UIView *)view area:(CGRect)rect
{
    UIGraphicsBeginImageContext(rect.size);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *parentImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    if(view.frame.size.width > rect.size.width || view.frame.size.height > rect.size.height)
    {
        CGImageRef imageRef = parentImage.CGImage;
        CGImageRef subImageRef = CGImageCreateWithImageInRect(imageRef, rect);
        
        UIGraphicsBeginImageContext(rect.size);
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextDrawImage(context, rect, subImageRef);
        
        UIImage* image = [UIImage imageWithCGImage:subImageRef];
        UIGraphicsEndImageContext();
        CFRelease(subImageRef);
        return image;
    }else{
        return parentImage;
    }
}

/**
 *  截断图片到指定大小
 **/
+ (UIImage *) catOffImage:(UIImage *)image toSize:(CGSize)size
{
    CGRect rect = CGRectMake(0, 0, size.width, size.height);
    CGImageRef subImageRef = CGImageCreateWithImageInRect(image.CGImage, rect);
    CGRect smallBounds = CGRectMake(0, 0, CGImageGetWidth(subImageRef), CGImageGetHeight(subImageRef));
    
    UIGraphicsBeginImageContext(smallBounds.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextDrawImage(context, smallBounds, subImageRef);
    UIImage* smallImage = [UIImage imageWithCGImage:subImageRef];
    
    UIGraphicsEndImageContext();
    CFRelease(subImageRef);
    return smallImage;
}

//保存图片到目录  .../xxx/xxx.jpg
+ (void)saveImage:(UIImage *)image toPath:(NSString *)path {
    [UIImageJPEGRepresentation(image, 1.0) writeToFile:path atomically:YES];
}

// 根据图片类型将图片保存到指定目录下
+ (BOOL)saveImage:(UIImage *)image toPath:(NSString *)path withName:(NSString *)imageName andExtension:(NSString *)extension {
    if ([[extension lowercaseString] isEqualToString:@"png"]) {
        NSLog(@"保存为png格式 ------------");
        [UIImagePNGRepresentation(image) writeToFile:[path stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@", imageName, @"png"]] options:NSAtomicWrite error:nil];
    } else if ([[extension lowercaseString] isEqualToString:@"jpg"] || [[extension lowercaseString] isEqualToString:@"jpeg"]) {
        NSLog(@"保存为jpg格式 ------------");
        [UIImageJPEGRepresentation(image, 1.0) writeToFile:[path stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@", imageName, @"jpg"]] options:NSAtomicWrite error:nil];
    } else {
        NSLog(@"Image Save Failed\nExtension: (%@) is not recognized, use (PNG/JPG)", extension);
        return NO;
    }
    NSLog(@"保存图片成功");
    
    return YES;
}

// 将两张图片合成一张图片
+ (UIImage *)compoundImageWithPhoto:(UIImage *)photo andDoodle:(UIImage *)doodle {
    UIGraphicsBeginImageContext(photo.size);
    // Draw image1
    [photo drawInRect:CGRectMake(0, 0, photo.size.width, photo.size.height)];
    // Draw image2
    [doodle drawInRect:CGRectMake(0, 0, doodle.size.width, doodle.size.height)];
    UIImage *compoundImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return compoundImage;
}

+ (BOOL)compressImage:(UIImage *)image AndSaveToPath:(NSString *)path SaveFileName:(NSString *)fileName andExtension:(NSString *)extension {
    BOOL result;
    NSData *imageCompressData;
    
    if ([[extension lowercaseString] isEqualToString:@"png"]) {
        imageCompressData = UIImagePNGRepresentation(image);
    } else if ([[extension lowercaseString] isEqualToString:@"jpg"] || [[extension lowercaseString] isEqualToString:@"jpeg"]) {
        imageCompressData = UIImageJPEGRepresentation(image, kImageCompressionQualityDefault);
    } else {
        NSLog(@"Image Save Failed\nExtension: (%@) is not recognized, use (PNG/JPG)", extension);
        return NO;
    }
    
    NSString *fullPath = [NSString stringWithFormat:@"%@/%@.%@", path, fileName, [extension lowercaseString]];
    result = [imageCompressData writeToFile:fullPath atomically:YES];
    
    return result;
}

#pragma mark - 网络请求

/**
 *  判断是否已联网
 **/
+(BOOL)isNetworkReachable{
    // Create zero addy
    struct sockaddr_in zeroAddress;
    bzero(&zeroAddress, sizeof(zeroAddress));
    zeroAddress.sin_len = sizeof(zeroAddress);
    zeroAddress.sin_family = AF_INET;
    
    // Recover reachability flags
    SCNetworkReachabilityRef defaultRouteReachability = SCNetworkReachabilityCreateWithAddress(NULL, (struct sockaddr *)&zeroAddress);
    SCNetworkReachabilityFlags flags;
    
    BOOL didRetrieveFlags = SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags);
    CFRelease(defaultRouteReachability);
    
    if (!didRetrieveFlags)
    {
        return NO;
    }
    
    BOOL isReachable = flags & kSCNetworkFlagsReachable;
    BOOL needsConnection = flags & kSCNetworkFlagsConnectionRequired;
    return (isReachable && !needsConnection) ? YES : NO;
}


/**
 *  HTTP GET 请求
 **/
+(NSData *) doHttpGet:(NSString *)url
{
    NSURL *uri = [NSURL URLWithString:url];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:uri];
    [request setHTTPMethod: @"GET" ];
    NSData *returnData = [NSURLConnection sendSynchronousRequest: request returningResponse: nil error: nil];
    return returnData;
}

/**
 *  HTTP POST请求
 **/
+(NSData *) doHttpPost:(NSString *)url withString:(NSString *)param
{
    NSData *data = nil;
    if(param != nil && [param isEqualToString:@""] == NO){
        param = [param stringByAddingPercentEscapesUsingEncoding:CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000)];
        data = [param dataUsingEncoding:CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000)];
    }
    //调用withParam NSData*类型的方法.
    return [self doHttpPost:url withParam:data];
}


/**
 *  HTTP POST请求
 **/
+(NSData *) doHttpPost:(NSString *)url withParam:(NSData *)param
{
    //新建请求
    NSURL *uri = [NSURL URLWithString:url];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:uri cachePolicy:NSURLRequestReloadIgnoringLocalCacheData  timeoutInterval:40.0];
    //设置请求参数
    [request setHTTPMethod:@"POST"];
    [request addValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Content-Type"];
    if(param != nil)
        [request setHTTPBody:param];
    //打开访问网络的状态提示
    //[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    //请求链接
    //NSError *error = nil;
    NSData *retData = [NSURLConnection sendSynchronousRequest:request returningResponse:nil error:nil];
    //NSLog(@"%d: %@", error.code, error.description);
    //关闭访问网络的状态提示
    //[[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    //返回结果
    return retData;
}


/**
 *  获取网络图片
 **/
+(UIImage *) getImageFromUrl:(NSString *)url
{
    if(url == nil || [url isEqualToString:@""]){
        return nil;
    }
    url = StringByTrimWhiteSpace(url);
    NSData *imageData = [[NSData alloc]initWithContentsOfURL:[NSURL URLWithString:url]];
    UIImage *image =[[UIImage alloc] initWithData:imageData];
    return image;
}

/**
 *  获取网络图片的内容
 **/
+(NSData *)getImageDataFromUrl:(NSString *)url
{
    if(url == nil || [url isEqualToString:@""]){
        return nil;
    }
    
    NSData *imageData = [[NSData alloc]initWithContentsOfURL:[NSURL URLWithString:url]];
    return imageData;
}

#pragma mark - 字符串处理

/**
 *  利用正则表达示获取字符串的匹配结果
 **/
+(NSString *) getRegExpressResult:(NSString *)source regExp:(NSString *)regExp
{
    NSString *temp = [NSString stringWithFormat:@"%@", source];
    
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regExp options:NSRegularExpressionCaseInsensitive error:nil];
    
    if (regex != nil) {
        NSTextCheckingResult *firstMatch = [regex firstMatchInString:temp options:0 range:NSMakeRange(0, [temp length])];
        
        if (firstMatch) {
            NSRange resultRange = [firstMatch rangeAtIndex:0];
            //截取数据
            NSString *result = [temp substringWithRange:resultRange];
            //返回结果
            return result;
        }
    }
    return @"";
}

/**
 *  匹配字符串中整个HTML标记的内容
 **/
+(NSString *) getHtmlText:(NSString *)source tagName:(NSString *)tag
{
    NSString *regexp = [NSString stringWithFormat:@"<\\s*%@\\s+([^>]*)\\s*>([^/%@>]*</%@>)?", tag, tag, tag];
    return [BaseFunction getRegExpressResult:source regExp:regexp];
}


/**
 *  匹配HTML标记内容中的属性值
 **/
+(NSString *) getHtmlTagAttr:(NSString *)tagContext attrName:(NSString *)attr
{
    NSString *regexp = [NSString stringWithFormat: @"%@\\s*=\\s*?(['\"][^'\"]*?)['\"]", attr];
    NSString *result = [BaseFunction getRegExpressResult:tagContext regExp:regexp];
    //替换
    NSString *oldstr = [NSString stringWithFormat:@"%@=\"", attr];
    NSString *newstr = [result stringByReplacingOccurrencesOfString:oldstr withString:@""];
    newstr = [newstr substringToIndex:[newstr length] - 1];
    return newstr;
}

/**
 *  获取HTML标记的文本
 **/
+(NSString *) getHTmlTagText:(NSString *)tagContext
{
    NSString *regExp = @"<\\s*\\w+\\s+([^>]*)\\s*>";
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regExp options:NSRegularExpressionCaseInsensitive error:nil];
    
    NSTextCheckingResult *firstMatch = [regex firstMatchInString:tagContext options:0 range:NSMakeRange(0, [tagContext length])];
    NSRange resultRange = [firstMatch rangeAtIndex:0];
    NSString *newStr = [tagContext substringFromIndex:resultRange.length];
    
    regExp = @"</\\w+\\s*>";
    regex = [NSRegularExpression regularExpressionWithPattern:regExp options:NSRegularExpressionCaseInsensitive error:nil];
    firstMatch = [regex firstMatchInString:newStr options:0 range:NSMakeRange(0, [newStr length])];
    resultRange = [firstMatch rangeAtIndex:0];
    
    return [newStr substringToIndex:resultRange.location];
}

/**
 *  替换HTML标签
 **/
+(NSString *) replaceHtmlTag:(NSString *)source
{
    source = [BaseFunction replaceString:source byRegexp:@"<[^>]+>"];
    return [BaseFunction replaceString:source byRegexp:@"</[^>]+>"];
}

+(NSString *) replaceString:(NSString *)source byRegexp:(NSString *)exp
{
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:exp options:0 error:nil];
    
    if(regex == nil)
        return source;
    
    NSString *ret = [NSString stringWithFormat:@"%@", source];
    NSArray *array = [regex matchesInString:ret options:NSMatchingReportProgress range:NSMakeRange(0, [ret length])];
    for(int i = (int)[array count] - 1; i >= 0; i--)
    {
        NSTextCheckingResult *tcr = [array objectAtIndex:i];
        NSRange range = [tcr range];
        ret = [ret stringByReplacingCharactersInRange:range withString:@""];
    }
    return ret;
}

/**
 *  正则验证
 **/
+(BOOL) string:(NSString *)source MatchRegex:(NSString *) exp
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", exp];
    return [predicate evaluateWithObject:source];
}


/**
 *  获取正则表达式中匹配的个数
 **/
+ (NSInteger) getMatchCount:(NSString *)text inRegx:(NSString *)exp
{
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:exp options:0 error:nil];
    
    int count = 0;
    if (regex != nil) {
        NSArray *array = [regex matchesInString:text options:NSMatchingReportProgress range:NSMakeRange(0, [text length])];
        
        for(int i=0; i< [array count]; i++)
        {
            NSTextCheckingResult *tcr = [array objectAtIndex:i];
            NSRange range = [tcr range];
            count += range.length;
        }
    }
    return count;
}


/**
 *  替换XML敏感字符
 **/
+ (NSString *) replaceXMLSensitiveLettler:(NSString *)text
{
    NSString *tmp = [text stringByReplacingOccurrencesOfString:@"&" withString:@"&amp;"];
    tmp = [tmp stringByReplacingOccurrencesOfString:@"<" withString:@"&lt;"];
    tmp = [tmp stringByReplacingOccurrencesOfString:@">" withString:@"&gt;"];
    return tmp;
}

/**
 *  分离坐标
 **/
+(void) separateCoordinate:(NSString *)coord lat:(NSString **)lat lng:(NSString **)lng
{
    *lng = @"", *lat = @"";
    //验证数据的合法性
    if(coord == nil){ return; }
    coord = StringByTrimWhiteSpace(coord);
    if(IsStringEmpty(coord)){
        return;
    }
    
    //将坐标分开
    NSArray *coordArray = [coord componentsSeparatedByString:@","];
    if([coordArray count]>0)
        *lng = [coordArray objectAtIndex:0];
    if([coordArray count]>1)
        *lat = [coordArray objectAtIndex:1];
}


/**
 *  从文件路径中分解出文件名
 **/
+ (NSString *) splitFileNameForPath:(NSString *)filePath
{
    NSArray *array = [filePath componentsSeparatedByString:@"/"];
    return [array lastObject];
}


/**
 *  从文件路径中分解出文件的扩展名
 **/
+ (NSString *) getFileExtension:(NSString *)filePath
{
    NSString *fileName = [self splitFileNameForPath:filePath];
    NSArray *array = [fileName componentsSeparatedByString:@"."];
    return [NSString stringWithFormat:@".%@",[array lastObject]];
}

/**
 *  获取设备型号
 **/
+ (NSString *) platform
{
    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *machine = (char *)malloc(size);
    sysctlbyname("hw.machine", machine, &size, NULL, 0);
    NSString *platform = [NSString stringWithCString:machine encoding:NSUTF8StringEncoding];
    free(machine);
    NSRange range = [platform rangeOfString:@","];
    return [platform substringToIndex:range.location];
}

/**
 *  MD5加密
 **/
+ (NSString *)md5Digest:(NSString *)str {
    const char *cStr = [str UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(cStr, (CC_LONG)strlen(cStr), result); // This is the md5 call
	NSMutableString *md5Result = [[NSMutableString alloc] init];
	for (int i = 0; i < CC_MD5_DIGEST_LENGTH; i++) {
		[md5Result appendFormat:@"%02x", result[i]];
	}
	
	return md5Result;
//    return [NSString stringWithFormat:
//            @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
//            result[0], result[1], result[2], result[3],
//            result[4], result[5], result[6], result[7],
//            result[8], result[9], result[10], result[11],
//            result[12], result[13], result[14], result[15]];
}

+ (NSString *)SHA1:(NSString *)str {
	const char *cStr = [str UTF8String];
	NSData *data = [NSData dataWithBytes:cStr length:str.length];
	uint8_t digest[CC_SHA1_DIGEST_LENGTH];
	CC_SHA1(data.bytes, (CC_LONG)data.length, digest);
	NSMutableString *result = [[NSMutableString alloc] init];
	for(int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++) {
		[result appendFormat:@"%02x", digest[i]];
	}
	
	return result;
}

//判断是否为整形
+ (BOOL)isPureInt:(NSString *)string{
    NSScanner* scan = [NSScanner scannerWithString:string];
    int val;
    return [scan scanInt:&val] && [scan isAtEnd];
}

//判断是否为浮点形
+ (BOOL)isPureFloat:(NSString *)string{
    NSScanner* scan = [NSScanner scannerWithString:string];
    float val;
    return [scan scanFloat:&val] && [scan isAtEnd];
}

/**
 *  版本比较
 **/
+ (BOOL)isVersion:(NSString*)versionA biggerThanVersion:(NSString*)versionB
{
    NSArray *arrayNow = [versionB componentsSeparatedByString:@"."];
    NSArray *arrayNew = [versionA componentsSeparatedByString:@"."];
    BOOL isBigger = NO;
    NSInteger i = arrayNew.count > arrayNow.count? arrayNow.count : arrayNew.count;
    NSInteger j = 0;
    BOOL hasResult = NO;
    for (j = 0; j < i; j ++) {
        NSString* strNew = [arrayNew objectAtIndex:j];
        NSString* strNow = [arrayNow objectAtIndex:j];
        if ([strNew integerValue] > [strNow integerValue]) {
            hasResult = YES;
            isBigger = YES;
            break;
        }
        if ([strNew integerValue] < [strNow integerValue]) {
            hasResult = YES;
            isBigger = NO;
            break;
        }
    }
    if (!hasResult) {
        if (arrayNew.count > arrayNow.count) {
            NSInteger nTmp = 0;
            NSInteger k = 0;
            for (k = arrayNow.count; k < arrayNew.count; k++) {
                nTmp += [[arrayNew objectAtIndex:k]integerValue];
            }
            if (nTmp > 0) {
                isBigger = YES;
            }
        }
    }
    return isBigger;
}

+ (NSString *)convertServerImageURLToURLString:(NSString *)imageURL {
	if (IsStringEmpty(imageURL)) {
		return @"";
	} else{
		NSString *tempString = @"";
		tempString = [imageURL stringByReplacingOccurrencesOfString:@"\\\\" withString:@"/"];
		tempString = [tempString stringByReplacingOccurrencesOfString:@"\\" withString:@"/"];
		return [NSString stringWithFormat:@"%@/%@", kServerAddress, tempString];
	}
}

#pragma mark - 阴影、圆角、边框、动画、view

/**
 *  文字高度
 **/
+ (CGSize)labelSizeWithText:(NSString *)text font:(UIFont *)font constrainedToSize:(CGSize)size {
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0){
        //IOS 7.0 以上
        NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:font,  NSFontAttributeName, nil];
        size =[text boundingRectWithSize:size
                                 options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading
                              attributes:attributes
                                 context:nil].size;
        size.width = ceilf(size.width);
        size.height = ceilf(size.height);
    }
    /*else {
     size = [text sizeWithFont:font constrainedToSize:size lineBreakMode:NSLineBreakByWordWrapping];
     }*/
    return size;
}

+ (CGSize)labelSizeWithText:(NSString *)text font:(UIFont *)font {
    CGSize size;
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0){
        //IOS 7.0 以上
        NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:font,  NSFontAttributeName, nil];
        size = [text sizeWithAttributes:attributes];
        size.width = ceilf(size.width);
        size.height = ceilf(size.height);
    }else{
        //size = [text sizeWithFont:font];
        size = [text sizeWithAttributes: @{NSFontAttributeName:font}];
    }
    return size;
}
/**
 *	设置view圆角
 *
 *	@param 	cornerRadius 	圆角大小
 *	@param 	view
 */
+ (void)setCornerRadius:(float)cornerRadius view:(UIView *)view {
    view.layer.cornerRadius = cornerRadius;
    view.layer.masksToBounds = YES;
}

/**
 *	设置view边框
 *
 *	@param 	width 	边框宽度
 *	@param 	color 	边框颜色
 *	@param 	view
 */
+ (void)setBorderWidth:(float)width color:(UIColor *)color view:(UIView *)view {
    view.layer.borderColor = color.CGColor;
    view.layer.borderWidth = width;
}

/**
 *	设置view阴影
 *
 *	@param 	color 	颜色
 *	@param 	opacity 不透明度
 *	@param 	radius 	阴影半径
 *	@param 	offset 	偏移
 *	@param 	view
 */
+ (void)setShadowByColor:(UIColor *)color opacity:(float)opacity radius:(float)radius  offset:(CGSize)offset view:(UIView *)view {
    view.layer.shadowPath = [[UIBezierPath bezierPathWithRect:view.bounds] CGPath];
    view.layer.shadowColor = color.CGColor;
    view.layer.shadowOpacity = opacity;
    if(radius != 0) {
        view.layer.shadowRadius = radius;
    }
    view.layer.shadowOffset = offset;
}

//输入框通用圆角、边框
+ (void)setContentViewBorderAndCorner:(UIView *)view {
    [self setBorderWidth:1.0 color:ColorWithWhite(0.85) view:view];
    [self setCornerRadius:4.0 view:view];
}

//动画
+ (void)fadeIn:(UIView *)view {
    view.alpha = 0.0;
    [UIView animateWithDuration:0.2 animations:^{
        view.alpha = 1.0;
    }];
}

+ (void)fadeOut:(UIView *)view {
    view.alpha = 1.0;
    [UIView animateWithDuration:0.2 animations:^{
        view.alpha = 0.0;
    }];
}

/**
 *  显示一个提示框
 **/
+ (void) showAlertMsg:(NSString *)msg title:(NSString *)title {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title message:msg delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
    [alert show];
}

#pragma mark - 电话号码

+ (BOOL) isEmailAddress:(NSString *)emailAddress {
    NSString *email = @"^[\\w-]+(\\.[\\w-]+)*@[\\w-]+(\\.[\\w-]+)+$";
    return [BaseFunction string:emailAddress MatchRegex:email];
}

// 判断是否为手机号码
+ (BOOL)isMobileNumber:(NSString *)mobileNum
{
    /**
     * 手机号码
     * 移动：134[0-8],135,136,137,138,139,150,151,157,158,159,182,187,188
     * 联通：130,131,132,152,155,156,185,186
     * 电信：133,1349,153,180,189
     */
    NSString * MOBILE = @"^1(3[0-9]|5[0-35-9]|8[025-9])\\d{8}$";
    /**
     * 大陆地区固话及小灵通
     * 区号：010,020,021,022,023,024,025,027,028,029
     * 号码：七位或八位
     */
    return [BaseFunction string:mobileNum MatchRegex:MOBILE];
}

// 判断是否移动手机号码
+ (BOOL) isChinaMobile:(NSString *)mobileNum
{
    /**
     * 中国移动：China Mobile
     * 134[0-8],135,136,137,138,139,150,151,157,158,159,182,187,188
     */
    NSString * CM = @"^1(34[0-8]|(3[5-9]|5[017-9]|8[278])\\d)\\d{7}$";
    return [BaseFunction string:mobileNum MatchRegex:CM];
}

// 判断是否联通手机号码
+ (BOOL) isChinaUnicom:(NSString *)mobileNum
{
    /**
     * 中国联通：China Unicom
     * 130,131,132,152,155,156,185,186
     */
    NSString * CU = @"^1(3[0-2]|5[256]|8[56])\\d{8}$";
    return [BaseFunction string:mobileNum MatchRegex:CU];
}

// 判断是否电信手机号码
+ (BOOL) isChinaTelecom:(NSString *)mobileNum
{
    /**
     * 中国电信：China Telecom
     * 133,1349,153,180,189
     */
    NSString * CT = @"^1((33|53|8[09])[0-9]|349)\\d{7}$";
    return [BaseFunction string:mobileNum MatchRegex:CT];
}


#pragma mark - 文件目录

//Documents目录,iTunes备份和恢复的时候会包括此目录，程序退出后不删除
+ (NSString *)pathForDocumentsDir{
    return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
}

//tmp目录，存放临时文件，不会备份，程序退出后删除
+ (NSString *)pathForTmpDir{
    return [NSHomeDirectory() stringByAppendingString:@"/tmp/"];
}

//Library/Caches目录，缓存目录，不会备份，程序退出后不删除
+ (NSString *)pathForCachesDir{
    return [NSHomeDirectory() stringByAppendingString:@"/Library/Caches/"];
}

//单个文件的大小
+ (long long) fileSizeAtPath:(NSString*) filePath {
    NSFileManager *manager = [NSFileManager defaultManager];
    if ([manager fileExistsAtPath:filePath]){
        return [[manager attributesOfItemAtPath:filePath error:nil] fileSize];
    }
    return 0;
}

+ (BOOL)deleteFileAtPath:(NSString *)path {
    NSError *error;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL deleteResult = [fileManager removeItemAtPath:path error:&error];
    NSLog(@"removeItemAtPath:path, error = %@", error);
    NSLog(@"删除文件：%@", deleteResult ? @"成功" : @"失败");
    
    return deleteResult;
}

// 获取当前的文件路径，解决应用包名发生改变之后找不到文件的问题
+ (NSString *)getCurrentPathWithFilePath:(NSString *)filePath {
    NSString *shortPath = [filePath substringFromIndex:[filePath rangeOfString:@"/Documents/"].location + 10];
    NSString *fileNewPath = [NSString stringWithFormat:@"%@%@", PATH_OF_DOCUMENT, shortPath];
    
    return fileNewPath;
}

#pragma mark - 其它函数

/**
 *  取一个随机整数
 **/
+ (int)random {
    return arc4random();
}

/**
 *  取一个随机整数 0~x-1
 **/
+ (int)random:(int)x {
    return arc4random() % x;
}

/**
 *  获取当前时间
 **/
+ (int) getCurrentTime
{
    NSDate *date = [NSDate date];
    NSString *num = [NSString stringWithFormat:@"%.0f",[date timeIntervalSince1970]];
    return [num intValue];
}

/**
 * 按照格式：“yyyy-MM-dd HH:mm:ss”获取当前的时间
 */
+ (NSString *)getToday {
    NSDate *currentDate = [NSDate date];
    NSDateFormatter *dateformatter = [[NSDateFormatter alloc] init];
    [dateformatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *currDateString = [dateformatter stringFromDate:currentDate];
    
    return currDateString;
}

/**
 * 按照格式：“yyMMddHHmmss”获取当前的时间
 */
+ (NSString *)getPhotoNameWithCurrentTime {
    NSDate *currentDate = [NSDate date];
    NSDateFormatter *dateformatter = [[NSDateFormatter alloc] init];
    [dateformatter setDateFormat:@"yyMMddHHmmss"];
    NSString *currDateString = [dateformatter stringFromDate:currentDate];
    
    return currDateString;
}

/**
 * 按照格式：“yyyyMMddHHmmss”获取当前的时间
 */
+ (NSString *)getTimeStampAtCurrentTime {
	NSDate *currentDate = [NSDate date];
	NSDateFormatter *dateformatter = [[NSDateFormatter alloc] init];
	[dateformatter setDateFormat:@"yyyyMMddHHmmss"];
	NSString *currDateString = [dateformatter stringFromDate:currentDate];
	
	return currDateString;
}

+ (NSString *)exchangeRateTimeFromString:(NSString *)dateString {
	NSDateFormatter *inputFormatter = [[NSDateFormatter alloc] init];
//	date = "8/5/2015";
//	fromCurrency = USD;
//	time = "9:53am";
	[inputFormatter setDateFormat:@"MM/d/yyyy K:mmaa"];
	[inputFormatter setTimeZone:[NSTimeZone defaultTimeZone]];
	NSDate *date = [inputFormatter dateFromString:[dateString uppercaseString]];
	
	return [BaseFunction stringFromDate:date format:@"yyyy-MM-dd HH:mm"];
}

+ (NSDate *)dateFromString:(NSString *)dateStr {
    NSDateFormatter *inputFormatter = [[NSDateFormatter alloc] init];
    [inputFormatter setDateFormat:@"yyyy-MM-dd"];
    [inputFormatter setTimeZone:[NSTimeZone defaultTimeZone]];
    //标准时间
    return [inputFormatter dateFromString:dateStr];
}

+ (NSDate *)longDateFromString:(NSString *)dateStr {
	NSDateFormatter *inputFormatter = [[NSDateFormatter alloc] init];
	[inputFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
	[inputFormatter setTimeZone:[NSTimeZone defaultTimeZone]];
	//标准时间
	return [inputFormatter dateFromString:dateStr];
}

+ (NSString *)dateFromString:(NSDate *)date dateFormat:(NSString *)dateFormat {
    NSDate *currentDate = [NSDate date];
    NSDateFormatter *dateformatter = [[NSDateFormatter alloc] init];
    [dateformatter setDateFormat:dateFormat];
    NSString *currDateString = [dateformatter stringFromDate:currentDate];
    return currDateString;
}

// 将当前时间转成字符串，格式：yyyy-MM-dd
+ (NSString *)stringFromCurrent {
    NSDate *currentDate = [NSDate date];
    NSDateFormatter *dateformatter = [[NSDateFormatter alloc] init];
    [dateformatter setDateFormat:@"yyyy-MM-dd"];
    NSString *currDateString = [dateformatter stringFromDate:currentDate];
    
    return currDateString;
}

// 获取当前时间的字典
+ (NSDictionary *)getCurrentDateDictionary {
    NSDate *currentDate = [NSDate date];
    NSCalendar* calendar = [NSCalendar currentCalendar];
    // Get necessary date components
    NSDateComponents* components = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:currentDate];
    NSInteger month = [components month];
    NSInteger day = [components day];
    NSString *yearString = [NSString stringWithFormat:@"%ld", [components year]];
    NSString *monthString = month < 10 ? [NSString stringWithFormat:@"0%ld", month] : [NSString stringWithFormat:@"%ld", month];
    NSString *dayString = day < 10 ? [NSString stringWithFormat:@"0%ld", day] : [NSString stringWithFormat:@"%ld", day];
    
    NSArray *objects = [NSArray arrayWithObjects:yearString, monthString, dayString, nil];
    NSArray *keys = [NSArray arrayWithObjects:@"YEAR", @"MONTH", @"DAY", nil];
    
    return [NSDictionary dictionaryWithObjects:objects forKeys:keys];
}

+ (NSTimeInterval)timeIntervalSinceNow:(NSDate *)date {
    NSTimeInterval interval = [date timeIntervalSinceNow];
    NSLog(@"%f",interval);
    return interval;
}

+ (NSString *)stringDateFromDate:(NSDate *)date {
    NSDateFormatter *dateformatter = [[NSDateFormatter alloc] init];
    [dateformatter setDateFormat:@"yyyy-MM-dd"];
    NSString *dateString = [dateformatter stringFromDate:date];
    return dateString;
}

+ (NSString *) stringFromDate : (NSDate *) date format : (NSString *) dateFormat {
    NSDateFormatter *dateformatter = [[NSDateFormatter alloc] init];
    [dateformatter setDateFormat:dateFormat];
    NSString *dateString = [dateformatter stringFromDate:date];
    return dateString;
}

// 获得屏幕指定控件图像
+ (UIImage *)imageFromView:(UIView *) theView
{
    UIGraphicsBeginImageContext(theView.frame.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [theView.layer renderInContext:context];
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}

// 计算两个经纬度之间的距离
+ (NSString *)calculateDistance:(float)longitude latitude:(float)latitude longitude2:(NSString *)longitude2 latitude2:(NSString *)latitude2 {
    NSString *result;
    
    double lo2 = [longitude2 doubleValue];
    double la2 = [latitude2 doubleValue];
    double radLat1 = [self rad:latitude];
    double radLat2 = [self rad:la2];
    double a = radLat1 - radLat2;
    double b = [self rad:longitude] - [self rad:lo2];
    double v = 2 * asin(sqrt(pow(sin(a / 2), 2) + cos(radLat1) * cos(radLat2) * pow(sin(b / 2), 2)));
    
    v = v * 6378137.0;
    v = round(v * 10000) / 10000;
    if (v > 1000) {
        result = [NSString stringWithFormat:@"%.3fKM", v / 1000];
    } else {
        result = [NSString stringWithFormat:@"%.3fM", v];
    }
    
    return result;
}

+ (double)rad:(double)d {
    return d * M_PI / 180.0;
}

+ (UIImage *) imageWithColor:(UIColor *)color {
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

+ (void) setShadow : (float) opacity shadowColor : (UIColor *) shadowColor offset : (CGSize) offset view : (UIView *) view {
    view.layer.masksToBounds = NO;
    view.layer.shadowColor = shadowColor.CGColor;
    view.layer.shadowOffset = offset;
    view.layer.shadowOpacity = opacity;
}

+ (void) addRefreshHeaderAndFooter:(UIScrollView *)scrollView refreshAction:(SEL)refreshAction loadMoreAction : (SEL) loadMoreAction target: (id) target{
    // 设置文字
    MJRefreshNormalHeader *header = [MJRefreshNormalHeader headerWithRefreshingTarget:target refreshingAction:refreshAction];
    [header setTitle:@"Pull down to refresh..." forState:MJRefreshStateIdle];
    [header setTitle:@"Release to refresh..." forState:MJRefreshStatePulling];
    [header setTitle:@"Loading..." forState:MJRefreshStateRefreshing];
    MJRefreshAutoNormalFooter *footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:target refreshingAction:loadMoreAction];
    [footer setTitle:@"Pull up to get more..." forState:MJRefreshStateIdle];
    [footer setTitle:@"Loading..." forState:MJRefreshStateRefreshing];
    // 隐藏更新时间
    header.lastUpdatedTimeLabel.hidden = YES;
    // 设置字体
    header.stateLabel.font = FontNeveLightWithSize(15.0);
    footer.stateLabel.font = FontNeveLightWithSize(15.0);
    // 添加上拉加载更多，下拉刷新
    scrollView.header = header;
    scrollView.footer = footer;
}

+ (NSString *)convertDistanceToShortString:(double)distance {
    if (distance < 1000) {
        return [NSString stringWithFormat:@"%dM", (int)distance];
    } else {
        return [NSString stringWithFormat:@"%dKM", (int)distance / 1000];
    }
}

+ (long)getDistanceFromSelectedNearby:(NSString *)sDistance {
    long distance = 0;
    if ([sDistance myContainsString:@"KM"]) {
        NSString *splitDistance = [sDistance componentsSeparatedByString:@"KM"][0];
        distance = [splitDistance integerValue] * 1000;
    } else if ([sDistance myContainsString:@"M"]){
        NSString *splitDistance = [sDistance componentsSeparatedByString:@"M"][0];
        distance = [splitDistance integerValue];
    }
    
    return distance;
}

+ (NSInteger)calculateAgeByBirthday:(NSDate *)birthday {
    NSDate* now = [NSDate date];
    NSDateComponents* ageComponents = [[NSCalendar currentCalendar]
                                       components:NSCalendarUnitYear
                                       fromDate:birthday
                                       toDate:now
                                       options:0];
    NSInteger age = [ageComponents year];
    return age;
}

+ (UIColor *)randomColor {
    CGFloat hue = ( arc4random() % 256 / 256.0 ); //0.0 to 1.0
    CGFloat saturation = ( arc4random() % 128 / 256.0 ) + 0.5; // 0.5 to 1.0,away from white
    CGFloat brightness = ( arc4random() % 128 / 256.0 ) + 0.5; //0.5 to 1.0,away from black
    
    return [UIColor colorWithHue:hue saturation:saturation brightness:brightness alpha:1];
}

+ (NSString *) dynamicDateFormat : (NSString *) date {
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    //设定时区NSString *timeZone = @"Asia/Shanghai";
    NSTimeZone *zone = [[NSTimeZone alloc] initWithName:@"Asia/Shanghai"];
    [df setTimeZone:zone];
    NSDate *serverDate = [df dateFromString:date];
    NSDate *nowDate = [NSDate date];
    
    //获取server time的年月日
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *componentServer = [[NSDateComponents alloc] init];
    NSInteger unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSWeekdayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit;
    componentServer = [calendar components:unitFlags fromDate:serverDate];
    
    NSDateComponents *componentsNow = [[NSDateComponents alloc] init];
    componentsNow = [calendar components:unitFlags fromDate:nowDate];
    
    NSString *dynamicDate;
    if(componentsNow.year != componentServer.year) {
        //前几年发布的，显示年月日
        dynamicDate = [NSString stringWithFormat:@"%ld-%@-%@",componentServer.year,[BaseFunction addZeroBeforeNumber:componentServer.month],[BaseFunction addZeroBeforeNumber:componentServer.day]];
    } else {
        if(componentsNow.month != componentServer.month) {
            //几个月前发布的，显示月日
            dynamicDate = [NSString stringWithFormat:@"%@-%@",[BaseFunction addZeroBeforeNumber:componentServer.month],[BaseFunction addZeroBeforeNumber:componentServer.day]];
        } else {
            if(componentsNow.day != componentServer.day) {
                if(componentsNow.day - componentServer.day == 1) {
                    //昨天发布的，显示Yesterday 小时分钟
                    dynamicDate = [NSString stringWithFormat:@"Yesterday %@:%@",[BaseFunction addZeroBeforeNumber:componentServer.hour],[BaseFunction addZeroBeforeNumber:componentServer.minute]];
                } else {
                    //前几天发布的，显示月日
                    dynamicDate = [NSString stringWithFormat:@"%@-%@",[BaseFunction addZeroBeforeNumber:componentServer.month],[BaseFunction addZeroBeforeNumber:componentServer.day]];
                }
            } else {
                if(componentsNow.hour != componentServer.hour) {
                    //今天发布的,显示几个小时之前
                    dynamicDate = [NSString stringWithFormat:@"%ld hour ago",componentsNow.hour - componentServer.hour];
                } else {
                    //一个小时之内发布的,5分钟之内，显示Just now
                    if(componentServer.minute == componentsNow.minute || componentsNow.minute - componentServer.minute <= 5) {
                        dynamicDate = @"Just now";
                    } else {
                        dynamicDate = [NSString stringWithFormat:@"%ld min ago",componentsNow.minute - componentServer.minute];
                    }
                }
            }
        }
    }
    return dynamicDate;
}

/**
 *  若数字小于10，则将该数字前面添加个0
 *
 *  @param number
 *
 *  @return 
 */
+ (NSString *) addZeroBeforeNumber : (NSInteger) number {
    if(number < 10) {
        return [NSString stringWithFormat:@"0%ld",number];
    } else {
        return [NSString stringWithFormat:@"%ld",number];
    }
}

+ (NSString *) chineseToPinyin:(NSString*)sourceString {
    CFMutableStringRef string = CFStringCreateMutableCopy(NULL, 0, (__bridge CFStringRef)sourceString);
    CFStringTransform(string, NULL, kCFStringTransformMandarinLatin, NO);
    CFStringTransform(string, NULL, kCFStringTransformStripDiacritics, NO);
    return [NSString stringWithFormat:@"%@",string];
}

+ (NSString *) uuid {
    CFUUIDRef puuid = CFUUIDCreate( nil );
    CFStringRef uuidString = CFUUIDCreateString( nil, puuid );
    NSString * result = (NSString *)CFBridgingRelease(CFStringCreateCopy( NULL, uuidString));
    CFRelease(puuid);
    CFRelease(uuidString);
    return result;
}

+ (NSString *)getWeekdayNameByIndex:(NSInteger)index {
	NSString *weekday;
	switch (index) {
		case 1:
			weekday = @"Monday";
			break;
		case 2:
			weekday = @"Tuesday";
			break;
		case 3:
			weekday = @"Wednesday";
			break;
		case 4:
			weekday = @"Thursday";
			break;
		case 5:
			weekday = @"Friday";
			break;
		case 6:
			weekday = @"Saturday";
			break;
		case 7:
			weekday = @"Sunday";
			break;
	}
	
	return weekday;
}

+ (NSString *)getWindDirectionEnglishNameByChineseName:(NSString *)windDirectionCNName {
	NSString *windDirectionENName;
	if ([windDirectionCNName isEqualToString:@"无持续风向"]) {
		windDirectionENName = @"No wind";
	} else if ([windDirectionCNName isEqualToString:@"东北风"]) {
		windDirectionENName = @"Northeast";
	} else if ([windDirectionCNName isEqualToString:@"东风"]) {
		windDirectionENName = @"East";
	} else if ([windDirectionCNName isEqualToString:@"东南风"]) {
		windDirectionENName = @"Southeast";
	} else if ([windDirectionCNName isEqualToString:@"南风"]) {
		windDirectionENName = @"South";
	} else if ([windDirectionCNName isEqualToString:@"西南风"]) {
		windDirectionENName = @"Southwest";
	} else if ([windDirectionCNName isEqualToString:@"西风"]) {
		windDirectionENName = @"West";
	} else if ([windDirectionCNName isEqualToString:@"西北风"]) {
		windDirectionENName = @"Northwest";
	} else if ([windDirectionCNName isEqualToString:@"北风"]) {
		windDirectionENName = @"North";
	} else if ([windDirectionCNName isEqualToString:@"旋转风"]) {
		windDirectionENName = @"Whirl wind";
	} else {
		windDirectionENName = windDirectionCNName;
	}
	
	return windDirectionENName;
}

+ (NSString *)getAirQualityEnglishNameByChinese:(NSString *)cnQualityName {
	NSString *enQualityName;
	if ([cnQualityName isEqualToString:@"优"]) {
		enQualityName = @"Excellent";
	} else if ([cnQualityName isEqualToString:@"良"]) {
		enQualityName = @"Good";
	} else if ([cnQualityName isEqualToString:@"轻度污染"]) {
		enQualityName = @"Light pollution";
	} else if ([cnQualityName isEqualToString:@"中度污染"]) {
		enQualityName = @"Moderate pollution";
	} else if ([cnQualityName isEqualToString:@"重度污染"]) {
		enQualityName = @"Heavy pollution";
	} else if ([cnQualityName isEqualToString:@"严重污染"]) {
		enQualityName = @"Severe pollution";
	} else {
		enQualityName = cnQualityName;
	}
	
	return enQualityName;
}

+ (NSString *)getWindPowerLevelByOriginalWindPower:(NSString *)originalWindPower {
	if ([originalWindPower myContainsString:@"级"]) {
		originalWindPower = [originalWindPower componentsSeparatedByString:@"级"][1];
	}
	NSRange symbolRange = [originalWindPower rangeOfString:@"<"];
	if (symbolRange.length != 0) {
		NSString *windPower = [originalWindPower substringFromIndex:symbolRange.location];
		return windPower;
	} else {
		return originalWindPower;
	}
}

+ (NSString *)getUVLevelByChineseName:(NSString *)cnUVName {
	NSString *uvLevelEN;
	if ([cnUVName isEqualToString:@"最弱"]) {
		uvLevelEN = @"Weakest";
	} else if ([cnUVName isEqualToString:@"弱"]) {
		uvLevelEN = @"Weak";
	} else if ([cnUVName isEqualToString:@"中等"]) {
		uvLevelEN = @"Moderate";
	} else if ([cnUVName isEqualToString:@"强"]) {
		uvLevelEN = @"Strong";
	} else if ([cnUVName isEqualToString:@"很强"]) {
		uvLevelEN = @"Strongest";
	} else {
		uvLevelEN = cnUVName;
	}
	
	return uvLevelEN;
}

+ (NSString *)getClothesIndexENByChineseName:(NSString *)cnCIName {
	NSString *clothesIndexEN;
	if ([cnCIName isEqualToString:@"炎热"]) {
		clothesIndexEN = @"Torridity";
	} else if ([cnCIName isEqualToString:@"热"]) {
		clothesIndexEN = @"Hot";
	} else if ([cnCIName isEqualToString:@"舒适"]) {
		 clothesIndexEN = @"Comfortable";
	} else {
		clothesIndexEN = cnCIName;
	}
	
	return clothesIndexEN;
}

+ (NSString *)getComfortLevelENByChineseName:(NSString *)cnComfortLevelName {
	NSString *comfortLevelEN;
	if ([cnComfortLevelName isEqualToString:@"最可接受"]) {
		comfortLevelEN = @"Most acceptable";
	} else if ([cnComfortLevelName isEqualToString:@"舒适"]) {
		comfortLevelEN = @"Comfortable";
	} else if ([cnComfortLevelName isEqualToString:@"较舒适"]) {
		comfortLevelEN = @"More Comfortable";
	} else if ([cnComfortLevelName isEqualToString:@"不舒适"]) {
		comfortLevelEN = @"Uncomfortable";
	} else if ([cnComfortLevelName isEqualToString:@"较不舒适"]) {
		comfortLevelEN = @"More uncomfortable";
	} else if ([cnComfortLevelName isEqualToString:@"极不舒适"]) {
		comfortLevelEN = @"Extremely uncomfortable";
	} else {
		comfortLevelEN = cnComfortLevelName;
	}
	
	return comfortLevelEN;
}

+ (NSString *)getSportsLevenENByChineseName:(NSString *)cnSportsName {
	NSString *sportsLevelEN;
	if ([cnSportsName isEqualToString:@"适宜"]) {
		sportsLevelEN = @"Suitable";
	} else if ([cnSportsName isEqualToString:@"较适宜"]) {
		sportsLevelEN = @"More Suitable";
	} else if ([cnSportsName isEqualToString:@"较不宜"]) {
		sportsLevelEN = @"Unfit";
	} else if ([cnSportsName isEqualToString:@"非常不适宜"]) {
		sportsLevelEN = @"Very Unfit";
	} else {
		sportsLevelEN = cnSportsName;
	}
	
	return sportsLevelEN;
}

+ (NSString *)getTravelLevelENByChineseName:(NSString *)cnTravelLevelName {
	// 一般\较不宜\适宜\不适宜
	NSString *travelLevelEN;
	if ([cnTravelLevelName isEqualToString:@"适宜"]) {
		travelLevelEN = @"Suitable";
	} else if ([cnTravelLevelName isEqualToString:@"较适宜"]) {
		travelLevelEN = @"More Suitable";
	} else if ([cnTravelLevelName isEqualToString:@"一般"]) {
		travelLevelEN = @"General";
	} else if ([cnTravelLevelName isEqualToString:@"较不宜"]) {
		travelLevelEN = @"Unfit";
	} else if ([cnTravelLevelName isEqualToString:@"不宜"]) {
		travelLevelEN = @"Inappropriate";
	} else {
		travelLevelEN = cnTravelLevelName;
	}
	
	return travelLevelEN;
}

+ (NSString *)encodeToPercentEscapeString:(NSString *)input {
	if (IsStringEmpty(input)) {
		return input;
	}
	
	NSString *outputStr = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)input, NULL, CFSTR(":/=,!$&'()*+;[]@#?"), kCFStringEncodingUTF8));
	
	return outputStr;
}

+ (NSString *)decodeFromPercentEscapeString:(NSString *)input {
	if (IsStringEmpty(input)) {
		return input;
	}
	
	NSMutableString *outputStr = [NSMutableString stringWithString:input];
	[outputStr replaceOccurrencesOfString:@"+" withString:@" " options:NSLiteralSearch range:NSMakeRange(0, [outputStr length])];
	
	return [outputStr stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}

+ (NSString *) getMonth : (NSUInteger) monthComponent {
    NSString *month;
    switch (monthComponent) {
        case 1:
            month = @"January";
            break;
        case 2:
            month = @"February";
            break;
        case 3:
            month = @"March";
            break;
        case 4:
            month = @"April";
            break;
        case 5:
            month = @"May";
            break;
        case 6:
            month = @"June";
            break;
        case 7:
            month = @"July";
            break;
        case 8:
            month = @"August";
            break;
        case 9:
            month = @"September";
            break;
        case 10:
            month = @"October";
            break;
        case 11:
            month = @"November";
            break;
        case 12:
            month = @"December";
            break;
        default:
            month = @"January";
            break;
    }
    return month;
}

#pragma mark 验证昵称
+ (BOOL)validateNickname:(NSString *)nickname {
	NSString *matchString = @"^[A-Za-z0-9_-]+$";
	NSPredicate *nicknamePre = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", matchString];
	return [nicknamePre evaluateWithObject:nickname];
}

@end
