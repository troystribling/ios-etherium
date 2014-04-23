#!/bin/bash

( cd ios-miniupnpc; ./miniupnpc.sh )
( cd ios-boost; ./boost.sh )
( cd ios-miniupnpc; ./miniupnpc.sh )
( cd ios-cryptopp; ./cryptopp )
( cd ios-gmp; ./gmp.sh )
( cd ios-leveldb; ./leveldb.sh )
( cd ios-ethereum; ./ethereum.sh )