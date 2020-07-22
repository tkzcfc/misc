#coding=utf-8 
import struct  
import os

_DELTA = 0x9E3779B9  
  
def _long2str(v, w):  
    n = (len(v) - 1) << 2  
    if w:  
        m = v[-1]  
        if (m < n - 3) or (m > n): return ''  
        n = m  
    s = struct.pack('<%iL' % len(v), *v)  
    return s[0:n] if w else s  
  
def _str2long(s, w):  
    n = len(s)  
    m = (4 - (n & 3) & 3) + n  
    s = s.ljust(m, "\0")  
    v = list(struct.unpack('<%iL' % (m >> 2), s))  
    if w: v.append(n)  
    return v  
  
def encrypt(str, key):  
    if str == '': return str  
    v = _str2long(str, True)  
    k = _str2long(key.ljust(16, "\0"), False)  
    n = len(v) - 1  
    z = v[n]  
    y = v[0]  
    sum = 0  
    q = 6 + 52 // (n + 1)  
    while q > 0:  
        sum = (sum + _DELTA) & 0xffffffff  
        e = sum >> 2 & 3  
        for p in xrange(n):  
            y = v[p + 1]  
            v[p] = (v[p] + ((z >> 5 ^ y << 2) + (y >> 3 ^ z << 4) ^ (sum ^ y) + (k[p & 3 ^ e] ^ z))) & 0xffffffff  
            z = v[p]  
        y = v[0]  
        v[n] = (v[n] + ((z >> 5 ^ y << 2) + (y >> 3 ^ z << 4) ^ (sum ^ y) + (k[n & 3 ^ e] ^ z))) & 0xffffffff  
        z = v[n]  
        q -= 1  
    return _long2str(v, False)  
  
def decrypt(str, key):  
    if str == '': return str  
    v = _str2long(str, False)  
    k = _str2long(key.ljust(16, "\0"), False)  
    n = len(v) - 1  
    z = v[n]  
    y = v[0]  
    q = 6 + 52 // (n + 1)  
    sum = (q * _DELTA) & 0xffffffff  
    while (sum != 0):  
        e = sum >> 2 & 3  
        for p in xrange(n, 0, -1):  
            z = v[p - 1]  
            v[p] = (v[p] - ((z >> 5 ^ y << 2) + (y >> 3 ^ z << 4) ^ (sum ^ y) + (k[p & 3 ^ e] ^ z))) & 0xffffffff  
            y = v[p]  
        z = v[n]  
        v[0] = (v[0] - ((z >> 5 ^ y << 2) + (y >> 3 ^ z << 4) ^ (sum ^ y) + (k[0 & 3 ^ e] ^ z))) & 0xffffffff  
        y = v[0]  
        sum = (sum - _DELTA) & 0xffffffff  
    return _long2str(v, True)

# with open('main.lua') as file_obj:
    # content = file_obj.read()


encryptsign = "c6lokjc7wb1b"
encryptkey = "lfkikv9m1wqe"

# 加密
def encryptFile(inFile, outFile):
    bytesFile = open(inFile, "rb+")
    content = bytesFile.read()
    bytesFile.close()

    dec_content = encrypt(content, encryptkey)
    dec_content = encryptsign + dec_content

    print(len(dec_content))
    if len(dec_content) > 0:
        bytesFile = open(outFile, "wb")
        bytesFile.seek(0)
        bytesFile.write(dec_content)
        bytesFile.close()

# 解密
def decryptFile(inFile, outFile):
	bytesFile = open(inFile, "rb+")
	content = bytesFile.read()
	bytesFile.close()

	content = content[len(encryptsign):]
	dec_content = decrypt(content, encryptkey)

	if len(dec_content) > 0:
		bytesFile = open(outFile, "wb")
		bytesFile.seek(0)
		bytesFile.write(dec_content)
		bytesFile.close()

# 遍历文件夹
def walkFile(file):
    for root, dirs, files in os.walk(file):
        # 遍历文件
        for f in files:
        	fullpath = os.path.join(root, f)
        	if fullpath[-3:] == "lua":
        		decryptFile(fullpath, fullpath)

        # 遍历所有的文件夹
        for d in dirs:
        	walkFile(os.path.join(root, d))

# walkFile("./")

# encryptFile("./src/main.lua", "./src/main.luac")
