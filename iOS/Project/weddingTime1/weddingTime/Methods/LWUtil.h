//
//  LWUtil.h
//  weddingTreasure
//
//  Created by momo on 15/6/25.
//  Copyright (c) 2015年 momo. All rights reserved.
//
/********************************************************
 ****************** ------------*************************
 ******************|**公共方法类**|************************
 ****************** ------------*************************
 ********************************************************/
#import "LWAssistUtil.h"
typedef enum{
    UIPanDirectionNone  = 0,
    UIPanDirectionLeft  = 1,
    UIPanDirectionRight = 2,
    UIPanDirectionTop   = 3,
    UIPanDirectionDown  = 4
}UIPanDirection;

@interface LWUtil : NSObject



/**
 *  设定width计算string的高度，
 *
 *  @param string 内容
 *  @param width  宽度
 *  @param font   字体
 *
 *  @return 返回高度值
 */
+ (float)countHeightOfString:(NSString *)string WithWidth:(float)width Font:(UIFont *)font;

+ (float)countHeightOfAttributeString:(NSAttributedString *)string WithWidth:(float)width;

+ (float)countWidthOfString:(NSString *)string WithHeight:(float)height Font:(UIFont *)font;

//使文本款的左边间距右移一段距离
+ (void)adjustTextFieldLeftView:(NSArray *)textFieldArr andWidth:(CGFloat)width;

/**
 *  验证手机号码是否正确
 *
 *  @param phone 手机号
 *
 *  @return 正确返回yes
 */
+ (BOOL)validatePhoneNumber:(NSString *)phone;


/**
 *  验证电子邮箱是否正确
 *
 *  @param  电子邮箱地址
 *
 *  @return 正确返回yes
 */
+ (BOOL)validateEmail:(NSString *)email;


/**
 *  验证身份证是否正确
 *
 *  @param cardNumber 身份证号码
 *
 *  @return 正确则返回yes
 */
+ (BOOL)validateCardNumber:(NSString *)cardNumber;

/**
 *  验证证件类型号码是否正确
 *
 *  @param cardNumber 证件号码
 *  @param type       类型0：身份证   1：护照  2：军官  3：台胞
 *
 *  @return 正确返回yes
 */
+ (BOOL)validateOtherCardNumber:(NSString *)cardNumber cardType:(int) type;

/**
 *  验证信用卡号是否正确
 *
 *  @param creditCardNumber 信用卡号
 *
 *  @return 正确返回yes
 */
+ (BOOL)validateCreditCardNumber:(NSString *)creditCardNumber;

/**
 *  获取一个手势的滑动方向
 *
 *  @param translation 滑动的转变坐标
 *
 *  @return 方向 @see UIPanDirection
 */
+ (UIPanDirection)calculatePanDirectionWithTranslation:(CGPoint)translation;

/**
 *  转换日历时间
 *
 *  @param date 2013-11-18
 *  @param hour 12
 *  @param min  30
 *
 *  @return 返回一个时间的字符串 2013-11-18 12:30
 */

+ (NSString *)getDateTypeByDate:(NSString *)date hour:(NSString *)hour min:(NSString *)min;

/**
 *  通过一个完整的日期得到一个只有月和日的日期
 *
 *  @param date 2013-11-18
 *  @param type 1,2
 *  @return 11/18,11月18日
 */
+ (NSString *)getSimpleDateByAllDate:(NSString *)date type:(int)type;


/**
 *  计算两个日期间的时间差
 *
 *  @param compareDate 后面的时间
 *  @param beforeTime  之前的时间
 *
 *  @return 返回相差天数
 */
+ (int) compareCurrentTime:(NSDate*) compareDate  beforeTime:(NSDate*) beforeTime;

/**
 *  计算两个日期间的时间差
 *
 *  @param compareDateStr 后面的时间
 *  @param beforeTimeStr  前面的时间
 *
 *  @return 返回相差天数
 */


