# 安卓11，lua报错  bad light userdata pointer

```
详情: https://forum.cocos.org/t/topic/102430/3

3.1.6版本cocos2d-x
在pixel 4a（android11 12月5号版本）运行游戏会发生lua报错
[LUA ERROR] bad light userdata pointer
此前安卓版本包括pixel2（android11 10月版本）都没问题，这次最新版本（还有其他机型）出了问题
求助一下各位大佬


我目前把TargrtApi版本降到29解决了，但是不是长久之计啊。



解决方案？(没试过)
https://github.com/xmake-io/xmake/blob/96b0eae26058482a83f5bbf57bab15a834339464/core/src/xmake/prefix.h#L45-L82

官方解决方案
https://github.com/LuaJIT/LuaJIT/commit/e9af1abec542e6f9851ff2368e7f196b6382a44c
```





