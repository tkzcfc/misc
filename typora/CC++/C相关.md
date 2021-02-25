## strcmp和stricmp的区别

```
strcmp比较区分字母大小写 相当是比较的时候纯粹按照ascii码值来比较从头到尾

而stricmp是不区分字母的大小写的。
```



## printf相关

```
%d=int,
%ld=long,
%lld=long long;

在32位编译器上，int=long=32bit；long long=64bit。


```



## ByteToHex  |  HexToByte

```c++
char* ByteToHex(const unsigned char* vByte, const int vLen)
{
    if (!vByte)
    {
        return NULL;
    }

    char* tmp = new char[vLen * 2 + 1]; 

    int tmp2;
    for (int i = 0; i < vLen; i++)
    {
        tmp2 = (int)(vByte[i]) / 16;
        tmp[i * 2] = (char)(tmp2 + ((tmp2 > 9) ? 'A' - 10 : '0'));
        tmp2 = (int)(vByte[i]) % 16;
        tmp[i * 2 + 1] = (char)(tmp2 + ((tmp2 > 9) ? 'A' - 10 : '0'));
    }

    tmp[vLen * 2] = '\0';
    return tmp;
}


unsigned char* HexToByte(const char* szHex)
{
    if (!szHex)
    {
        return NULL;
    }

    int iLen = strlen(szHex);

    if (iLen <= 0 || 0 != iLen % 2)
    {
        return NULL;
    }

    unsigned char* pbBuf = new unsigned char[iLen / 2]; 

    int tmp1, tmp2;
    for (int i = 0; i < iLen / 2; i++)
    {
        tmp1 = (int)szHex[i * 2] - (((int)szHex[i * 2] >= 'A') ? 'A' - 10 : '0');

        if (tmp1 >= 16)
        {
            return NULL;
        }

        tmp2 = (int)szHex[i * 2 + 1] - (((int)szHex[i * 2 + 1] >= 'A') ? 'A' - 10 : '0');

        if (tmp2 >= 16)
        {
            return NULL;
        }

        pbBuf[i] = (tmp1 * 16 + tmp2);
    }

    return pbBuf;
}
```



## C实现buf

```c
// 源地址https://github.com/Genymobile/scrcpy/blob/master/app/src/util/cbuf.h

// generic circular buffer (bounded queue) implementation
#ifndef CBUF_H
#define CBUF_H

#include <stdbool.h>
#include <unistd.h>

#include "config.h"

// To define a circular buffer type of 20 ints:
//     struct cbuf_int CBUF(int, 20);
//
// data has length CAP + 1 to distinguish empty vs full.
#define CBUF(TYPE, CAP) { \
    TYPE data[(CAP) + 1]; \
    size_t head; \
    size_t tail; \
}

#define cbuf_size_(PCBUF) \
    (sizeof((PCBUF)->data) / sizeof(*(PCBUF)->data))

#define cbuf_is_empty(PCBUF) \
    ((PCBUF)->head == (PCBUF)->tail)

#define cbuf_is_full(PCBUF) \
    (((PCBUF)->head + 1) % cbuf_size_(PCBUF) == (PCBUF)->tail)

#define cbuf_init(PCBUF) \
    (void) ((PCBUF)->head = (PCBUF)->tail = 0)

#define cbuf_push(PCBUF, ITEM) \
    ({ \
        bool ok = !cbuf_is_full(PCBUF); \
        if (ok) { \
            (PCBUF)->data[(PCBUF)->head] = (ITEM); \
            (PCBUF)->head = ((PCBUF)->head + 1) % cbuf_size_(PCBUF); \
        } \
        ok; \
    })

#define cbuf_take(PCBUF, PITEM) \
    ({ \
        bool ok = !cbuf_is_empty(PCBUF); \
        if (ok) { \
            *(PITEM) = (PCBUF)->data[(PCBUF)->tail]; \
            (PCBUF)->tail = ((PCBUF)->tail + 1) % cbuf_size_(PCBUF); \
        } \
        ok; \
    })

#endif

```



## C实现队列

