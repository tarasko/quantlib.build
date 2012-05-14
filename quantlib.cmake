# Define variables for parent scope
set(QUANTLIB_INCLUDE_DIRS "${CMAKE_CURRENT_SOURCE_DIR}/QuantLib-1.2")
set(QUANTLIB_DEFINITIONS "-DQL_NO_AUTO_LINK")
# Available libraries
#	QuantLib (only on Unix)
#	QuantLib.s

# Copy patched auto_link.hpp
# This prevent auto-linking of Quanlib when compile for msvc
execute_process(COMMAND ${CMAKE_COMMAND} -E copy ${CMAKE_CURRENT_SOURCE_DIR}/auto_link.hpp ${CMAKE_CURRENT_SOURCE_DIR}/QuantLib-1.2/ql)

# Fix runtime error when compile with Intel + MSVC for debug
execute_process(COMMAND ${CMAKE_COMMAND} -E copy ${CMAKE_CURRENT_SOURCE_DIR}/qldefines.hpp ${CMAKE_CURRENT_SOURCE_DIR}/QuantLib-1.2/ql)

# Workaround for Intel bug related to /Ob1 flag 
execute_process(COMMAND ${CMAKE_COMMAND} -E copy ${CMAKE_CURRENT_SOURCE_DIR}/singleton.hpp ${CMAKE_CURRENT_SOURCE_DIR}/QuantLib-1.2/ql/patterns)

# Workaround for Intel bug related to interprocedural optimization
execute_process(COMMAND ${CMAKE_COMMAND} -E copy ${CMAKE_CURRENT_SOURCE_DIR}/timehomogeneousforwardcorrelation.cpp ${CMAKE_CURRENT_SOURCE_DIR}/QuantLib-1.2/ql/models/marketmodels/correlations)

include_directories(
	"${Boost_INCLUDE_DIRS}"
	"${QUANTLIB_INCLUDE_DIRS}"
)

# Evaluate all quantlib headers and sources
file(GLOB_RECURSE headers "${CMAKE_CURRENT_SOURCE_DIR}/QuantLib-1.2/ql/*.hpp" "${CMAKE_CURRENT_SOURCE_DIR}/QuantLib-1.2/ql/*.h")
file(GLOB_RECURSE sources "${CMAKE_CURRENT_SOURCE_DIR}/QuantLib-1.2/ql/*.cpp" "${CMAKE_CURRENT_SOURCE_DIR}/QuantLib-1.2/ql/*.c")

# Create fancy source groups for msvc
foreach(src ${sources} ${headers})
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

# Add examples
if(NOT SKIP_EXAMPLES)
	file(GLOB_RECURSE examples "${CMAKE_CURRENT_SOURCE_DIR}/QuantLib-1.2/Examples/*.cpp")
	foreach(example ${examples})
		string(REGEX REPLACE ".*/Examples/(.*)/.*" "QuantLib.examples.\\1" target "${example}")
		add_executable(${target} ${example})
		target_link_libraries(${target} QuantLib.s)
	endforeach(example)
endif(NOT SKIP_EXAMPLES)

