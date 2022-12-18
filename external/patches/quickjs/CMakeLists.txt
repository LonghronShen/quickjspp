cmake_minimum_required(VERSION 3.13)
project(quickjs LANGUAGES C CXX)

file(RENAME "${CMAKE_CURRENT_LIST_DIR}/VERSION" "${CMAKE_CURRENT_LIST_DIR}/QUICKJS_VERSION" RESULT rename_result)

file(STRINGS "${CMAKE_CURRENT_LIST_DIR}/QUICKJS_VERSION" QUICKJS_VERSION)
message(STATUS "Building quickjs version: ${QUICKJS_VERSION}")

configure_file("${CMAKE_CURRENT_LIST_DIR}/quickjs-version.h.in" "${CMAKE_CURRENT_LIST_DIR}/quickjs-version.h")

file(GLOB_RECURSE dybase_src
    ${CMAKE_CURRENT_LIST_DIR}/storage/dybase/src/*.cpp
    ${CMAKE_CURRENT_LIST_DIR}/storage/dybase/src/*.h
    ${CMAKE_CURRENT_LIST_DIR}/storage/dybase/include/*.h
)

option(USING_JSX "Use jsx." ON)
option(USING_STORAGE "Use storage." ON)
option(DUMP_LEAKS "Dump leaks" OFF)

add_library(dybase STATIC ${dybase_src})
target_include_directories(dybase
    PUBLIC "${CMAKE_CURRENT_LIST_DIR}/storage/dybase/include/"
)

add_library(quickjs::dybase ALIAS dybase)

set(quickjs_src 
    "cutils.c"
    "cutils.h"
    "libbf.c"
    "libregexp-opcode.h"
    "libregexp.c"
    "libregexp.h"
    "libunicode-table.h"
    "libunicode.c"
    "libunicode.h"
    "list.h"
    "quickjs-atom.h"
    "quickjs-jsx.h"
    "quickjs-libc.c"
    "quickjs-libc.h"
    "quickjs-opcode.h"
    "quickjs.c"
    "quickjs.h"
)

if(USING_STORAGE)
    list(APPEND quickjs_src 
        "storage/quickjs-storage.c"
        "storage/quickjs-storage.h"
    )
endif()

set(quickjs_def CONFIG_VERSION="${QUICKJS_VERSION}" _GNU_SOURCE CONFIG_BIGNUM JS_STRICT_NAN_BOXING)

add_library(quickjs STATIC ${quickjs_src})

if(MSVC)
    target_compile_features(quickjs PUBLIC cxx_std_20)
endif()

target_include_directories(quickjs
    PUBLIC "${CMAKE_CURRENT_LIST_DIR}/"
)

set_target_properties(quickjs PROPERTIES 
    PUBLIC_HEADER "quickjs.h;quickjs-libc.h"
)

target_compile_definitions(quickjs 
    PUBLIC ${quickjs_def}
)

target_link_libraries(quickjs
    PUBLIC ${CMAKE_THREAD_LIBS_INIT}
)

if(UNIX)
    target_link_libraries(quickjs
        PUBLIC ${DL_LIBRARY}
    )
endif()

if(USING_STORAGE)
    target_compile_definitions(quickjs 
        PUBLIC CONFIG_STORAGE
    )
    target_link_libraries(quickjs
        PUBLIC dybase
    )
endif()

if(USING_JSX)
    target_compile_definitions(quickjs 
        PUBLIC CONFIG_JSX
    )
endif()

if(DUMP_LEAKS)
    target_compile_definitions(quickjs 
        PRIVATE DUMP_LEAKS=1
    )
endif()

add_library(quickjs::quickjs ALIAS quickjs)

# ========
add_library(quickjs-dumpleaks STATIC ${quickjs_src})

if(MSVC)
    target_compile_features(quickjs-dumpleaks PUBLIC cxx_std_20)
endif()

target_include_directories(quickjs-dumpleaks
    PUBLIC "${CMAKE_CURRENT_LIST_DIR}/"
)

set_target_properties(quickjs-dumpleaks PROPERTIES 
    PUBLIC_HEADER "quickjs.h;quickjs-libc.h"
)

target_compile_definitions(quickjs-dumpleaks 
    PUBLIC ${quickjs_def}
)

target_link_libraries(quickjs-dumpleaks
    PUBLIC ${CMAKE_THREAD_LIBS_INIT}
)

if(UNIX)
    target_link_libraries(quickjs-dumpleaks
        PUBLIC ${DL_LIBRARY}
    )
endif()

if(USING_STORAGE)
    target_compile_definitions(quickjs-dumpleaks 
        PUBLIC CONFIG_STORAGE
    )
    target_link_libraries(quickjs-dumpleaks
        PUBLIC dybase
    )
endif()

if(USING_JSX)
    target_compile_definitions(quickjs 
        PUBLIC CONFIG_JSX
    )
endif()

target_compile_definitions(quickjs-dumpleaks 
    PRIVATE DUMP_LEAKS=1
)

add_library(quickjs::quickjs-dumpleaks ALIAS quickjs-dumpleaks)
# ========

add_executable(qjsc "qjsc.c")
target_link_libraries(qjsc
    PRIVATE quickjs
)

set(built_js_files)
set(qjs_js "qjscalc.js" "repl.js")
foreach(js IN ITEMS ${qjs_js})
    get_filename_component(js_file_name "${js}" NAME_WLE)
    set(OUT_C_FILE "${CMAKE_CURRENT_BINARY_DIR}/${js_file_name}.c")
    # message(STATUS "Set js file compilation: \"${js}\" to \"${OUT_C_FILE}\"")
    add_custom_command(
        OUTPUT "${OUT_C_FILE}"
        COMMAND "$<TARGET_FILE:qjsc>" ARGS -c -o "${CMAKE_CURRENT_BINARY_DIR}/${js_file_name}.c" -m "${CMAKE_CURRENT_LIST_DIR}/${js}"
        WORKING_DIRECTORY "${CMAKE_CURRENT_LIST_DIR}/"
        DEPENDS qjsc
        MAIN_DEPENDENCY "${CMAKE_CURRENT_LIST_DIR}/${js}"
        COMMENT "Compile js file: \"${js}\" to \"${OUT_C_FILE}\""
        VERBATIM
    )
    list(APPEND built_js_files "${OUT_C_FILE}")
endforeach()

add_custom_target(
  compile_js_for_qjs ALL
  DEPENDS ${built_js_files}
)

add_executable(qjs 
    "qjs.c"
    ${built_js_files}
)

add_dependencies(qjs compile_js_for_qjs)

target_link_libraries(qjs
    PRIVATE quickjs
)
