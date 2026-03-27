find_package(Qt6 REQUIRED COMPONENTS Core Gui Qml Quick)
qt_standard_project_setup(REQUIRES 6.5)

qt_add_executable(${PROJECT_NAME}
  main.cpp
)
qt_add_qml_module(${PROJECT_NAME}
  URI ${PROJECT_NAME}
  VERSION ${CMAKE_PROJECT_VERSION}
  QML_FILES
    Main.qml
)
target_compile_definitions(${PROJECT_NAME} PRIVATE
  "$<$<OR:$<CONFIG:Debug>,$<CONFIG:RelWithDebInfo>>:QT_QML_DEBUG>"
)

configure_file(config.h.in config.h)
target_include_directories(${PROJECT_NAME} PRIVATE ${CMAKE_CURRENT_BINARY_DIR})

target_link_libraries(${PROJECT_NAME} PRIVATE
  Qt6::Core
  Qt6::Gui
  Qt6::Qml
  Qt6::Quick
)

# Generate .qmlls.ini
find_program(_qmake NAMES qmake6 qmake HINTS "${Qt6_DIR}/../../../bin")
if(_qmake)
  execute_process(
    COMMAND "${_qmake}" -query QT_INSTALL_QML
    OUTPUT_VARIABLE _qt_qml_dir
    OUTPUT_STRIP_TRAILING_WHITESPACE
  )
  file(RELATIVE_PATH _qmlls_build_dir "${CMAKE_SOURCE_DIR}" "${CMAKE_BINARY_DIR}")
  file(WRITE "${CMAKE_SOURCE_DIR}/.qmlls.ini"
    "[General]\nbuildDir=${_qmlls_build_dir}\nimportPaths=${_qt_qml_dir}\n"
  )
else()
  message(WARNING "qmake not found. .qmlls.ini will not be generated, which may affect QML language features in some IDEs.")
endif()

# App Bundle
if (win32)
  # https://doc.qt.io/qt-6/windows-deployment.html
  set_target_properties(${PROJECT_NAME} PROPERTIES
    WIN32_EXECUTABLE TRUE
  )
  # Determine the path to windeployqt
  set(WINDEPLOYQT_PATH "${Qt6_DIR}/../../tools/Qt6/bin")
  set(WINDEPLOYQT_EXE "${WINDEPLOYQT_PATH}/windeployqt.exe")
  set(WINDEPLOYQT_DEBUG_EXE "${WINDEPLOYQT_PATH}/windeployqt.debug.bat")

  # Add post build command to call windeployqt
  add_custom_command(TARGET ${PROJECT_NAME} POST_BUILD
      COMMAND "$<IF:$<CONFIG:Debug>,${WINDEPLOYQT_DEBUG_EXE},${WINDEPLOYQT_EXE}>"
      --qmldir ${CMAKE_CURRENT_SOURCE_DIR}
      --verbose 1
      "$<TARGET_FILE:${PROJECT_NAME}>"
  )

elseif(APPLE)
  # https://doc.qt.io/qt-6/macos-deployment.html
  set_target_properties(${PROJECT_NAME} PROPERTIES
    MACOSX_BUNDLE TRUE
  )

  # Find macdeployqt
  get_target_property(QT_BIN_DIR Qt::qmake IMPORTED_LOCATION)
  find_program(MACDEPLOYQT NAMES macdeployqt HINTS "${QT_BIN_DIR}")

  # Use macdeployqt to bundle Qt libraries
  add_custom_command(TARGET ${PROJECT_NAME} POST_BUILD
      COMMAND ${MACDEPLOYQT}
      "$<TARGET_BUNDLE_DIR:${PROJECT_NAME}>"
      -qmldir=${CMAKE_CURRENT_SOURCE_DIR}
      -verbose=1
      -always-overwrite
      -codesign=-
      -no-strip
      "$<IF:$<CONFIG:Release>,-dmg,-use-debug-libs>"
      COMMENT "Bundling Qt libraries"
  )

endif()