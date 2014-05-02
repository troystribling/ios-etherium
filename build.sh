#!/bin/bash

( cd ios-boost; \
  ./boost.sh )

( cd ios-miniupnpc; \
  ./miniupnpc.sh )

( cd ios-cryptopp; \
  ./cryptopp.sh )

( cd ios-gmp; \
  ./gmp.sh )

( cd ios-leveldb; \
  ./leveldb.sh )

( cd ios-secp256k1; \
 ./secp256k1.sh )

( cd ios-libethcore; \
  ./ethcore.sh )

( cd ios-ethereum; \
 ./ethereum.sh )

xcrun -sdk iphoneos lipo -info ios-boost/framework/boost.framework/Versions/A/boost
xcrun -sdk iphoneos lipo -info ios-miniupnpc/framework/miniupnpc.framework/Versions/A/miniupnpc
xcrun -sdk iphoneos lipo -info ios-cryptopp/framework/cryptopp.framework/Versions/A/cryptopp
xcrun -sdk iphoneos lipo -info ios-gmp/framework/gmp.framework/Versions/A/gmp
xcrun -sdk iphoneos lipo -info ios-leveldb/framework/leveldb.framework/Versions/A/leveldb
xcrun -sdk iphoneos lipo -info ios-secp256k1/framework/secp256k1.framework/Versions/A/secp256k1
xcrun -sdk iphoneos lipo -info ios-libethcore/framework/libethcore.framework/Versions/A/libethcore
xcrun -sdk iphoneos lipo -info ios-ethereum/framework/ethereum.framework/Versions/A/ethereum