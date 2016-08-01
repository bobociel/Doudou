//
//  LWUtil.m
//  weddingTreasure
//
//  Created by momo on 15/6/25.
//  Copyright (c) 2015年 momo. All rights reserved.
//

#import "LWUtil.h"

@implementation LWUtil

+ (float)countHeightOfString:(NSString *)string WithWidth:(float)width Font:(UIFont *)font {
    if ([NSNull null] == (id)string) {
        string = @"暂时没有数据";
    }
#pragma clang diagnostic ignored "-Wdeprecated"
    CGSize constraintSize = CGSizeMake(width, MAXFLOAT);
    CGSize labelSize = [string sizeWithFont:font constrainedToSize:constraintSize lineBreakMode:NSLineBreakByWordWrapping];
    return labelSize.height;
}


+ (float)countHeightOfAttributeString:(NSAttributedString *)string WithWidth:(float)width {
    UITextView * label = [[UITextView alloc] init];
    label.width = width;
    [label setAttributedText:string];
    
    CGSize size = [label sizeThatFits:CGSizeMake(width, FLT_MAX)];
    return size.height;
}

+ (float)countWidthOfString:(NSString *)string WithHeight:(float)height Font:(UIFont *)font {
    if ([NSNull null] == (id)string) {
        string = @"暂时没有数据";
    }
    CGSize constraintSize = CGSizeMake(MAXFLOAT, height);
    CGSize labelSize = [string sizeWithFont:font constrainedToSize:constraintSize lineBreakMode:NSLineBreakByWordWrapping];
    return labelSize.width;
}

+ (void)adjustTextFieldLeftView:(NSArray *)textFieldArr andWidth:(CGFloat)width {
    for(UITextField *textField in textFieldArr) {
        textField.leftView=[[UIView alloc] initWithFrame:CGRectMake(0, 0, 8, 0)];
        textField.leftViewMode=UITextFieldViewModeAlways;
    }
}

+ (UIPanDirection)calculatePanDirectionWithTranslation:(CGPoint)translation {
    if (fabs(translation.x/translation.y)>5.0f) {
        if (translation.x>0) {
            return UIPanDirectionRight;
        }else {
            return UIPanDirectionLeft;
        }
    }else {
        if (translation.y>0) {
            return UIPanDirectionTop;
        }else {
            return UIPanDirectionDown;
        }
    }
}

+ (NSString *)getDateTypeByDate:(NSString *)date hour:(NSString *)hour min:(NSString *)min {
    //    NSDate *now = [NSDate date];
    //
    //    NSCalendar *calendar = [NSCalendar currentCalendar];
    //    NSUInteger unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSSecondCalendarUnit;
    //    NSDateComponents *dateComponent = [calendar components:unitFlags fromDate:now];
    
    NSString *creatDate=[NSString stringWithFormat:@"%@ %@:%@",date,hour,min];
    return creatDate;
}

+ (NSString *)getSimpleDateByAllDate:(NSString *)date type:(int)type {
    NSString *monthStr;
    NSString *dayStr;
    NSArray *dateArray=[date componentsSeparatedByString:@"-"];
    
    monthStr=[NSString stringWithFormat:@"%@",dateArray[1]];
    dayStr=[NSString stringWithFormat:@"%@",dateArray[2]];
    
    NSString *m=[monthStr substringToIndex:1];
    NSString *d=[dayStr substringToIndex:1];
    
    if([m isEqualToString:@"0"]){
        monthStr=[monthStr substringFromIndex:1];
    }
    
    if ([d isEqualToString:@"0"]) {
        dayStr=[dayStr substringFromIndex:1];
    }
    
    NSString *creatDate;
    if (type==1) {
        creatDate=[NSString stringWithFormat:@"%@/%@",monthStr,dayStr];
    }else {
        creatDate=[NSString stringWithFormat:@"%@月%@日",monthStr,dayStr];
    }
    return creatDate;
}

