require"luno/stringEx"
require"luno/tableEx"
require"luno/ioEx"
require"luno/util"
require"luno/funcional"


auxParser = {}

--function auxParser.loadFromFile(auxFileName)
--    local auxContents = ioEx.getTextFromFile(auxFileName)
--    return parseAuxContents(auxContents)
--end

local function swapKeyValue(tb)
    local ret = {}
    for i, v in pairs(tb) do
        ret[v] = i
    end
    return ret
end


function auxParser.parseContents(auxContents)
    local ret = {}
    local lines = stringEx.splitLines(auxContents)

    local ini, fim
    local citations = {}
    local citationPos = 1
    local bibData
    for i, line in ipairs(lines) do
        -- Citations:
        local ini, fim, refName = string.find(line, "\\citation{([%w%d]+)}")
        if ini ~= nil and citations[refName] == nil then
            citations[refName] = citationPos
            citationPos = citationPos + 1
        end

        -- BibData:
        ini, fim, bibData = string.find(line, "\\bibdata{([%w%d]+)}")
        if ini ~= nil then
            ret.bibData = bibData
        end

        -- BibStyle:
        ini, fim, bibStyle = string.find(line, "\\bibstyle{([%w%d]+)}")
        if ini ~= nil then
            ret.bibStyle = bibStyle
        end
    end
    ret.citations = swapKeyValue(citations)

    return ret
end

