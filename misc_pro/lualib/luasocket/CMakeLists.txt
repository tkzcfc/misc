project(luasocket)

set(LFS_SRC
  lua_extensions.c
  lua_extensions.def
luasocket/auxiliar.c
luasocket/auxiliar.h
luasocket/buffer.c
luasocket/buffer.h
luasocket/except.c
luasocket/except.h
luasocket/inet.c
luasocket/inet.h
luasocket/io.c
luasocket/io.h
luasocket/luasocket.c
luasocket/luasocket.h
luasocket/luasocket_scripts.c
luasocket/luasocket_scripts.h
luasocket/mime.c
luasocket/mime.h
luasocket/options.c
luasocket/options.h
luasocket/select.c
luasocket/select.h
luasocket/socket.h
luasocket/tcp.c
luasocket/tcp.h
luasocket/timeout.c
luasocket/timeout.h
luasocket/udp.c
luasocket/udp.h
luasocket/wsocket.c
luasocket/wsocket.h
)

#luasocket/serial.c
#luasocket/unix.c
#luasocket/unix.h
#luasocket/usocket.c
#luasocket/usocket.h

source_group("" FILES ${LFS_SRC})

include_directories(
  ../lua
)

add_library(${PROJECT_NAME} SHARED ${LFS_SRC})

target_link_libraries(${PROJECT_NAME} lua5.1 ws2_32)

