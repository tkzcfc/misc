project(lpeglabel)

set(LPEG_SRC
  lpcap.c
  lpcode.c
  lpprint.c
  lptree.c
  lpvm.c
  lpeglabel.def
)

source_group("" FILES ${LPEG_SRC})

include_directories(
  ../lua
)

add_library(${PROJECT_NAME} SHARED ${LPEG_SRC})

target_link_libraries(${PROJECT_NAME} lua5.1)

