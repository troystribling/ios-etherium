#!/bin/bash

( cd Frameworks/ios-miniupnpc; ./miniupnpc.sh )
( cd Frameworks/ios-boost; ./boost.sh )
( cd Frameworks/ios-miniupnpc; ./miniupnpc.sh )
( cd Frameworks/ios-cryptopp; ./cryptopp )
( cd Frameworks/ios-gmp; ./gmp.sh )
( cd Frameworks/ios-leveldb; ./leveldb.sh )
( cd Frameworks/ios-ethereum; ./ethereum.sh )