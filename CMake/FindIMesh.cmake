# FindIMesh.cmake
#
# If you set the IMESH_CFG CMake variable to point to a file  names "iMesh-Defs.inc"
# (produced by MOAB as part of any build or install), then the script will locate
# iMesh assets for your package to use.
#
# This script defines the following CMake variables:
# IMESH_FOUND         defined with IMESH is located, false otherwise
# IMESH_LIBRARIES     paths to IMESH library and its dependencies
# IMESH_INCLUDE_DIRS  directories containing IMESH headers

find_file(IMESH_CFG iMesh-Defs.inc DOC "Path to iMesh-Defs.inc configuration file")
if(IMESH_CFG)
  set(IMESH_FOUND 1)
  file(READ ${IMESH_CFG} IMESH_CFG_DATA)
  ##
  ## Replace line continuations ('\' at EOL) so we don't have to parse them later
  ##
  string(REGEX REPLACE "\\\\\\\n" "" IMESH_CFG_DATA "${IMESH_CFG_DATA}")

  ##
  ## Find include directories
  ##
  string(REGEX MATCHALL "IMESH_INCLUDEDIR=[^\\\n]*" _IMESH_INCS "${IMESH_CFG_DATA}")
  foreach(_IMESH_INC ${_IMESH_INCS})

    # Only use include directories specified by the *last*
    # occurrence of IMESH_INCLUDEDIR in the config file:
    unset(IMESH_INCLUDE_DIRS)
    string(REGEX REPLACE "=" "=;" _IMESH_INC_LIST "${_IMESH_INC}")
    string(STRIP "${_IMESH_INC_LIST}" _IMESH_INC_LIST)
    foreach(_IMESH_INC_ITEM ${_IMESH_INC_LIST})
      if(NOT "${_IMESH_INC_ITEM}" MATCHES "=$")
        list(APPEND IMESH_INCLUDE_DIRS "${_IMESH_INC_ITEM}")
      endif()
    endforeach()
  endforeach()
  #message("IMESH_INCLUDE_DIRS: ${IMESH_INCLUDE_DIRS}")


  ##
  ## Find lib directories
  ##

  # All of this is to find the directory to look in for the libraries.
  # Find the paths after "-L"
  string(REGEX MATCHALL "IMESH_LDFLAGS = [^\\\n]*" _IMESH_LDIR "${IMESH_CFG_DATA}")
  string(REGEX REPLACE "IMESH_LDFLAGS = ([^\\\n]*)" "\\1" _IMESH_LDIR "${_IMESH_LDIR}")
  string(REGEX REPLACE " -L" ";-L" _IMESH_LDIR "${_IMESH_LDIR}")
  string(REGEX REPLACE " -l" ";-l" _IMESH_LDIR "${_IMESH_LDIR}")
  set(_IMESH_LDIRS)
  foreach(_IMESH_LL ${_IMESH_LDIR})
    if("${_IMESH_LL}" MATCHES "^-L.*")
      string(REGEX REPLACE "-L" "" _IMESH_LL "${_IMESH_LL}")
      string(STRIP "${_IMESH_LL}" _IMESH_LL)
      list(APPEND _IMESH_LDIRS "${_IMESH_LL}")
    endif()
  endforeach()
  set(IMESH_LIB_DIRS "${IMESH_LIB_DIRS};${_IMESH_LDIRS}")
  #message("IMESH_LIB_DIRS: ${IMESH_LIB_DIRS}")

  # Search for MOAB_LIBDIR in the imesh config
  string(REGEX MATCH "MOAB_LIBDIR=[^\\\n]*" _MOAB_LIBDIR "${IMESH_CFG_DATA}")
  string(REGEX REPLACE "=" "=;" _MOAB_LIBDIR "${_MOAB_LIBDIR}")
  foreach(_MOAB_LL ${_MOAB_LIBDIR})
    if(NOT "${_MOAB_LL}" MATCHES "=")
      list(APPEND IMESH_LIB_DIRS "${_MOAB_LL}")
    endif()
  endforeach()
  string(REGEX MATCH "IMESH_LIBDIR=[^\\\n]*" _IMESH_LIBDIR "${IMESH_CFG_DATA}")
  string(REGEX REPLACE "=" "=;" _IMESH_LIBDIR "${_IMESH_LIBDIR}")
  foreach(_IMESH_LL ${_IMESH_LIBDIR})
    if(NOT "{_IMESH_LL}" MATCHES "=")
      list(APPEND IMESH_LIB_DIRS "${_IMESH_LL}")
    endif()
  endforeach()
  #message("IMESH_LIB_DIRS: ${IMESH_LIB_DIRS}")

  ##
  ## Find the IMESH library and its dependencies
  ##
  # These spaces are important    [- -]
  string(REGEX MATCHALL "IMESH_LIBS = [^\\\n]*" _IMESH_LIBS "${IMESH_CFG_DATA}")
  string(REGEX MATCHALL "-l[^ \t\n]+" _IMESH_LIBS "${_IMESH_LIBS}")
  foreach(_IMESH_LIB ${_IMESH_LIBS})
    string(REGEX REPLACE "-l" "" _IMESH_LIB "${_IMESH_LIB}")
    find_library(_IMESH_LIB_LOC
      NAME "${_IMESH_LIB}"
      # Cannot quote since it contains semicolons:
      PATHS ${IMESH_LIB_DIRS}
      NO_DEFAULT_PATH
      NO_CMAKE_ENVIRONMENT_PATH
      NO_CMAKE_PATH
      NO_CMAKE_SYSTEM_PATH
    )
    if (_IMESH_LIB_LOC)
      list(APPEND IMESH_LIBRARIES "${_IMESH_LIB_LOC}")
      unset(_IMESH_LIB_LOC CACHE)
      unset(_IMESH_LIB_LOC)
    else()
      message("Could not find ${_IMESH_LIB} library (part of IMESH)")
      unset(IMESH_FOUND)
    endif()
  endforeach()

endif(IMESH_CFG)