+ (int)compareTwoDateTimeByString:(NSString *)compareDateStr beforeTime:(NSString *)beforeTimeStr;

/**
 *  计算两个时间的差 得到秒数
 *
 *  @param compareDate 当前时间
 *  @param beforeTime  以前的时间
 *
 *  @return 时间差的秒数
 */
+ (int)compareCurrentTimeSec:(NSDate *)compareDate beforeTime:(NSDate *)beforeTime;
/**
 *  把string类型转换为date类型
 *
 *  @param dateStr string日期
 *
 *  @return NSDate
 */
+ (NSDate *) convertStringToDate:(NSString *)dateStr;


/**
 *  把日期型转换成字符型
 *
 *  @param date 日期
 *
 *  @return 字符串格式yyyy-mm-dd HH:mm:ss
 */
+ (NSString *)convertNSDateToNSString:(NSDate *)date;

/**
 *  把日期型转换成字符型,并且带有业务逻辑
 *
 *  @param date 日期
 *
 *  @return 字符串
 */
+ (NSString *)getTimeStringWithDate:(NSDate *)date;
/**
 *  通过日期得到第二天的日期
 *
 *  @param date 当前日期
 *
 *  @return 第二天的日期
 */
+ (NSDate *) getTomorrowDateByCurrentDate:(NSDate *)date;

+ (NSDate *) getBeforeDateByCurrentDate:(NSDate *)date;

+ (NSDate *)getDateAfterByCurrentDate:(NSDate *)date withInterval:(int)day;

/**
 *  得到当前日期
 *
 *  @return 2013-12-8
 */
+ (NSString *)getToday;

/**
 *  得到系统当前日期的第二天的值
 *
 *  @return 2013-12-9
 */
+ (NSString *)getTomorrow;

/**
 *  得到当前时间  18：00
 *
 *  @return 18：00
 */
+ (NSString *)getNowTime;

/**
 *  得到照片存储路径
 *
 *  @param filename 照片名
 *
 *  @return 路径
 */
+ (NSString *)documentPath:(NSString *)filename;

/**
 *  //把照片存到路径中
 
 *
 *  @param image 图片
 *  @param aPath 路径
 *
 *  @return 是否成功
 */

//图片压缩
+ (UIImage*) OriginImage:(UIImage *)image scaleToSize:(CGSize)size;

+ (UIImage *)placeholdImage:(CGSize)size;

+ (UIImage*) circleImage:(UIImage*) image withParam:(CGFloat) inset ;

+ (BOOL)writeImage:(UIImage*)image toFileAtPath:(NSString*)aPath;

/**
 *  //用16进制设置颜色
 
 *
 *  @param color 16进制颜色(带#号)
 *
 *  @return UIColor
 */

//得到一个随机字符串
+ (NSString *)randomStringWithLength:(int)len;

+ (UIColor *) colorWithHexString: (NSString *)color;

+ (UIColor *) colorWithHexString: (NSString *)color alpha:(float)alpha;

+ (UIImage*) replaceColor:(UIColor*)color inImage:(UIImage*)image withTolerance:(float)tolerance;

+(NSMutableAttributedString*)returnAttributedStringWithHtml:(NSString*)html;

//通过颜色来生成一个纯色图片
+(UIImage *)imageWithColor:(UIColor *)color frame:(CGRect)frame;

+ (UIImage *)imageWithColor:(UIColor *) color;

//json相关
+(BOOL)scrollDidScrollToBottom:(UIScrollView*)scrollview;

+ (NSString *)getString:(id)info andDefaultStr:(NSString *)defaultStr ;

+ (NSArray *)defaultSearchType;
+ (NSArray *)defaultSearchItem;


+ (NSString *)toJSONString:(id)theData;

// 将JSON串转化为字典或者数组
+ (id)toArrayOrNSDictionary:(NSData *)jsonData;

+(NSMutableAttributedString*)returnAttributedStringWithString:(NSString*)string andLineWidth:(float)width andFont:(UIFont*)font andColor:(UIColor*)color;

@end