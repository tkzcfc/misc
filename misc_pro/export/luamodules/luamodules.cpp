#include "luamodules.h"

extern "C"
{
	#include "lfs/lfs.h"
	#include "cjson/lua_cjson.h"
}

#include "math/lua_math.h"

static luaL_Reg luax_exts[] = {
	{ "cjson", luaopen_cjson_safe },
	{ NULL, NULL }
};

int luamodules_open(lua_State* L)
{
	luaopen_lfs(L);
	luaopen_math(L);

	// load extensions
	luaL_Reg* lib = luax_exts;
	lua_getglobal(L, "package");
	lua_getfield(L, -1, "preload");
	for (; lib->func; lib++)
	{
		lua_pushcfunction(L, lib->func);
		lua_setfield(L, -2, lib->name);
	}
	lua_pop(L, 2);

	return 1;
}

