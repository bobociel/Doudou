
#import sys  reload(sys) sys.setdefaultencode('utf-8')

print('hello')
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
########## 返回函数 ##########


########## 匿名函数 ##########
def addABS(x, y, f): return f(x) + f(y)

(lambda x,y,f : f(x) + f(y))

##########装饰器##########




##########偏函数##########



#*************************************面向对象编程***************************************

########## 类和实例 ##########    ########## 访问和限制 ##########
class StudentObject(object):
    def __init__(self, name, age):
        self._name = name
        self._age = age

    def setName(self,name):
        self._name = name

    def getName(self):
        return self._name

    def setAge(self, age):
        self._age = age;

    def getAge(self):
        return self._age;

    def printStudent(self):
        print('name:%s age:%s' %(self._name, self._age))

s = StudentObject('sansan',20)
s.setAge(12)
s.printStudent()

########## 继承和多态 ##########

class Animal(object):
    _slots_ = ('name', 'sex')
    def run(self):
        print('Animal run......')

class Dog(Animal):
    def run(self):
        print('Dog run......');

class Cat(Animal):
    def run(self):
        print('Cat run......')

def run(animal): animal.run();

run(Animal())
run(Dog())
run(Cat())

########## 获得对象信息 ##########
#-type()           获得对象类型
#-isinstance()     判断对象类型
#-dir()            获得对象的方法和属性 以及 getattr()、setattr()以及hasattr()

#----print(dir(Animal))

#-通过内置的一系列函数，我们可以对任意一个Python对象进行剖析，拿到其内部的数据。要注意的是，只有在不知道对象信息的时候，我们才会去获取对象信息

########## 实例属性和类属性 ##########
class StudentObject(object):
    name = 'Student'

#-在编写程序的时候，千万不要把实例属性和类属性使用相同的名字，因为相同名称的实例属性将屏蔽掉类属性，但是当你删除实例属性后，再使用相同的名称，访问到的将是类属性。

#*************************************面向对象高级编程***************************************
########## slots ##########
from types import MethodType

class SlotsDemo(object):
    pass
#    __slots__ = ('name', 'score')

def setAge(self, age):
    self.age = age;

a = SlotsDemo()
a.name = 'animal'
a.setAge = MethodType(setAge, a)
a.setAge(20)

b = SlotsDemo()
b.setAge = MethodType(setAge,b)
b.setAge(21)

print(a.name, a.age, b.age)

########## @property ##########
class PropertyDemo(object):
    @property
    def score(self):
        return self._score;
    @score.setter
    def score(self, score):
        if not isinstance(score,float) and not isinstance(score,int):
            raise ValueError('score should be float');
        if score < 0 or score > 100 :
            raise ValueError('score should be 0-100');
        self._score = score;

p = PropertyDemo()
p.score = 99
print('p.score',p.score);

########## 多重继承 ##########
#-由于Python允许使用多重继承，因此，MixIn就是一种常见的设计。
#-只允许单一继承的语言（如Java）不能使用MixIn的设计。

#*************************************错误、调试、测试***************************************
########## 错误 ##########

########## 调试 ##########

########## 测试 ##########

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



#************************************* 进程和线程 ***************************************
#-多进程模式；
#-多线程模式；
#-多进程+多线程模式。
########## 多进程 ##########



########## 多线程 ##########


########## 多线程 ##########

#************************************* 常见内建模块 ***************************************
########## datetime ##########
from datetime import datetime
from datetime import timedelta
print( datetime.now() )
print( datetime(2016,7,2,1,53,30) )
print( datetime(2016,7,2,1).timestamp() )
print( datetime.fromtimestamp(1429417200.0) )
print( datetime.strptime('2016-7-2 10:20:30','%Y-%m-%d %H:%M:%S') )
print( datetime.now().strftime('%a %b %d %H:%M') )
print( datetime.now() + timedelta(days=1, hours=2) )

########## collections ##########
from collections import namedtuple
Point = namedtuple('Point', ['x','y'])
p = Point(1,2)
print( p, p.x, p.y )

from collections import deque
q = deque(['1','2','3'])
q.appendleft('0')
q.append('4')
q.pop()
q.popleft()
print(q)

from collections import defaultdict
dd = defaultdict(lambda: 'null')
dd['1'] = 1
print(dd['2'])

from collections import OrderedDict
od = OrderedDict( [('1',1),('2',2),('3',3),('4',4)] )
print(od, od['1'])

from collections import Counter

