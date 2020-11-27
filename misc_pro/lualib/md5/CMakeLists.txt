project(md5)

set(LFS_SRC
  compat-5.2.c
  des56.c
  ldes56.c
  md5.c
  md5lib.c
  md5.def
)

source_group("" FILES ${LFS_SRC})

include_directories(
  ../lua
)

add_library(${PROJECT_NAME} SHARED ${LFS_SRC})

target_link_libraries(${PROJECT_NAME} lua5.1)

