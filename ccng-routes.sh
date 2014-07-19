#!/bin/bash

ccng_repo=${CCNG_REPO:-${PWD}/cloud_controller_ng}

if [ ! -d $ccng_repo ]; then
    git clone https://github.com/cloudfoundry/cloud_controller_ng.git
fi

pushd $ccng_repo

if [ "${CCNG_REV}" != "" ]; then
    git checkout ${CCNG_REV} 2>&1
fi

git submodule sync; git submodule update --init --recursive
bundle install --path vendor/bundle

popd

CCNG_REPO=${ccng_repo} BUNDLE_GEMFILE=${ccng_repo}/Gemfile bundle exec rake routes
