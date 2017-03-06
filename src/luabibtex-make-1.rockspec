
package = "LuaBibTex"
version = "make-1"
source =
{
    url = "git://github.com/echiesse/luabibtex",
    --tag = ???
}

description =
{
    summary = "Lua implementation of BibTeX.",
    detailed = [[]],
    homepage = "https://github.com/echiesse/luabibtex",
    license = "MIT",
}

dependencies =
{
    "lua >= 5.1",
    "luno >= make",
    "luafilesystem >= 1.5.0",
    --"luno >= 20121129",
}

build =
{
    type = "builtin",
    modules =
    {
        ["luaBibTex"] = "src/luaBibTex.lua",
        ["luaBibTex.bibParser"]        = "src/bibParser.lua",
        ["luaBibTex.auxParser"]        = "src/auxParser.lua",
        ["luaBibTex.bibFunctions"]     = "src/bibFunctions.lua",
        ["luaBibTex.bblGenerator"]     = "src/bblGenerator.lua",
        ["luaBibTex.fileSystemHelper"] = "src/fileSystemHelper.lua",
        ["luaBibTex.logger"]           = "src/logger.lua",
        ["luaBibTex.nameObject"]       = "src/nameObject.lua",
        --["luaBibTex.stringBuffer"]     = "src/stringBuffer.lua",
    },

    install =
    {
        lua =
        {
            ["luaBibTex.plain"] = "src/plain.lbst",
        },

        bin =
        {
            ["luaBibTex.bat"]   = "src/scripts/luaBibTex.bat",
            ["luaBibTex"]  = "src/scripts/luaBibTex.sh",
        },
    },
}