```C
//源地址 https://github.com/Genymobile/scrcpy/blob/master/app/src/util/queue.h

// generic intrusive FIFO queue
#ifndef QUEUE_H
#define QUEUE_H

#include <assert.h>
#include <stdbool.h>
#include <stddef.h>

#include "config.h"

// To define a queue type of "struct foo":
//    struct queue_foo QUEUE(struct foo);
#define QUEUE(TYPE) { \
    TYPE *first; \
    TYPE *last; \
}

#define queue_init(PQ) \
    (void) ((PQ)->first = (PQ)->last = NULL)

#define queue_is_empty(PQ) \
    !(PQ)->first

// NEXTFIELD is the field in the ITEM type used for intrusive linked-list
//
// For example:
//    struct foo {
//        int value;
//        struct foo *next;
//    };
//
//    // define the type "struct my_queue"
//    struct my_queue QUEUE(struct foo);
//
//    struct my_queue queue;
//    queue_init(&queue);
//
//    struct foo v1 = { .value = 42 };
//    struct foo v2 = { .value = 27 };
//
//    queue_push(&queue, next, v1);
//    queue_push(&queue, next, v2);
//
//    struct foo *foo;
//    queue_take(&queue, next, &foo);
//    assert(foo->value == 42);
//    queue_take(&queue, next, &foo);
//    assert(foo->value == 27);
//    assert(queue_is_empty(&queue));
//

// push a new item into the queue
#define queue_push(PQ, NEXTFIELD, ITEM) \
    (void) ({ \
        (ITEM)->NEXTFIELD = NULL; \
        if (queue_is_empty(PQ)) { \
            (PQ)->first = (PQ)->last = (ITEM); \
        } else { \
            (PQ)->last->NEXTFIELD = (ITEM); \
            (PQ)->last = (ITEM); \
        } \
    })

// take the next item and remove it from the queue (the queue must not be empty)
// the result is stored in *(PITEM)
// (without typeof(), we could not store a local variable having the correct
// type so that we can "return" it)
#define queue_take(PQ, NEXTFIELD, PITEM) \
    (void) ({ \
        assert(!queue_is_empty(PQ)); \
        *(PITEM) = (PQ)->first; \
        (PQ)->first = (PQ)->first->NEXTFIELD; \
    })
    // no need to update (PQ)->last if the queue is left empty:
    // (PQ)->last is undefined if !(PQ)->first anyway

#endif

```



## 大小端

https://github.com/JacobRBlomquist/Tiny-Endian

https://github.com/ekg/endian

### C++

```c++
// from http://stackoverflow.com/a/8979034/238609
inline int IsBigEndian()
{
    union
    {
        unsigned int i;
        char c[sizeof(unsigned int)];
    } u;
    u.i=1;
    return !u.c[0];
}

/* or (pedantic non-UB version) */
inline int IsBigEndian()
{
    int i=1;
    return ! *((char *)&i);
}

// from http://stackoverflow.com/a/4956493/238609
template <typename T>
T swap_endian(T u)
{
    union
    {
        T u;
        unsigned char u8[sizeof(T)];
    } source, dest;

    source.u = u;

    for (size_t k = 0; k < sizeof(T); k++)
        dest.u8[k] = source.u8[sizeof(T) - k - 1];

    return dest.u;
}

template <typename T>
T to_big_endian(T u)
{
    if (IsBigEndian()) {
        return u;
    } else {
        return swap_endian<T>(u);
    }
}

template <typename T>
T to_little_endian(T u)
{
    if (!IsBigEndian()) {
        return u;
    } else {
        return swap_endian<T>(u);
    }
}
```



### C实现的,非常全

```c
//endian.h

#ifndef ENDIAN_H
#define ENDIAN_H

#include <stdint.h>

#ifdef __cplusplus
	extern "C" {
#endif

/* Big-Endian */
uint16_t readUint16InBigEndian(void* memory);
uint32_t readUint32InBigEndian(void* memory);
uint64_t readUint64InBigEndian(void* memory);

void writeUint16InBigEndian(void* memory, uint16_t value);
void writeUint32InBigEndian(void* memory, uint32_t value);
void writeUint64InBigEndian(void* memory, uint64_t value);

int16_t readInt16InBigEndian(void* memory);
int32_t readInt32InBigEndian(void* memory);
int64_t readInt64InBigEndian(void* memory);

void writeInt16InBigEndian(void* memory, int16_t value);
void writeInt32InBigEndian(void* memory, int32_t value);
void writeInt64InBigEndian(void* memory, int64_t value);


/* Little-Endian */
uint16_t readUint16InLittleEndian(void* memory);
uint32_t readUint32InLittleEndian(void* memory);
uint64_t readUint64InLittleEndian(void* memory);

void writeUint16InLittleEndian(void* memory, uint16_t value);
void writeUint32InLittleEndian(void* memory, uint32_t value);
void writeUint64InLittleEndian(void* memory, uint64_t value);

int16_t readInt16InLittleEndian(void* memory);
int32_t readInt32InLittleEndian(void* memory);
int64_t readInt64InLittleEndian(void* memory);

void writeInt16InLittleEndian(void* memory, int16_t value);
void writeInt32InLittleEndian(void* memory, int32_t value);
void writeInt64InLittleEndian(void* memory, int64_t value);

#ifdef __cplusplus
	}
#endif

#endif

```

