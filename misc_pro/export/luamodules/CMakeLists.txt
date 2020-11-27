project(luamodules)

set(LUA_MODULES_SRC
  lua_function/LuaFunction.cpp
  lua_function/LuaFunction.h
  lua_function/LuaFunctionBond.cpp
  lua_function/LuaFunctionBond.h
  lua_function/tolua_ext.cpp
  lua_function/tolua_ext.h
  
  lfs/lfs.h
  lfs/lfs.c
  
  cjson/fpconv.h
  cjson/fpconv.c
  cjson/lua_cjson.h
  cjson/lua_cjson.c
  cjson/strbuf.h
  cjson/strbuf.c
  
  math/CCMath.h
  math/CCMathBase.h
  math/CLine.cpp
  math/CLine.h
  math/CRect.cpp
  math/CRect.h
  math/LineValue.cpp
  math/LineValue.h
  math/Mat4.cpp
  math/Mat4.h
  math/Mat4.inl
  math/Math.cpp
  math/Math.h
  math/MathCom.h
  math/MathUtil.cpp
  math/MathUtil.h
  math/MathUtil.inl
  math/MathUtilNeon.inl
  math/MathUtilNeon64.inl
  math/MathUtilSSE.inl
  math/Quaternion.cpp
  math/Quaternion.h
  math/Quaternion.inl
  math/Vec3.cpp
  math/Vec3.h
  math/Vec3.inl
  math/Vec4.cpp
  math/Vec4.h
  math/Vec4.inl
  math/lua_math.cpp
  math/lua_math.h
  
  
  luamodules.h
  luamodules.cpp
)

include_directories(
  ../lua
  ../tolua
)


source_group("" FILES ${LUA_MODULES_SRC})

add_library(${PROJECT_NAME} STATIC ${LUA_MODULES_SRC})

target_include_directories(${PROJECT_NAME} PUBLIC ${CMAKE_CURRENT_SOURCE_DIR})


