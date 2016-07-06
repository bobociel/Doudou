
import logging; logging.basicConfig(level=logging.INFO)

import asyncio, os, sjon, time
import datetime from datetime

import web from aiohttp

def index(request):
    return web.Response(body=b'<h1>Hello</h1>')

@asyncio.coroutine
def init(loop):
    app = web.Application(loop=loop)
    app.router.add_route('Get','/',index)
    srv = yield from loop.create_server(app.make_handler(),'127.0.0.1','9000')
    logging.info('server started...')
    return srv

loop = asyncio.get_event_loop()
loop.run_until_complete(init(loop))
loop.run_forever()