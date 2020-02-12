#!/usr/bin/env zsh

rm -rf build
mkdir -p build/result
rsync -a as-is/ build/result/
