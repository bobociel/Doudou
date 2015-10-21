//
//  BaseFunction.h
//  nihao
//
//  Created by HelloWorld on 5/26/15.
//  Copyright (c) 2015 jiazhong. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface BaseFunction : NSObject

#pragma mark - 图片调整

/**
 *  调整图片至指定大小，等比缩放
 *
 *  @param image     需要缩放的uiimage对象
 *  @param scaleSize 缩放比例
 *
 *  @return 经过缩放后的uiimage对象
 */
+(UIImage *)scaleImage:(UIImage *)image toScale:(float)scaleSize;

/**
 *  调整图片至指定大小，以CGSize与图片的最小比例值进行等比缩放
 *
 *  @param image 需要缩放的uiimage对象
 *  @param scaleSize 缩放比例
 *
 *  @return 经过缩放后的uiimage对象
 */
+(UIImage *)scaleImage:(UIImage *)image toSize:(CGSize)scaleSize;

/**
 *  调整图片至指定大小，以CGSize与图片的最小比例值进行等比缩放
 *
 *  @param imageName 图片名字
 *  @param scaleSize 缩放比例
 *
 *  @return 经过缩放后的uiimage对象
 */
+(UIImage *)scaleImage:(NSString *)imageName toFixed:(CGSize)scaleSize;

/**
 *  调整图片至指定大小
 *
 *  @param imageName 图片名字
 *  @param scaleSize 缩放比例
 *
 *  @return 经过缩放后的uiimage对象
 */
+(UIImage *)makeImageSize: (NSString *)imageName toFixed:(CGSize)scaleSize;

/**
 *  调整图片至指定大小
 *
 *  @param image     uiimage
 *  @param scaleSize 缩放的指定大小
 *
 *  @return 经过缩放后的uiimage对象
 */
+(UIImage *)makeImageSize: (UIImage *)image fixed:(CGSize)scaleSize;

/**
 *  截屏
 *
 *  @param view 需要截图的uiview
 *  @param rect 截图的区域
 *
 *  @return 截屏得到的uiimage对象
 */
+ (UIImage *) getScreenToImage:(UIView *)view area:(CGRect)rect;

/**
 *  截断图片
 *
 *  @param image 截断图片的uiimage对象
 *  @param size  截断的目标区域
 *
 *  @return
 */
+ (UIImage *) catOffImage:(UIImage *)image toSize:(CGSize)size;

/**
 *  保存图片到本地
 *
 *  @param image 需要保存的图片对象
 *  @param path  保存的指定本地路径
 */
+ (void)saveImage:(UIImage *)image toPath:(NSString *)path;

/**
 *  根据图片类型将图片保存到指定目录下
 *
 *  @param image     需要保存的图片对象
 *  @param path      保存的指定本地路径
 *  @param imageName 图片名
 *  @param extension 图片后缀，如png，jpg
 *
 *  @return 是否保存成功
 */
+ (BOOL)saveImage:(UIImage *)image toPath:(NSString *)path withName:(NSString *)imageName andExtension:(NSString *)extension;

/**
 *  将两张图片合成一张图片
 *
 *  @param photo
 *  @param doodle
 *
 *  @return
 */
+ (UIImage *)compoundImageWithPhoto:(UIImage *)photo andDoodle:(UIImage *)doodle;

/**
 *  全分辨率压缩图片并保存
 *
 *  @param image    要压缩保存的图片
 *  @param path     保存的路径
 *  @param fileName 保存的文件名
 *  @param extension 压缩和保存的文件后缀
 *
 *  @return 保存结果
 */
+ (BOOL)compressImage:(UIImage *)image AndSaveToPath:(NSString *)path SaveFileName:(NSString *)fileName andExtension:(NSString *)extension;

#pragma mark - 网络请求

/**
 *  判断是否已联网
 *
 *  @return yes表示已联网，否则未联网
 */
+(BOOL)isNetworkReachable;

/**
 *  HTTP GET请求
 *
 *  @param url
 *
 *  @return
 */
+(NSData *) doHttpGet:(NSString *)url;

/**
 *  HTTP POST请求
 *
 *  @param url
 *  @param param
 *
 *  @return
 */
+(NSData *) doHttpPost:(NSString *)url withParam:(NSData *)param;

/**
 *  HTTP POST请求
 *
 *  @param url
 *  @param param
 *
 *  @return
 */
+(NSData *) doHttpPost:(NSString *)url withString:(NSString *)param;

