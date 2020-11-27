project(lfs)

set(LFS_SRC
  lfs.c
  lfs.def
)

source_group("" FILES ${LFS_SRC})

include_directories(
  ../lua
)

add_library(${PROJECT_NAME} SHARED ${LFS_SRC})

target_link_libraries(${PROJECT_NAME} lua5.1)

