project(xxtea)

set(XXTEA_SRC
  lxxtea.c
  xxtea.c
  xxtea.def
)

source_group("" FILES ${XXTEA_SRC})

include_directories(
  ../lua
)

add_library(${PROJECT_NAME} SHARED ${XXTEA_SRC})

target_link_libraries(${PROJECT_NAME} lua5.1)

