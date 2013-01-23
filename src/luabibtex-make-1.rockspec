
package = "LuaBibTex"
version = "make-1"
source =
{
    url = "http://...",
}

description =
{
    summary = "Lua implementation of BibTeX.",
    detailed = [[]],
    homepage = "http://code.google.com/p/luabibtex/",
    license = "MIT",
}

dependencies =
{
    "lua >= 5.1",
    "luno >= make",
    --"luno >= 20121129",
}

build =
{
    type = "builtin",
    modules =
    {
        ["luaBibTex.bibParser"]        = "bibParser.lua",
        ["luaBibTex.auxParser"]        = "auxParser.lua",
        ["luaBibTex.bibFunctions"]     = "bibFunctions.lua",
        ["luaBibTex.bblGenerator"]     = "bblGenerator.lua",
        ["luaBibTex.fileSystemHelper"] = "fileSystemHelper.lua",
        ["luaBibTex.logger"]           = "logger.lua",
        ["luaBibTex.nameObject"]       = "nameObject.lua",
        --["luaBibTex.stringBuffer"]     = "stringBuffer.lua",
    },

    install =
    {
        lua =
        {
            ["luaBibTex"] = "luaBibTex.lua",
            ["luaBibTex.plain"] = "plain.lbst",
        },

        bin =
        {
            ["luaBibTexWin"]   = "scripts/luaBibTex.bat",
            ["luaBibTex"]  = "scripts/luaBibTex.sh",
        },

    },
}
