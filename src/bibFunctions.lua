require"luno/funcional"
require"luno/stringEx"
require"luno/tableEx"


function joinAuthors(authorsTable)
    return stringEx.join(authorsTable, ", ")
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


function putLastNameFirst(name)
    local list = splitName(name)
    table.insert(list, 1, table.remove(list))
    return stringEx.join(list, " ")
end


function encloseParentheses(text)
    return "(" .. text .. ")"
end

function abbreviateFirstNames(name)
    local list = splitName(name)
    for i = 1, #list-1 do
        list[i] = string.sub(list[i], 1, 1) .. "."
    end
    return stringEx.join(list, " ")
end


function formatItalics(text)
    return "\\emph{" .. text .. "}"
end


function formatBold(text)
    return "\\textbf{" .. text .. "}"
end

--function main()
--    local name = ""
--    print(F.pipe(abbreviateFirstNames, putLastNameFirst, string.upper)(name))
--end
--main()
