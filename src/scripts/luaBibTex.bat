@echo off

set baseFile=%1
set luaBibTex=%LUA_DEV%\lua\luaBibTex.lua

lua %luaBibTex% %baseFile%
