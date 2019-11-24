if(NOT OpenCV_FOUND)
  return()
endif()

# Add more configurations support for OpenCV.
set(link_only_libraries)
foreach(m ${OpenCV_LIBRARIES})
  get_target_property(imported_implib ${m} IMPORTED_IMPLIB_RELEASE)
  get_target_property(imported_location ${m} IMPORTED_LOCATION_RELEASE)
  #message("${imported_implib}")
  #message("${imported_location}")
  foreach(cfg RELWITHDEBINFO MINSIZEREL)
    set_property(TARGET ${m} APPEND PROPERTY IMPORTED_CONFIGURATIONS ${cfg})
    set_target_properties(${m} PROPERTIES
      INTERFACE_INCLUDE_DIRECTORIES "${OpenCV_INCLUDE_DIRS}"
      IMPORTED_IMPLIB_${cfg} ${imported_implib}
      IMPORTED_LOCATION_${cfg} ${imported_location}
      )
  endforeach(cfg)
  get_target_property(INTERFACE_LINK_LIBRARIES ${m} INTERFACE_LINK_LIBRARIES)
  string(REGEX MATCHALL "\\$<LINK_ONLY:([^ ]+)>" INTERFACE_LINK_LIBRARIES ${INTERFACE_LINK_LIBRARIES})
  if(NOT INTERFACE_LINK_LIBRARIES)
    continue()
  endif()
  string(REPLACE "$<LINK_ONLY:" "" INTERFACE_LINK_LIBRARIES ${INTERFACE_LINK_LIBRARIES})
  string(REPLACE ">" ";" INTERFACE_LINK_LIBRARIES ${INTERFACE_LINK_LIBRARIES})
  list(APPEND link_only_libraries ${INTERFACE_LINK_LIBRARIES})
endforeach(m)
if(link_only_libraries)
  list(REMOVE_DUPLICATES link_only_libraries)
endif()
foreach(m ${link_only_libraries})
  if(NOT TARGET ${m})
    continue()
  endif()
  get_target_property(imported_location ${m} IMPORTED_LOCATION_RELEASE)
  if(NOT imported_location)
    continue()
  endif()
  foreach(cfg RELWITHDEBINFO MINSIZEREL)
    set_property(TARGET ${m} APPEND PROPERTY IMPORTED_CONFIGURATIONS ${cfg})
    set_target_properties(${m} PROPERTIES
      IMPORTED_LOCATION_${cfg} ${imported_location}
      )
  endforeach(cfg)
endforeach(m)
unset(imported_implib)
unset(imported_location)
unset(INTERFACE_LINK_LIBRARIES)
unset(link_only_libraries)
