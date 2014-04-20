#!/bin/bash

# Bundle config
: ${BUNDLE:=cpp-ethereum.zip}
: ${DOWNLOAD_URL:=https://github.com/ethereum/cpp-ethereum/archive/master.zip}
: ${LIBRARY:=libethereum.a}

# framework config
: ${FRAMEWORK_NAME:=cpp-ethereum}
: ${FRAMEWORK_VERSION:=A}
: ${FRAMEWORK_CURRENT_VERSION:=master}
: ${FRAMEWORK_IDENTIFIER:=org.ethereum}

# iphone SDK version
: ${IPHONE_SDKVERSION:=7.1}

source ../../shared.sh

exportConfig() {
  echo "Export configuration..."
  IOS_ARCH=$1
  if [ "$IOS_ARCH" == "i386" ]; then
    IOS_SYSROOT=$XCODE_SIMULATOR_SDK
  else
    IOS_SYSROOT=$XCODE_DEVICE_SDK
  fi
  CXXFLAGS="-arch $IOS_ARCH -fPIC -g -Os -pipe --sysroot=$IOS_SYSROOT"
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
    make clean; \
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
if [ "$ENV_ERROR" == "0" ]; then
  cleanUp
  createDirs
  downloadSrc
  unzipBundle
  applyPatches
  compileSrcForAllArchs
  # buildUniversalLib
  # moveHeadersToFramework
  # buildFrameworkPlist
  echo "Completed successfully.."
else
  echo "Build failed..."
fi

