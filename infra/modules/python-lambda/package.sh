#!/bin/bash -e

# Make tmp folder if not exists
mkdir -p $tmp_path
# Clean up the tmp folder from previous builds
rm -rf $tmp_path/**
# Copy the lambda source code to tmp folder
cp -r $lambda_src_path/* $tmp_path
cd $tmp_path
# Install the dependencies
pip install --platform=manylinux_2_17_x86_64 --only-binary=:all:\
    -r $lambda_src_path/requirements.txt\
    --upgrade --target .
