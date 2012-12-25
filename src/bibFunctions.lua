require"luno.functional"
require"luno.string"
require"luno.table"


-- Aliases:
luno.string.useAlias()
luno.table.useAlias()

luno.string.exposeSome()
luno.table.exposeSome()



-- Funções:
local function generalize(f, arg)
    local ret
    if type(arg) == "string" then
        ret = f(arg)
    elseif type(arg) == "table" then
        ret = F.map(f, arg)
    else
        error("bad argument #2 to 'generalize' (string or table expected, got " .. type(arg), 2)
    end

    return ret
end


function joinAuthors(authorsTable, sep)
    sep = sep or " and " -- Precisa ser atualizada para ajustar corretamente o último nome --<<<<<
    --local prependComma = prepend", "
    local authorNames = map(joinWords, authorsTable)
    --local authorNames2 = map(prependComma, drop(1, authorNames))
    --authorNames2 = table.insert(authorNames2, 1, authorNames[1])
    local ret = join(authorNames, ", ")
    return ret
end


function splitName(name)
    name = trim(name)
    local groups = {}
    for val in string.gmatch(name, "{(.-)}") do
        table.insert(groups, val)
    end
    name = string.gsub(name, "{.-}", "#g")

    local list = split(name, "%s")

    if not isEmpty(groups) then
        local pos = 1
        for i, v in ipairs(list) do
            if string.find(v, "#g") then
                list[i] = string.gsub(v, "#g", groups[pos])
                pos = pos + 1
            end
        end
    end
    return list
end


function getLastName(name)
    local list = splitName(name)
    return list[#list]
end


function putLastNameFirst(tbName)
    local list = copy(tbName)
    table.insert(list, 1, table.remove(list))
    return list
end


function encloseParentheses(text)
    return "(" .. text .. ")"
end


function abbreviateFirstNames(tbName)
    local list = copy(tbName)
    for i = 1, #list-1 do
        list[i] = string.sub(list[i], 1, 1) .. "."
    end
    return list
end


function texFormatItalics(text)
    local f = function(x) return "{\\em " .. x .. "}" end
    return generalize(f, text)
end


function formatItalics(text)
    local f = function(x) return "\\emph{" .. x .. "}" end
    return generalize(f, text)
end


function formatBold(text)
    local f = function(x) return "\\textbf{" .. x .. "}" end
    return generalize(f, text)
end


function upperCase(arg)
    return generalize(string.upper, arg)
end


function prepend(str)
    return function(text)
        return str .. text
    end
end

function append(str)
    return function(text)
        return text .. str
    end
end

-- Considerar colocar esta função em outro arquivo: --<<<<<
function nextChar(ch)
    return string.char(string.byte(ch) + 1)
end


function formatItems(bblItems, formatter)

end


function sortBy(tb, field, comp)
    comp = comp or function(a, b) return a <= b end

    for ini = 1, #tb-1 do
        for i = ini, #tb do
            if not comp(tb[ini][field], tb[i][field]) then
                tb[ini], tb[i] = tb[i], tb[ini]
            end
        end
    end
end


function sortByAuthor(refs, comp)
    comp = comp or function(a, b) return a <= b end

    for ini = 1, #refs-1 do
        for i = ini, #refs do
            if not comp(refs[ini].author[1][1], refs[i].author[1][1]) then
                refs[ini], refs[i] = refs[i], refs[ini]
            end
        end
    end
end


function sortByAuthorLastName(refs, comp)
    comp = comp or function(a, b) return a <= b end

    for ini = 1, #refs-1 do
        for i = ini, #refs do
            if not comp(ltable.last(refs[ini].author[1]), ltable.last(refs[i].author[1])) then
                refs[ini], refs[i] = refs[i], refs[ini]
            end
        end
    end
end
