require"luno/funcional"
require"luno/stringEx"
require"luno/tableEx"

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


function joinAuthors(authorsTable)
    local authorNames = F.map(stringEx.joinWords, authorsTable)
    return stringEx.join(authorNames, ", ")
end


function splitName(name)
    name = stringEx.trim(name)
    local groups = {}
    for val in string.gmatch(name, "{(.+)}") do
        table.insert(groups, val)
    end
    name = string.gsub(name, "{.+}", "#g")

    local list = stringEx.split(name, "%s")

    if not tableEx.isEmpty(groups) then
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


