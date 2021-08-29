#!/usr/bin/cmake -P

# Usage:
# - cmake script mode: cmake -P gl3w_gen.cmake or ./gl3w_gen.cmake
# - from a cmake project: include(gl3w_gen) then gl3w_gen(OUTPUT_PATH)
# Pavel Rojtberg 2016

# gl3w_gen([OUTDIR dir])
function(gl3w_gen)

cmake_parse_arguments(PARSE_ARGV 0 GL3W "" "OUTDIR" "")

function(join_path ROOT APPEND OUT)
  string(LENGTH "${ROOT}" LAST)
  math(EXPR LAST "${LAST} - 1")
  string(SUBSTRING "${ROOT}" ${LAST} 1 RES)
  if(RES STREQUAL "/")
    set(${OUT} "${ROOT}${APPEND}" PARENT_SCOPE)
  else()
    set(${OUT} "${ROOT}/${APPEND}" PARENT_SCOPE)
  endif()
endfunction()

function(ensure_downloaded URL PATH)
  if(NOT EXISTS "${PATH}")
    message(STATUS "Downloading ${PATH}...")
    file(DOWNLOAD "${URL}" "${PATH}")
  else()
    message(STATUS "Reusing ${PATH}...")
  endif()
endfunction()

if(NOT GL3W_OUTDIR)
  set(GL3W_OUTDIR "${CMAKE_CURRENT_LIST_DIR}")
endif()

join_path("${GL3W_OUTDIR}" include/GL INCLUDE_GL_DIR)
join_path("${GL3W_OUTDIR}" src SRC_DIR)

file(MAKE_DIRECTORY "${INCLUDE_GL_DIR}")
file(MAKE_DIRECTORY "${SRC_DIR}")

ensure_downloaded("https://www.khronos.org/registry/OpenGL/api/GL/glcorearb.h" "${INCLUDE_GL_DIR}/glcorearb.h")

message(STATUS "Parsing glcorearb.h header...")

file(STRINGS "${INCLUDE_GL_DIR}/glcorearb.h" GLCOREARB)

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

configure_file(${CMAKE_CURRENT_LIST_DIR}/gl3w.in.h "${INCLUDE_GL_DIR}/gl3w.h")

message(STATUS "Generating gl3w.c in src...")

set(PROC_NAMES "")
foreach(PROC ${PROCS})
    string(APPEND PROC_NAMES "\t\"${PROC}\",\n")
endforeach()

configure_file(${CMAKE_CURRENT_LIST_DIR}/gl3w.in.c "${SRC_DIR}/gl3w.c")

endfunction()

if(NOT CMAKE_PROJECT_NAME)
    gl3w_gen(".")
endif()