/**
 *  获取网络图片
 *
 *  @param url
 *
 *  @return
 */
+(UIImage *) getImageFromUrl:(NSString *)url;


/**
 *  获取网络图片
 *
 *  @param url
 *
 *  @return
 */
+(NSData *)getImageDataFromUrl:(NSString *)url;


#pragma mark - 字符串处理

/**
 *  利用正则表达示获取字符串的匹配结果
 *
 *  @param source 源字符串
 *  @param regExp 正则表达式
 *
 *  @return 匹配结果字符串
 */
+(NSString *) getRegExpressResult:(NSString *)source regExp:(NSString *)regExp;

/**
 *  匹配字符串中的HTML标记内容
 *
 *  @param source 源字符串
 *  @param tag    html的tag
 *
 *  @return 匹配结果
 */
+(NSString *) getHtmlText:(NSString *)source tagName:(NSString *)tag;

/**
 *  匹配HTML标记内容中的属性值
 *
 *  @param tagContext
 *  @param attr
 *
 *  @return
 */
+(NSString *) getHtmlTagAttr:(NSString *)tagContext attrName:(NSString *)attr;

/**
 *  获取HTML标记的文本
 *
 *  @param tagContext
 *
 *  @return
 */
+(NSString *) getHTmlTagText:(NSString *)tagContext;

/**
 *  替换HTML标签
 *
 *  @param source 源字符串
 *
 *  @return
 */
+(NSString *) replaceHtmlTag:(NSString *)source;

/**
 *  替换HTML标签
 *
 *  @param source 源字符串
 *  @param exp    正则表达式
 *
 *  @return
 */
+(NSString *) replaceString:(NSString *)source byRegexp:(NSString *)exp;

/**
 *  正则验证
 *
 *  @param source 源字符串
 *  @param exp 正则表达式
 *
 *  @return true可通过验证；否则未通过
 */
+(BOOL) string:(NSString *)source MatchRegex:(NSString *) exp;

/**
 *  获取正则表达式中匹配的个数
 *
 *  @param text 源字符串
 *  @param exp  正则表达式
 *
 *  @return 匹配的个数
 */
+ (NSInteger) getMatchCount:(NSString *)text inRegx:(NSString *)exp;

/**
 *  替换XML敏感字符
 *
 *  @param text 源字符串
 *
 *  @return 经过处理后的字符串
 */
+ (NSString *) replaceXMLSensitiveLettler:(NSString *)text;

/**
 *  分离坐标
 *
 *  @param coord 坐标点
 *  @param lat   纬度
 *  @param lng   精度
 */
+(void) separateCoordinate:(NSString *)coord lat:(NSString **)lat lng:(NSString **)lng;

/**
 *  从文件路径中分解出文件名
 *
 *  @param filePath 文件目录
 *
 *  @return 获取到的文件名
 */
+ (NSString *) splitFileNameForPath:(NSString *)filePath;

/**
 *  从文件路径中分解出文件名
 *
 *  @param filePath 文件目录
 *
 *  @return 获取到的文件后缀
 */
+ (NSString *) getFileExtension:(NSString *)filePath;

/**
 *  获取设备型号
 *
 *  @return
 */
+ (NSString *) platform;

/**
 *  MD5加密
 *
 *  @param str 源字符串
 *
 *  @return md5加密结果
 */
+ (NSString *)md5Digest:(NSString *)str;

/**
 *  HMAC-SHA1 加密
 *
 *  @param str 待加密的字符串
 *
 *  @return 加密之后的字符串
 */
+ (NSString *)SHA1:(NSString *)str;

/**
 *  判断string是否可转化为整形
 *
 *  @param string 源字符串
 *
 *  @return
 */
+ (BOOL)isPureInt:(NSString *)string;

/**
 *  判断string是否可转化为浮点形
 *
 *  @param string 源字符串
 *
 *  @return
 */
+ (BOOL)isPureFloat:(NSString *)string;

/**
 *  版本号比较
 *
 *  @param versionA 版本号a
 *  @param versionB 版本号b
 *
 *  @return 返回yes，表示a的版本号比b大，否则比b小
 */
+ (BOOL)isVersion:(NSString*)versionA biggerThanVersion:(NSString*)versionB;

/**
 *  将服务器获取过来的图片地址转换成为可以请求的图片地址
 *
 *  @param imageURL 图片服务器地址
 *
 *  @return 返回转换过的图片地址
 */
+ (NSString *)convertServerImageURLToURLString:(NSString *)imageURL;


