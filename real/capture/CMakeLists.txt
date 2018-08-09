# CMake version requirement
cmake_minimum_required(VERSION 2.8)

project(Capture)

if(MSVC)
	add_definitions(-DUNICODE -D_UNICODE)
	add_definitions ("-DBOOST_ALL_NO_LIB -D_SCL_SECURE_NO_WARNINGS -D_CRT_SECURE_NO_WARNINGS -DNOMINMAX")
	SET(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} /bigobj /EHsc /fp:fast /wd4800 /wd4521 /wd4251 /wd4275 /wd4305 /wd4355 /wd4819 /wd4250 /wd4267")
	# comment following 3 lines to disable global code optimization to speed up compile
	#SET(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE} /GL /wd4800")
	#SET(CMAKE_SHARED_LINKER_FLAGS_RELEASE "${CMAKE_SHARED_LINKER_FLAGS_RELEASE} /LTCG")
	#SET(CMAKE_EXE_LINKER_FLAGS_RELEASE "${CMAKE_EXE_LINKER_FLAGS_RELEASE} /LTCG")
	
	# /MANIFEST:NO") # please, don't disable manifest generation, otherwise crash at start for vs2008
	if(MSVC90 OR MSVC10 OR MSVC11 AND NOT ${CMAKE_MAJOR_VERSION}.${CMAKE_MINOR_VERSION} LESS 2.8 AND NOT ${CMAKE_MINOR_VERSION}.${CMAKE_PATCH_VERSION} LESS 8.6)
		include(ProcessorCount)
		ProcessorCount(N)
		if(NOT N EQUAL 0)
			SET(CMAKE_C_FLAGS   "${CMAKE_C_FLAGS}   /MP${N} ")
			SET(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} /MP${N} ")
		endif()
	endif()
endif()

# ----------------------------------------------------------------------------------------------------

set(ptgrey_api_path "C:/Program Files/Point Grey Research/FlyCapture2")
include_directories(${ptgrey_api_path}/include)
link_directories(${ptgrey_api_path}/lib64/vs2015)

find_package(OpenCV REQUIRED)

find_package(Boost 1.63 COMPONENTS filesystem system REQUIRED)
include_directories(${Boost_INCLUDE_DIR})
link_directories(${Boost_INCLUDE_DIR}/stage/lib)

add_definitions("/W3 /D_CRT_SECURE_NO_WARNINGS /wd4005 /wd4018 /wd4244 /wd4267 /wd4305 /wd4312 /wd4819 /wd4838 /wd4996 /nologo" )

# ----------------------------------------------------------------------------------------------------

file(GLOB cap_incs		"*.h")
file(GLOB cap_srcs		"*.cpp")

# --------------------------------------------------

source_group("include" FILES ${cap_incs})
source_group("sources" FILES ${cap_srcs})
add_executable(capture ${cap_incs} ${cap_srcs})

target_link_libraries(capture
	${OpenCV_LIBS}
	${Boost_LIBRARIES}
	debug FlyCapture2d_v140 optimized FlyCapture2_v140
)