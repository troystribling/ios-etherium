#!/bin/bash

LIBRARY_ROOT=$WORKING_DIR/..
INCLUDE_DIR=$WORKING_DIR/include
CRYPTOPP_DIR=$WORKING_DIR/include/cryptopp
GMP_DIR=$WORKING_DIR/include/gmp

exportConfig() {
  echo "Export configuration..."
  IOS_ARCH=$1
  if [ "$IOS_ARCH" == "i386" ]; then
    IOS_SYSROOT=$XCODE_SIMULATOR_SDK
  else
    IOS_SYSROOT=$XCODE_DEVICE_SDK
  fi
  CXXFLAGS="-arch $IOS_ARCH -fPIC -g -Os -pipe --sysroot=$IOS_SYSROOT -I$CRYPTOPP_DIR -I$INCLUDE_DIR -std=c++11 -stdlib=libc++ -Wno-constexpr-not-const"
  CFLAGS="-arch $IOS_ARCH -g -Os -pipe --sysroot=$IOS_SYSROOT -DUSE_NUM_GMP -DUSE_FIELD_GMP -DUSE_FIELD_INV_NUM -I$GMP_DIR"
  if [ "$IOS_ARCH" == "armv7s" ] || [ "$IOS_ARCH" == "armv7" ]; then
    CXXFLAGS="$CXXFLAGS -mios-version-min=6.0"
    CFLAGS="$CFLAGS -mios-version-min=6.0"
  else
    CXXFLAGS="$CXXFLAGS -mios-version-min=7.0"
    CFLAGS="$CFLAGS -mios-version-min=7.0"
  fi
  export IOS_ARCH
  export CC=clang
  export CXX=clang++
  export CXXFLAGS
  export CFLAGS
  export AR=ar
  export IOS_SYSROOT
  export LIBRARY
  export PATH="$XCODE_TOOLCHAIN_USR_BIN":"$XCODE_USR_BIN":"$ORIGINAL_PATH"
  echo "IOS_ARC: $IOS_ARCH"
  echo "CC: $CC"
  echo "CXX: $CXX"
  echo "CXXFLAGS: $CXXFLAGS"
  echo "CFLAGS: $CFLAGS"
  echo "AR: $AR"
  echo "IOS_SYSROOT: $IOS_SYSROOT"
  echo "LIBRARY: $LIBRARY"
  echo "PATH: $PATH"
  doneSection
}

checkForLibraryDependencies() {
  echo "Check that library dependencies exist..."
  for libraryName in $LIBRARY_DEPENDENCIES
  do
    echo "Checking for library: $libraryName"
    local headerPath=$(getHeadersPath $libraryName)
    if [ ! -e "$headerPath" ]; then
      ENV_ERROR=1
      echo "Library path or library header path does not exist"
      echo "Library header path: $headerPath"
    fi
  done
  doneSection
}

createIncludeDirs() {
  echo "Create include directories..."
  mkdir $WORKING_DIR/lib $WORKING_DIR/include
  for libraryName in $LIBRARY_DEPENDENCIES
  do
    local headerPath=$(getHeadersPath $libraryName)
    ln -s $headerPath $WORKING_DIR/include/$libraryName
  done
  doneSection
}

removeIncludeDir() {
  echo "Create include directory..."
  rm -rf $WORKING_DIR/include
  doneSection
}

getHeadersPath() {
  local libraryName=$1
  local headerPath=$LIBRARY_ROOT/ios-$libraryName/framework/$libraryName.framework/Versions/A/Headers
  echo $headerPath
}


