find_package (Java REQUIRED)
find_package (JNI REQUIRED)

find_program (JNI_JAVAH
	NAMES javah
	HINTS ${_JAVA_HINTS}
	PATHS ${_JAVA_PATHS}
)

include_directories(${QUANTLIB_INCLUDE_DIRS} ${JNI_INCLUDE_DIRS})
add_library(QuantLibJNI SHARED "${CMAKE_CURRENT_SOURCE_DIR}/QuantLib-SWIG-1.2/Java/quantlib_wrap.cpp")
target_link_libraries(QuantLibJNI QuantLib.s)

if(MSVC)
	set_target_properties(QuantLibJNI PROPERTIES COMPILE_FLAGS "/bigobj")
endif(MSVC)

if(WIN32 AND NOT MSVC)
	set_target_properties(QuantLibJNI PROPERTIES LINK_FLAGS "-Wl,--kill-at")
endif(WIN32 AND NOT MSVC)

file(GLOB java_sources "${CMAKE_CURRENT_SOURCE_DIR}/QuantLib-SWIG-1.2/Java/org/quantlib/*.java")

add_custom_command(
	OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/java.compiled
	COMMAND ${JAVA_COMPILE} ARGS
		-classpath ${CMAKE_CURRENT_BINARY_DIR}
		-sourcepath ${CMAKE_CURRENT_SOURCE_DIR}/QuantLib-SWIG-1.2/Java
		-d ${CMAKE_CURRENT_BINARY_DIR}
		"${CMAKE_CURRENT_SOURCE_DIR}/QuantLib-SWIG-1.2/Java/org/quantlib/*.java"
	COMMAND ${CMAKE_COMMAND} -E touch ${CMAKE_CURRENT_BINARY_DIR}/java.compiled
	DEPENDS ${java_sources}
	WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/QuantLib-SWIG-1.2/Java/org/quantlib"
)

add_custom_target(
	JQuantLib ALL ${JAVA_ARCHIVE} cf JQuantLib.jar org
	DEPENDS ${CMAKE_CURRENT_BINARY_DIR}/java.compiled
)

install(TARGETS QuantLibJNI RUNTIME DESTINATION bin LIBRARY DESTINATION lib)
install (FILES ${CMAKE_CURRENT_BINARY_DIR}/JQuantLib.jar DESTINATION bin)