```C
//endian.c

#include "endian.h"
#include <stdio.h>

/* Big-Endian */

uint16_t readUint16InBigEndian(void* memory)
{
	uint8_t* p = memory;
	return (((uint16_t)p[0]) << 8) | 
		   (((uint16_t)p[1]));
}

uint32_t readUint32InBigEndian(void* memory)
{
	uint8_t* p = memory;
	return (((uint32_t)p[0]) << 24) | 
		   (((uint32_t)p[1]) << 16) |
		   (((uint32_t)p[2]) <<  8) |
		   (((uint32_t)p[3]));
}


uint64_t readUint64InBigEndian(void* memory)
{
	uint8_t* p = memory;
	return (((uint64_t)p[0]) << 56) | 
		   (((uint64_t)p[1]) << 48) |
		   (((uint64_t)p[2]) << 40) |
		   (((uint64_t)p[3]) << 32) |
		   (((uint64_t)p[4]) << 24) | 
		   (((uint64_t)p[5]) << 16) |
		   (((uint64_t)p[6]) <<  8) |
		   (((uint64_t)p[7]));
}


void writeUint16InBigEndian(void* memory, uint16_t value)
{
	uint8_t* p = memory;
	p[0] = (uint8_t)(value >> 8);
	p[1] = (uint8_t)(value);
}


void writeUint32InBigEndian(void* memory, uint32_t value)
{
	uint8_t* p = memory;
	p[0] = (uint8_t)(value >> 24);
	p[1] = (uint8_t)(value >> 16);
	p[2] = (uint8_t)(value >> 8);
	p[3] = (uint8_t)(value);
}


void writeUint64InBigEndian(void* memory, uint64_t value)
{
	uint8_t* p = memory;
	p[0] = (uint8_t)(value >> 56);
	p[1] = (uint8_t)(value >> 48);
	p[2] = (uint8_t)(value >> 40);
	p[3] = (uint8_t)(value >> 32);
	p[4] = (uint8_t)(value >> 24);
	p[5] = (uint8_t)(value >> 16);
	p[6] = (uint8_t)(value >> 8);
	p[7] = (uint8_t)(value);
}


int16_t readInt16InBigEndian(void* memory)
{
	return (int16_t)readUint16InBigEndian(memory);
}


int32_t readInt32InBigEndian(void* memory)
{
	return (int32_t)readUint32InBigEndian(memory);
}


int64_t readInt64InBigEndian(void* memory)
{
	return (int64_t)readUint64InBigEndian(memory);
}


void writeInt16InBigEndian(void* memory, int16_t value)
{
	writeUint16InBigEndian(memory, (uint16_t)value);
}


void writeInt32InBigEndian(void* memory, int32_t value)
{
	writeUint32InBigEndian(memory, (uint32_t)value);
}


void writeInt64InBigEndian(void* memory, int64_t value)
{
	writeUint64InBigEndian(memory, (uint64_t)value);
}

/* Little-Endian */

uint16_t readUint16InLittleEndian(void* memory)
{
	uint8_t* p = memory;
	return (((uint16_t)p[1]) << 8) | 
		   (((uint16_t)p[0]));
}

uint32_t readUint32InLittleEndian(void* memory)
{
	uint8_t* p = memory;
	return (((uint32_t)p[3]) << 24) | 
		   (((uint32_t)p[2]) << 16) |
		   (((uint32_t)p[1]) <<  8) |
		   (((uint32_t)p[0]));
}


uint64_t readUint64InLittleEndian(void* memory)
{
	uint8_t* p = memory;
	return (((uint64_t)p[7]) << 56) | 
		   (((uint64_t)p[6]) << 48) |
		   (((uint64_t)p[5]) << 40) |
		   (((uint64_t)p[4]) << 32) |
		   (((uint64_t)p[3]) << 24) | 
		   (((uint64_t)p[2]) << 16) |
		   (((uint64_t)p[1]) <<  8) |
		   (((uint64_t)p[0]));
}


void writeUint16InLittleEndian(void* memory, uint16_t value)
{
	uint8_t* p = memory;
	p[1] = (uint8_t)(value >> 8);
	p[0] = (uint8_t)(value);
}


void writeUint32InLittleEndian(void* memory, uint32_t value)
{
	uint8_t* p = memory;
	p[3] = (uint8_t)(value >> 24);
	p[2] = (uint8_t)(value >> 16);
	p[1] = (uint8_t)(value >> 8);
	p[0] = (uint8_t)(value);
}


void writeUint64InLittleEndian(void* memory, uint64_t value)
{
	uint8_t* p = memory;
	p[7] = (uint8_t)(value >> 56);
	p[6] = (uint8_t)(value >> 48);
	p[5] = (uint8_t)(value >> 40);
	p[4] = (uint8_t)(value >> 32);
	p[3] = (uint8_t)(value >> 24);
	p[2] = (uint8_t)(value >> 16);
	p[1] = (uint8_t)(value >> 8);
	p[0] = (uint8_t)(value);
}

int16_t readInt16InLittleEndian(void* memory)
{
	return (int16_t)readUint16InLittleEndian(memory);
}


int32_t readInt32InLittleEndian(void* memory)
{
	return (int32_t)readUint32InLittleEndian(memory);
}


int64_t readInt64InLittleEndian(void* memory)
{
	return (int64_t)readUint64InLittleEndian(memory);
}


void writeInt16InLittleEndian(void* memory, int16_t value)
{
	writeUint16InLittleEndian(memory, (uint16_t)value);
}


void writeInt32InLittleEndian(void* memory, int32_t value)
{
	writeUint32InLittleEndian(memory, (uint32_t)value);
}


void writeInt64InLittleEndian(void* memory, int64_t value)
{
	writeUint64InLittleEndian(memory, (uint64_t)value);
}




char* ByteToHex(const unsigned char* vByte, const int vLen)
{
    if (!vByte)
    {
        return NULL;
    }

    char* tmp = malloc(vLen * 2 + 1); 

    int tmp2;
    for (int i = 0; i < vLen; i++)
    {
        tmp2 = (int)(vByte[i]) / 16;
        tmp[i * 2] = (char)(tmp2 + ((tmp2 > 9) ? 'A' - 10 : '0'));
        tmp2 = (int)(vByte[i]) % 16;
        tmp[i * 2 + 1] = (char)(tmp2 + ((tmp2 > 9) ? 'A' - 10 : '0'));
    }

    tmp[vLen * 2] = '\0';
    return tmp;
}

void printHex(const unsigned char* value, const int len)
{
	char* data = ByteToHex(value, len);
	int strl = strlen(data) / 2;
	char buf[3] = {0};
	for(int i = 0; i < strl; ++i)
	{
		buf[0] = data[i * 2];
		buf[1] = data[i * 2 + 1];
		printf("%s ", buf);
	}
	printf("\n");
	delete[]data;
}


int main()
{
	char memory[8];
	memset(memory, 0, 8);
	
	
	writeUint16InBigEndian(memory,UINT16_MAX);
	printf("%u  %u\n",readUint16InBigEndian(memory), UINT16_MAX);
	writeUint32InBigEndian(memory,UINT32_MAX);
	printf("%u  %u\n",readUint32InBigEndian(memory), UINT32_MAX);
	writeUint64InBigEndian(memory,UINT64_MAX);
	printf("%llu  %llu\n",readUint64InBigEndian(memory), UINT64_MAX);
	
	printf("-----------------------------\n");
	
	writeInt16InBigEndian(memory,INT16_MIN);
	printf("%d  %d\n",readInt16InBigEndian(memory), INT16_MIN);
	writeInt32InBigEndian(memory,INT32_MIN);
	printf("%d  %d\n",readInt32InBigEndian(memory), INT32_MIN);
	writeInt64InBigEndian(memory,INT64_MIN);
	printf("%lld  %lld\n",readInt64InBigEndian(memory), INT64_MIN);

	printf("-----------------------------\n");
	
	writeUint16InLittleEndian(memory,UINT16_MAX);
	printf("%u  %u\n",readUint16InLittleEndian(memory), UINT16_MAX);
	writeUint32InLittleEndian(memory,UINT32_MAX);
	printf("%u  %u\n",readUint32InLittleEndian(memory), UINT32_MAX);
	writeUint64InLittleEndian(memory,UINT64_MAX);
	printf("%llu  %llu\n",readUint64InLittleEndian(memory), UINT64_MAX);
	
	printf("-----------------------------\n");
	
	writeInt16InLittleEndian(memory,INT16_MIN);
	printf("%d  %d\n",readInt16InLittleEndian(memory), INT16_MIN);
	writeInt32InLittleEndian(memory,INT32_MIN);
	printf("%d  %d\n",readInt32InLittleEndian(memory), INT32_MIN);
	writeInt64InLittleEndian(memory,INT64_MIN);
	printf("%lld  %lld\n",readInt64InLittleEndian(memory), INT64_MIN);
	
	printf("#############################\n");
	
	
	
	//writeUint32InLittleEndian(memory,(uint32_t)0x12345678);
	*((uint32_t*)memory) = (uint32_t)0x12345678;
	printHex(memory, 4);
	printf("uint:%lu   %lu\n", readUint32InLittleEndian(memory), (uint32_t)0x12345678);
	
	writeUint32InBigEndian(memory,(uint32_t)0x12345678);
	printHex(memory, 4);
	printf("uint:%lu   %lu\n", readUint32InBigEndian(memory), (uint32_t)0x12345678);
}
```

