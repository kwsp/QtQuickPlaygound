if(NOT CONFIG STREQUAL "Release")
  message(STATUS "Skipping macdeployqt for ${CONFIG} build")
  return()
endif()

execute_process(
  COMMAND "${MACDEPLOYQT}" "${BUNDLE_DIR}"
    -qmldir=${QMLDIR}
    -verbose=1
    -always-overwrite
    -codesign=-
    -no-strip
    -dmg
  COMMAND_ERROR_IS_FATAL ANY
)
