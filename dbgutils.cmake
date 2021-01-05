include_guard()
# Get all propreties that cmake supports
execute_process(COMMAND cmake --help-property-list OUTPUT_VARIABLE CMAKE_PROPERTY_LIST)

# Convert command output into a CMake list
STRING(REGEX REPLACE ";" "\\\\;" CMAKE_PROPERTY_LIST "${CMAKE_PROPERTY_LIST}")
STRING(REGEX REPLACE "\n" ";" CMAKE_PROPERTY_LIST "${CMAKE_PROPERTY_LIST}")

function(print_cmake_properties)
    message ("CMAKE_PROPERTY_LIST = ${CMAKE_PROPERTY_LIST}")
endfunction(print_cmake_properties)

# print properties
#   print_properties(GLOBAL | TARGET <name> | DIRECTORY <name> | SOURCE <name> | TEST <name>)
#
function(print_properties ...)
    foreach (prop ${CMAKE_PROPERTY_LIST})
        string(REPLACE "<CONFIG>" "${CMAKE_BUILD_TYPE}" prop ${prop})
        # Fix https://stackoverflow.com/questions/32197663/how-can-i-remove-the-the-location-property-may-not-be-read-from-target-error-i
        if(prop STREQUAL "LOCATION" OR prop MATCHES "^LOCATION_" OR prop MATCHES "_LOCATION$")
            continue()
        endif()
        # message ("Checking ${prop}")
        get_property(propisset ${ARGV0} ${ARGV1} PROPERTY ${prop} SET)
        if (propisset)
            if("${ARGV0}" STREQUAL "GLOBAL")
                get_cmake_property(propval ${prop})
            elseif("${ARGV0}" STREQUAL "TARGET")
                get_target_property(propval ${ARGV1} ${prop})
            elseif("${ARGV0}" STREQUAL "DIRECTORY")
                get_directory_property(propval DIRECTORY ${ARGV1} ${prop})
            elseif("${ARGV0}" STREQUAL "SOURCE")
                get_source_file_property(propval ${ARGV1} ${prop})
            elseif("${ARGV0}" STREQUAL "TEST")
                get_test_property(propval ${ARGV1} ${prop})
            else()
                message("Unknown property scope")
            endif()
            message ("${ARGV1} ${prop} = ${propval}")
        endif()
    endforeach(prop)
endfunction()

# print all buildsystem target under <dir>
function(print_all_targets dir)
    # depth first
    get_directory_property(subdirs DIRECTORY ${dir} SUBDIRECTORIES)
    foreach(subdir ${subdirs})
        print_all_targets(${subdir})
    endforeach()
    # then print targets for this directory
    get_directory_property(targets DIRECTORY ${dir} BUILDSYSTEM_TARGETS)
    if(NOT "${targets}" STREQUAL "")
        message("---- Targets in ${dir} ----")
        foreach(tgt ${targets})
            message(" ${tgt}")
        endforeach(tgt ${targets})
    endif()
endfunction()
