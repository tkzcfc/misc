project(int64)

set(LFS_SRC
  lint64.c
  lint64.def
)

source_group("" FILES ${LFS_SRC})

include_directories(
  ../lua
)

add_library(${PROJECT_NAME} SHARED ${LFS_SRC})

target_link_libraries(${PROJECT_NAME} lua5.1)