#pragma mark - 阴影、圆角、边框、动画、view

/**
 *  根据字符串，文本框字体和文本框限制大小，来获取能显示完整字符串，文本框所需的实际大小
 *
 *  @param text 需显示的字符串
 *  @param font 文本字体
 *  @param size 文本框绘制的区域大小
 *
 *  @return
 */
+ (CGSize)labelSizeWithText:(NSString *)text font:(UIFont *)font constrainedToSize:(CGSize)size;

/**
 *  根据文本框的字体大小，要想全部绘制一段字符串，文本框所需的实际大小
 *
 *  @param text 需显示的字符串
 *  @param font 文本框绘制的区域大小
 *
 *  @return
 */
+ (CGSize)labelSizeWithText:(NSString *)text font:(UIFont *)font;

/**
 *  给view的背景添加圆角
 *
 *  @param cornerRadius 圆角半径
 *  @param view         需处理的view对象
 */
+ (void)setCornerRadius:(float)cornerRadius view:(UIView *)view;

/**
 *  给view添加边框
 *
 *  @param width 边框的宽度
 *  @param color 边框的颜色
 *  @param view  需处理的view对象
 */
+ (void)setBorderWidth:(float)width color:(UIColor *)color view:(UIView *)view;

/**
 *  给view添加阴影
 *
 *  @param color   阴影颜色
 *  @param opacity 阴影透明度
 *  @param radius  阴影的半径
 *  @param offset  阴影的偏移
 *  @param view    需处理的view对象
 */
+ (void)setShadowByColor:(UIColor *)color opacity:(float)opacity radius:(float)radius  offset:(CGSize)offset view:(UIView *)view;

/**
 *  输入框通用圆角、边框
 *
 *  @param view  需处理的view对象
 */
+ (void)setContentViewBorderAndCorner:(UIView *)view;

/**
 *  view执行渐入动画
 *
 *  @param view
 */
+ (void)fadeIn:(UIView *)view;

/**
 *  view执行渐出动画
 *
 *  @param view
 */
+ (void)fadeOut:(UIView *)view;

/**
 *  显示提示框
 *
 *  @param msg   提示框消息
 *  @param title 提示框标题
 */
+(void) showAlertMsg:(NSString *)msg title:(NSString *)title;


#pragma mark - 电话号码

/**
 *  判断是否为手机号码
 *
 *  @param mobileNum 电话号码
 *
 *  @return yes表示为电话号码否则不是
 */
+ (BOOL) isMobileNumber:(NSString *)mobileNum;

/**
 *  判断是否为移动手机号码
 *
 *  @param mobileNum 电话号码
 *
 *  @return yes表示此号码是移动号码否则不是
 */
+ (BOOL) isChinaMobile:(NSString *)mobileNum;

/**
 *  判断是否为联通手机号码
 *
 *  @param mobileNum 电话号码
 *
 *  @return yes表示为联通号码否则不是
 */
+ (BOOL) isChinaUnicom:(NSString *)mobileNum;

/**
 *  判断是否为电信手机号码
 *
 *  @param mobileNum 电话号码
 *
 *  @return yes表示为电信号码否则不是
 */
+ (BOOL) isChinaTelecom:(NSString *)mobileNum;

/**
 *  判断字符串是否为邮箱地址
 *
 *  @param email 邮箱字符串
 *
 *  @return yes表示为正确的邮箱地址否则不是
 */
+ (BOOL) isEmailAddress:(NSString *)email;


#pragma mark - 文件目录
/**
 *  Documents目录,iTunes备份和恢复的时候会包括此目录，程序退出后不删除
 *
 *  @return Documents目录路径
 */
+ (NSString *)pathForDocumentsDir;

/**
 *  tmp目录，存放临时文件，不会备份，程序退出后删除
 *
 *  @return tmp目录路径
 */
+ (NSString *)pathForTmpDir;

/**
 *  Library/Caches目录，缓存目录，不会备份，程序退出后不删除
 *
 *  @return Library/Caches目录路径
 */
+ (NSString *)pathForCachesDir;

/**
 *  单个文件的大小
 *
 *  @param filePath 文件路径
 *
 *  @return 文件大小
 */
+ (long long) fileSizeAtPath:(NSString*) filePath;

/**
 *  删除指定文件
 *
 *  @param path 要删除的文件路径
 *
 *  @return 文件删除结果
 */
+ (BOOL)deleteFileAtPath:(NSString *)path;

