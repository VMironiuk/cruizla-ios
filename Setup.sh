#!/bin/bash

# Run omim/configure.sh
omim/configure.sh

# Copy setup_omim.patch to omim directory, aplly and then remove it
cp setup_omim.patch omim
cd omim
git apply setup_omim.patch
rm setup_omim.patch
cd ..
