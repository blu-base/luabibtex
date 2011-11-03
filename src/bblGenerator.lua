

bblGenerator = {}

function bblGenerator.createBblContents(auxData, bibData, styles)

    -- Filtrar pelas publicações que aparecem nos \citation:
    local referenceList = {}
    for i, citation in ipairs(auxData.citations) do
        referenceList[citation] = bibData[citation]
    end

    -- Criar lista ordenada de pelo sobrenome do autor principal:
    local bblItems = bblGenerator.createBblItems(referenceList)

    -- Escrever arquivo .bbl:
    local bblContents = ""
    local bblHeader = "\\begin{thebibliography}{#n}\n"
    bblHeader = string.gsub(bblHeader, "#n", #bblItems)
    bblHeader = bblHeader .. styles.customBblHeader

    local bblFooter = "\n\\end{thebibliography}\n"

    bblContents = bblContents .. bblHeader
    for i, item in ipairs(bblItems) do
        bblContents = bblContents .. bblGenerator.writeBblItem(item) .. "\n\n"
    end

    bblContents = bblContents .. bblFooter

    return bblContents
end


function bblGenerator.createBblItems(bibData)
    -- Verificar se há autores com duas publicações no mesmo ano e diferenciar:
    local lookup = {}
    for refName, refData in pairs(bibData) do
        local lastName = tableEx.last(refData.author[1])
        local lookupIndex = lastName .. refData.year
        if lookup[lookupIndex] == nil then
            lookup[lookupIndex] = {refName}
        else
            table.insert(lookup[lookupIndex], refName)
        end
    end

    for lookupIndex, refNames in pairs(lookup) do
        if #refNames > 1 then
            local currentSuffix = "a"
            for i, name in ipairs(refNames) do
                local refData = bibData[name]
                refData.year = refData.year .. currentSuffix
                currentSuffix = nextChar(currentSuffix)
            end
        end
    end

    -- Criar lista ordenada de pelo sobrenome do autor principal:
    local bblItems = {}
    for refName, refData in pairs(bibData) do
        local mainAuthor = refData.author[1]
        local lastName = string.lower(tableEx.last(mainAuthor))
        local pos = 1
        for i = 1, #bblItems do
            local currentMainAuthor = bblItems[i].author[1]
            local currentLastName = string.lower(tableEx.last(currentMainAuthor))
            if lastName < currentLastName then break end
            pos = pos + 1
        end
        refData.refName = refName
        table.insert(bblItems, pos, refData)
    end
    return bblItems
end


function bblGenerator.writeBblItem(bblItem)
    local authors = bblItem.author
    local mainAuthorLastName = string.upper(tableEx.last(authors[1]))
    local splittedMainAuthorLastName = stringEx.splitWords(mainAuthorLastName)
    if #splittedMainAuthorLastName > 1 then
        mainAuthorLastName = "{" .. stringEx.joinWords(splittedMainAuthorLastName).. "}"
    end
    local year = bblItem.year

    local refAlias = mainAuthorLastName
    if #authors > 1 then
        refAlias = refAlias .. " ET~AL."
    end
    refAlias = refAlias .. encloseParentheses(year)
    if #authors > 1 then
        local authorsLastNameList = stringEx.join(F.map(F.compose(string.upper, tableEx.last), authors), ", ")
        refAlias = stringEx.trim(refAlias .. (authorsLastNameList or ""))
    end

    local strBblItem = "\\bibitem[" .. refAlias .. "]{" .. bblItem.refName .. "}\n"

    local refType = bblItem.refType
    local style = bibStyles[refType] or {}
    for key, value in pairs(bibStyles.default) do
        style[key] = style[key] or value
    end

    local fields = {}
    for key, value in pairs(bblItem) do
        local processors = style[key]
        -- Se falhar, não fazer nada:
        if processors == nil then
            processors = {function(x) return x end}
        end

        if key == "author" then
            fields[key] = joinAuthors(F.map(F.pipe(processors), value))
        else
            fields[key] = F.pipe(processors)(value)
        end
    end

    local strItemBody = style.layout
    --print(refType) --<<<<<
    for i, v in ipairs(fieldTypes[refType]) do
        strItemBody = string.gsub(strItemBody, "#"..v, fields[v] or "")
    end
    strItemBody = string.gsub(strItemBody, "#%w+", "")

    strBblItem = strBblItem .. strItemBody
    return strBblItem
end
