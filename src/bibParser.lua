require"luno/stringEx"
require"luno/tableEx"
require"luno/ioEx"
require"luno/util"
require"luno/funcional"


bibParser = {}

--[[
@book{agrawal001,
    author    = "Govind P. Agrawal",
    title     = "Fiber-Optic Communication Systems",
    publisher = "Wiley Inter-Science",
    year      = "2002",
}

agrawal001 =
{
    refType   = "book",
    authors   = "Govind P. Agrawal",                  -- Atenção ao plural em "authors" !!
    title     = "Fiber-Optic Communication Systems",
    publisher = "Wiley Inter-Science",
    year      = "2002",
}
]]

teste = [[@book{agrawal001,
    author    = "Govind P. Agrawal",
    title     = "Fiber-Optic Communication Systems",
    publisher = "Wiley Inter-Science",
    year      = "2002",
}
]]

local refPattern = "@(%w+%b{})"
local refTypePattern = "(%w+)(%b{})"
local refNamePattern = "{([%w%.]+),"


local function getKeyValue(fieldLine)
    fieldLine = F.pipe(stringEx.trim, stringEx.removeLast)(fieldLine)
    local key, value = unpack(F.map(stringEx.trim, stringEx.split(fieldLine, "=")))
    return key, value
end


local function parseRefBody(refBody)
    -- Remover as chaves no início e no final
    refBody = stringEx.gtrim(refBody, "%s*{", "}%s*")

    -- Remover linhas em branco:
    local lines = F.filter(F.partial(Op.ne, ""), F.map(stringEx.trim, stringEx.splitLines(refBody)))

    -- Remover a vírgula no final da linha:
    local refName = stringEx.grtrim(lines[1], ",%s*")

    -- Ler os campos:
    local fields = {}
    for i = 2, #lines do
        local key, value = getKeyValue(lines[i])
        value = stringEx.gtrim(value, "\"")
        fields[key] = value
    end

    -- Acertar autores:
    --fields.authors = fields.author
    --fields.author = nil
    --fields.authors = stringEx.split(fields.authors, "%s+and%s+")
    fields.author = stringEx.split(fields.author, "%s+and%s+")

    return refName, fields
end


local function getBibFields(bibItem)
    local refName
    local fields
    local results = {string.find(bibItem, refTypePattern)}
    if not tableEx.isEmpty(results) then
        refName, fields = parseRefBody(results[4])
        fields.refType = results[3]
    end
    return fields, refName
end


local function getContentList(contents)
    local entry = {string.find(contents, refPattern)}
    local items = {}
    while not tableEx.isEmpty(entry) do
        local item, refName = getBibFields(entry[3])
        if refName ~= nil and stringEx.trim(refName) ~= "" then
            items[refName] = item
        end
        entry = {string.find(contents, refPattern, entry[2]+1)}
    end
    return items
end


--function bibParser.loadFromFile(fileName)
function bibParser.parseContents(bibContents)
    --local bibContents = ioEx.getTextFromFile(fileName)
    return getContentList(bibContents)
end

