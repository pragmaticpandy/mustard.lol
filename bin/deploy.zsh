#!/usr/bin/env zsh

aws --profile mustard-lol-deployer s3 rm s3://mustard.lol --recursive
aws --profile mustard-lol-deployer s3 cp build/result s3://mustard.lol/ --recursive --acl public-read