/**
 *  获取当前的文件路径，解决应用包名发生改变之后找不到文件的问题
 *
 *  @param filePath 文件路径
 *
 *  @return 替换之后的文件路径
 */
+ (NSString *)getCurrentPathWithFilePath:(NSString *)filePath;

#pragma mark - 其它函数

/**
 *  取一个随机整数
 **/
+ (int)random;

/**
 *  取一个随机整数 0~x-1
 *
 *  @param x
 *
 *  @return
 */
+ (int)random:(int)x;

/**
 *  获取当前时间
 *
 *  @return
 */
+(int) getCurrentTime;

/**
 *  按照格式：“yyyy-MM-dd HH:mm:ss”获取当前的时间
 *
 *  @return 获取当前时间字符串
 */
+ (NSString *)getToday;

/**
 * 按照格式：“yyMMddHHmmss”获取当前的时间
 *
 *  @return 获取当前时间字符串
 */
+ (NSString *)getPhotoNameWithCurrentTime;

/**
 * 按照格式：“yyyyMMddHHmmss”获取当前的时间
 */
+ (NSString *)getTimeStampAtCurrentTime;

/**
 *  获取汇率界面的时间
 *
 *  @param dateString 汇率记录时间
 *
 *  @return 转换之后的时间
 */
+ (NSString *)exchangeRateTimeFromString:(NSString *)dateString;

/**
 *  将dateStr解析成yyyy-MM-dd格式的字符串
 *
 *  @param dateStr 日期字符串
 *
 *  @return 返回yyyy-MM-dd格式的字符串
 */
+ (NSDate *)dateFromString:(NSString *)dateStr;

+ (NSDate *)longDateFromString:(NSString *)dateStr;

/**
 *  将dateStr解析成根据制定的日期格式的字符串
 *
 *  @param dateStr 日期字符串
 *  @param dateFormat 时间格式字符串
 *
 *  @return 返回指定格式的字符串
 */
+ (NSDate *)dateFromString:(NSString *)dateStr dateFormat:(NSString *)dateFormat;

/**
 *  将当前时间转成字符串，格式：yyyy-MM-dd
 *
 *  @return
 */
+ (NSString *)stringFromCurrent;

/**
 *  获取当前时间的字典
 *
 *  @return
 */
+ (NSDictionary *)getCurrentDateDictionary;

/**
 *  获取指定日期的时间戳
 *
 *  @param date date
 *
 *  @return
 */
+ (NSTimeInterval)timeIntervalSinceNow:(NSDate *)date;

/**
 *  按照格式：“yyyy-MM-dd”获取传入的时间
 *
 *  @return 获取传入的日期字符串
 */
+ (NSString *)stringDateFromDate:(NSDate *)date;

/**
 *  根据传入的时间格式，格式化日期
 *
 *  @param date       日期
 *  @param dateFormat 时间格式化字符串
 *
 *  @return 时间
 */
+ (NSString *) stringFromDate : (NSDate *) date format : (NSString *) dateFormat;

/**
 *  获得屏幕指定控件图像
 *
 *  @param theView 要获取图像的视图
 *
 *  @return 视图的图片
 */
+ (UIImage *)imageFromView:(UIView *) theView;

/**
 *  计算两个经纬度之间的距离
 *
 *  @param longitude  经度1
 *  @param latitude    纬度1
 *  @param longitude2 经度2
 *  @param latitude2   纬度2
 *
 *  @return 距离，字符串格式
 */
+ (NSString *)calculateDistance:(float)longitude latitude:(float)latitude longitude2:(NSString *)longitude2 latitude2:(NSString *)latitude2;

/**
 *  计算弧度
 *
 *  @param d 经度或者纬度
 *
 *  @return 弧度值
 */
+ (double)rad:(double)d;

/**
 *  将uicolor对象转化为uiimage对象
 *
 *  @param color
 *
 *  @return
 */
+ (UIImage *)imageWithColor:(UIColor *)color;

/**
 *  给view添加边框阴影
 *
 *  @param opacity      阴影透明度
 *  @param shadowColor  阴影颜色
 *  @param view         需要处理的view对象
 */
+ (void) setShadow : (float) opacity shadowColor : (UIColor *) shadowColor offset : (CGSize) offset view : (UIView *) view;

/**
 *  添加上拉刷新下拉加载控件
 *
 *  @param table          uitableview
 *  @param refreshAction  刷新操作
 *  @param loadMoreAction 加载更多操作
 *  @param target         viewcontroller
 */
