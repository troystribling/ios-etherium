#!/bin/bash

# Bundle config
: ${BUNDLE:=cryptopp562.zip}
: ${DOWNLOAD_URL:=http://prdownloads.sourceforge.net/cryptopp/cryptopp562.zip}
: ${LIBRARY:=libcryptopp.a}

# framework config
: ${FRAMEWORK_NAME:=cryptopp}
: ${FRAMEWORK_VERSION:=A}
: ${FRAMEWORK_CURRENT_VERSION:=562}
: ${FRAMEWORK_IDENTIFIER:=com.cryptopp}

# iphone SDK version
: ${IPHONE_SDKVERSION:=7.1}

source ../shared.sh

exportConfig() {
  echo "Export configuration..."
  IOS_ARCH=$1
  export IS_IOS=1
  export IS_CROSS_COMPILE=1
  export IOS_ARCH
  if [ "$IOS_ARCH" == "i386" ]; then
    IOS_SYSROOT=$XCODE_SIMULATOR_SDK
  else
    IOS_SYSROOT=$XCODE_DEVICE_SDK
  fi
  export IOS_SYSROOT
  export PATH="$XCODE_TOOLCHAIN_USR_BIN":"$XCODE_USR_BIN":"$ORIGINAL_PATH"
  echo "IOS_ARC: $IOS_ARCH"
  echo "IS_IOS: $IS_IOS"
  echo "IOS_SYSROOT: $IOS_SYSROOT"
  echo "PATH: $PATH"
  doneSection
}

applyPatches() {
  echo "Apply patches..."
  patch -i $WORKING_DIR/GNUmakefile-ios.patch -d $SRC_DIR
  patch -i $WORKING_DIR/config.h.patch -d $SRC_DIR
  doneSection
}

moveHeadersToFramework() {
  echo "Copying includes to $FRAMEWORK_BUNDLE/Headers/..."
  cp -r $SRC_DIR/*.h  $FRAMEWORK_BUNDLE/Headers/
  doneSection
}

compileSrcForArch() {
  local buildArch=$1
  echo "Building source for architecture $buildArch..."
  ( cd $SRC_DIR; \
    make clean; \
    make static; \
    mkdir -p $BUILD_DIR/$buildArch; \
    mv $LIBRARY $BUILD_DIR/$buildArch )
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
  buildUniversalLib
  moveHeadersToFramework
  buildFrameworkPlist
  echo "Completed successfully.."
else
  echo "Build failed..."
fi

