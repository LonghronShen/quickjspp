if(UNIX)
    find_package(DL REQUIRED)
endif()

set(THREADS_PREFER_PTHREAD_FLAG ON)
find_package(Threads REQUIRED)

set(FETCHCONTENT_UPDATES_DISCONNECTED ON CACHE STRING "FETCHCONTENT_UPDATES_DISCONNECTED" FORCE)

include(FetchContent)

# quickjs
FetchContent_Declare(quickjs
    GIT_REPOSITORY https://github.com/c-smile/quickjspp.git
    GIT_TAG master)

FetchContent_GetProperties(quickjs)
if(NOT quickjs_POPULATED)
    FetchContent_Populate(quickjs)
    configure_file("${CMAKE_CURRENT_LIST_DIR}/patches/quickjs/CMakeLists.txt" "${quickjs_SOURCE_DIR}/CMakeLists.txt" COPYONLY)
    configure_file("${CMAKE_CURRENT_LIST_DIR}/patches/quickjs/quickjs-version.h.in" "${quickjs_SOURCE_DIR}/quickjs-version.h.in" COPYONLY)
    add_subdirectory(${quickjs_SOURCE_DIR} ${quickjs_BINARY_DIR} EXCLUDE_FROM_ALL)
endif()
