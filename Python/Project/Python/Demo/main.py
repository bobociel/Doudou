
#************************************* 进程和线程 ***************************************
#-线程是最小的执行单元，而进程由至少一个线程组成。如何调度进程和线程，完全由操作系统决定，程序自己不能决定什么时候执行，执行多长时间。
#-多线程模式；
#-多进程+多线程模式。
########## 多进程 ##########
#-在Unix/Linux下，可以使用fork()调用实现多进程。
#-要实现跨平台的多进程，可以使用multiprocessing模块。
#-进程间通信是通过Queue、Pipes等实现的。

#import os
#print('Progress %s start...' % os.getpid() )
#pid = os.fork()
#if pid == 0:
#    print('Child:%s Parent:%s' % (os.getpid(), os.getppid()) )
#else:
#    print('Parent:%s Child:%s' % (os.getpid(), pid) )

from multiprocessing import Process
import os

def run_proc(name):
    print('Run Child process %s: %s ' % (name, os.getpid() ) )

if __name__ == '__main__':
    print('Parent process %s', os.getpid() )
    p = Process(target=run_proc, args=('test',))
    print('Child process start')
    p.start()
    p.join()
    print('Child process end')


from multiprocessing import Pool
import subprocess
import os,time,random

def long_time_task(name):
    print('Run Process %s: %s' % (name,os.getpid() ))
    start = time.time()
    time.sleep( random.random() * 3 )
    end = time.time()
    print('Run Process %s: %s, Time:%s' % (name, os.getpid(), (end-start)) )

    r = subprocess.call(['nslookup', 'www.baidu.com'])
    print('execute end:', r)

if __name__ == '__main__':
    print('Processes start in ', os.getpid() )
    p = Pool(4)
    for t in range(5):
        p.apply_async(long_time_task,args=(t,) )
    print('waiting all process...')
    p.close()
    p.join()
    print('Processes All End')

########## 多线程 ##########


########## 多线程 ##########

#************************************* 网络编程 ***************************************
########## TCP,UDP简介 ##########

########## TCP ##########

########## UDP ##########

#************************************* 访问数据库 ***************************************
########## SQLITE ##########

#import sqlite3
#
#conn = sqlite3.connect('./python.db')
#cursor = conn.cursor()
#
#cursor.execute('CREATE TABLE IF NOT EXISTS "student" ("studentID" INTEGER PRIMARY KEY AUTOINCREMENT, "name" TEXT, "age" INTEGER, "sex" INTEGER ) ')
#
#cursor.execute('INSERT INTO "student" ("name", "age", "sex" ) values ("bobo", 25, 2 ) ')
#print(cursor.rowcount)
#
#cursor.execute('SELECT * FROM student')
#print(cursor.fetchall())
#
#cursor.close()
#
#conn.commit()
#conn.close()

########## SQLAlchemy ##########
#-这就是传说中的ORM技术：Object-Relational Mapping，把关系数据库的表结构映射到对象上。是不是很简单？
#-但是由谁来做这个转换呢？所以ORM框架应运而生。
#-在Python中，最有名的ORM框架是SQLAlchemy。我们来看看SQLAlchemy的用法。

#from sqlalchemy import Column, BOOLEAN, Integer, String, create_engine
#from sqlalchemy.orm import sessionmaker
#from sqlalchemy.ext.declarative import declarative_base
#
#Base = declarative_base()
#class Student(Base):
#    __tablename__ = 'student'
#
#    studentID = Column(Integer, primary_key=True)
#    name = Column(String())
#    age = Column(Integer)
#    sex = Column(Integer)
#
#engine = create_engine('sqlite:///python.db',echo=True)
#DBSession = sessionmaker(bind=engine)
#session = DBSession()
#
##session.add( Student(studentID=999,name='sansan', age=28, sex=2) )
#session.commit()
#stuList = session.query(Student).all()
#stuA = session.query(Student).filter(Student.name=='sansan').one()
#session.close()
#print( stuList[0].name )
#print( stuA.name )

#************************************* Web开发 ***************************************
########## WSGI接口 ##########
#def application(environ, start_response):
#    start_response('200 OK', [('Content-Type', 'text/html')])
#    body = '<h1>Hello Python! %s</h1>' % (environ['PATH_INFO'][1:] or 'web')
#    return [body.encode('utf-8')]

########## Web框架 ##########
#-由于用Python开发一个Web框架十分容易，所以Python有上百个开源的Web框架。这里我们先不讨论各种Web框架的优缺点，直接选择一个比较流行的Web框架——Flask来使用。
#-用Flask编写Web App比WSGI接口简单（这不是废话么，要是比WSGI还复杂，用框架干嘛？
from flask import Flask
from flask import request
from flask import render_template

#app = Flask(__name__)
#@app.route('/', methods = ['GET','POST'] )
#def home():
#    return '<h1>Home Main</h1>'
#
#@app.route('/signin', methods = ['GET'])
#def signin_form():
#    return '''<form action="/signin" method="post">
#              <p><input name="username"></p>
#              <p><input name="password" type="password"></p>
#              <p><button type="submit">Sign In</button></p>
#              </form>'''
#
#@app.route('/signin', methods = ['POST'])
#def signin():
#    if request.form['username'] == 'admin' and request.form['password'] == '123' :
#        return '<h1>Login Success</h1>'
#    return '<h1>Login failure</h1>'
#
#if __name__ == '__main__':
#    app.run()

########## 使用模板 ##########
#_Flask通过render_template()函数来实现模板的渲染。和Web框架类似，Python的模板也有很多种。Flask默认支持的模板是jinja2
#-通过MVC，我们在Python代码中处理M：Model和C：Controller，而V：View是通过模板处理的，这样，我们就成功地把Python代码和HTML代码最大限度地分离了。
#-使用模板的另一大好处是，模板改起来很方便，而且，改完保存后，刷新浏览器就能看到最新的效果，这对于调试HTML、CSS和JavaScript的前端工程师来说实在是太重要了。

#app = Flask(__name__)
#
#@app.route('/', methods = ['GET', 'POST'])
#def home():
#    return render_template('home.html')
#
#@app.route('/signin', methods = ['GET'])
#def signin_form():
#    return render_template('form.html')
#
#@app.route('/signin', methods = ['POST'])
#def signin():
#    username = request.form['username']
#    password = request.form['password']
#    if username == 'admin' and password == '123':
#        return render_template('sign_ok.html', username=username)
#    return render_template('form.html',message='username or password error', username=username)
#
#if __name__ == '__main__':
#    app.run()



#************************************* 异步IO ***************************************
########## 协程 ##########
#-协程看上去也是子程序，但执行过程中，在子程序内部可中断，然后转而执行别的子程序，在适当的时候再返回来接着执行。
#_注意，在一个子程序中中断，去执行其他子程序，不是函数调用，有点类似CPU的中断。

########## asyncio ##########


########## asyncio/waite ##########


########## aiohttp ##########


#************************************* 正则表达式 ***************************************

#************************************* 电子邮件 ***************************************

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

