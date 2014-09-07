# FindIREL.cmake
#
# If you set the IREL_CFG CMake variable to point to a file  names "IREL-Defs.inc"
# (produced by CGM as part of any build or install), then the script will locate
# IREL assets for your package to use.
#
# This script defines the following CMake variables:
# IREL_FOUND         defined with IREL is located, false otherwise
# IREL_LIBRARIES     paths to IREL library and its dependencies
# IREL_INCLUDE_DIRS  directories containing IREL headers

find_file(IREL_CFG iRel-Defs.inc DOC "Path to iRel-Defs.inc configuration file")
if(IREL_CFG)
  set(IREL_FOUND 1)
  file(READ ${IREL_CFG} IREL_CFG_DATA)
  ##
  ## Replace line continuations ('\' at EOL) so we don't have to parse them later
  ##
  string(REGEX REPLACE "\\\\\\\n" "" IREL_CFG_DATA "${IREL_CFG_DATA}")

  ##
  ## Find include directories
  ##
  string(REGEX MATCHALL "IREL_INCLUDEDIR=[^\\\n]*" _IREL_INCS "${IREL_CFG_DATA}")
  foreach(_IREL_INC ${_IREL_INCS})

    # Only use include directories specified by the *last*
    # occurrence of IREL_INCLUDEDIR in the config file:
    unset(IREL_INCLUDE_DIRS)
    string(REGEX REPLACE "=" "=;" _IREL_INC_LIST "${_IREL_INC}")
    string(STRIP "${_IREL_INC_LIST}" _IREL_INC_LIST)
    foreach(_IREL_INC_ITEM ${_IREL_INC_LIST})
      if(NOT "${_IREL_INC_ITEM}" MATCHES "=$")
        list(APPEND IREL_INCLUDE_DIRS "${_IREL_INC_ITEM}")
      endif()
    endforeach()
  endforeach()
 # message("IREL_INCLUDE_DIRS: ${IREL_INCLUDE_DIRS}")


  ##
  ## Find lib directories
  ##
  string(REGEX MATCHALL "IREL_LIBDIR=[^\\\n]*" _IREL_LDIR "${IREL_CFG_DATA}")
  string(REGEX REPLACE "=" "=;" _IREL_LDIR "${_IREL_LDIR}")
  set(_IREL_LDIRS)
  foreach(_IREL_LL ${_IREL_LDIR})
    # Only use include directories specified by the *last*
    # occurrence of IREL_INCLUDEDIR in the config file:
    unset(_IREL_LDIRS)
    if(NOT "${_IREL_LL}" MATCHES "=$")
      list(APPEND _IREL_LDIRS "${_IREL_LL}")
    endif()
  endforeach()
  set(IREL_LIB_DIRS "${IREL_LIB_DIRS};${_IREL_LDIRS}")
  #message("IREL_LIB_DIRS: ${IREL_LIB_DIRS}")


  ##
  ## Find the IREL library and its dependencies
  ##
  # These spaces are important   [- -] TODO: fix this
  string(REGEX MATCHALL "IREL_LIBS = [^\\\n]*" _IREL_LIBS "${IREL_CFG_DATA}")
  string(REGEX MATCHALL "-l[^ \t\n]+" _IREL_LIBS "${_IREL_LIBS}")
  foreach(_IREL_LIB ${_IREL_LIBS})
    string(REGEX REPLACE "-l" "" _IREL_LIB "${_IREL_LIB}")
    find_library(_IREL_LIB_LOC
      NAME "${_IREL_LIB}"
      # Cannot quote since it contains semicolons:
      PATHS ${IREL_LIB_DIRS}
      NO_DEFAULT_PATH
      NO_CMAKE_ENVIRONMENT_PATH
      NO_CMAKE_PATH
      NO_CMAKE_SYSTEM_PATH
    )
    if (_IREL_LIB_LOC)
      list(APPEND IREL_LIBRARIES "${_IREL_LIB_LOC}")
      unset(_IREL_LIB_LOC CACHE)
      unset(_IREL_LIB_LOC)
    else()
      message("Could not find ${_IREL_LIB} library (part of IREL)")
      unset(IREL_FOUND)
    endif()
  endforeach()

else()
  message( FATAL_ERROR "You must provide an iRel-Defs.inc!" )
endif(IREL_CFG)
