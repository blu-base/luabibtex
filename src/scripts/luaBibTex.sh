#!/bin/bash

baseFile=$1
#luaBibTex=/usr/local/share/lua/5.1/luaBibTex.lua

#lua $luaBibTex $baseFile
lua -l luaBibTex -e main(\"$baseFile\")
