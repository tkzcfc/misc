project(tolua)

set(TOLUA_SRC
  tolua_event.c
  tolua_is.c
  tolua_map.c
  tolua_push.c
  tolua_to.c
)

include_directories(
  ../lua
)


source_group("" FILES ${TOLUA_SRC})

add_library(${PROJECT_NAME} STATIC ${TOLUA_SRC})

target_include_directories(${PROJECT_NAME} PUBLIC ${CMAKE_CURRENT_SOURCE_DIR})
