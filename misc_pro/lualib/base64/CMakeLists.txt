project(base64)

set(BASE64_SRC
  lbase64.c
  base64.def
)

source_group("" FILES ${BASE64_SRC})

include_directories(
  ../lua
)

add_library(${PROJECT_NAME} SHARED ${BASE64_SRC})

target_link_libraries(${PROJECT_NAME} lua5.1)

