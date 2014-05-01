#!/bin/bash

( cd ios-boost; \
  ./boost.sh \
  xcrun -sdk iphoneos lipo -info framework/boost.framework/Versions/A/boost )

( cd ios-miniupnpc; \
  ./miniupnpc.sh \
  xcrun -sdk iphoneos lipo -info framework/miniupnpc.framework/Versions/A/miniupnpc )

( cd ios-cryptopp; \
  ./cryptopp.sh \
  xcrun -sdk iphoneos lipo -info framework/cryptopp.framework/Versions/A/cryptopp )

( cd ios-gmp; \
  ./gmp.sh \
  xcrun -sdk iphoneos lipo -info framework/gmp.framework/Versions/A/gmp )

( cd ios-leveldb; \
  ./leveldb.sh \
  xcrun -sdk iphoneos lipo -info framework/leveldb.framework/Versions/A/leveldb )

( cd ios-secp256k1; \
 ./secp256k1.sh \
 xcrun -sdk iphoneos lipo -info framework/secp256k1.framework/Versions/A/secp256k1 )

( cd ios-libethcore; \
  ./ethcore.sh \
  xcrun -sdk iphoneos lipo -info framework/ethcore.framework/Versions/A/ethcore )

( cd ios-ethereum; \
 ./ethereum.sh \
 xcrun -sdk iphoneos lipo -info framework/ethereum.framework/Versions/A/ethereum )
