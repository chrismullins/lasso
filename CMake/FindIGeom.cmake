# FindIGeom.cmake
#
# If you set the IGEOM_CFG CMake variable to point to a file  names "iGeom-Defs.inc"
# (produced by CGM as part of any build or install), then the script will locate
# iGeom assets for your package to use.
#
# This script defines the following CMake variables:
# IGEOM_FOUND         defined with iGeom is located, false otherwise
# IGEOM_LIBRARIES     paths to iGeom library and its dependencies
# IGEOM_INCLUDE_DIRS  directories containing iGeom headers

find_file(IGEOM_CFG iGeom-Defs.inc DOC "Path to iGeom-Defs.inc configuration file")
if(IGEOM_CFG)
  set(IGEOM_FOUND 1)
  file(READ ${IGEOM_CFG} IGEOM_CFG_DATA)
  ##
  ## Replace line continuations ('\' at EOL) so we don't have to parse them later
  ##
  string(REGEX REPLACE "\\\\\\\n" "" IGEOM_CFG_DATA "${IGEOM_CFG_DATA}")

  ##
  ## Find include directories
  ##
  string(REGEX MATCHALL "IGEOM_INCLUDEDIR =[^\\\n]*" _IGEOM_INCS "${IGEOM_CFG_DATA}")
  foreach(_IGEOM_INC ${_IGEOM_INCS})

    # Only use include directories specified by the *last*
    # occurrence of IGEOM_INCLUDEDIR in the config file:
    unset(IGEOM_INCLUDE_DIRS)
    string(REGEX REPLACE "=" "=;" _IGEOM_INC_LIST "${_IGEOM_INC}")
    string(STRIP "${_IGEOM_INC_LIST}" _IGEOM_INC_LIST)
    foreach(_IGEOM_INC_ITEM ${_IGEOM_INC_LIST})
      if(NOT "${_IGEOM_INC_ITEM}" MATCHES "=$")
        string(STRIP "${_IGEOM_INC_ITEM}" _IGEOM_INC_ITEM)
        list(APPEND IGEOM_INCLUDE_DIRS "${_IGEOM_INC_ITEM}")
      endif()
    endforeach()
  endforeach()
  #message("IGEOM_INCLUDE_DIRS: ${IGEOM_INCLUDE_DIRS}")


  ##
  ## Find lib directories
  ##

  # All of this is to find the directory to look in for the libraries.
  # Find the paths after "-L" in IGEOM_LDFLAGS
  string(REGEX MATCHALL "IGEOM_LDFLAGS = [^\\\n]*" _IGEOM_LDIR "${IGEOM_CFG_DATA}")
  string(REGEX REPLACE "IGEOM_LDFLAGS = ([^\\\n]*)" "\\1" _IGEOM_LDIR "${_IGEOM_LDIR}")
  string(REGEX REPLACE " -L" ";-L" _IGEOM_LDIR "${_IGEOM_LDIR}")
  set(_IGEOM_LDIRS)
  foreach(_IGEOM_LL ${_IGEOM_LDIR})
    unset(IGEOM_LIB_DIRS)
    if("${_IGEOM_LL}" MATCHES "^-L.*")
      string(REGEX REPLACE "-L" "" _IGEOM_LL "${_IGEOM_LL}")
      string(STRIP "${_IGEOM_LL}" _IGEOM_LL)
      list(APPEND _IGEOM_LDIRS "${_IGEOM_LL}")
    endif()
  endforeach()
  set(IGEOM_LIB_DIRS "${IGEOM_LIB_DIRS};${_IGEOM_LDIRS}")
  #message("IGEOM_LIB_DIRS: ${IGEOM_LIB_DIRS}")

  # Do the same thing for IGEOM_CXX_LDFLAGS
  # Only works for one directory in the last instance of IGEOM_CXX_LDFLAGS
  unset(_IGEOM_LDIRS)
  string(REGEX MATCHALL "IGEOM_CXX_LDFLAGS = [^\\\n]*" _IGEOM_LDIR "${IGEOM_CFG_DATA}")
  string(REGEX REPLACE "IGEOM_CXX_LDFLAGS = ([^\\\n]*)" "\\1" _IGEOM_LDIR "${_IGEOM_LDIR}")
  string(REGEX REPLACE " -L" ";-L" _IGEOM_LDIR "${_IGEOM_LDIR}")
  set(_IGEOM_LDIRS)
  foreach(_IGEOM_LL ${_IGEOM_LDIR})
    unset(IGEOM_CXX_LIB_DIR)
    if("${_IGEOM_LL}" MATCHES "^-L.")
      string(REGEX REPLACE "-L" "" _IGEOM_LL "${_IGEOM_LL}")
      string(STRIP "${_IGEOM_LL}" _IGEOM_LL)
      set(IGEOM_CXX_LIB_DIR "${_IGEOM_LL}")
    endif()
  endforeach()
  list(APPEND IGEOM_LIB_DIRS "${IGEOM_CXX_LIB_DIR}")
  #message("IGEOM_LIB_DIRS: ${IGEOM_LIB_DIRS}")


  ##
  ## Find the iGeom library and its dependencies
  ##
  # These spaces are important    [---- -]
  string(REGEX MATCHALL "IGEOM_LIBS    = [^\\\n]*" _IGEOM_LIBS "${IGEOM_CFG_DATA}")
  string(REGEX MATCHALL "-l[^ \t\n]+" _IGEOM_LIBS "${_IGEOM_LIBS}")
  foreach(_IGEOM_LIB ${_IGEOM_LIBS})
    string(REGEX REPLACE "-l" "" _IGEOM_LIB "${_IGEOM_LIB}")
    find_library(_IGEOM_LIB_LOC
      NAME "${_IGEOM_LIB}"
      # Cannot quote since it contains semicolons:
      PATHS ${IGEOM_LIB_DIRS}
      NO_DEFAULT_PATH
      NO_CMAKE_ENVIRONMENT_PATH
      NO_CMAKE_PATH
      NO_CMAKE_SYSTEM_PATH
    )
    if (_IGEOM_LIB_LOC)
      list(APPEND IGEOM_LIBRARIES "${_IGEOM_LIB_LOC}")
      unset(_IGEOM_LIB_LOC CACHE)
      unset(_IGEOM_LIB_LOC)
    else()
      message("Could not find ${_IGEOM_LIB} library (part of iGeom)")
      unset(IGEOM_FOUND)
    endif()
  endforeach()

endif(IGEOM_CFG)
