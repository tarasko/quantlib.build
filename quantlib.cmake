# Copy patched auto_link.hpp
# This prevent auto-linking of Quanlib when compile for msvc
execute_process(COMMAND ${CMAKE_COMMAND} -E copy ${CMAKE_CURRENT_SOURCE_DIR}/auto_link.hpp ${CMAKE_CURRENT_SOURCE_DIR}/QuantLib-1.2/ql)

file(GLOB_RECURSE headers "${CMAKE_CURRENT_SOURCE_DIR}/QuantLib-1.2/ql/*.hpp" "${CMAKE_CURRENT_SOURCE_DIR}/QuantLib-1.2/ql/*.h")
file(GLOB_RECURSE sources "${CMAKE_CURRENT_SOURCE_DIR}/QuantLib-1.2/ql/*.cpp" "${CMAKE_CURRENT_SOURCE_DIR}/QuantLib-1.2/ql/*.c")

include_directories(
	"${Boost_INCLUDE_DIRS}"
	"${CMAKE_CURRENT_SOURCE_DIR}/QuantLib-1.2"
)

foreach(src ${sources} ${headers})
	# Evaluate source group
	string(REGEX REPLACE "${CMAKE_CURRENT_SOURCE_DIR}/QuantLib-1.2/(.*)/.*" "\\1" dir ${src})
	source_group(${dir} FILES ${src})
endforeach(src ${sources} ${headers})

add_definitions(-D_SCL_SECURE_NO_WARNINGS)

add_library(QuantLib.s STATIC ${headers} ${sources})

if(NOT WIN32)
	# Quantlib doesn`t support dll
	add_library(QuantLib SHARED ${headers} ${sources})

	install(TARGETS QuantLib.s
		RUNTIME DESTINATION bin 
		LIBRARY DESTINATION lib 
		ARCHIVE DESTINATION lib
	)
	# TODO
	# install(DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/include DESTINATION .)	
endif(NOT WIN32)
