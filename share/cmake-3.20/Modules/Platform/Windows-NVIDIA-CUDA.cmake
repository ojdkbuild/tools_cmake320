include(Platform/Windows-MSVC)

set(CMAKE_CUDA_COMPILE_PTX_COMPILATION
  "<CMAKE_CUDA_COMPILER> ${_CMAKE_CUDA_EXTRA_FLAGS} <DEFINES> <INCLUDES> <FLAGS> ${_CMAKE_COMPILE_AS_CUDA_FLAG} -ptx <SOURCE> -o <OBJECT> -Xcompiler=-Fd<TARGET_COMPILE_PDB>,-FS")
set(CMAKE_CUDA_COMPILE_SEPARABLE_COMPILATION
  "<CMAKE_CUDA_COMPILER> ${_CMAKE_CUDA_EXTRA_FLAGS} <DEFINES> <INCLUDES> <FLAGS> ${_CMAKE_COMPILE_AS_CUDA_FLAG} -dc <SOURCE> -o <OBJECT> -Xcompiler=-Fd<TARGET_COMPILE_PDB>,-FS")
set(CMAKE_CUDA_COMPILE_WHOLE_COMPILATION
  "<CMAKE_CUDA_COMPILER> ${_CMAKE_CUDA_EXTRA_FLAGS} <DEFINES> <INCLUDES> <FLAGS> ${_CMAKE_COMPILE_AS_CUDA_FLAG} -c <SOURCE> -o <OBJECT> -Xcompiler=-Fd<TARGET_COMPILE_PDB>,-FS")

set(__IMPLICT_LINKS )
foreach(dir ${CMAKE_CUDA_HOST_IMPLICIT_LINK_DIRECTORIES})
  string(APPEND __IMPLICT_LINKS " -LIBPATH:\"${dir}\"")
endforeach()
foreach(lib ${CMAKE_CUDA_HOST_IMPLICIT_LINK_LIBRARIES})
  string(APPEND __IMPLICT_LINKS " \"${lib}\"")
endforeach()
set(CMAKE_CUDA_LINK_EXECUTABLE
   "<CMAKE_CUDA_HOST_LINK_LAUNCHER> <LINK_FLAGS> <OBJECTS> /out:<TARGET> /implib:<TARGET_IMPLIB> /pdb:<TARGET_PDB> /version:<TARGET_VERSION_MAJOR>.<TARGET_VERSION_MINOR> <LINK_LIBRARIES>${__IMPLICT_LINKS}")

set(_CMAKE_VS_LINK_DLL "<CMAKE_COMMAND> -E vs_link_dll --intdir=<OBJECT_DIR> --rc=<CMAKE_RC_COMPILER> --mt=<CMAKE_MT> --manifests <MANIFESTS> -- ")
set(_CMAKE_VS_LINK_EXE "<CMAKE_COMMAND> -E vs_link_exe --intdir=<OBJECT_DIR> --rc=<CMAKE_RC_COMPILER> --mt=<CMAKE_MT> --manifests <MANIFESTS> -- ")
set(CMAKE_CUDA_CREATE_SHARED_LIBRARY
  "${_CMAKE_VS_LINK_DLL}<CMAKE_LINKER> ${CMAKE_CL_NOLOGO} <OBJECTS> ${CMAKE_START_TEMP_FILE} /out:<TARGET> /implib:<TARGET_IMPLIB> /pdb:<TARGET_PDB> /dll /version:<TARGET_VERSION_MAJOR>.<TARGET_VERSION_MINOR>${_PLATFORM_LINK_FLAGS} <LINK_FLAGS> <LINK_LIBRARIES>${__IMPLICT_LINKS} ${CMAKE_END_TEMP_FILE}")

set(CMAKE_CUDA_CREATE_SHARED_MODULE ${CMAKE_CUDA_CREATE_SHARED_LIBRARY})
set(CMAKE_CUDA_CREATE_STATIC_LIBRARY  "<CMAKE_AR> ${CMAKE_CL_NOLOGO} <LINK_FLAGS> /out:<TARGET> <OBJECTS> ")
set(CMAKE_CUDA_LINKER_SUPPORTS_PDB ON)
set(CMAKE_CUDA_LINK_EXECUTABLE
  "${_CMAKE_VS_LINK_EXE}<CMAKE_LINKER> ${CMAKE_CL_NOLOGO} <OBJECTS> ${CMAKE_START_TEMP_FILE} /out:<TARGET> /implib:<TARGET_IMPLIB> /pdb:<TARGET_PDB> /version:<TARGET_VERSION_MAJOR>.<TARGET_VERSION_MINOR>${_PLATFORM_LINK_FLAGS} <LINK_FLAGS> <LINK_LIBRARIES>${__IMPLICT_LINKS} ${CMAKE_END_TEMP_FILE}")
unset(_CMAKE_VS_LINK_EXE)
unset(_CMAKE_VS_LINK_EXE)


