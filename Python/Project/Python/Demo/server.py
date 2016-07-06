from wsgiref.simple_server import make_server
from main import application

httpd = make_server('', 8080, application)
print('Hello Start 8080......')

httpd.serve_forever()