//
//  NESQuickLogger.h
//  NESDataSyncDemo
//
//  Created by Nestor on 14/12/19.
//  Copyright (c) 2014年 NesTalk. All rights reserved.
//

#ifndef NES_QUICK_LOGGER_H
#define NES_QUICK_LOGGER_H

/** LOG级别定义 */
#define LOG_LEVEL_ERROR     0x1         ///错误,需要终止程序的重大问题
#define LOG_LEVEL_WARNING   0x2         ///警告,没有获得正常预期的结果,但是不会影响程序继续执行
#define LOG_LEVEL_ASSERT    0x4         ///断言,根据自定义条件输出
#define LOG_LEVEL_MESSAGE   0x8         ///消息,通常用于打印程序运行时内容
#define LOG_LEVEL_INFO      0x10        ///信息,通常用作提示性文本
#define LOG_LEVEL_TODO      0x20        ///任务,标记当前尚未完成的任务
#define LOG_LEVEL_TEST      0x40        ///测试,仅在进行测试时输出的内容

/** LOG输出模式定义 */

///信息模式,包含除TODO,TEST之外的全部输出
#define LOG_MODE_INFO (LOG_LEVEL_INFO | LOG_LEVEL_ERROR | LOG_LEVEL_MESSAGE | LOG_LEVEL_ASSERT | LOG_LEVEL_WARNING)
///默认,消息模式,包含ERROR,WARNING,ASSERT,MESSAGE
#define LOG_MODE_MESSAGE (LOG_LEVEL_ERROR | LOG_LEVEL_MESSAGE | LOG_LEVEL_ASSERT | LOG_LEVEL_WARNING)
///断言模式,包含ERROR,WARNING,ASSERT
#define LOG_MODE_ASSERT (LOG_LEVEL_ERROR | LOG_LEVEL_ASSERT | LOG_LEVEL_WARNING)
///警告模式,包含ERROR和WARNING
#define LOG_MODE_WARNING (LOG_LEVEL_ERROR | LOG_LEVEL_WARNING)
///调试模式,仅显示ERROR
#define LOG_MODE_DEBUG (LOG_LEVEL_ERROR)
///任务模式,查看尚未完成的任务(根据程序运行显示),如按钮单击事件以做了声明但未实现,可用TODO输出标记,测试时单击按钮即可显示任务目标,用作开发提示
#define LOG_MODE_TODO (LOG_LEVEL_TODO)
///测试模式,包含ERROR,WARNING,ASSERT和TEST,通常将在运行测试用例时输出的内容标记为TEST
#define LOG_MODE_TEST (LOG_LEVEL_TEST | LOG_MODE_ASSERT)
///消息模式,仅显示提示内容,包括MESSAGE和INFO
#define LOG_MODE_INFO_MESSAGE (LOG_LEVEL_INFO | LOG_LEVEL_MESSAGE)
///仅显示信息
#define LOG_MODE_INFO_ONLY (LOG_LEVEL_INFO)
///仅显示消息
#define LOG_MODE_MESSAGE_ONLY (LOG_LEVEL_MESSAGE)
///不做任何输出
#define LOG_MODE_NONE 0x8000

////
/** 输出模式
 默认为MESSAGE模式,可以通过位运算自定义所需的模式,或直接引用已定义的宏
 */
#define LOG_MODE LOG_MODE_MESSAGE
////


#ifdef DEBUG
///基本输出宏,手动指定输出级别,不建议直接使用

