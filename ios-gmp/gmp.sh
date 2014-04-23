#!/bin/bash

# Bundle config
: ${BUNDLE:=gmp-5.1.3.tar.lz}
: ${DOWNLOAD_URL:=https://gmplib.org/download/gmp/gmp-5.1.3.tar.lz}
: ${LIBRARY:=libgmp.a}

# framework config
: ${FRAMEWORK_NAME:=gmp}
: ${FRAMEWORK_VERSION:=A}
: ${FRAMEWORK_CURRENT_VERSION:=5.1.3}
: ${FRAMEWORK_IDENTIFIER:=org.gmplib}

# iphone SDK version
: ${IPHONE_SDKVERSION:=7.1}

source ../shared.sh

untarLzippedBundle() {
  echo "Untar bundle to $SRC_DIR..."
  if [ ! -e "gmp-5.1.3.tar" ]; then
    lzip -d $BUNDLE
  fi
  tar -xvf gmp-5.1.3.tar -C $SRC_DIR
  doneSection
}

exportConfig() {
  echo "Export configuration..."
  IOS_ARCH=$1
  if [ "$IOS_ARCH" == "i386" ]; then
    IOS_SYSROOT=$XCODE_SIMULATOR_SDK
  else
    IOS_SYSROOT=$XCODE_DEVICE_SDK
  fi
  CFLAGS="-arch $IOS_ARCH -fPIC -g -Os -pipe --sysroot=$IOS_SYSROOT"
  if [ "$IOS_ARCH" == "armv7s" ] || [ "$IOS_ARCH" == "armv7" ]; then
    CFLAGS="$CFLAGS -mios-version-min=6.0"
  else
    CFLAGS="$CFLAGS -mios-version-min=7.0"
  fi
  CXXFLAGS=$CFLAGS
  CPPFLAGS=$CFLAGS
  CC_FOR_BUILD=/usr/bin/clang
  export CC=clang
  export CXX=clang++
  export CFLAGS
  export CXXFLAGS
  export IOS_SYSROOT
  export CC_FOR_BUILD
  export PATH="$XCODE_TOOLCHAIN_USR_BIN":"$XCODE_USR_BIN":"$ORIGINAL_PATH"
  echo "IOS_ARC: $IOS_ARCH"
  echo "CC: $CC"
  echo "CXX: $CXX"
  echo "LDFLAGS: $LDFLAGS"
  echo "CC_FOR_BUILD: $CC_FOR_BUILD"
  echo "CFLAGS: $CFLAGS"
  echo "CXXFLAGS: $CXXFLAGS"
  echo "IOS_SYSROOT: $IOS_SYSROOT"
  echo "PATH: $PATH"
  doneSection
}

moveHeadersToFramework() {
  echo "Copying includes to $FRAMEWORK_BUNDLE/Headers/..."
  cp -r $BUILD_DIR/armv7/include/*.h  $FRAMEWORK_BUNDLE/Headers/
  doneSection
}

compileSrcForArch() {
  local buildArch=$1
  configureForArch $buildArch
  echo "Building source for architecture $buildArch..."
  ( cd $SRC_DIR/$FRAMEWORK_NAME-$FRAMEWORK_CURRENT_VERSION; \
    echo "Calling make clean..."
    make clean; \
    echo "Calling make check..."
    make check; \
    echo "Calling make..."
    make;
    echo "Calling make install..."
    make install; \
    echo "Place libgmp.a for lipoing..." )
  mv $BUILD_DIR/$buildArch/lib/$LIBRARY $BUILD_DIR/$buildArch
  doneSection
}

configureForArch() {
  local buildArch=$1
  echo "Configure for architecture $buildArch..."
  ( cd $SRC_DIR/$FRAMEWORK_NAME-$FRAMEWORK_CURRENT_VERSION; \
    ./configure --prefix $BUILD_DIR/$buildArch --disable-shared --host="none-apple-darwin" --enable-static --disable-assembly )
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
  untarLzippedBundle
  compileSrcForAllArchs
  buildUniversalLib
  moveHeadersToFramework
  buildFrameworkPlist
  echo "Completed successfully.."
else
  echo "Build failed..."
fi

