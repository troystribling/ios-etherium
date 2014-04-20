#!/bin/bash

# build directories
: ${WORKING_DIR:=`pwd`}
: ${SRC_DIR:=`pwd`/src}
: ${BUILD_DIR:=`pwd`/build}
: ${FRAMEWORK_DIR:=`pwd`/framework}

# XCode directories
: ${XCODE_ROOT:=`xcode-select -print-path`}
XCODE_SIMULATOR=$XCODE_ROOT/Platforms/iPhoneSimulator.platform/Developer
XCODE_DEVICE=$XCODE_ROOT/Platforms/iPhoneOS.platform/Developer

XCODE_SIMULATOR_SDK=$XCODE_SIMULATOR/SDKs/iPhoneSimulator$IPHONE_SDKVERSION.sdk
XCODE_DEVICE_SDK=$XCODE_DEVICE/SDKs/iPhoneOS$IPHONE_SDKVERSION.sdk

XCODE_TOOLCHAIN_USR_BIN=$XCODE_ROOT/Toolchains/XcodeDefault.xctoolchain/usr/bin/
XCODE_USR_BIN=$XCODE_ROOT/usr/bin/

# framework setup
FRAMEWORK_BUNDLE=$FRAMEWORK_DIR/$FRAMEWORK_NAME.framework
FRAMEWORK_INSTALL_NAME=$FRAMEWORK_BUNDLE/Versions/$FRAMEWORK_VERSION/$FRAMEWORK_NAME

# save path
ORIGINAL_PATH=$PATH

# commands
: ${LIPO="xcrun -sdk iphoneos lipo"}

doneSection() {
    echo
    echo "================================================================="
    echo "Done"
    echo
}

showConfig() {
  echo "Bundle Configuration..."
  echo "BUNDLE: $BUNDLE"
  echo "DOWNLOAD_URL: $DOWNLOAD_URL"
  echo
  echo "Framework Configuration"
  echo "FRAMEWORK_NAME: $FRAMEWORK_NAME"
  echo "FRAMEWORK_VERSION: $FRAMEWORK_VERSION"
  echo "FRAMEWORK_CURRENT_VERSION: $FRAMEWORK_CURRENT_VERSION"
  echo "FRAMEWORK_IDENTIFIER: $FRAMEWORK_IDENTIFIER"
  echo
  echo "Build Directories..."
  echo "WORKING_DIR: $WORKING_DIR"
  echo "SRC_DIR: $SRC_DIR"
  echo "BUILD_DIR: $BUILD_DIR"
  echo "FRAMEWORK_DIR: $FRAMEWORK_DIR"
  echo
  echo "XCode Directories..."
  echo "XCODE_SIMULATOR: $XCODE_SIMULATOR"
  echo "XCODE_DEVICE: $XCODE_DEVICE"
  echo "XCODE_SIMULATOR_SDK: $XCODE_SIMULATOR_SDK"
  echo "XCODE_DEVICE_SDK: $XCODE_DEVICE_SDK"
  echo "XCODE_TOOLCHAIN_USR_BIN: $XCODE_TOOLCHAIN_USR_BIN"
  echo "XCODE_USR_BIN: $XCODE_USR_BIN"
  echo
  echo "FRAMEWORK_BUNDLE: $FRAMEWORK_BUNDLE"
  echo "FRAMEWORK_INSTALL_NAME: $FRAMEWORK_INSTALL_NAME"
  doneSection
}

developerToolsPresent () {
  echo "Check that developer tools present..."
  ENV_ERROR=0

  # check for root directories
  if [ ! -d "$XCODE_SIMULATOR" ]; then
    echo "ERROR: unable to find Xcode Simulator directory: $XCODE_SIMULATOR"
    ENV_ERROR=1
  fi

  # check for device directory
  if [ ! -d "$XCODE_DEVICE" ]; then
    echo "ERROR: unable to find Xcode Device directory: $XCODE_DEVICE"
    ENV_ERROR=1
  fi

  #check for SDKs
  if [ ! -d "$XCODE_SIMULATOR_SDK" ]; then
    echo "ERROR: Simulator SDK not found"
    ENV_ERROR=1
  fi

  if [ ! -d "$XCODE_DEVICE_SDK" ]; then
    echo "ERROR: Device SDK not found"
    ENV_ERROR=1
  fi

  # check for presence oc cross compiler tools
  if [ ! -d "$XCODE_TOOLCHAIN_USR_BIN" ]; then
    echo "ERROR: unable to find Xcode toolchain usr/bin directory: $XCODE_TOOLCHAIN_USR_BIN"
    ENV_ERROR=1
  fi

  if [ ! -d "$XCODE_USR_BIN" ]; then
    echo "ERROR: unable to find Xcode usr/bin directory: $XCODE_USR_BIN"
    ENV_ERROR=1
  fi

  local targetTools="clang++ clang ar ranlib libtool ld lipo"
  for tool in $targetTools
  do
    if [ ! -e "$XCODE_TOOLCHAIN_USR_BIN/$tool" ] && [ ! -e "$XCODE_USR_BIN/$tool" ]; then
      echo "ERROR: unable to find $tool at device or simulator IOS_TOOLCHAIN or XCODE_TOOLCHAIN"
      ENV_ERROR=1
    fi
  done

  doneSection
}

