add_library(utils_library
    STATIC
    string_buffer.c
)

target_include_directories(utils_library PUBLIC ${CMAKE_CURRENT_SOURCE_DIR})
