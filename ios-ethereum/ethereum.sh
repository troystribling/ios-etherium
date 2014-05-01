#!/bin/bash

# Bundle config
: ${BUNDLE:=cpp-ethereum.zip}
: ${DOWNLOAD_URL:=https://github.com/troystribling/cpp-ethereum/archive/develop.zip}
: ${LIBRARY:=libethereum.a}

# framework config
: ${FRAMEWORK_NAME:=ethereum}
: ${FRAMEWORK_VERSION:=A}
: ${FRAMEWORK_CURRENT_VERSION:=develop}
: ${FRAMEWORK_IDENTIFIER:=org.ethereum}

# iphone SDK version
: ${IPHONE_SDKVERSION:=7.1}

source ../shared.sh
source ../ethereum_shared.sh

LIBRARY_DEPENDENCIES="boost cryptopp gmp leveldb miniupnpc libethcore secp256k1"
LIBETHREUM_DIR=$SRC_DIR/$FRAMEWORK_NAME-$FRAMEWORK_CURRENT_VERSION/libethereum

applyPatches() {
  echo "Apply patches..."
  mv $SRC_DIR/cpp-ethereum-$FRAMEWORK_CURRENT_VERSION $SRC_DIR/$FRAMEWORK_NAME-$FRAMEWORK_CURRENT_VERSION
  cp $LIBRARY_ROOT/Makefile-ios $LIBETHREUM_DIR/Makefile
  cp $LIBRARY_ROOT/find_sources $LIBETHREUM_DIR
  doneSection
}

moveHeadersToFramework() {
  echo "Copying includes to $FRAMEWORK_BUNDLE/Headers/..."
  cp -r $SRC_DIR/$FRAMEWORK_NAME-$FRAMEWORK_CURRENT_VERSION/libethereum/*.h  $FRAMEWORK_BUNDLE/Headers/
  doneSection
}

compileSrcForArch() {
  local buildArch=$1
  echo "Building libethereum for architecture $buildArch..."
  ( cd $SRC_DIR/$FRAMEWORK_NAME-$FRAMEWORK_CURRENT_VERSION/libethereum; \
    make clean; \
    make; \
    mkdir -p $BUILD_DIR/$buildArch; \
    mv *.o $BUILD_DIR/$buildArch )
  echo "Archiving for $buildArch..."
  ( cd $BUILD_DIR/$buildArch; \
    $AR -crus $LIBRARY *.o )
  doneSection
}

echo "================================================================="
echo "Start"
echo "================================================================="
showConfig
developerToolsPresent
checkForLibraryDependencies
if [ "$ENV_ERROR" == "0" ]; then
  cleanUp
  removeIncludeDir
  createDirs
  createIncludeDirs
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

