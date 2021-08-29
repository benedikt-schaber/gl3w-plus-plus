#!/usr/bin/cmake -P

# Usage:
# - cmake script mode: cmake -P gl3w_gen.cmake or ./gl3w_gen.cmake
# - from a cmake project: include(gl3w_gen) then gl3w_gen(OUTPUT_PATH)
# Pavel Rojtberg 2016

# gl3w_gen([OUTDIR dir])
function(gl3w_gen)

cmake_parse_arguments(PARSE_ARGV 0 GL3W "" "OUTDIR" "")

if(NOT GL3W_OUTDIR)
  set(GL3W_OUTDIR ${CMAKE_CURRENT_LIST_DIR})
endif()

file(MAKE_DIRECTORY ${GL3W_OUTDIR}/include/GL)
file(MAKE_DIRECTORY ${GL3W_OUTDIR}/src)

if(NOT EXISTS ${GL3W_OUTDIR}/include/GL/glcorearb.h)
    message(STATUS "Downloading glcorearb.h to include/GL...")
    file(DOWNLOAD
        https://www.khronos.org/registry/OpenGL/api/GL/glcorearb.h
        ${GL3W_OUTDIR}/include/GL/glcorearb.h)
else()
    message(STATUS "Reusing glcorearb.h from include/GL...")
endif()

message(STATUS "Parsing glcorearb.h header...")

file(STRINGS ${GL3W_OUTDIR}/include/GL/glcorearb.h GLCOREARB)

set(EXT_SUFFIXES ARB EXT KHR OVR NV AMD INTEL)
function(is_ext PROC)
  foreach(SUFFIX ${EXT_SUFFIXES})
    if(${PROC} MATCHES "${SUFFIX}$")
      set(I_E TRUE PARENT_SCOPE)
    endif()
  endforeach()
endfunction()

foreach(LINE ${GLCOREARB})
    string(REGEX MATCH "GLAPI.*APIENTRY[ ]+([a-zA-Z0-9_]+)" MATCHES ${LINE})
    if(MATCHES)
      set(I_E)
      is_ext(${CMAKE_MATCH_1})
      if(NOT I_E)
        list(APPEND PROCS ${CMAKE_MATCH_1})
      endif()
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
endmacro()

message(STATUS "Generating gl3w.h in include/GL...")

set(HDR_OUT ${GL3W_OUTDIR}/include/GL/gl3w.h)

list(LENGTH PROCS PROCS_LEN)

set(INTERNALS "")
foreach(PROC ${PROCS})
    getprocsignature(${PROC})
    getproctype_aligned(${PROC})
    string(APPEND INTERNALS "\t\t${P_T} ${P_S};\n")
endforeach()

set(DEFINES "")
foreach(PROC ${PROCS})
    string(SUBSTRING ${PROC} 2 -1 P_S)
    string(LENGTH ${PROC} LEN)
    math(EXPR LEN "48 - ${LEN}")
    string(SUBSTRING ${SPACES} 0 ${LEN} PAD)
    string(APPEND DEFINES "#define ${PROC}${PAD} gl3wProcs.gl.${P_S}\n")
endforeach()

configure_file(${CMAKE_CURRENT_LIST_DIR}/gl3w.in.h ${HDR_OUT} )

message(STATUS "Generating gl3w.c in src...")
set(SRC_OUT ${GL3W_OUTDIR}/src/gl3w.c)

set(PROC_NAMES "")
foreach(PROC ${PROCS})
    string(APPEND PROC_NAMES "\t\"${PROC}\",\n")
endforeach()

configure_file(${CMAKE_CURRENT_LIST_DIR}/gl3w.in.c ${SRC_OUT})

endfunction()

if(NOT CMAKE_PROJECT_NAME)
    gl3w_gen(".")
endif()