### scrcpy里面的

```C

static inline void
buffer_write16be(uint8_t *buf, uint16_t value) {
    buf[0] = value >> 8;
    buf[1] = value;
}

static inline void
buffer_write32be(uint8_t *buf, uint32_t value) {
    buf[0] = value >> 24;
    buf[1] = value >> 16;
    buf[2] = value >> 8;
    buf[3] = value;
}

static inline void
buffer_write64be(uint8_t *buf, uint64_t value) {
    buffer_write32be(buf, value >> 32);
    buffer_write32be(&buf[4], (uint32_t) value);
}

static inline uint16_t
buffer_read16be(const uint8_t *buf) {
    return (buf[0] << 8) | buf[1];
}

static inline uint32_t
buffer_read32be(const uint8_t *buf) {
    return (buf[0] << 24) | (buf[1] << 16) | (buf[2] << 8) | buf[3];
}

static inline uint64_t
buffer_read64be(const uint8_t *buf) {
    uint32_t msb = buffer_read32be(buf);
    uint32_t lsb = buffer_read32be(&buf[4]);
    return ((uint64_t) msb << 32) | lsb;
}

```









## utf8

```C

// return the index to truncate a UTF-8 string at a valid position
size_t
utf8_truncation_index(const char *utf8, size_t max_len) {
    size_t len = strlen(utf8);
    if (len <= max_len) {
        return len;
    }
    len = max_len;
    // see UTF-8 encoding <https://en.wikipedia.org/wiki/UTF-8#Description>
    while ((utf8[len] & 0x80) != 0 && (utf8[len] & 0xc0) != 0xc0) {
        // the next byte is not the start of a new UTF-8 codepoint
        // so if we would cut there, the character would be truncated
        len--;
    }
    return len;
}
```

