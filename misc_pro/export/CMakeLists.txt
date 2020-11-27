cmake_minimum_required(VERSION 3.8)
project(publish-tool)

add_subdirectory(lua)
add_subdirectory(tolua)
add_subdirectory(luamodules)

set(Main_Sources
	main.cpp
)

add_executable(${PROJECT_NAME} ${Main_Sources})
target_link_libraries(${PROJECT_NAME} lua)
target_link_libraries(${PROJECT_NAME} tolua)
target_link_libraries(${PROJECT_NAME} luamodules)
