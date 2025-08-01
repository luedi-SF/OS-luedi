cmake_minimum_required(VERSION 3.31)
project(luedi_os C)

set(CMAKE_C_STANDARD 99)

add_executable(luedi_os src/tools/main.c
        src/tools/floppy.c
        src/tools/floppy.h
        src/tools/log.c
        src/tools/log.h
)
