extern "C"
{
#include "lua.h"
#include "lualib.h"
#include "lauxlib.h"
}

#include "luamodules.h"

int main(char argc, char** argv)
{
	lua_State* L = luaL_newstate();
	luaL_openlibs(L);
	luamodules_open(L);

	lua_newtable(L);
	for (int i = 0; i < argc; ++i)
	{
		lua_pushstring(L, argv[i]);
		lua_rawseti(L, -2, i + 1);
	}
	lua_setglobal(L, "args");

	luaL_dofile(L, "main.lua");
	return 0;
}

