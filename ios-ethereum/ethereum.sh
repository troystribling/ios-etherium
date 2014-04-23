#!/bin/bash

# Bundle config
: ${BUNDLE:=cpp-ethereum.zip}
: ${DOWNLOAD_URL:=https://github.com/troystribling/cpp-ethereum/archive/develop.zip}
: ${LIBRARY:=libethereum.a}

# framework config
: ${FRAMEWORK_NAME:=cpp-ethereum}
: ${FRAMEWORK_VERSION:=A}
: ${FRAMEWORK_CURRENT_VERSION:=develop}
: ${FRAMEWORK_IDENTIFIER:=org.ethereum}

# iphone SDK version
: ${IPHONE_SDKVERSION:=7.1}

source ../shared.sh

LIBRARY_ROOT=$WORKING_DIR/..
LIBRARY_DEPENDENCIES="boost cryptopp gmp leveldb miniupnpc"
INCLUDE_DIR=$WORKING_DIR/include
CRYPTOPP_INCLUDE_DIR=$WORKING_DIR/include/cryptopp
SECP256K1_INCLUDE_DIR=$SRC_DIR/$FRAMEWORK_NAME-$FRAMEWORK_CURRENT_VERSION/secp256k1

exportConfig() {
  echo "Export configuration..."
  IOS_ARCH=$1
  if [ "$IOS_ARCH" == "i386" ]; then
    IOS_SYSROOT=$XCODE_SIMULATOR_SDK
  else
    IOS_SYSROOT=$XCODE_DEVICE_SDK
  fi
  CXXFLAGS="-arch $IOS_ARCH -fPIC -g -Os -pipe --sysroot=$IOS_SYSROOT -I$INCLUDE_DIR -I$CRYPTOPP_INCLUDE_DIR -I$SECP256K1_INCLUDE_DIR -std=c++11 -stdlib=libc++ -Wno-constexpr-not-const"
  if [ "$IOS_ARCH" == "armv7s" ] || [ "$IOS_ARCH" == "armv7" ]; then
    CXXFLAGS="$CXXFLAGS -mios-version-min=6.0"
  else
    CXXFLAGS="$CXXFLAGS -mios-version-min=7.0"
  fi
  CFLAGS=$CXXFLAGS
  export IOS_ARCH
  export CC=clang
  export CXX=clang++
  export CXXFLAGS
  export CFLAGS
  export AR=ar
  export IOS_SYSROOT
  export PATH="$XCODE_TOOLCHAIN_USR_BIN":"$XCODE_USR_BIN":"$ORIGINAL_PATH"
  echo "IOS_ARC: $IOS_ARCH"
  echo "CC: $CC"
  echo "CXX: $CXX"
  echo "CXXFLAGS: $CXXFLAGS"
  echo "CFLAGS: $CFLAGS"
  echo "AR: $AR"
  echo "IOS_SYSROOT: $IOS_SYSROOT"
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

applyPatches() {
  echo "Apply patches..."
  cp $WORKING_DIR/Makefile-ios $SRC_DIR/$FRAMEWORK_NAME-$FRAMEWORK_CURRENT_VERSION/libethereum/Makefile
  cp $WORKING_DIR/find_sources $SRC_DIR/$FRAMEWORK_NAME-$FRAMEWORK_CURRENT_VERSION/libethereum
  doneSection
}

moveHeadersToFramework() {
  echo "Copying includes to $FRAMEWORK_BUNDLE/Headers/..."
  cp -r $SRC_DIR/$FRAMEWORK_NAME-$FRAMEWORK_CURRENT_VERSION/include/$FRAMEWORK_NAME/*.h  $FRAMEWORK_BUNDLE/Headers/
  doneSection
}

compileSrcForArch() {
  local buildArch=$1
  echo "Building source for architecture $buildArch..."
  ( cd $SRC_DIR/$FRAMEWORK_NAME-$FRAMEWORK_CURRENT_VERSION/libethereum; \
    # make clean; \
    make; \
    mkdir -p $BUILD_DIR/$buildArch; \
    mv $LIBRARY $BUILD_DIR/$buildArch )
  doneSection
}

echo "================================================================="
echo "Start"
echo "================================================================="
showConfig
developerToolsPresent
checkForLibraryDependencies
if [ "$ENV_ERROR" == "0" ]; then
  # cleanUp
  # removeIncludeDir
  # createDirs
  # createIncludeDirs
  # downloadSrc
  # unzipBundle
  # applyPatches
  compileSrcForAllArchs
  # buildUniversalLib
  # moveHeadersToFramework
  # buildFrameworkPlist
  echo "Completed successfully.."
else
  echo "Build failed..."
fi