+ (NSDate *)convertStringToDate:(NSString *)dateStr {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init] ;
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    [formatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:8]];
    NSDate *date=[formatter dateFromString:dateStr];
    return date;
}

+(NSString*)getTimeStringWithDate:(NSDate*)date
{
    NSDateFormatter *inputFormatter = [[NSDateFormatter alloc] init];
    [inputFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US"]];
    NSDate *datenow=[NSDate date];
    
    [inputFormatter setDateFormat:@"yyyy"];
    NSString *year=[inputFormatter stringFromDate:date];
    NSString *yearnow= [inputFormatter stringFromDate:datenow];
    if([year intValue]==[yearnow intValue])
    {
        [inputFormatter setDateFormat:@"MM"];
        NSString *month=[inputFormatter stringFromDate:date];
        NSString *monthnow=[inputFormatter stringFromDate:datenow];
        
        
        if([month intValue]==[monthnow intValue])
        {
            [inputFormatter setDateFormat:@"dd"];
            NSString *day=[inputFormatter stringFromDate:date];
            NSString *daynow=[inputFormatter stringFromDate:datenow];
            if([day intValue]==[daynow intValue])
            {
                NSTimeInterval sendTimestamp=[date timeIntervalSince1970];
                NSTimeInterval nowTimestamp=[[NSDate date] timeIntervalSince1970];
                if ( nowTimestamp-sendTimestamp<=60*60) {
                    if (nowTimestamp-sendTimestamp<60) {
                        if (nowTimestamp-sendTimestamp<1) {
                            return @" 刚刚 ";
                        }
                        else
                        {
                            return [NSString stringWithFormat:@"%i秒前",(int)(([[NSDate date] timeIntervalSince1970]-sendTimestamp))];
                        }
                    }
                    else
                    {
                        return [NSString stringWithFormat:@"%i分钟前",(int)(([[NSDate date] timeIntervalSince1970]-sendTimestamp)/60)];
                    }
                }
                else
                {
                    [inputFormatter setDateFormat:@"HH:mm"];
                    return  [NSString stringWithFormat:@"%@ %@",@"今天",[inputFormatter stringFromDate:date]];
                }
            }
            else if([daynow intValue]-[day intValue]==1)
            {
                [inputFormatter setDateFormat:@"HH:mm"];
                return  [NSString stringWithFormat:@"%@ %@",@"昨天",[inputFormatter stringFromDate:date]];
            }
            else
            {
                [inputFormatter setDateFormat:@"MM-dd HH:mm"];
                return  [inputFormatter stringFromDate:date];
            }
        }
        else
        {
            [inputFormatter setDateFormat:@"MM-dd HH:mm"];
            return  [inputFormatter stringFromDate:date];
        }
    }
    else
    {
        [inputFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
        return  [inputFormatter stringFromDate:date];
    }
    return @"";
}

+ (NSString *)convertNSDateToNSString:(NSDate *)date {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *stringFromDate = [formatter stringFromDate:date];
    return stringFromDate;
}


+ (NSDate *)getDateAfterByCurrentDate:(NSDate *)date withInterval:(int)day {
    NSTimeInterval a_day = 24*60*60*day;
    NSDate *tomorrow = [date dateByAddingTimeInterval:a_day];
    return tomorrow;
}

+ (NSDate *)getTomorrowDateByCurrentDate:(NSDate *)date {
    NSTimeInterval a_day = 24*60*60;
    NSDate *tomorrow = [date dateByAddingTimeInterval:a_day];
    return tomorrow;
}

+ (NSDate *)getBeforeDateByCurrentDate:(NSDate *)date {
    NSTimeInterval a_day=24*60*60;
    NSDate *before=[date dateByAddingTimeInterval:-a_day];
    return before;
}

+ (int)compareCurrentTime:(NSDate *)compareDate beforeTime:(NSDate *)beforeTime {
    NSTimeInterval  timeInterval=[compareDate timeIntervalSinceDate:beforeTime];
    NSString *result;
    long temp=timeInterval/60/60/24;
    result=[NSString stringWithFormat:@"%ld",temp];
    return [result intValue];
}

+ (int)compareTwoDateTimeByString:(NSString *)compareDateStr beforeTime:(NSString *)beforeTimeStr {
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init] ;
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    
    NSDate *compareDate=[formatter dateFromString:[compareDateStr componentsSeparatedByString:@" "][0]];
    NSDate *beforeDate=[formatter dateFromString:[beforeTimeStr componentsSeparatedByString:@" "][0]];
    
    NSTimeInterval  timeInterval=[compareDate timeIntervalSinceDate:beforeDate];
    NSString *result;
    long temp=timeInterval/60/60/24;
    result=[NSString stringWithFormat:@"%ld",temp];
    return [result intValue];
}

+ (int)compareCurrentTimeSec:(NSDate *)compareDate beforeTime:(NSDate *)beforeTime {
    return [compareDate timeIntervalSinceDate:beforeTime];
}

+ (NSString *)getToday {
    NSDate *now = [NSDate date];
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSUInteger unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSSecondCalendarUnit;
    NSDateComponents *dateComponent = [calendar components:unitFlags fromDate:now];
    
    NSString  *dateToday=[NSString stringWithFormat:@"%ld-%ld-%ld",(long)[dateComponent year],(long)[dateComponent month],(long)[dateComponent day]];
    return dateToday;
}

+ (NSString *)getNowTime {
    NSDate *now = [NSDate date];
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSUInteger unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSSecondCalendarUnit;
    NSDateComponents *dateComponent = [calendar components:unitFlags fromDate:now];
    
    NSString  *datetime=[NSString stringWithFormat:@"%ld:%ld",(long)[dateComponent hour],(long)[dateComponent minute]];
    return datetime;
}


+ (NSString *)getTomorrow {
    
    NSDate * tomorrow =[[NSDate alloc]initWithTimeIntervalSinceNow:24*60*60];
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSUInteger unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSSecondCalendarUnit;
    NSDateComponents *dateTomorrowComponent=[calendar components:unitFlags fromDate:tomorrow];
    
    NSString *dateTomorrow=[NSString stringWithFormat:@"%ld-%ld-%ld",(long)[dateTomorrowComponent year],(long)[dateTomorrowComponent month],(long)[dateTomorrowComponent day]];
    return dateTomorrow;
}

+ (BOOL)validatePhoneNumber:(NSString *)phone {
    if ([phone length]!=11) {
        return NO;
    }
    NSString *regExStr = @"^1\\d{10}$";
    NSError *error = NULL;
    
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regExStr
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:&error];
    
    
    long result = [regex numberOfMatchesInString:phone options:0 range:NSMakeRange(0, [phone length])];
    if(result>0) {
        return YES;
    }else {
        return NO;
    }
    
}

