if(UNIX)
    find_package(DL REQUIRED)
endif()

set(THREADS_PREFER_PTHREAD_FLAG ON)
find_package(Threads REQUIRED)

set(FETCHCONTENT_UPDATES_DISCONNECTED ON CACHE STRING "FETCHCONTENT_UPDATES_DISCONNECTED" FORCE)

include(FetchContent)
include(Patch)


if(MSVC)
  # sys_time_h
  FetchContent_Declare(sys_time_h
      GIT_REPOSITORY https://github.com/win32ports/sys_time_h.git
      GIT_TAG master)

  FetchContent_GetProperties(sys_time_h)
  if(NOT sys_time_h_POPULATED)
      FetchContent_Populate(sys_time_h)
      include_directories(SYSTEM ${sys_time_h_SOURCE_DIR})
  endif()


  # unistd_h
  FetchContent_Declare(unistd_h
      GIT_REPOSITORY https://github.com/win32ports/unistd_h.git
      GIT_TAG master)

  FetchContent_GetProperties(unistd_h)
  if(NOT unistd_h_POPULATED)
      FetchContent_Populate(unistd_h)
      include_directories(SYSTEM ${unistd_h_SOURCE_DIR})
  endif()


  # dirent_h
  FetchContent_Declare(dirent_h
      GIT_REPOSITORY https://github.com/LonghronShen/dirent_h.git
      GIT_TAG master)

  FetchContent_GetProperties(dirent_h)
  if(NOT dirent_h_POPULATED)
      FetchContent_Populate(dirent_h)
      include_directories(SYSTEM ${dirent_h_SOURCE_DIR})
  endif()
endif()


# quickjs
FetchContent_Declare(quickjs
    GIT_REPOSITORY https://github.com/c-smile/quickjspp.git
    GIT_TAG master)

FetchContent_GetProperties(quickjs)
if(NOT quickjs_POPULATED)
    FetchContent_Populate(quickjs)

    file(GLOB quickjs_patches
        "${CMAKE_CURRENT_LIST_DIR}/patches/quickjs/patch_files/*.patch"
    )

    foreach(patch_file IN ITEMS ${quickjs_patches})
        message(STATUS "Applying patch for quickjs: ${patch_file}")
        patch_directory("${quickjs_SOURCE_DIR}" "${patch_file}")
    endforeach()

    configure_file("${CMAKE_CURRENT_LIST_DIR}/patches/quickjs/CMakeLists.txt" "${quickjs_SOURCE_DIR}/CMakeLists.txt" COPYONLY)
    configure_file("${CMAKE_CURRENT_LIST_DIR}/patches/quickjs/quickjs-version.h.in" "${quickjs_SOURCE_DIR}/quickjs-version.h.in" COPYONLY)
    add_subdirectory(${quickjs_SOURCE_DIR} ${quickjs_BINARY_DIR} EXCLUDE_FROM_ALL)
endif()
