#!/bin/bash

# Bundle config
: ${BUNDLE:=miniupnpc-1.9.tar.gz}
: ${DOWNLOAD_URL:=http://miniupnp.free.fr/files/download.php?file=miniupnpc-1.9.tar.gz}
: ${LIBRARY:=libminiupnpc.a}

# framework config
: ${FRAMEWORK_NAME:=miniupnpc}
: ${FRAMEWORK_VERSION:=A}
: ${FRAMEWORK_CURRENT_VERSION:=1.9}
: ${FRAMEWORK_IDENTIFIER:=org.tuxfamily.miniupnp}

# iphone SDK version
: ${IPHONE_SDKVERSION:=7.1}

source ../shared.sh

exportConfig() {
  echo "Export configuration..."
  IOS_ARCH=$1
  export CC=clang
  export OS=ios
  export AR=ar
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
  echo "IS_CROSS_COMPILE: $IS_CROSS_COMPILE"
  echo "OS: $OS"
  echo "CC: $CC"
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
  cp -r $SRC_DIR/$FRAMEWORK_NAME-$FRAMEWORK_CURRENT_VERSION/*.h  $FRAMEWORK_BUNDLE/Headers/
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