########## base64 ##########
import base64
print( base64.b64encode(b'abcd') )
print( base64.b64decode('YWJjZA==') )
print( base64.urlsafe_b64encode(b'www.baidu.com/name+age') )
print( base64.urlsafe_b64decode('d3d3LmJhaWR1LmNvbS9uYW1lK2FnZQ==') )
########## struct ##########
import struct

########## hashlib ##########


########## itertools ##########

########## XML ##########

########## HTMLParser ##########

########## urllib ##########

########## PIL ##########

#************************************* 正则表达式 ***************************************

#************************************* 图形界面 ***************************************
from tkinter import *
import tkinter.messagebox as messagebox
class Application(Frame):
    def __init__(self, master=None):
        Frame.__init__(self, master)
        self.pack()
        self.createWidgets()
    def createWidgets(self):
        self.helloLabel = Label(self, text = '你好')
        self.helloLabel.pack()
        self.quiteButton = Button(self, text='退出', command = self.quit)
        self.quiteButton.pack()
        self.nameInput = Entry(self)
        self.nameInput.pack()
        self.alertButton = Button(self, text='Hello', command = self.hello)
        self.alertButton.pack()
    def hello(self):
        messagebox.showinfo('Message', 'Hello %s' % (self.nameInput.get() or 'world') )

#app = Application()
#app.master.title('Hello')
#app.mainloop()

#************************************* 网络编程 ***************************************
########## TCP,UDP简介 ##########

########## TCP ##########

########## UDP ##########

#************************************* 电子邮件 ***************************************



#************************************* 访问数据库 ***************************************
########## SQLITE ##########
import sqlite3

conn = sqlite3.connect('./python.db')
cursor = conn.cursor()

cursor.execute('CREATE TABLE IF NOT EXISTS "student" ("studentID" INTEGER PRIMARY KEY AUTOINCREMENT, "name" TEXT, "age" INTEGER, "sex" INTEGER ) ')

cursor.execute('INSERT INTO "student" ("name", "age", "sex" ) values ("bobo", 25, 2 ) ')
print(cursor.rowcount)

cursor.execute('SELECT * FROM student')
print(cursor.fetchall())

cursor.close()

conn.commit()
conn.close()
########## SQLAlchemy ##########
#-这就是传说中的ORM技术：Object-Relational Mapping，把关系数据库的表结构映射到对象上。是不是很简单？
#-但是由谁来做这个转换呢？所以ORM框架应运而生。
#-在Python中，最有名的ORM框架是SQLAlchemy。我们来看看SQLAlchemy的用法。

from sqlalchemy import Column, BOOLEAN, Integer, String, create_engine
from sqlalchemy.orm import sessionmaker
from sqlalchemy.ext.declarative import declarative_base

Base = declarative_base()
class Student(Base):
    __tablename__ = 'student'

    studentID = Column(Integer, primary_key=True)
    name = Column(String())
    age = Column(Integer)
    sex = Column(Integer)

engine = create_engine('sqlite:///python.db',echo=True)
DBSession = sessionmaker(bind=engine)
session = DBSession()

#session.add( Student(studentID=999,name='sansan', age=28, sex=2) )
session.commit()
stuList = session.query(Student).all()
stuA = session.query(Student).filter(Student.name=='sansan').one()
session.close()
print( stuList[0].name )
print( stuA.name )

#************************************* Web开发 ***************************************
########## WSGI接口 ##########
def application(environ, start_response):
    start_response('200 OK', [('Content-Type', 'text/html')])
    body = '<h1>Hello Python! %s</h1>' % (environ['PATH_INFO'][1:] or 'web')
    return [body.encode('utf-8')]

########## Web框架 ##########
#-由于用Python开发一个Web框架十分容易，所以Python有上百个开源的Web框架。这里我们先不讨论各种Web框架的优缺点，直接选择一个比较流行的Web框架——Flask来使用。
#-用Flask编写Web App比WSGI接口简单（这不是废话么，要是比WSGI还复杂，用框架干嘛？

########## 使用模板 ##########
#_Flask通过render_template()函数来实现模板的渲染。和Web框架类似，Python的模板也有很多种。Flask默认支持的模板是jinja2

#************************************* 异步IO ***************************************
########## 协程 ##########
#-协程看上去也是子程序，但执行过程中，在子程序内部可中断，然后转而执行别的子程序，在适当的时候再返回来接着执行。
#_注意，在一个子程序中中断，去执行其他子程序，不是函数调用，有点类似CPU的中断。

########## asyncio ##########


########## asyncio/waite ##########


########## aiohttp ##########


