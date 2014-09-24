cmake_minimum_required(VERSION 2.8)


set(CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/CMake" ${CMAKE_MODULE_PATH})

option(ENABLE_IGEOM "Enable iGeom interface (CGM)" ON)
option(ENABLE_FBIGEOM "Enable FBiGeom" ON)
option(ENABLE_IMESH "ENable iMesh interface (MOAB)" ON)

if(ENABLE_IMESH)
  if(MOAB_DIR)
    # MOAB implements the iMesh interface
    # If we're using the cmake version, use the 
    # MOABConfig.cmake
    find_package(MOAB REQUIRED NO_MODULE)
    set(IMESH_INCLUDE_DIRS "${MOAB_INCLUDE_DIRS}")
    set(IMESH_LIBRARIES iMesh)
    set(IMESH_FOUND TRUE)
    if(MOAB_FOUND)
      add_definitions("-DHAVE_MOAB")
    endif()
  else()
   # If we aren't using the cmake version of MOAB,
   # pass in the CGM_CFG to moab.make and IMESH_CFG to
   # iMesh-Defs.inc
   find_package(MOAB REQUIRED)
   find_package(IMesh REQUIRED)
  endif(MOAB_DIR)
endif(ENABLE_IMESH)
if(ENABLE_IGEOM)
  find_package(CGM REQUIRED)
  find_package(IGeom REQUIRED)
endif(ENABLE_IGEOM)

set(iRel_SOURCES
  ArrayManager.hpp
  AssocPair.cpp
  AssocPair.hpp
  AssocPairSide.hpp
  iRel_Lasso.cpp
  iRel_Lasso.hpp
  Lasso.cpp
  Lasso.hpp
  )

set(iRel_HEADERS
  iRel.h
  iRel_f.h
  iRel_protos.h
  iRel_FCDefs.h
)

set(iRel_INCLUDES
  ${CMAKE_SOURCE_DIR}
  ${CMAKE_BINARY_DIR}
)
set(iRel_LINK_LIBS)

if(ENABLE_IGEOM)
  list(APPEND iRel_SOURCES
    GeomAssocPairSide.cpp
    GeomAssocPairSide.hpp )
  list(APPEND iRel_INCLUDES
    ${IGEOM_INCLUDE_DIRS} )
  list(APPEND iRel_LINK_LIBS
    ${IGEOM_LIBRARIES} )
endif(ENABLE_IGEOM)

if(ENABLE_IMESH)
  list(APPEND iRel_SOURCES
    MeshAssocPairSide.cpp
    MeshAssocPairSide.hpp )
  list(APPEND iRel_INCLUDES
    ${CGM_INCLUDE_DIRS}
    ${IMESH_INCLUDE_DIRS} )
  list(APPEND iRel_LINK_LIBS
    ${IMESH_LIBRARIES})
endif(ENABLE_IMESH)

include_directories(${iRel_INCLUDES})
add_library(iRel
  ${iRel_SOURCES}
  ${iRel_HEADERS}
)
target_link_libraries(iRel
  ${iRel_LINK_LIBS}
)

include(LassoTargets.cmake)
set(CMAKE_INSTALL_INCLUDE_DIR
  "${CMAKE_INSTALL_PREFIX}/include")
set(CMAKE_INSTALL_LIB_DIR
  "${CMAKE_INSTALL_PREFIX}/lib")
set(CMAKE_INSTALL_LIBS "iRel")

set(IREL_INCLUDEDIR "${CMAKE_INSTALL_PREFIX}/include")
set(IREL_LIBDIR "${CMAKE_INSTALL_PREFIX}/lib")
configure_file(
  ${CMAKE_SOURCE_DIR}/iRel-Defs.inc.in
  ${CMAKE_BINARY_DIR}/iRel-Defs.inc
  )

configure_file(
  ${CMAKE_SOURCE_DIR}/LassoConfig.cmake.in
  ${CMAKE_BINARY_DIR}/LassoConfig.cmake
  )

file(GLOB lasso_cpp_headers
  "${CMAKE_SOURCE_DIR}/*.hpp")
install(FILES ${lasso_cpp_headers}
              ${iRel_HEADERS}
  DESTINATION ${CMAKE_INSTALL_PREFIX}/include
  )
install(TARGETS iRel
  DESTINATION ${CMAKE_INSTALL_PREFIX}/lib
  )
install(FILES ${CMAKE_BINARY_DIR}/iRel-Defs.inc
  DESTINATION lib
  )
install(FILES ${CMAKE_BINARY_DIR}/LassoConfig.cmake
  DESTINATION include
  )
