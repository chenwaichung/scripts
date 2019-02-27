# -*- coding: utf-8 -*-

import sys
import urllib
import urllib2

# 返回对象
class respObject:
    def __init__(self, code, content):
        self.statusCode = code
        self.content = content
    statusCode = 0
    content = ''

# http get请求
def get(url):
    respObj = respObject(200, '')
    request = urllib2.Request(url)
    try:
        response = urllib2.urlopen(request)
    except urllib2.HTTPError, e:
        print('HTTPError = ' + str(e.code))
        respObj.statusCode = e.code
    except urllib2.URLError, e:
        print('URLError = ' + str(e.reason))
        respObj.statusCode = 404
    except Exception:
        respObj.statusCode = 500

    if(respObj.statusCode == 200):
        respObj.content = response.read()

    return respObj

# 计算下载进度
def report(blocknr, blocksize, size):
    current = blocknr * blocksize
    sys.stdout.write("\rDownloading [ {0:.0f}% ]".format(
        100.0 * current / size))

# 下载文件
def downloadFile(url, dist):
    fl = urllib.URLopener()
    fl.retrieve(url, dist, report)
    print "\n"