+ (void) addRefreshHeaderAndFooter:(UIScrollView *)scrollView refreshAction:(SEL)refreshAction loadMoreAction : (SEL) loadMoreAction target: (id) target;

/**
 *  将距离转换成短的距离字符串
 *
 *  @param distance          距离
 */
+ (NSString *)convertDistanceToShortString:(double)distance;

/**
 *  将Nearby下选择的距离转换成long类型的距离
 *
 *  @param sDistance          距离
 */
+ (long)getDistanceFromSelectedNearby:(NSString *)sDistance;

/**
 *  通过生日计算年龄
 *
 *  @param birthday          生日
 */
+ (NSInteger)calculateAgeByBirthday:(NSDate *)birthday;

/**
 *  随机颜色
 *
 */
+ (UIColor *)randomColor;

/**
 *  将服务器返回的动态添加时间与本地时间进行对比，格式化成指定格式的字符串
 *
 *  @param date yyyy-MM-dd hh:mm:ss
 *
 *  @return 5分钟以内返回just now，5-60分钟之内返回x min ago，超过一个小时但是今天发布的返回x hour ago，昨天发布的返回Yesterday, 比昨天还要更早的返回具体日期MM-dd
 */
+ (NSString *) dynamicDateFormat : (NSString *) date;

/**
 *  将中文转化为英文
 *
 *  @param sourceString 中文
 *
 *  @return 拼音
 */
+ (NSString *) chineseToPinyin:(NSString*)sourceString;

/**
 *  获取设备的唯一码
 *
 *  @return 
 */
+ (NSString *) uuid;

/**
 *  根据 index 来获取是星期几的英文单词
 *
 *  @param index 小标，从1开始，比如1就是 Monday
 *
 *  @return  星期几的英文单词
 */
+ (NSString *)getWeekdayNameByIndex:(NSInteger)index;

/**
 *  根据风向的中文名称获取对应的英文名称
 *
 *  @param windCNName 风向的中文名称
 *
 *  @return 风向的英文名称
 */
+ (NSString *)getWindDirectionEnglishNameByChineseName:(NSString *)windDirectionCNName;

/**
 *  根据质量的中文来获取对应的英文单词
 *
 *  @param cnQualityName 中文名称
 *
 *  @return 对应的英文单词
 */
+ (NSString *)getAirQualityEnglishNameByChinese:(NSString *)cnQualityName;

/**
 *  根据获取来的风力截取出不包含中文的风力字符串
 *
 *  @param originalWindPower 原风力数据
 *
 *  @return 截取后的风力数据
 */
+ (NSString *)getWindPowerLevelByOriginalWindPower:(NSString *)originalWindPower;

/**
 *  根据中文的紫外线等级获取对应的英文词语
 *
 *  @param cnUVName 中文等级
 *
 *  @return 英文等级
 */
+ (NSString *)getUVLevelByChineseName:(NSString *)cnUVName;

/**
 *  根据中文的穿衣指数等级获取对应的英文词语
 *
 *  @param cnCIName 中文的穿衣指数等级
 *
 *  @return 英文的穿衣指数等级
 */
+ (NSString *)getClothesIndexENByChineseName:(NSString *)cnCIName;

/**
 *  根据中文舒适度等级获取对应的英文等级
 *
 *  @param cnComfortLevelName 中文舒适度等级
 *
 *  @return 英文舒适度等级
 */
+ (NSString *)getComfortLevelENByChineseName:(NSString *)cnComfortLevelName;

/**
 *  根据中文的运动指数等级获取对应的英文等级
 *
 *  @param cnSportsName 中文等级
 *
 *  @return 英文等级
 */
+ (NSString *)getSportsLevenENByChineseName:(NSString *)cnSportsName;

/**
 *  根据中文的旅游指数等级获取对应的英文等级
 *
 *  @param cnTravelLevelName 中文等级
 *
 *  @return 英文等级
 */
+ (NSString *)getTravelLevelENByChineseName:(NSString *)cnTravelLevelName;

+ (NSString *)encodeToPercentEscapeString:(NSString *)input;

+ (NSString *)decodeFromPercentEscapeString:(NSString *)input;

+ (NSString *) getMonth : (NSUInteger) monthComponent;

/**
 *  昵称验证
 *
 *  @param nickname 昵称
 *
 *  @return 是否符合
 */
+ (BOOL)validateNickname:(NSString *)nickname;

@end
