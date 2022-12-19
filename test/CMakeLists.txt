enable_testing()

macro(make_test name src_file)
    add_executable(${name} ${src_file})
    target_link_libraries(${name} 
        PRIVATE quickjspp 
        PRIVATE quickjs-dumpleaks
    )

    add_test(
        NAME ${name}
        COMMAND "${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/${name}")

    # try to compile with -DCONFIG_CHECK_JSVALUE
    add_executable(${name}-checkjsv ${src_file})
    target_compile_definitions(${name}-checkjsv
        PRIVATE CONFIG_CHECK_JSVALUE=1
    )
    target_link_libraries(${name}-checkjsv
        PRIVATE quickjspp
    )

    add_test(
        NAME ${name}-checkjsv
        COMMAND "${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/${name}-checkjsv")
endmacro()

file(GLOB tests
    "${CMAKE_CURRENT_LIST_DIR}/*.cpp"
)

foreach(test IN ITEMS ${tests})
    get_filename_component(src_file_name "${test}" NAME_WLE)
    make_test("${src_file_name}" "${test}")
endforeach()
