

bblGenerator = {}
--[[
function bblGenerator.init(style)
    bblGenerator.style = style
end


function bblGenerator.createBblContents(auxData, bibData)

    local style = bblGenerator.style

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
    bblHeader = bblHeader .. style.customBblHeader

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
        local lastName = luno.table.last(refData.author[1])
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
    -- !!! Na verdade o critério de ordenação deve ser definido no estilo. !!!! <<<<<
    local bblItems = {}
    for refName, refData in pairs(bibData) do
        local mainAuthor = refData.author[1]
        local lastName = string.lower(luno.table.last(mainAuthor))
        local pos = 1
        for i = 1, #bblItems do
            local currentMainAuthor = bblItems[i].author[1]
            local currentLastName = string.lower(luno.table.last(currentMainAuthor))
            if lastName < currentLastName then break end
            pos = pos + 1
        end
        refData.refName = refName
        table.insert(bblItems, pos, refData)
    end
    return bblItems
end


function bblGenerator.writeBblItem(bblItem)
    local style = bblGenerator.style
    return style:genItem(bblItem)
end
]]
