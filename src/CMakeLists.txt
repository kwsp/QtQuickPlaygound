find_package(Qt6 REQUIRED COMPONENTS Core Gui Qml Quick)

qt_standard_project_setup(REQUIRES 6.5)

configure_file(config.h.in config.h)

qt_add_executable(${PROJECT_NAME}
  main.cpp
)

set_target_properties(${PROJECT_NAME} PROPERTIES
  MACOSX_BUNDLE TRUE
)

target_include_directories(${PROJECT_NAME} PRIVATE ${CMAKE_CURRENT_BINARY_DIR})

qt_add_qml_module(${PROJECT_NAME}
  URI ${PROJECT_NAME}
  VERSION 1.0
  QML_FILES
    Main.qml
)

target_link_libraries(${PROJECT_NAME} PRIVATE
  Qt6::Core
  Qt6::Gui
  Qt6::Qml
  Qt6::Quick
)

find_program(_qmake NAMES qmake6 qmake HINTS "${Qt6_DIR}/../../../bin")
if(_qmake)
  execute_process(
    COMMAND "${_qmake}" -query QT_INSTALL_QML
    OUTPUT_VARIABLE _qt_qml_dir
    OUTPUT_STRIP_TRAILING_WHITESPACE
  )
endif()

file(RELATIVE_PATH _qmlls_build_dir "${CMAKE_SOURCE_DIR}" "${CMAKE_BINARY_DIR}")
file(WRITE "${CMAKE_SOURCE_DIR}/.qmlls.ini"
  "[General]\nbuildDir=${_qmlls_build_dir}\nimportPaths=${_qt_qml_dir}\n"
)
