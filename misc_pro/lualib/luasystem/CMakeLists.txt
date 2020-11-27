project(system)

set(LFS_SRC
  src/compat.c
  src/core.c
  src/time.c
)

source_group("" FILES ${LFS_SRC})

include_directories(
  ../lua
)

add_library(${PROJECT_NAME} SHARED ${LFS_SRC})

target_link_libraries(${PROJECT_NAME} lua5.1)