#define NESLog(fmt,level,...) \
do{\
if((level) & (LOG_MODE)){\
NSString *logLevel;\
switch ((level)) {\
case LOG_LEVEL_ASSERT:logLevel = @"<ASSERT>"; break;\
case LOG_LEVEL_ERROR:logLevel = @"<ERROR>"; break;\
case LOG_LEVEL_INFO:logLevel = @"<INFO>"; break;\
case LOG_LEVEL_WARNING:logLevel = @"<WARNING>"; break;\
case LOG_LEVEL_MESSAGE:logLevel = @"<MESSAGE>"; break;\
case LOG_LEVEL_TODO:logLevel = @"<TODO>"; break;\
case LOG_LEVEL_TEST:logLevel = @"<TEST>"; break;\
}\
NSLog((@"\n%@ %-10s: [LINE %d]:\n-\t" fmt),[[NSString stringWithUTF8String:__PRETTY_FUNCTION__]substringFromIndex:1],logLevel.UTF8String, __LINE__, ##__VA_ARGS__);\
printf("\n");\
}\
}while(0)

/** 按照error级别输出 */
#define NESError(fmt,...) NESLog(fmt,LOG_LEVEL_ERROR, ##__VA_ARGS__)
/** 按照warning级别输出 */
#define NESWarning(fmt,...) NESLog(fmt,LOG_LEVEL_WARNING, ##__VA_ARGS__)
/** 按照info级别输出 */
#define NESInfo(fmt,...) NESLog(fmt,LOG_LEVEL_INFO, ##__VA_ARGS__)
/** 按照message级别输出 */
#define NESMessage(fmt,...) NESLog(fmt,LOG_LEVEL_MESSAGE, ##__VA_ARGS__)
/** 按照todo级别输出 */
#define NESTodo(fmt,...) NESLog(fmt,LOG_LEVEL_TODO, ##__VA_ARGS__)
/** 按照test级别输出 */
#define NESTest(fmt,...) NESLog(fmt,LOG_LEVEL_TEST, ##__VA_ARGS__)


/** 按照assert级别输出
 伪断言,仅作输出之用,如果条件不成立则输出内容,但是不会造成程序中断,
 在模拟器环境下会自动输出condition对应的文本,但在真机测试时仅输出描述文字
 如果希望达到系统断言的效果,同时遵从输出级别限制需要使用NESRealAssert
 可以直接用作表达式判断,并根据结果输出,
 如果在代码中使用伪断言而非BOOL类型的标记那么总是可以在输出内容中看到具体出错的代码内容
 例如:
 NSString *str1 = @"1";
 NSString *str2 = @"2";
 BOOL succ = [str1 isEqual:str2];
 if (!succ) {
 NSLog(@"未成功,str1:%@,str2:%@",str1,str2);
 }
 
 NESAssert([str1 isEqual:str2],@"未成功,str1:%@,str2:%@",str1,str2);
 
 完整输出结果为:
 [CLASS FUNCTION:] <ASSERT>  : [LINE num]:
 -	CONDITION:"[str1 isEqual:str2]" IS FAILED!
 -	REASON: 未成功,str1:1,str2:2
 
 @warning 因为考虑到伪断言不应该影响程序的执行,所以在没有DEBUG定义时所有的NESAssert都会直接呗替换成表达式本身,所以直接套用比较表达式并在失败时执行输出可以减少代码量,但切记当表达式的结果为假程序便应当停止执行时这会是一个糟糕的选择.
 */
#define NESAssert(condition,fmt,...) \
do{\
if(!(condition)){\
NSString *code = @"";\
FILE *fp = fopen(__FILE__,"r");\
if(fp){\
char str[1024] = {0};\
for(int i=0;i<__LINE__;i++){\
fgets(str,1000,fp);\
};\
code = [NSString stringWithUTF8String:str];\
code = [[code componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"(,"]] objectAtIndex:1];\
code = [NSString stringWithFormat:@"CONDITION:\"%@\" IS FAILED!\n-\t",code];\
fclose(fp);\
}\
NESLog(@"%@REASON: " fmt,LOG_LEVEL_ASSERT, code, ##__VA_ARGS__);\
}\
} while(0)

/** 与NESAssert功能相同,仅仅将表达式的值保存至flag中 
 适用于需要在条件失败时执行输出,同时根据判断结果继续执行的代码
 例:
 
 BOOL succ = [[NSFileManager defaultManager] createFileAtPath:path contents:data attributes:nil];
 if(succ)
 //do something;
 else
 //do other things;
 
 可以写成:
 BOOL succ;
 NESAssertFlag([[NSFileManager defaultManager] createFileAtPath:path contents:data attributes:nil], @"于%@位置创建文件失败", succ,path);
 if(succ)
 //do something;
 else
 //do other things;
 
 条件失败时的输出为:
 -	CONDITION:"[[NSFileManager defaultManager] createFileAtPath:path contents:data attributes:nil]" IS FAILED!
 -	REASON: 于 `some path` 位置创建文件失败
 
 */
#define NESAssertFlag(condition,fmt,flag,...)\
do{\
flag = condition;\
if(!(flag)){\
NSString *code = @"";\
FILE *fp = fopen(__FILE__,"r");\
if(fp){\
char str[1024] = {0};\
for(int i=0;i<__LINE__;i++){\
fgets(str,1000,fp);\
};\
code = [NSString stringWithUTF8String:str];\
code = [[code componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"(,"]] objectAtIndex:1];\
code = [NSString stringWithFormat:@"CONDITION:\"%@\" IS FAILED!\n-\t",code];\
fclose(fp);\
}\
NESLog(@"%@REASON: " fmt,LOG_LEVEL_ASSERT, code, ##__VA_ARGS__);\
}\
} while(0)

/** 与NESAssert(condition,fmt,...)类似,
 区别在于如果条件不成立则输出错误描述,并调用return语句,返回值为value对应的值
 例:
 BOOL succ = [str1 isEqual:str2];
 if (!succ) {
 NSLog(@"未成功,str1:%@,str2:%@",str1,str2);
 return NO;
 }
 可改写成
 NESAssertReturn([str1 isEqual:str2], @"未成功,str1:%@,str2:%@",NO,str1,str2);
 @warning 返回值须在参数列表之前!
 */
#define NESAssertReturn(condition,fmt,value,...)\
do{\
if(!(condition)){\
NSString *code = @"";\
FILE *fp = fopen(__FILE__,"r");\
if(fp){\
char str[1024] = {0};\
for(int i=0;i<__LINE__;i++){\
fgets(str,1000,fp);\
};\
code = [NSString stringWithUTF8String:str];\
code = [[code componentsSeparatedByCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"(,"]] objectAtIndex:1];\
code = [NSString stringWithFormat:@"CONDITION:\"%@\" IS FAILED!\n-\t",code];\
fclose(fp);\
}\
NESLog(@"%@REASON: " fmt,LOG_LEVEL_ASSERT, code, ##__VA_ARGS__);\
return value;\
}\
} while(0)

/** 调用NESAssertReturn,仅仅调用return;语句,但是没有任何返回值 */
#define NESAssertReturnVoid(condition,fmt,...) NESAssertReturn(condition,fmt,, ##__VA_ARGS__)

/** 如果输出模式包含断言,则转为NSAssert */
#define NESRealAssert(condition,fmt,...) {\
if(LOG_MODE & LOG_LEVEL_ASSERT){\
NSAssert(condition,fmt,##__VA_ARGS__);\
}\
}

#else
#define NESLog(fmt,level,...)
#define NESError(fmt,...)
#define NESWarning(fmt,...)
#define NESInfo(fmt,...)
#define NESMessage(fmt,...)
#define NESTodo(fmt,...)
#define NESTest(fmt,...)
#define NESAssert(condition,fmt,...) do{condition;}while(0)
#define NESAssertFlag(condition,fmt,flag,...) do{flag = condition;}while(0)
#define NESAssertReturn(condition,fmt,value,...) do{if(!(condition)) return value;}while(0)
#define NESAssertReturnVoid(condition,fmt,...) do{if(!(condition)) return;}while(0)
#define NESRealAssert(condition,fmt,...) do{condition;}while(0)
#endif
#endif