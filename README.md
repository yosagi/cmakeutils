# Cmakeutils
Collection of utility functions/macros

## Usage

Add this repository as submodule of a host repository and,

1. Add the directory to CMAKE_MODULE_PATH in a CMakeLists.txt of a host repository.

``` cmake
set(CMAKE_MODULE_PATH ${CMAKE_MODULE_PATH}:path/to/cmakeutils)
include(dbgutils.cmake)
```

2. Or include files with path to submodule.

``` cmake
include(path/to/cmakeutils/dbgutils.cmake)
```

## dbgutils.cmake

### print_properties(GLOBAL | TARGET [name] | DIRECTORY [name] | SOURCE [name] | TEST [name])

Print all properties set on a entity.

### print_all_targets([dir])

Print all buildsystem target under [dir]

## install_helpers.cmake

### installTargetAs( [exportID] [targets...])

Install multiple targets in standard directories and export it as exportID.

### exportTargetFile( Prefix NS resVar exportIDs...)

Export targets specified by exportID as '{Prefix}{exportID}Targets.cmake'.
A list of resulting filenames is set on resVar variable.

### installClientLib(NS exportID resVar targets...)

installTargetAs() + exportTargetFile(). For each target, this macro adds alias library targets as NS::target.

### installPackageConfigSimple( _PKGNAME _VERSION targetFiles...)

Install '{_PKGNAME}Config.cmake' and '{_PKGNAME}ConfigVersion.cmake'.
'{_PKGNAME}Config.cmake' will be filled with simple content: including targetFiles beside it.

### installImportedTarget

Copy files specified in target properties to standard destination directories.
