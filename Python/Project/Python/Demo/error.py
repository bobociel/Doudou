
#*************************************错误、调试、测试***************************************
########## 错误 ##########
#-try...except...finally
try:
    print(10 / 0)
except ZeroDivisionError as e:
    print('expection:',e)
finally:
    print('finally')

#-调用堆栈
#print(10/0)

#-记录错误
import logging
try:
    print(8 / 0)
except Exception as e:
    logging.exception(e)

#-抛出错误
try:
    print(10 / 0)
except Exception as e:
    raise e;

########## 调试 ##########
#-写程序最痛苦的事情莫过于调试，程序往往会以你意想不到的流程来运行，你期待执行的语句其实根本没有执行，这时候，就需要调试了。
#-虽然用IDE调试起来比较方便，但是最后你会发现，logging才是终极武器。
#-1,print 2,asset 3,logging 4,pdb 5,IDE


########## 单元测试 ##########

########## 文档测试 ##########



