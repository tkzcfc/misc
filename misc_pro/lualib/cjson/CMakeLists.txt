project(cjson)

set(CJSON_SRC
  fpconv.c
  lua_cjson.c
  strbuf.c
  cjson.def
)

source_group("" FILES ${CJSON_SRC})

include_directories(
  ../lua
)

add_library(${PROJECT_NAME} SHARED ${CJSON_SRC})

target_link_libraries(${PROJECT_NAME} lua5.1)

