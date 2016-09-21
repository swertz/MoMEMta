
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Wno-unused-variable -std=c++11 -O3 -fcx-fortran-rules -fcx-limited-range -fPIC")
set(CMAKE_Fortran_FLAGS "${CMAKE_Fortran_FLAGS} -fno-underscoring -fPIC")

file(GLOB_RECURSE SOURCES "*.cc" "*.f")

add_library(me_pp_hh_bbbb OBJECT ${SOURCES})

include_directories("include")
include_directories("SubProcesses/P1_Sigma_SMEFT_FF_2_gg_bbxbbx/")