## windows宽字节转换

```C

#ifdef _WIN32
# include <windows.h>
# include <tchar.h>

// convert a UTF-8 string to a wchar_t string
// returns the new allocated string, to be freed by the caller
wchar_t *
utf8_to_wide_char(const char *utf8) {
    int len = MultiByteToWideChar(CP_UTF8, 0, utf8, -1, NULL, 0);
    if (!len) {
        return NULL;
    }

    wchar_t *wide = malloc(len * sizeof(wchar_t));
    if (!wide) {
        return NULL;
    }

    MultiByteToWideChar(CP_UTF8, 0, utf8, -1, wide, len);
    return wide;
}

char *
utf8_from_wide_char(const wchar_t *ws) {
    int len = WideCharToMultiByte(CP_UTF8, 0, ws, -1, NULL, 0, NULL, NULL);
    if (!len) {
        return NULL;
    }

    char *utf8 = malloc(len);
    if (!utf8) {
        return NULL;
    }

    WideCharToMultiByte(CP_UTF8, 0, ws, -1, utf8, len, NULL, NULL);
    return utf8;
}

#endif
```

## scrcpy里面的浮点数转定点数

```C
static uint16_t
to_fixed_point_16(float f) {
    assert(f >= 0.0f && f <= 1.0f);
    uint32_t u = f * 0x1p16f; // 2^16
    if (u >= 0xffff) {
        u = 0xffff;
    }
    return (uint16_t) u;
}
```