# Add implicit host link directories that contain device libraries
# to the device link line.
set(__IMPLICT_DLINK_DIRS ${CMAKE_CUDA_IMPLICIT_LINK_DIRECTORIES})
if(__IMPLICT_DLINK_DIRS)
  list(REMOVE_ITEM __IMPLICT_DLINK_DIRS ${CMAKE_CUDA_HOST_IMPLICIT_LINK_DIRECTORIES})
endif()
set(__IMPLICT_DLINK_FLAGS )
foreach(dir ${__IMPLICT_DLINK_DIRS})
  if(EXISTS "${dir}/curand_static.lib")
    string(APPEND __IMPLICT_DLINK_FLAGS " -L\"${dir}\"")
  endif()
endforeach()
unset(__IMPLICT_DLINK_DIRS)

set(CMAKE_CUDA_DEVICE_LINK_LIBRARY
  "<CMAKE_CUDA_COMPILER> ${_CMAKE_CUDA_EXTRA_FLAGS} <LANGUAGE_COMPILE_FLAGS> <LINK_FLAGS> ${_CMAKE_CUDA_EXTRA_DEVICE_LINK_FLAGS} -shared -dlink <OBJECTS> -o <TARGET> <LINK_LIBRARIES> -Xcompiler=-Fd<TARGET_COMPILE_PDB>,-FS${__IMPLICT_DLINK_FLAGS}")
set(CMAKE_CUDA_DEVICE_LINK_EXECUTABLE
  "<CMAKE_CUDA_COMPILER> ${_CMAKE_CUDA_EXTRA_FLAGS} <LANGUAGE_COMPILE_FLAGS> <LINK_FLAGS> ${_CMAKE_CUDA_EXTRA_DEVICE_LINK_FLAGS} -shared -dlink <OBJECTS> -o <TARGET> <LINK_LIBRARIES> -Xcompiler=-Fd<TARGET_COMPILE_PDB>,-FS${__IMPLICT_DLINK_FLAGS}")
unset(__IMPLICT_DLINK_FLAGS)

string(REPLACE "/D" "-D" _PLATFORM_DEFINES_CUDA "${_PLATFORM_DEFINES}${_PLATFORM_DEFINES_CXX}")

if(CMAKE_MSVC_RUNTIME_LIBRARY_DEFAULT)
  set(_MDd "")
  set(_MD "")
else()
  set(_MDd "-MDd ")
  set(_MD "-MD ")
endif()

cmake_policy(GET CMP0092 _cmp0092)
if(_cmp0092 STREQUAL "NEW")
  set(_W3 "")
else()
  set(_W3 "/W3")
endif()
unset(_cmp0092)

set(CMAKE_CUDA_RUNTIME_LIBRARY_LINK_OPTIONS_STATIC  "cudadevrt;cudart_static")
set(CMAKE_CUDA_RUNTIME_LIBRARY_LINK_OPTIONS_SHARED  "cudadevrt;cudart")
set(CMAKE_CUDA_RUNTIME_LIBRARY_LINK_OPTIONS_NONE    "")

if(UNIX)
  list(APPEND CMAKE_CUDA_RUNTIME_LIBRARY_LINK_OPTIONS_STATIC "rt" "pthread" "dl")
endif()

string(APPEND CMAKE_CUDA_FLAGS_INIT " ${PLATFORM_DEFINES_CUDA} -D_WINDOWS -Xcompiler=\"${_W3}${_FLAGS_CXX}\"")
string(APPEND CMAKE_CUDA_FLAGS_DEBUG_INIT " -Xcompiler=\"${_MDd}-Zi -Ob0 -Od ${_RTC1}\"")
string(APPEND CMAKE_CUDA_FLAGS_RELEASE_INIT " -Xcompiler=\"${_MD}-O2 -Ob2\" -DNDEBUG")
string(APPEND CMAKE_CUDA_FLAGS_RELWITHDEBINFO_INIT " -Xcompiler=\"${_MD}-Zi -O2 -Ob1\" -DNDEBUG")
string(APPEND CMAKE_CUDA_FLAGS_MINSIZEREL_INIT " -Xcompiler=\"${_MD}-O1 -Ob1\" -DNDEBUG")
unset(_W3)
unset(_MDd)
unset(_MD)

set(CMAKE_CUDA_COMPILE_OPTIONS_MSVC_RUNTIME_LIBRARY_MultiThreaded         -Xcompiler=-MT)
set(CMAKE_CUDA_COMPILE_OPTIONS_MSVC_RUNTIME_LIBRARY_MultiThreadedDLL      -Xcompiler=-MD)
set(CMAKE_CUDA_COMPILE_OPTIONS_MSVC_RUNTIME_LIBRARY_MultiThreadedDebug    -Xcompiler=-MTd)
set(CMAKE_CUDA_COMPILE_OPTIONS_MSVC_RUNTIME_LIBRARY_MultiThreadedDebugDLL -Xcompiler=-MDd)

set(CMAKE_CUDA_STANDARD_LIBRARIES_INIT "${CMAKE_C_STANDARD_LIBRARIES_INIT}")

__windows_compiler_msvc_enable_rc("${_PLATFORM_DEFINES} ${_PLATFORM_DEFINES_CXX}")
