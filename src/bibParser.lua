require"luno.string"
require"luno.table"
require"luno.io"
require"luno.util"
require"luno.funcional"
require"luaBibTex.bibFunctions"

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
    fieldLine = F.pipe(trim, lstring.removeLast)(fieldLine)
    local key, value = unpack(F.map(trim, split(fieldLine, "=")))
    return key, value
end


local function parseRefBody(refBody)
    -- Remover as chaves no início e no final
    refBody = gtrim(refBody, "%s*{", "}%s*")

    -- Remover linhas em branco:
    local lines = F.filter(F.partial(Op.ne, ""), F.map(trim, splitLines(refBody)))

    -- Remover a vírgula no final da linha:
    local refName = lstring.grtrim(lines[1], ",%s*")

    -- Ler os campos:
    local fields = {}
    for i = 2, #lines do
        local key, value = getKeyValue(lines[i])
        value = gtrim(value, "\"")
        fields[key] = value
    end

    -- Acertar autores:
    fields.author = split(fields.author, "%s+and%s+")
    fields.author = F.map(splitName, fields.author)

    return refName, fields
end


local function getBibFields(bibItem)
    local refName
    local fields
    local results = {string.find(bibItem, refTypePattern)}
    if not isEmpty(results) then
        refName, fields = parseRefBody(results[4])
        fields.refType = results[3]
    end
    return fields, refName
end


local function getContentList(contents)
    local entry = {string.find(contents, refPattern)}
    local items = {}
    while not isEmpty(entry) do
        local item, refName = getBibFields(entry[3])
        if refName ~= nil and trim(refName) ~= "" then
            items[refName] = item
        end
        entry = {string.find(contents, refPattern, entry[2]+1)}
    end
    return items
end


function bibParser.parseContents(bibContents)
    return getContentList(bibContents)
end

