# -*- coding: utf-8 -*-

Num = 123456
Str = '123456AbCd'
List = [1,2,3,4,5,6,-1,-2,-3,-4,'A','b','C','d']
Tuple = (1,2,3,4,5,6)
Dict = {'1':1, '2':2, '3':3, '4':4, '5':5, '6':6}
Set = set([1,2,3,4,5,6])
Gen = ( x for x in '123456' )
#*************************************函数***************************************
########## 函数参数，位置参数 ##########
def power1(x):
    return x * x

########## 函数参数，默认参数 ##########
def power2(x, n = 2):
	s = 1
	while n > 0:
		n = n - 1
		s = s * x
	return s
print(power2(5,2))

def student(name , age, className = 'One grade'):
    print('name:', name, 'age:', age, 'class:', className)
student('sansan', 20, 'Two grade')
student('sansan2', 10, 'three grade')

def add_end(L=[]):
    L.append('END')
    return L
print( add_end() )
print( add_end() )


def add_end2(L=None):
    if L == None:
        L = []
    L.append('END')
    return L
print( add_end2() )
print( add_end2() )

########## 函数参数，可变参数 ##########
def sum(*n):
    s = 0
    for x in n:
        s = s + x
    return s
print( sum(*Tuple) )

########## 函数,递归函数 ##########
def fact(n):
	return fact_inter(n, 1)

def fact_inter(num, product):
	if num == 1:
		return product;
	return fact_inter(num - 1, num * product)

# print fact_inter(120, 1)

#*************************************高级特性***************************************

########## 高级特性,切片 ##########
print(List[1:10:2])
print(List[-6:])
print(Tuple[1:10])
print(Str[1:4])

########## 高级特性,迭代 ##########
#--任何可迭代对象都可以作用于for循环，包括我们自定义的数据类型，只要符合迭代条件，就可以使用for循环。
from collections import Iterable
print('isinstance(Num, Iterable):', isinstance(Num, Iterable) )
print('isinstance(Str, Iterable):', isinstance(Str, Iterable) )
print('isinstance(List, Iterable):', isinstance(List, Iterable) )
print('isinstance(Tuple, Iterable):', isinstance(Tuple, Iterable) )
print('isinstance(Dict, Iterable):', isinstance(Dict, Iterable) )
print('isinstance(Set, Iterable):', isinstance(Set, Iterable) )
for s in Str: print('s',s)
for l in List: print('l',l)
for t in Tuple: print('t',t)
for s in Set: print('s',s)
for key in Dict.keys(): print('key',key)
for value in Dict.values(): print('value',value)
for key, value in Dict.items(): print('key',key,'value',value)

for i,value in enumerate(Str):          print('str-i',i,'value',value)
for i,value in enumerate(List):         print('list-i',i,'value',value)
for i,value in enumerate(Tuple):        print('tuple-i',i,'value',value)
for i,value in enumerate(Set):          print('set-i',i,'value',value)
for i,key   in enumerate(Dict.keys()):   print('Dict-i',i,'key',key)
for i,value in enumerate(Dict.values()): print('Dict-i',i,'value',key)
for i,item in enumerate(Dict.items()):  print('Dict-i',i,'item',item)

########## 高级特性,列表生成式 ##########
print( list(range(10))[2:8:2] )
print( [x * x for x in range(10) if x%2 == 0] )
print( [x * y for x in range(10) for y in range(5) ] )
print( [key + '==' + str(value) for key,value in Dict.items()])
print( [s.lower() for s in List if isinstance(s,str)] )

import os
print( [d for d in os.listdir('.')] )
########## 高级特性,生成器 ##########
#--通过列表生成式，我们可以直接创建一个列表。但是，受到内存限制，列表容量肯定是有限的。
#-而且，创建一个包含100万个元素的列表，不仅占用很大的存储空间，如果我们仅仅需要访问前面几个元素，
#-那后面绝大多数元素占用的空间都白白浪费了。

#--所以，如果列表元素可以按照某种算法推算出来，那我们是否可以在循环的过程中不断推算出后续的元素呢？这样就不必创建完整的list，从而节省大量的空间。在Python中，这种一边循环一边计算的机制，称为生成器：generator。

#--要创建一个generator，有很多种方法。第一种方法很简单，只要把一个列表生成式的[]改成()，就创建了一个generator：
print('Gen:', Gen)
for x in Gen: print( x )
#-这就是定义generator的另一种方法。如果一个函数定义中包含yield关键字，那么这个函数就不再是一个普通函数，而是一个generator
def fib(max):
    n,a,b = 0,0,1
    while n < max:
        yield b
        a,b = b,a + b
        n = n + 1
    return 'done'

generator2 = fib(6)
while True:
    try:
        print( next(generator2) )
    except StopIteration as e:
        print(e.value)
        break

########## 高级特性,迭代器 ##########
#-凡是可作用于for循环的对象都是Iterable类型；

#-凡是可作用于next()函数的对象都是Iterator类型，它们表示一个惰性计算的序列；

