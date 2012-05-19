# Define variables for parent scope
set(QUANTLIB_INCLUDE_DIRS "${CMAKE_CURRENT_SOURCE_DIR}/QuantLib-1.2")
set(QUANTLIB_DEFINITIONS "-DQL_NO_AUTO_LINK")
# Available libraries
#	QuantLib (only on Unix)
#	QuantLib.s

# Patch QuantLib
# This prevent auto-linking of Quanlib when compile for msvc
# Fix runtime error when compile with Intel + MSVC for debug
# Workaround for Intel bug related to /Ob1 flag 
# Workaround for Intel bug related to interprocedural optimization
add_custom_command(OUTPUT quantlib.patched
	COMMAND ${CMAKE_COMMAND} ARGS -E copy ${CMAKE_CURRENT_SOURCE_DIR}/auto_link.hpp ${CMAKE_CURRENT_SOURCE_DIR}/QuantLib-1.2/ql
	COMMAND ${CMAKE_COMMAND} ARGS -E copy ${CMAKE_CURRENT_SOURCE_DIR}/qldefines.hpp ${CMAKE_CURRENT_SOURCE_DIR}/QuantLib-1.2/ql
	COMMAND ${CMAKE_COMMAND} ARGS -E copy ${CMAKE_CURRENT_SOURCE_DIR}/singleton.hpp ${CMAKE_CURRENT_SOURCE_DIR}/QuantLib-1.2/ql/patterns
	COMMAND ${CMAKE_COMMAND} ARGS -E copy ${CMAKE_CURRENT_SOURCE_DIR}/timehomogeneousforwardcorrelation.cpp ${CMAKE_CURRENT_SOURCE_DIR}/QuantLib-1.2/ql/models/marketmodels/correlations
	COMMAND ${CMAKE_COMMAND} ARGS -E touch quantlib.patched)

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
add_dependencies(QuantLib.s quantlib.patched)

if(NOT WIN32)
	# Quantlib doesn`t support dll
	add_library(QuantLib SHARED ${headers} ${sources})
	add_dependencies(QuantLib quantlib.patched)

	install(TARGETS QuantLib.s
		RUNTIME DESTINATION bin 
		LIBRARY DESTINATION lib 
		ARCHIVE DESTINATION lib
	)
	# TODO
	# install(DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/include DESTINATION .)	
endif(NOT WIN32)

# Add examples
if(QUANTLIB_ADD_EXAMPLES)
	file(GLOB_RECURSE examples "${CMAKE_CURRENT_SOURCE_DIR}/QuantLib-1.2/Examples/*.cpp")
	foreach(example ${examples})
		string(REGEX REPLACE ".*/Examples/(.*)/.*" "QuantLib.examples.\\1" target "${example}")
		add_executable(${target} ${example})
		target_link_libraries(${target} QuantLib.s)
	endforeach(example)
endif(QUANTLIB_ADD_EXAMPLES)

# Add tests
if(ADD_TESTS)
	file(GLOB test_sources "${CMAKE_CURRENT_SOURCE_DIR}/QuantLib-1.2/test-suite/*.cpp" "${CMAKE_CURRENT_SOURCE_DIR}/QuantLib-1.2/test-suite/*.hpp")
	list(REMOVE_ITEM test_sources "${CMAKE_CURRENT_SOURCE_DIR}/QuantLib-1.2/test-suite/quantlibbenchmark.cpp")
	list(REMOVE_ITEM test_sources "${CMAKE_CURRENT_SOURCE_DIR}/QuantLib-1.2/test-suite/quantlibtestsuite.cpp")
	add_library(QuantLib.unittestlib STATIC ${test_sources})
	add_executable(QuantLib.unittest "${CMAKE_CURRENT_SOURCE_DIR}/QuantLib-1.2/test-suite/quantlibtestsuite.cpp")
	add_executable(QuantLib.benchmarktest "${CMAKE_CURRENT_SOURCE_DIR}/QuantLib-1.2/test-suite/quantlibbenchmark.cpp")
	target_link_libraries(QuantLib.unittest QuantLib.unittestlib QuantLib.s ${Boost_LIBRARIES})
	target_link_libraries(QuantLib.benchmarktest QuantLib.unittestlib QuantLib.s ${Boost_LIBRARIES})
	set_target_properties(QuantLib.unittest QuantLib.benchmarktest PROPERTIES COMPILE_DEFINITIONS "QL_LIB_NAME=\"QuantLib\"")
endif(ADD_TESTS)
