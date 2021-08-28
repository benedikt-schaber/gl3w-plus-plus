#!/usr/bin/cmake -P

# Usage:
# - cmake script mode: cmake -P gl3w_gen.cmake or ./gl3w_gen.cmake
# - from a cmake project: include(gl3w_gen) then gl3w_gen(OUTPUT_PATH)
# Pavel Rojtberg 2016

function(gl3w_gen OUTDIR)

file(MAKE_DIRECTORY ${OUTDIR}/include/GL)
file(MAKE_DIRECTORY ${OUTDIR}/src)

if(NOT EXISTS ${OUTDIR}/include/GL/glcorearb.h)
    message(STATUS "Downloading glcorearb.h to include/GL...")
    file(DOWNLOAD
        https://www.khronos.org/registry/OpenGL/api/GL/glcorearb.h
        ${OUTDIR}/include/GL/glcorearb.h)
else()
    message(STATUS "Reusing glcorearb.h from include/GL...")
endif()

message(STATUS "Parsing glcorearb.h header...")

file(STRINGS ${OUTDIR}/include/GL/glcorearb.h GLCOREARB)

foreach(LINE ${GLCOREARB})
    string(REGEX MATCH "GLAPI.*APIENTRY[ ]+([a-zA-Z0-9_]+)" MATCHES ${LINE})
    if(MATCHES)
        list(APPEND PROCS ${CMAKE_MATCH_1})
    endif()
endforeach()

list(SORT PROCS)

set(SPACES "                                                       ") # 55 spaces

macro(getproctype PROC)
    string(TOUPPER ${PROC} P_T)
    set(P_T "PFN${P_T}PROC")
endmacro()

macro(getproctype_aligned PROC)
    getproctype(${PROC})
    string(LENGTH ${P_T} LEN)
    math(EXPR LEN "55 - ${LEN}")
    string(SUBSTRING ${SPACES} 0 ${LEN} PAD)
    set(P_T "${P_T}${PAD}")
endmacro()

macro(getprocsignature PROC)
    string(SUBSTRING ${PROC} 2 -1 P_S)
    set(P_S "gl3w${P_S}")
endmacro()

message(STATUS "Generating gl3w.h in include/GL...")

set(HDR_OUT ${OUTDIR}/include/GL/gl3w.h)

set(EXTERNS "")
foreach(PROC ${PROCS})
    getprocsignature(${PROC})
    getproctype_aligned(${PROC})
    string(APPEND EXTERNS "extern ${P_T} ${P_S};\n")
endforeach()

set(DEFINES "")
foreach(PROC ${PROCS})
    string(SUBSTRING ${PROC} 2 -1 P_S)
    string(LENGTH ${PROC} LEN)
    math(EXPR LEN "48 - ${LEN}")
    string(SUBSTRING ${SPACES} 0 ${LEN} PAD)
    string(APPEND DEFINES "#define ${PROC}${PAD} gl3w${P_S}\n")
endforeach()

configure_file(${CMAKE_CURRENT_LIST_DIR}/gl3w.in.h ${HDR_OUT} )

message(STATUS "Generating gl3w.c in src...")
set(SRC_OUT ${OUTDIR}/src/gl3w.c)

set(DECLARATIONS "")
foreach(PROC ${PROCS})
    getprocsignature(${PROC})
    getproctype_aligned(${PROC})
    string(APPEND DECLARATIONS "${P_T} ${P_S};\n")
endforeach()

set(LOADS "")
foreach(PROC ${PROCS})
    getprocsignature(${PROC})
    getproctype(${PROC})
    string(APPEND LOADS "\t${P_S} = (${P_T})proc(\"${PROC}\");\n")
endforeach()

configure_file(${CMAKE_CURRENT_LIST_DIR}/gl3w.in.c ${SRC_OUT})

endfunction()

if(NOT CMAKE_PROJECT_NAME)
    gl3w_gen(".")
endif()
