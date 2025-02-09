#!/bin/bash

qt_dir=${1}
src_dir=${2}

set -o errexit
set -o nounset
set -o xtrace
OS=$(uname)

mkdir build
pushd build
CONFIGURATION="Release"

if [[ "${BETA:-0}" -eq 1 ]]; then
    NETWORK_CFG="beta"
    CONFIGURATION="RelWithDebInfo"
elif [[ "${TEST:-0}" -eq 1 ]]; then
    NETWORK_CFG="test"
else
    NETWORK_CFG="live"
fi

cmake \
-G'Unix Makefiles' \
-DACTIVE_NETWORK=nano_${NETWORK_CFG}_network \
-DNANO_POW_SERVER=ON \
-DNANO_GUI=ON \
-DPORTABLE=1 \
-DCMAKE_BUILD_TYPE=${CONFIGURATION} \
-DCMAKE_VERBOSE_MAKEFILE=ON \
-DBOOST_ROOT=/tmp/boost/ \
-DNANO_SHARED_BOOST=OFF \
-DQt5_DIR=${qt_dir} \
-DCI_BUILD=true \
..

if [[ "$OS" == 'Linux' ]]; then
    cmake --build ${PWD} --target package --config ${CONFIGURATION} -- -j$(nproc)
else
    sudo cmake --build ${PWD} --target package --config ${CONFIGURATION} -- -j2
fi

popd