+ (BOOL)validateCardNumber:(NSString *)cardNumber{
    if ([cardNumber isEqualToString:@""]||([cardNumber length]!=18&&[cardNumber length]!=15)) {
        return NO;
    }
    return YES;
}

+ (BOOL)validateEmail:(NSString *)email {
    
    NSString *regExStr = @"^\\w*@\\w*\\.\\w*$";
    NSError *error = NULL;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regExStr
                                                                           options:NSRegularExpressionCaseInsensitive
                                                                             error:&error];
    long result = [regex numberOfMatchesInString:email options:0 range:NSMakeRange(0, [email length])];
    if(result>0){
        return YES;
    }else{
        return NO;
    }
}

+ (BOOL)validateCVV2:(NSString *)CVV2 {
    if ([CVV2 isEqualToString:@""]||[CVV2 length]!=3) {
        return NO;
    }
    return YES;
}

+ (BOOL)validateYear:(NSString *)year month:(NSString *)month {
    NSDate *now = [NSDate date];
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSUInteger unitFlags = NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitHour | NSCalendarUnitMinute | NSSecondCalendarUnit;
    NSDateComponents *dateComponent = [calendar components:unitFlags fromDate:now];
    
    long nowYear=[dateComponent year];
    long simpleYear=nowYear-2000;
    long nowMonth=[dateComponent month];
    
    if (year!=nil) {
        if ([year isEqualToString:@""]||[year length]!=2||[year intValue]<simpleYear) {
            return NO;
        }
        return YES;
    }
    if (month!=nil) {
        if ([month isEqualToString:@""]||([month length]!=2&&[month length]!=1)||[month intValue]<1||[month intValue]>12) {
            return NO;
        }else if ([year intValue]==simpleYear&&[month intValue]<nowMonth){
            return NO;
        }
        return YES;
    }
    return YES;
}

