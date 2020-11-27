#include <string.h>

#include "lua.h"
#include "lauxlib.h"
#include "xxtea.h"

#define MYNAME		"xxtea"
#define MYVERSION	MYNAME " library for " LUA_VERSION " / Mar 2010"

static int Lencode(lua_State *L)		/** encode(s) */
{
  int argc = lua_gettop(L);
  if(argc >= 2)
  {
    size_t datalen;
    const unsigned char *data = luaL_checklstring(L, 1, &datalen);

    size_t keylen;
    const unsigned char *key = luaL_checklstring(L, 2, &keylen);

    if(data == NULL || datalen <= 0 || key == NULL || keylen <= 0)
    {
      luaL_error(L, "invalid arguments in function 'encode'\n");
      return 0;
    }

    xxtea_long ecodelen = 0;
    unsigned char* edata = xxtea_encrypt(data, datalen, key, keylen, &ecodelen);
    
    lua_pushlstring(L, edata, ecodelen);
    lua_pushnumber(L, (lua_Number)ecodelen);
    
    free(edata);
    
    return 2;
  }
  luaL_error(L, "%s has wrong number of arguments: %d, was expecting %d \n", "encode",argc, 2);
  return 0;
}

static int Ldecode(lua_State *L)		/** decode(s) */
{
  int argc = lua_gettop(L);
  if(argc >= 2)
  {
    size_t datalen;
    const unsigned char *data = luaL_checklstring(L, 1, &datalen);

    size_t keylen;
    const unsigned char *key = luaL_checklstring(L, 2, &keylen);

    if(data == NULL || datalen <= 0 || key == NULL || keylen <= 0)
    {
      luaL_error(L, "invalid arguments in function 'decode'\n");
      return 0;
    }

    xxtea_long decodelen = 0;
    unsigned char* dedata = xxtea_decrypt(data, datalen, key, keylen, &decodelen);
    
    lua_pushlstring(L, dedata, decodelen);
    lua_pushnumber(L, (lua_Number)decodelen);
    
    free(dedata);
    
    return 2;
  }
  luaL_error(L, "%s has wrong number of arguments: %d, was expecting %d \n", "decode",argc, 2);
  return 0;
}

static const luaL_Reg R[] =
{
	{ "encode",	Lencode	},
	{ "decode",	Ldecode	},
	{ NULL,		NULL	}
};

LUALIB_API int luaopen_xxtea(lua_State *L)
{
 luaL_register(L,MYNAME,R);
 lua_pushliteral(L,"version");			/** version */
 lua_pushliteral(L,MYVERSION);
 lua_settable(L,-3);
 return 1;
}