#-集合数据类型如list、Dictt、str等是Iterable但不是Iterator，不过可以通过iter()函数获得一个Iterator对象。

#-Python的for循环本质上就是通过不断调用next()函数实现的
from collections import Iterator
print('isinstance(Num, Iterator):', isinstance(Num, Iterator) )
print('isinstance(Str, Iterator):', isinstance(Str, Iterator) )
print('isinstance(List, Iterator):', isinstance(List, Iterator) )
print('isinstance(Tuple, Iterator):', isinstance(Tuple, Iterator) )
print('isinstance(Dict, Iterator):', isinstance(Dict, Iterator) )
print('isinstance(Set, Iterator):', isinstance(Set, Iterator) )
print('isinstance(Gen, Iterator):', isinstance(Gen, Iterator) )

print ( iter(Str) )
print ( iter(List) )
print ( iter(Tuple) )
print ( iter(Dict) )
print ( iter(Set) )

#*************************************函数式编程***************************************

ABS = abs
########## 高阶函数 ##########
#-变量可以指向函数
#-函数名也是变量   // abs = 10
#-把函数作为参数传入，这样的函数称为高阶函数，函数式编程就是指这种高度抽象的编程范式。
print(ABS(-10))
#def addABS(x, y, f): return f(x) + f(y)
print((lambda x,y,f : f(x) + f(y))(-10, 10, ABS))

#-map()函数接收两个参数，一个是函数，一个是Iterable，map将传入的函数依次作用到序列的每个元素，并把结果作为新的Iterator返回。
#-reduce把一个函数作用在一个序列[x1, x2, x3, ...]上，这个函数必须接收两个参数，reduce把结果继续和序列的下一个元素做累积计算
#-filter()把传入的函数依次作用于每个元素，然后根据返回值是True还是False决定保留还是丢弃该元素。
#-sorted()也是一个高阶函数。用sorted()排序的关键在于实现一个映射函数。
print( list( map(ABS,[-9,-8,-7]) ) )

def toName(name): return name.capitalize()
print( list(map(toName,['adam', 'LISA', 'barT'])) )

from functools import reduce
def cheng(x, y): return 10*x + y
def prod(L): return reduce(cheng,L)
print(prod([1,2,3]))

def not_empty(s): return s.strip();
print( list( filter(not_empty,['A','  ','C','D',''])) )

student = [('Bob', 75), ('Adam', 92), ('Bart', 66), ('Lisa', 88)]
print( sorted(student, key = lambda tuple:tuple[0]) )
#print( sorted(student, cmp = lambda x,y:cmp(x[1],y[1])) )

########## 返回函数、闭包 ##########
#-一个函数可以返回一个计算结果，也可以返回一个函数。
#-返回一个函数时，牢记该函数并未执行，返回函数中不要引用任何可能会变化的变量。
def lazy_sum(*args):
    def sum():
        ax = 0
        for n in args:
            ax = ax + n
        return ax
    return sum

print('sum = %s' % lazy_sum(1,2,3)() )

def addX(x):
    def addXY(y):
        print('x =', x, 'y = ', y)
        return x + y;
    print('x =', x)
    addXY(8)
    return addXY;

def count():
    fs = []
    for b in range(1,5):
        print('b = ', b)
        def double():
            return b * b
        fs.append(double)
        print('fs = ', fs)
    return fs

f1 = count()
print( f1[0]() )

########## 匿名函数 ##########
def addABS(x, y, f): return f(x) + f(y)

(lambda x,y,f : f(x) + f(y))

##########装饰器##########
import functools
def log(text=None):
    def decorator(func):
        @functools.wraps(func)
        def wrapper(*args, **kw):
            print('%s LOG INFO: %s'% (text or '' ,func.__name__) )
            return  func(*args, **kw)
        return wrapper
    return decorator

@log()
def doubleABS(x): return ABS(x * x) ;

print(doubleABS(-2))

##########偏函数##########
#-当函数的参数个数太多，需要简化时，使用functools.partial可以创建一个新的函数，这个新函数可以固定住原函数的部分参数，从而在调用时更简单。
import functools
int2 = functools.partial(int, base=2)
int2('1000000')

#*************************************IO编程***************************************
########## 文件读写 ##########
#-在Python中，文件读写是通过open()函数打开的文件对象完成的。使用with语句操作文件IO是个好习惯。
with open('./text.text', 'w') as f:
    f.write('Lily, Hello World, everyone, write ok');
    f.write('Lily, Hello World, man, write ok');
    f.write('Lily, Hello World, woman, write ok');
    f.write('Lily, Hello World, child, write ok');
    f.write('Lily, Hello World, old, write ok');

with open('./text.text', 'r') as f:
    print( 'read size: ', f.read(8) );
    print( 'read line: ', f.readline() )
    print( 'read lines: ', f.readlines() )

with open('./text.text', 'r') as f:
    for line in f.readlines():
        print( 'line: ',line.strip() );

########## StringIO和BytesIO ##########




########## 操作文件和目录 ##########


########## 序列化 ##########