+ (BOOL)validateCreditCardNumber:(NSString *)creditCardNumber {
    if ([creditCardNumber isEqualToString:@""]||[creditCardNumber length]<13||[creditCardNumber length]>18) {
        return NO;
    }
    return YES;
}

+ (BOOL)validateOtherCardNumber:(NSString *)cardNumber cardType:(int)type{
    switch (type) {
        case 0:
            if ([cardNumber isEqualToString:@""]||([cardNumber length]!=18&&[cardNumber length]!=15)) {
                return NO;
            }
            return YES;
            break;
        case 1:
            if ([cardNumber isEqualToString:@""]||[cardNumber length]!=9) {
                return NO;
            }
            return YES;
            break;
        case 2:
            if ([cardNumber isEqualToString:@""]||[cardNumber length]!=8) {
                return NO;
            }
            return YES;
            break;
        case 3:
            if ([cardNumber isEqualToString:@""]||[cardNumber length]!=10) {
                return NO;
            }
            return YES;
            break;
        default:
            return YES;
            break;
    }
}


+ (NSString *)documentPath:(NSString *)filename{
    NSString *result=nil;
    NSArray *folders = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask,YES);
    NSString *documentsFolder = [folders objectAtIndex:0];
    result = [documentsFolder stringByAppendingPathComponent:filename];
    
    return result;
}