## NoticeCenter使用示例

```C++
#include <iostream>
#include "NoticeCenter.h"


//广播名称1
#define NOTICE_NAME1 "NOTICE_NAME1"
//广播名称2
#define NOTICE_NAME2 "NOTICE_NAME2"


template<typename T>
void print(T& t) {
	cout << "lvalue" << endl;
}
template<typename T>
void print(T&& t) {
	cout << "rvalue" << endl;
}

template<typename T>
void TestForward(T && v) {
	print(v);
	print(std::forward<T>(v));
	print(std::move(v));
}

std::unordered_map<const char*, void*> callMap;

template <typename FUNC>
void registerCall(const char* name, FUNC&& func)
{
	typedef typename function_traits<typename std::remove_reference<FUNC>::type>::stl_function_type funType;
	auto call = new funType(std::forward<FUNC>(func));

	callMap[name] = (void*)call;
}

template <typename ...Args>
void emit(const char* name, Args&& ... args)
{
	void* p = callMap[name];
	typedef std::function<void(decltype(std::forward<Args>(args))...)> funcType;
	funcType* call = (funcType*)p;
	(*call)(std::forward<Args>(args)...);
}


int main() {
	const char* event1 = "event_1";

	registerCall(event1, [](int a, const char* b) 
	{
		printf("a = %d, b = %s\n", a, b);
	});

	emit(event1, 10, (const char*)"hahahah");


	auto func = [](int a, const char* b)
		{
			printf("a = %d, b = %s\n", a, b);
		};
	typedef decltype(func) fType;
	fType* f1 = new fType(func);

	(*f1)(10, "hahaha");

	//TestForward(1);
	//int x = 1;
	//TestForward(x);
	//TestForward(std::forward<int>(x));


	////对事件NOTICE_NAME1新增一个监听
	////addListener方法第一个参数是标签，用来删除监听时使用
	////需要注意的是监听回调的参数列表个数类型需要与emitEvent广播时的完全一致，否则会有无法预知的错误
	//NoticeCenter::Instance().addListener(0, NOTICE_NAME1,
	//	[](int &a, const char * &b, double &c, string &d) {
	//	std::cout << "NOTICE_NAME1 1 -------------> " << a << " " << b << " " << c << " " << d << std::endl;
	//	NoticeCenter::Instance().delListener(0, NOTICE_NAME1);

	//	NoticeCenter::Instance().addListener(0, NOTICE_NAME1,
	//		[](int &a, const char * &b, double &c, string &d) {
	//		std::cout << "NOTICE_NAME1 2 -------------> " << a << " " << b << " " << c << " " << d << std::endl;
	//	});
	//});

	////监听NOTICE_NAME2事件
	//NoticeCenter::Instance().addListener(0, NOTICE_NAME2,
	//	[](string &d, double &c, const char *&b, int &a) {
	//	std::cout << "NOTICE_NAME2 1 -------------> " << a << " " << b << " " << c << " " << d << std::endl;
	//	NoticeCenter::Instance().delListener(0, NOTICE_NAME2);

	//	NoticeCenter::Instance().addListener(0, NOTICE_NAME2,
	//		[](string &d, double &c, const char *&b, int &a) {
	//		std::cout << "NOTICE_NAME2 2 -------------> " << a << " " << b << " " << c << " " << d << std::endl;
	//	});

	//});

	//int count = 0;
	//int a = 0;
	//while (true) {
	//	const char *b = "b";
	//	double c = 3.14;
	//	string d("d");
	//	//每隔1秒广播一次事件，如果无法确定参数类型，可加强制转换
	//	NoticeCenter::Instance().emitEvent(NOTICE_NAME1, ++a, (const char *)"b", c, d);
	//	NoticeCenter::Instance().emitEvent(NOTICE_NAME2, d, c, b, a);
	//	::Sleep(1000); // sleep 1 second

	//	if (++count > 3)
	//	{
	//		break;
	//	}
	//}

	//testFunc();

	system("pause");
	return 0;
}

```

## 二分法开方实现

```c++
void main()
{
	double value = 3.0;
	double left = 0.0, mid = value / 2, right = value, last;

	while (true)
	{
		if (mid * mid > value)
		{
			right = mid;
		}
		else
		{
			left = mid;
		}
		last = mid;
		mid = left + (right - left) / 2.0;
		if (abs(last - mid) < 1e-5)break;
	}
	printf("c1:%lf\n", mid);
}
```





