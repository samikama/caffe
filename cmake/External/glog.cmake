# glog depends on gflags
include("cmake/External/gflags.cmake")

if (NOT __GLOG_INCLUDED)
  set(__GLOG_INCLUDED TRUE)

  # try the system-wide glog first,
  # allow user to define a custom installed location
  # and check for glog-config.cmake
  find_package(glog QUIET HINTS ${glog_DIR})
  if(glog_FOUND)
    set(GLOG_FOUND TRUE)
  # else()
  #   find_package(Glog)
  #   set(glog_DIR "${GLOG_ROOT_DIR}")
  endif()
  if (GLOG_FOUND)
      set(GLOG_EXTERNAL FALSE)
  else()
    # fetch and build glog from github

    # build directory
    set(glog_PREFIX ${CMAKE_BINARY_DIR}/external/glog-prefix)
    # install directory
    set(glog_INSTALL ${CMAKE_BINARY_DIR}/external/glog-install)

    # we build glog statically, but want to link it into the caffe shared library
    # this requires position-independent code
    if (UNIX)
      set(GLOG_EXTRA_COMPILER_FLAGS "-fPIC")
    endif()

    set(GLOG_CXX_FLAGS ${CMAKE_CXX_FLAGS} ${GLOG_EXTRA_COMPILER_FLAGS})
    set(GLOG_C_FLAGS ${CMAKE_C_FLAGS} ${GLOG_EXTRA_COMPILER_FLAGS})

    # depend on gflags if we're also building it
    if (GFLAGS_EXTERNAL)
      set(GLOG_DEPENDS gflags)
    endif()

    ExternalProject_Add(glog
      DEPENDS ${GLOG_DEPENDS}
      #PREFIX ${glog_PREFIX}
      GIT_REPOSITORY "https://github.com/google/glog"
      GIT_TAG "v0.3.4"
      #UPDATE_COMMAND ""
      SOURCE_DIR "${glog_PREFIX}"
      BINARY_DIR "${CMAKE_BINARY_DIR}/external/glog-build"
      INSTALL_DIR "${glog_INSTALL}"
      #PATCH_COMMAND autoreconf -i ${glog_PREFIX}/src/glog
      #CONFIGURE_COMMAND env "CFLAGS=${GLOG_C_FLAGS}" "CXXFLAGS=${GLOG_CXX_FLAGS}" ${glog_PREFIX}/src/glog/configure --prefix=${glog_INSTALL} --enable-shared=no --enable-static=yes --with-gflags=${GFLAGS_LIBRARY_DIRS}/..
      CMAKE_CACHE_ARGS -DCMAKE_BUILD_TYPE:STRING=Release
                       -DCMAKE_POSITION_INDEPENDENT_CODE:BOOL=ON
                       -DCMAKE_VERBOSE_MAKEFILE:BOOL=OFF
      CMAKE_ARGS -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}
                 -DCMAKE_INSTALL_PREFIX=${glog_INSTALL}
                 -DBUILD_TESTING=OFF
		 -DCMAKE_POSITION_INDEPENDENT_CODE=ON
                 -DWITH_GFLAGS=ON
                 -DWITH_THREADS=ON
                 -Dgflags_DIR=${gflags_DIR}
                 -DINSTALL_HEADERS=ON
                 -DCMAKE_C_FLAGS=${CMAKE_C_FLAGS}
                 -DCMAKE_CXX_FLAGS=${CMAKE_CXX_FLAGS}
      LOG_DOWNLOAD 1
      #LOG_CONFIGURE 1
      LOG_INSTALL 1
      )

    set(GLOG_FOUND TRUE)
    set(GLOG_INCLUDE_DIRS ${glog_INSTALL}/include)
    set(GLOG_LIBRARIES ${GFLAGS_LIBRARIES} ${glog_INSTALL}/lib/libglog.a)
    set(GLOG_LIBRARY_DIRS ${glog_INSTALL}/lib)
    set(GLOG_EXTERNAL TRUE)
    set(glog_DIR ${glog_INSTALL})
    list(APPEND external_project_dependencies glog)
  endif()

endif()

