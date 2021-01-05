include_guard()

# installTargetAs して、exportTargetfile する
#    exportIDと同名の変数に namespace をつけた library のリストが格納される
#    TargetListResponse に出力した ${_EXPORT}Targets.cmake のファイル名が追加される
#
#    namespace     exportする名前空間。::は書かない
#    exportID      unique ならば何でもいい。同名の変数に出力したライブラリのリストが
#                  格納されるので、後の xxxConfig.cmake.in で参照して利用する
#    TargetListRes 出力した TargetFile の名前をリストアップする変数名
#                  後の xxxConfig.cmake.in の中で参照して利用する
#                  必ずしもuniqueな必要はなく、すでに存在するものに追記することもできる
#  installClientLib("NameSpace" ExportID TargetListRes Targets ....)
#
macro(installClientLib _NS _EXPORT _RES)
  # message("NS=${_NS}")
  # message("EXPORT=${_EXPORT}")
  # message("argn=${ARGN}")
  foreach(_lib ${ARGN} )
    add_library(${_NS}::${_lib} ALIAS ${_lib})
  endforeach()
  installTargetAs(${_EXPORT} ${ARGN})
  exportTargetFile("" ${_NS} ${_RES} ${_EXPORT})
endmacro()

# installTargetAs(_EXPORT _TARGETS)
#   _TARGETS で指定したtarget(複数可)をまとめてインストールし、
#   export名 _EXPORT でexportする。
#
function(installTargetAs _EXPORT)
  install(TARGETS ${ARGN}
    EXPORT ${_EXPORT}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    ARCHIVE DESTINATION ${CMAKE_INSTALL_LIBDIR}
    INCLUDES DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}
    PUBLIC_HEADER DESTINATION ${CMAKE_INSTALL_INCLUDEDIR}
    )
endfunction()

# exportTargetfile(_PREFIX _NS _RESULT _EXPORTS...)
#    _EXPORTSで指定したexport名の対象を namespace _NS でexportする
#     xxxTarget.cmakeファイルを生成してインストールする。
#    _EXPORTSには複数の対象を指定することができ、それぞれのxxxTarget.cmakeを生成する。
#    生成する xxxTarget.cmake ファイルのファイル名は
#       ${_PREFIX}${_EXPORT}Target.cmake
#    となる。
#
macro(exportTargetFile _Prefix _NS _Res)
  foreach(_lib ${ARGN})
    install(EXPORT "${_lib}"
      FILE ${_Prefix}${_lib}Targets.cmake
      NAMESPACE ${_NS}::
      DESTINATION ${CMAKECONFIG_INSTALL_DIR})
    list(APPEND ${_Res} "${_Prefix}${_lib}Targets.cmake")
  endforeach()
endmacro()

# installPackageConfigSimple(_PKGNAME _VERSION targetFiles...)
#  {_CONFIGFILENAME}Config.cmake.in から {_CONFIGFILENAME}Config.cmakeを作り、
#  {_VERSION}から{_CONFIGFILENAME}ConfigVersion.cmake を作り、
#  それぞれインストールする

function(installPackageConfigSimple _PKGNAME _VERSION)
  include(CMakePackageConfigHelpers)
  write_basic_package_version_file(${_PKGNAME}Version.cmake
  VERSION ${_VERSION}
  COMPATIBILITY SameMajorVersion
  )
  file(WRITE ${CMAKE_CURRENT_BINARY_DIR}/${_PKGNAME}Config.cmake.in
  @PACKAGE_INIT@\n
  )
  foreach(_targetFileName ${ARGN})
    file(APPEND ${CMAKE_CURRENT_BINARY_DIR}/${_PKGNAME}Config.cmake.in
    include(\${CMAKE_CURRENT_LIST_DIR}/${_targetFileName})\n)
  endforeach()
  configure_package_config_file(
  ${CMAKE_CURRENT_BINARY_DIR}/${_PKGNAME}Config.cmake.in
  ${CMAKE_CURRENT_BINARY_DIR}/${_PKGNAME}Config.cmake
  INSTALL_DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake
  )
endfunction()


# installConfigTemplate(_CONFIGFILENAME _VERSION)
#  {_CONFIGFILENAME}Config.cmake.in から {_CONFIGFILENAME}Config.cmakeを作り、
#  {_VERSION}から{_CONFIGFILENAME}ConfigVersion.cmake を作り、
#  それぞれインストールする

macro(installPackageConfigTemplate _CONFIGFILENAME _VERSION)
  include(CMakePackageConfigHelpers)
  write_basic_package_version_file(${_CONFIGFILENAME}Version.cmake
  VERSION ${_VERSION}
  COMPATIBILITY SameMajorVersion
  )
  configure_package_config_file(
    ${_CONFIGFILENAME}Config.cmake.in
    ${_CONFIGFILENAME}Config.cmake
    INSTALL_DESTINATION ${CMAKE_INSTALL_LIBDIR}/cmake
    PATH_VARS INCLUDE_INSTALL_DIR)

  install(FILES 
    ${CMAKE_CURRENT_BINARY_DIR}/${_CONFIGFILENAME}Config.cmake
    ${CMAKE_CURRENT_BINARY_DIR}/${_CONFIGFILENAME}Version.cmake
    DESTINATION ${CMAKECONFIG_INSTALL_DIR})
endmacro()

# Imported target をインストールする
#  target property に従ってファイルをコピーする
#  IMPORTED_LOCATION             -> LIBRARY_INSTALL_DIR
#  INTERFACE_INCLUDE_DIRECTORIES -> INCLUDE_INSTALL_DIR
# ヘッダファイル群はディレクトリの構造を保ったままコピーする。
macro(installImportedTarget )
  foreach(_tgt ${ARGN})
    get_target_property(_LIBLOCATION ${_tgt} LOCATION)
    get_target_property(_INCLUDES ${_tgt} INTERFACE_INCLUDE_DIRECTORIES)
    install(FILES ${_LIBLOCATION} DESTINATION ${CMAKE_INSTALL_LIBDIR})
    foreach(_incdir ${_INCLUDES})
      file(GLOB _hdrs ${_incdir}/*)
      foreach(_incfile ${_hdrs})
        #message(" file in interface include: " ${_incfile})
        if(IS_DIRECTORY ${_incfile})
          install(DIRECTORY ${_incfile} DESTINATION ${CMAKE_INSTALL_INCLUDEDIR})
        else()
          install(FILES ${_incfile} DESTINATION ${CMAKE_INSTALL_INCLUDEDIR})
        endif()
      endforeach()
    endforeach()
  endforeach()
endmacro()
