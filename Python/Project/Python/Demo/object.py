
# -*- coding:utf-8 -*-

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

########## 定制类 ##########
#-看到类似__slots__这种形如__xxx__的变量或者函数名就要注意，这些在Python中是有特殊用途的。
#-__slots__我们已经知道怎么用了，__len__()方法我们也知道是为了能让class作用于len()函数。
#-除此之外，Python的class中还有许多这样有特殊用途的函数，可以帮助我们定制类。

#-①：__str__；②：__repr__；__getattr__；__call__
#-__getitem__；__delitem__
class StudentObject(object):
    def  __init__(self,name):
        self.name = name
    def  __str__(self):
        return  'Student name is %s' % self.name
    __repr__ = __str__
    def __getattr__(self, attr):
        if attr == 'gender':
            return 12
        raise AttributeError('StudentObject has no attribute %s' % attr)

s = StudentObject('sansan')
#print(s,s.hello)

########## 枚举类 ##########
#-Enum可以把一组相关常量定义在一个class中，且class不可变，而且成员可以直接比较。
from enum import Enum,unique

Month = ( 'Month',('Jan', 'Feb', 'Mar', 'Apr', 'May', 'June', 'July', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec') )

print(dir(Month))

for member in Month:
    print('name: , member: %s', member)

@unique
class Weekday(Enum):
    Mon = 1
    Tue = 2
    Wen = 3
    Thu = 4
    Fri = 5
    Sun = 6
    Sat = 7

for name,member in Weekday.__members__.items():
    print('name:', name, ',mamber:', member, 'value: ', member.value)

########## 使用元类 ##########