createDirs () {
  echo "Create directories..."
  [ -d $SRC_DIR ] || mkdir -p $SRC_DIR
  [ -d $BUILD_DIR ] || mkdir -p $BUILD_DIR
  [ -d $FRAMEWORK_DIR ] || mkdir -p $FRAMEWORK_DIR

  mkdir -p $FRAMEWORK_BUNDLE
  mkdir -p $FRAMEWORK_BUNDLE/Versions
  mkdir -p $FRAMEWORK_BUNDLE/Versions/$FRAMEWORK_VERSION
  mkdir -p $FRAMEWORK_BUNDLE/Versions/$FRAMEWORK_VERSION/Resources
  mkdir -p $FRAMEWORK_BUNDLE/Versions/$FRAMEWORK_VERSION/Headers
  mkdir -p $FRAMEWORK_BUNDLE/Versions/$FRAMEWORK_VERSION/Documentation

  ln -s $FRAMEWORK_VERSION               $FRAMEWORK_BUNDLE/Versions/Current
  ln -s Versions/Current/Headers         $FRAMEWORK_BUNDLE/Headers
  ln -s Versions/Current/Resources       $FRAMEWORK_BUNDLE/Resources
  ln -s Versions/Current/Documentation   $FRAMEWORK_BUNDLE/Documentation
  ln -s Versions/Current/$FRAMEWORK_NAME $FRAMEWORK_BUNDLE/$FRAMEWORK_NAME

  doneSection
}

cleanUp() {
    echo "Cleaning up before build..."
    rm -rf $SRC_DIR
    rm -rf $BUILD_DIR
    rm -rf $FRAMEWORK_DIR
    doneSection
}

buildFrameworkPlist() {
  echo "Framework: Creating plist..."
  cat > $FRAMEWORK_BUNDLE/Resources/Info.plist <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>CFBundleDevelopmentRegion</key>
  <string>English</string>
  <key>CFBundleExecutable</key>
  <string>${FRAMEWORK_NAME}</string>
  <key>CFBundleIdentifier</key>
  <string>${FRAMEWORK_IDENTIFIER}</string>
  <key>CFBundleInfoDictionaryVersion</key>
  <string>6.0</string>
  <key>CFBundlePackageType</key>
  <string>FMWK</string>
  <key>CFBundleSignature</key>
  <string>????</string>
  <key>CFBundleVersion</key>
  <string>${FRAMEWORK_CURRENT_VERSION}</string>
</dict>
</plist>
EOF
  doneSection
}

unzipBundle() {
  echo "Unzip bundle to $SRC_DIR..."
  unzip $BUNDLE -d $SRC_DIR
  doneSection
}

untarGzippedBundle() {
  echo "Untar gzipped bundle to $SRC_DIR..."
  tar -xzvf $BUNDLE -C $SRC_DIR
  doneSection
}

downloadSrc() {
  echo "Download source if needed..."
  if [ ! -e "$WORKING_DIR/$BUNDLE" ]; then
    wget $DOWNLOAD_URL -O $WORKING_DIR/$BUNDLE
  fi
  doneSection
}

compileSrcForAllArchs() {
  # buildArchs="i386 armv7s armv7"
  buildArchs="armv7"
  for buildArch in $buildArchs
  do
    exportConfig $buildArch
    compileSrcForArch $buildArch
  done
}

buildUniversalLib() {
  echo "Lipoing library to $FRAMEWORK_INSTALL_NAME..."
  $LIPO \
      -create \
      -arch armv7  "$BUILD_DIR/armv7/$LIBRARY" \
      -arch armv7s "$BUILD_DIR/armv7s/$LIBRARY" \
      -arch i386   "$BUILD_DIR/i386/$LIBRARY" \
      -o           "$FRAMEWORK_INSTALL_NAME" \
  || abort "lipo failed"
  doneSection
}
