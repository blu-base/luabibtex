#!/bin/bash

baseFile=$1
luaBibTex=$LUA_DEV/lua/luaBibTex.lua

lua $luaBibTex $baseFile
