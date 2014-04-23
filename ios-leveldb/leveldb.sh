#!/bin/bash

# Bundle config
: ${BUNDLE:=level.tar.gz}
: ${DOWNLOAD_URL:=https://leveldb.googlecode.com/files/leveldb-1.15.0.tar.gz}
: ${LIBRARY:=libleveldb.a}

# framework config
: ${FRAMEWORK_NAME:=leveldb}
: ${FRAMEWORK_VERSION:=A}
: ${FRAMEWORK_CURRENT_VERSION:=1.15.0}
: ${FRAMEWORK_IDENTIFIER:=com.google.leveldb}

# iphone SDK version
: ${IPHONE_SDKVERSION:=7.1}

source ../shared.sh

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
  TARGET_OS=IOS
  export IOS_ARCH
  export TARGET_OS
  export CROSS_COMPILE=true
  export CC=clang
  export CXX=clang++
  export CXXFLAGS
  export CFLAGS
  export AR=ar
  export IOS_SYSROOT
  export PATH="$XCODE_TOOLCHAIN_USR_BIN":"$XCODE_USR_BIN":"$ORIGINAL_PATH"
  echo "IOS_ARC: $IOS_ARCH"
  echo "TARGET_OS: $TARGET_OS"
  echo "CROSS_COMPILE: $CROSS_COMPILE"
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
  patch -i $WORKING_DIR/Makefile-ios.patch -d $SRC_DIR/$FRAMEWORK_NAME-$FRAMEWORK_CURRENT_VERSION
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
  ( cd $SRC_DIR/$FRAMEWORK_NAME-$FRAMEWORK_CURRENT_VERSION; \
    make clean; \
    make $LIBRARY; \
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
  untarGzippedBundle
  applyPatches
  compileSrcForAllArchs
  buildUniversalLib
  moveHeadersToFramework
  buildFrameworkPlist
  echo "Completed successfully.."
else
  echo "Build failed..."
fi