+ (UIImage *)getImage:(NSString *)imageName{
    NSArray *paths = NSSearchPathForDirectoriesInDomains( NSDocumentDirectory,                                                                          NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *filePath2 = [documentsDirectory stringByAppendingPathComponent:imageName];
    UIImage *img = [UIImage imageWithContentsOfFile:filePath2];
    return img;
}

+ (UIImage*) OriginImage:(UIImage *)image scaleToSize:(CGSize)size{
    UIGraphicsBeginImageContext(size);
    [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext(); UIGraphicsEndImageContext();
    return scaledImage;
}

+ (UIImage*) circleImage:(UIImage*) image withParam:(CGFloat) inset {
    UIGraphicsBeginImageContext(image.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(context, 2);
    CGContextSetStrokeColorWithColor(context, [UIColor redColor].CGColor);
    CGRect rect = CGRectMake(inset, inset, image.size.width - inset * 2.0f, image.size.height - inset * 2.0f);
    CGContextAddEllipseInRect(context, rect);
    CGContextClip(context);
    
    [image drawInRect:rect];
    CGContextAddEllipseInRect(context, rect);
    CGContextStrokePath(context);
    UIImage *newimg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newimg;
}


+ (UIImage *)placeholdImage:(CGSize)size {
    return [LWUtil OriginImage:[UIImage imageNamed :@"defaultPic.jpg"] scaleToSize:size];
}

+ (BOOL)writeImage:(UIImage*)image toFileAtPath:(NSString*)aPath {
    if ((image == nil) || (aPath == nil) || ([aPath isEqualToString:@""]))
        return NO;
    @try {
        NSData *imageData = nil;
        //        NSString *ext = [aPath pathExtension];
        imageData = UIImagePNGRepresentation(image);
        //        if ([ext isEqualToString:@"png"]) {
        //            imageData = UIImagePNGRepresentation(image);
        //        }
        //        else {
        //            imageData = UIImageJPEGRepresentation(image, 1);
        //        }
        
        if ((imageData == nil) || ([imageData length] <= 0))
            return NO;
        
        [imageData writeToFile:aPath atomically:YES];
        return YES;
    }
    @catch (NSException *e) {
        MSLog(@"保存图片失败");
    }
    return NO;
}


+ (NSString *)randomStringWithLength:(int)len {
    NSString *letters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    NSMutableString *randomString = [NSMutableString stringWithCapacity: len];
    
    for (int i=0; i<len; i++) {
        [randomString appendFormat: @"%C", [letters characterAtIndex: arc4random_uniform((int)[letters length])]];
    }
    
    return randomString;
}

#pragma mark - 颜色转换 IOS中十六进制的颜色转换为UIColor
+ (UIColor *) colorWithHexString: (NSString *)color{
    NSString *cString = [[color stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    
    
    if ([cString length] < 6) {
        return [UIColor clearColor];
    }
    
    
    if ([cString hasPrefix:@"0X"])
        cString = [cString substringFromIndex:2];
    if ([cString hasPrefix:@"#"])
        cString = [cString substringFromIndex:1];
    if ([cString length] != 6) {
        MSLog(@"输入的16进制有误，不足6位！");
        return [UIColor clearColor];
        
    }
    
    NSRange range;
    range.location = 0;
    range.length = 2;
    
    //r
    NSString *rString = [cString substringWithRange:range];
    
    //g
    range.location = 2;
    NSString *gString = [cString substringWithRange:range];
    
    //b
    range.location = 4;
    NSString *bString = [cString substringWithRange:range];
    
    // Scan values
    unsigned int r, g, b;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    
    return [UIColor colorWithRed:((float) r / 255.0f) green:((float) g / 255.0f) blue:((float) b / 255.0f) alpha:1.0f];
}

+ (UIColor *) colorWithHexString: (NSString *)color alpha:(float)alpha{
    NSString *cString = [[color stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    
    
    if ([cString length] < 6) {
        return [UIColor clearColor];
    }
    
    
    if ([cString hasPrefix:@"0X"])
        cString = [cString substringFromIndex:2];
    if ([cString hasPrefix:@"#"])
        cString = [cString substringFromIndex:1];
    if ([cString length] != 6) {
        MSLog(@"输入的16进制有误，不足6位！");
        return [UIColor clearColor];
        
    }
    
    NSRange range;
    range.location = 0;
    range.length = 2;
    
    //r
    NSString *rString = [cString substringWithRange:range];
    
    //g
    range.location = 2;
    NSString *gString = [cString substringWithRange:range];
    
    //b
    range.location = 4;
    NSString *bString = [cString substringWithRange:range];
    
    // Scan values
    unsigned int r, g, b;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    
    return [UIColor colorWithRed:((float) r / 255.0f) green:((float) g / 255.0f) blue:((float) b / 255.0f) alpha:alpha];
}

+ (UIImage*) replaceColor:(UIColor*)color inImage:(UIImage*)image withTolerance:(float)tolerance {
    UIGraphicsBeginImageContextWithOptions(image.size, NO, image.scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextTranslateCTM(context, 0, image.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    CGContextSetBlendMode(context, kCGBlendModeNormal);
    CGRect rect = CGRectMake(0, 0, image.size.width, image.size.height);
    CGContextClipToMask(context, rect, image.CGImage);
    [color setFill];
    CGContextFillRect(context, rect);
    UIImage*newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

+(NSMutableAttributedString*)returnAttributedStringWithHtml:(NSString*)html
{
    NSMutableAttributedString * attrStr = [[NSMutableAttributedString alloc] initWithData:[html dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];
    return attrStr;
}

+(UIImage *)imageWithColor:(UIColor *)color frame:(CGRect)frame{
    
    CGRect rect = CGRectMake(0, 0, frame.size.width, frame.size.height);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}

+ (UIImage *)imageWithColor:(UIColor *)color
{
    CGRect rect = CGRectMake(0,0,1.0,1.0);

    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, color.CGColor);
    CGContextFillRect(context, rect);
    UIImage *coloredImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return coloredImage;
}

+(BOOL)scrollDidScrollToBottom:(UIScrollView*)scrollview
{
    
    CGPoint offset = scrollview.contentOffset;
    
    CGRect bounds = scrollview.bounds;
    
    CGSize size = scrollview.contentSize;
    
    UIEdgeInsets inset = scrollview.contentInset;
    
    
    CGFloat currentOffset = offset.y + bounds.size.height - inset.bottom;
    
    CGFloat maximumOffset = size.height;
    
    //当currentOffset与maximumOffset的值相等时，说明scrollview已经滑到底部了。也可以根据这两个值的差来让他做点其他的什么事情
    
    if(currentOffset>=maximumOffset)
    {
        return YES;
    }
    else
    {
        return NO;
    }
    
}

+ (NSString *)getString:(id)info andDefaultStr:(NSString *)defaultStr{
    if (!info) {
        return defaultStr;
    }
    
    if ([info isKindOfClass:[NSNull class]]) {
        return defaultStr;
    }
    
    if ([info isKindOfClass:[NSString class]]) {
        if ([info isNotEmptyWithSpace]) {
            if ([info isEqualToString:@"<null>"]) {
                return defaultStr;
            }
            return [NSString stringWithFormat:@"%@", info];
        } else {
            return defaultStr;
        }
    }
    
    return [NSString stringWithFormat:@"%@", info];

}

+ (NSArray *)defaultSearchType {
  
    return @[
             @{
                 @"value" : @(2),
                 @"name" : @"星级酒店"
                 },
             @{
                 @"value" : @(3),
                 @"name" : @"特色餐厅"
                 },
             @{
                 @"value" : @(4),
                 @"name" : @"婚礼会所"
                 },
             @{
                 @"value" : @(5),
                 @"name" : @"游轮婚礼"
                 },
             @{
                 @"value" : @(6),
                 @"name" : @"花园洋房"
                 },
             @{
                 @"value" : @(7),
                 @"name" : @"三星酒店"
                 },
             @{
                 @"value" : @(8),
                 @"name" : @"四星酒店"
                 },
             @{
                 @"value" : @(9),
                 @"name" : @"五星酒店"
                 }
             ];
}

+ (NSArray *)defaultSearchItem {
    
    return @[
             @"创意婚礼",
             @"室外婚礼",
             @"西式婚礼",
             @"草坪婚礼",
             @"小型婚宴",
             @"大厅无柱",
             @"独立门面",
             @"酒水自带",
             @"落地玻璃",
             @"露台仪式",
             @"观景餐厅",
             @"水晶吊灯"
             ];
}

+ (NSString *)toJSONString:(id)theData{
    
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:theData
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&error];
    
    if ([jsonData length] > 0 && error == nil){
        return  [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];;
    }else{
        return nil;
    }
    
}

// 将JSON串转化为字典或者数组
+ (id)toArrayOrNSDictionary:(NSData *)jsonData{
    NSError *error = nil;
    id jsonObject = [NSJSONSerialization JSONObjectWithData:jsonData
                                                    options:NSJSONReadingAllowFragments
                                                      error:&error];
    
    if (jsonObject != nil && error == nil){
        return jsonObject;
    }else{
        // 解析错误
        return nil;
    }
    
}

+(NSMutableAttributedString*)returnAttributedStringWithString:(NSString*)string andLineWidth:(float)width andFont:(UIFont*)font andColor:(UIColor*)color
{
    string = [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];//去掉首位空格
    
    NSMutableAttributedString *attrString = [[NSMutableAttributedString alloc] initWithString:string];
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
    [paragraphStyle setLineSpacing:width];
    [attrString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, string.length)];
    
    [attrString addAttribute:NSForegroundColorAttributeName value:color range:NSMakeRange(0, string.length)];
    
    [attrString addAttribute:NSFontAttributeName value:font range:NSMakeRange(0, string.length)];
    return attrString;
}


@end
