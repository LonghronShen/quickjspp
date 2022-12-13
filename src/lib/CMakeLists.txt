file(GLOB_RECURSE src
    ${CMAKE_CURRENT_LIST_DIR}/*.h
    ${CMAKE_CURRENT_LIST_DIR}/*.hpp

    ${CMAKE_CURRENT_LIST_DIR}/*.c
	${CMAKE_CURRENT_LIST_DIR}/*.cc
	${CMAKE_CURRENT_LIST_DIR}/*.cpp
)

file(GLOB_RECURSE public_headers
    ${CMAKE_CURRENT_LIST_DIR}/include/public/*.h
    ${CMAKE_CURRENT_LIST_DIR}/include/public/*.hpp
)

add_library(quickjspp STATIC ${src})

target_include_directories(quickjspp
    PUBLIC "${CMAKE_CURRENT_LIST_DIR}/include/public/"
    PRIVATE "${CMAKE_CURRENT_LIST_DIR}/include/private/"
)

target_compile_definitions(quickjspp
    PRIVATE -DCURL_STATICLIB
    PRIVATE -DPCRE2_STATIC
    PRIVATE -DYAML_CPP_STATIC_DEFINE
)

target_link_libraries(quickjspp
    PUBLIC quickjs::quickjs
)

add_library(quickjspp::quickjspp ALIAS quickjspp)
