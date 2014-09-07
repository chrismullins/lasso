# FindMOAB.cmake
# Adapted from David Thompson's FindCGM.cmake
#
# If you set the MOAB_CFG CMake variable to point to a file named "moab.make"
# (produced by MOAB as part of any build or install), then the script will
# locate MOAB assets for your package to use.
#
# This script defines the following CMake variables:
#   MOAB_FOUND           defined when MOAB is located, false otherwise
#   MOAB_INCLUDE_DIRS    directories containing MOAB headers
#   MOAB_DEFINES         preprocessor definitions you should add to source files
#   MOAB_LIBRARIES       paths to MOAB library and its dependencies
#   MOAB_HAVE_VERSION_H  true when the "moab_version.h" header exists (v14.0 or later).
#
# Note that this script does not produce MOAB_VERSION as that information
# is not available in the "moab.make" configuration file that MOAB creates.

find_file(MOAB_CFG moab.make DOC "Path to moab.make configuration file")
if(MOAB_CFG)
  set(MOAB_FOUND 1)
  add_definitions(-DHAVE_MOAB=TRUE)
  file(READ "${MOAB_CFG}" MOAB_CFG_DATA)
  ##
  ## Replace line continuations ('\' at EOL) so we don't have to parse them later
  ##
  string(REGEX REPLACE "\\\\\\\n" "" MOAB_CFG_DATA "${MOAB_CFG_DATA}")

  ##
  ## Find include directories
  ##
  string(REGEX MATCHALL "MOAB_INCLUDES=[^\\\n]*" _MOAB_INCS "${MOAB_CFG_DATA}")
  foreach(_MOAB_INC ${_MOAB_INCS})
    # Only use include directories specified by the *last*
    # occurrence of MOAB_INT_INCLUDE in the config file:
    unset(MOAB_INCLUDE_DIRS)

    string(REGEX REPLACE "-I" ";-I" _MOAB_INC "${_MOAB_INC}")
    foreach(_MOAB_IDIR ${_MOAB_INC})
      if ("${_MOAB_IDIR}" MATCHES "^-I.*")
        string(REGEX REPLACE "-I" "" _MOAB_IDIR "${_MOAB_IDIR}")
        string(STRIP "${_MOAB_IDIR}" _MOAB_IDIR)
        list(APPEND MOAB_INCLUDE_DIRS "${_MOAB_IDIR}")
      endif()
    endforeach()
    # Alternately, one might:
    #list(APPEND MOAB_INCLUDE_DIRS "${_MOAB_INC}")
  endforeach()
  #message("MOAB_INCLUDE_DIRS=\"${MOAB_INCLUDE_DIRS}\"")

  ##
  ## Find preprocessor definitions
  ##
  #string(REGEX MATCH "MOAB_DEFINES =[^\\\n]*" MOAB_DEFINES "${MOAB_CFG_DATA}")
  #string(REGEX REPLACE "MOAB_DEFINES = ([^\\\n]*)" "\\1" MOAB_DEFINES "${MOAB_DEFINES}")

  ##
  ## Find MOAB library directory(-ies)
  ##
  #string(REGEX MATCHALL "MOAB_INT_LDFLAGS =[^\\\n]*" _MOAB_LDIRS "${MOAB_CFG_DATA}")
  #foreach(_MOAB_LDIR ${_MOAB_LDIRS})
  #  set(MOAB_LIB_DIRS)
  #  string(REGEX REPLACE " -L" ";-L" _MOAB_LDIR "${_MOAB_LDIR}")
  #  string(REGEX REPLACE "MOAB_INT_LDFLAGS = ([^\\\n]*)" "\\1" _MOAB_LDIR "${_MOAB_LDIR}")
  #  foreach(_MOAB_LL ${_MOAB_LDIR})
  #    if("${_MOAB_LL}" MATCHES "^-L.*")
  #      string(REGEX REPLACE "-L" "" _MOAB_LL "${_MOAB_LL}")
  #      string(STRIP "${_MOAB_LL}" _MOAB_LL)
  #      list(APPEND MOAB_LIB_DIRS "${_MOAB_LL}")
  #    endif()
  #  endforeach()
  #endforeach()

  ##
  ## Now add dependent library directories to MOAB_LIB_DIRS
  ##
  string(REGEX MATCH "MOAB_LDFLAGS =[^\\\n]*" _MOAB_LDIR "${MOAB_CFG_DATA}")
  string(REGEX REPLACE "MOAB_LDFLAGS = ([^\\\n]*)" "\\1" _MOAB_LDIR "${_MOAB_LDIR}")
  string(REGEX REPLACE " -L" ";-L" _MOAB_LDIR "${_MOAB_LDIR}")
  string(REGEX REPLACE " -l" ";-l" _MOAB_LDIR "${_MOAB_LDIR}")
  set(_MOAB_LDIRS)
  foreach(_MOAB_LL ${_MOAB_LDIR})
    if("${_MOAB_LL}" MATCHES "^-L.*")
      string(REGEX REPLACE "-L" "" _MOAB_LL "${_MOAB_LL}")
      string(STRIP "${_MOAB_LL}" _MOAB_LL)
      list(APPEND _MOAB_LDIRS "${_MOAB_LL}")
    endif()
  endforeach()
  set(MOAB_LIB_DIRS "${MOAB_LIB_DIRS};${_MOAB_LDIRS}")
  #message("MOAB_LIB_DIRS: ${MOAB_LIB_DIRS}")

  string(REGEX MATCH "MOAB_LIBDIR=[^\\\n]*" _MOAB_LIBDIR "${MOAB_CFG_DATA}")
  string(REGEX REPLACE "=" "=;" _MOAB_LIBDIR "${_MOAB_LIBDIR}")
  foreach(_MOAB_LL ${_MOAB_LIBDIR})
    if(NOT "${_MOAB_LL}" MATCHES "=")
      list(APPEND MOAB_LIB_DIRS "${_MOAB_LL}")
    endif()
  endforeach()

  ##
  ## Find the MOAB library and its dependencies
  ##
  string(REGEX MATCHALL "MOAB_LIBS_LINK =[^\\\n]*" _MOAB_LIBS "${MOAB_CFG_DATA}")
  string(REGEX MATCHALL "-l[^ \t\n]+" _MOAB_LIBS "${_MOAB_LIBS}")
  foreach(_MOAB_LIB ${_MOAB_LIBS})
    string(REGEX REPLACE "-l" "" _MOAB_LIB "${_MOAB_LIB}")
    find_library(_MOAB_LIB_LOC
      NAME "${_MOAB_LIB}"
      # Cannot quote since it contains semicolons:
      PATHS ${MOAB_LIB_DIRS}
      NO_DEFAULT_PATH
      NO_CMAKE_ENVIRONMENT_PATH
      NO_CMAKE_PATH
      NO_SYSTEM_ENVIRONMENT_PATH
      NO_CMAKE_SYSTEM_PATH
      )
    #message("Lib \"${_MOAB_LIB}\" @ \"${_MOAB_LIB_LOC}\" paths \"${MOAB_LIB_DIRS}\"")
    if (_MOAB_LIB_LOC)
      list(APPEND MOAB_LIBRARIES "${_MOAB_LIB_LOC}")
      unset(_MOAB_LIB_LOC CACHE)
      unset(_MOAB_LIB_LOC)
    else()
      message("Could not find ${_MOAB_LIB} library (part of MOAB)")
      unset(MOAB_FOUND)
    endif()
  endforeach()
  #message("Libs ${MOAB_LIBRARIES}")

  # Look for dagmc
  find_library(_DAGMC_LIB_LOC
    NAME "dagmc"
    PATHS ${MOAB_LIB_DIRS}
    NO_DEFAULT_PATH
      NO_CMAKE_ENVIRONMENT_PATH
      NO_CMAKE_PATH
      NO_SYSTEM_ENVIRONMENT_PATH
      NO_CMAKE_SYSTEM_PATH
      )
  if(_DAGMC_LIB_LOC)
    message("MOAB build with dagmc")
    set(HAVE_DAGMC_MOAB 1)
    list(APPEND MOAB_LIBRARIES ${_DAGMC_LIB_LOC} )
  else()
    message("MOAB built without dagmc")
  endif(_DAGMC_LIB_LOC)


  # Now detect the MOAB version (or at least whether it is v14+).
  #
  # This is not as simple as it should be. MOAB v14.0 and later
  # provide macros in moab_version.h while earlier versions provide
  # "const int GeometryQueryTool::MOAB_MAJOR_VERSION" which may
  # only be queried at run time, not compile time. We want to avoid
  # TRY_RUN since we may be cross-compiling.

  # Verify the file exists every time CMake is run, not just
  # the first time.
  if (MOAB_VERSION_H AND NOT EXISTS "${MOAB_VERSION_H}")
    unset(MOAB_VERSION_H CACHE)
  endif()
  find_file(MOAB_VERSION_H
    NAMES MBVersion.h
    PATHS ${MOAB_INCLUDE_DIRS}
    DOC "Path to MBVersion.h if it exists"
    NO_DEFAULT_PATH
  )
  if (EXISTS "${MOAB_VERSION_H}")
    set(MOAB_HAVE_VERSION_H 1)
  else()
    unset(MOAB_HAVE_VERSION_H)
  endif()

  ##
  ## Kill temporary variables
  ##
  unset(_MOAB_INCS)
  unset(_MOAB_INC)
  unset(_MOAB_IDIR)
  unset(_MOAB_LDIRS)
  unset(_MOAB_LDIR)
  unset(_MOAB_LL)
  unset(_MOAB_LIBS)
  unset(_MOAB_LIB)
  unset(_MOAB_LIB_LOC)
else()
  unset(MOAB_FOUND)
endif()

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(MOAB
  REQUIRED_VARS MOAB_INCLUDE_DIRS MOAB_LIBRARIES
  VERSION_VAR MOAB_VERSION
)
