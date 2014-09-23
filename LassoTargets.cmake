set(CXXFLAGS "-Wall -pipe -pedantic -Wno-long-long -O2 -DNDEBUG")
set(CFLAGS   "-Wall -pipe -pedantic -Wno-long-long -O2 -DNDEBUG")





set(DEFS "-DHAVE_CONFIG_H")

#if this doesn't work, try the source dir
set(IREL_INCLUDE_DIRS "${CMAKE_INSTALL_PREFIX}/include")

set(IREL_LIB_DIR "${CMAKE_INSTALL_PREFIX}/lib")

set(IREL_LIBS "-L${IREL_LIB_DIR} -liRel -lm")

