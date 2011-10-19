require"luno/argReader"
require"luno/tableEx"
require"auxParser"
require"bibParser"
require"bibFunctions"

bibDir = [[C:\Eric\UFF\Mestrado\Dissertacao\Base\Dissertacao\trunk]]
--bibFile = bibDir .. "\\referencias.bib"
auxFile = "dissertacao.aux"
auxFileName = bibDir .. "\\" .. auxFile

fieldTypes =
{
    article = {"author", "title", "journal", "volume", "number", "pages", "year", "month", "note"},
    book = {"author", "title", "publisher", "volume", "number", "series", "address", "edition", "year", "month", "note"},
}

function writeBblItem(bblItem)
    local authors = bblItem.author
    local mainAuthorLastName = F.compose(string.upper, getLastName)(authors[1])
    local year = bblItem.year

    local refAlias = mainAuthorLastName
    if #authors > 1 then
        refAlias = refAlias .. " ET~AL."
    end
    refAlias = refAlias .. encloseParentheses(year)
    if #authors > 1 then
        local authorsLastNameList = stringEx.join(F.map(F.compose(string.upper, getLastName), authors), ", ")
        refAlias = stringEx.trim(refAlias .. (authorsLastNameList or ""))
    end

    local strBblItem = "\\bibitem[".. refAlias .. "]{" .. bblItem.refName .. "}\n"

    local refType = bblItem.refType
    local fields = {}
    for key, value in pairs(bblItem) do
        local processors
        processors = bibStyles[refType][key]
        -- Se falhar tenta carregar o default:
        if processors == nil then
            processors = bibStyles.default[key]
        end
        -- Se tudo falhar, não fazer nada:
        if processors == nil then
            processors = {function(x) return x end}
        end

        if key == "author" then
            fields[key] = joinAuthors(F.map(F.pipe(unpack(processors)), value))
        else
            fields[key] = F.pipe(unpack(processors))(value)
        end
    end

    local strItemBody = bibStyles[refType].layout
    for i, v in ipairs(fieldTypes[refType]) do
        strItemBody = string.gsub(strItemBody, "#"..v, fields[v] or "")
    end

    strBblItem = strBblItem .. strItemBody
    return strBblItem
end

function main(...)
    -- Pegar as informações no arquivo .aux:
    local auxContents = ioEx.getTextFromFile(auxFileName)
    local auxData = auxParser.parseContents(auxContents)

    -- Pegar as informações do arquivo .bib:
    local bibFileName = bibDir .. "\\" .. auxData.bibData .. ".bib"
    local bibContents = ioEx.getTextFromFile(bibFileName)
    local bibInfo = bibParser.parseContents(bibContents)

    local bibStyleFileName = bibDir .. "\\" .. auxData.bibStyle .. ".lbst"
    --dofile(bibStyleFileName) --<<<<<
    dofile("abnt.lbst")

    -- Filtrar pelas publicações que aparecem nos \citation:
    local referenceList = {}
    for i, citation in ipairs(auxData.citations) do
        referenceList[citation] = bibInfo[citation]
    end

    -- Criar lista ordenada de pelo sobrenome do autor principal:
    local bblItems = {}
    for refName, refData in pairs(referenceList) do
        local mainAuthor = refData.author[1]
        local lastName = string.lower(getLastName(stringEx.trim(mainAuthor)))
        local pos = 1
        for i = 1, #bblItems do
            local aux = string.lower(getLastName(stringEx.trim(bblItems[i].author[1])))
            if lastName < aux then break end
            pos = pos + 1
        end
        refData.refName = refName
        table.insert(bblItems, pos, refData)
    end

    -- Escrever arquivo .bbl:
    local bblContents = ""
    for i, item in ipairs(bblItems) do
        if item.refType == "article" then
            bblContents = bblContents .. writeBblItem(item) .. "\n\n"
        end
    end

    --printDeep(bibInfo)
    --printDeep(auxData)
    --printDeep(referenceList)
    --printDeep(bblItems)
    print(bblContents)
end

main()

