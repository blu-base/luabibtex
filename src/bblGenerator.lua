
bblGenerator = {}

--[[
local bibData_mt =
{
    __index = function(t, i) return "" end
}
]]

function bblGenerator.createBblData(auxData, bibData, bibStyle)
    -- Criar lista de referências:
    local bblData = {}
    for i, citation in ipairs(auxData.citations) do -- => Filtrar pelas publicações que aparecem nos \citation:
        local item = bibData[citation]
        -- Armazenar o nome da referência:
        item.refName = citation
        -- Armazenar a ordem de aparição no texto:
        item.docOrder = i

        table.insert(bblData, item)
    end

    -- Criar lista ordenada de acordo com o critério definido no estilo:
    bibStyle.sortBblData(bblData)

    return bblData
end


function bblGenerator.createBblContents(auxData, bibData, bibStyle)

    local bblData = bblGenerator.createBblData(auxData, bibData, bibStyle)

    -- Escrever conteúdo do arquivo .bbl:
    local bblContents = ""
    bblContents = bblContents .. "\\begin{thebibliography}{#n}\n"
    bblContents = string.gsub(bblContents, "#n", #bblData)
    bblContents = bblContents .. bibStyle.customBblHeader
    --printDeep(bblData) --<<<<<
    for i, bblEntry in ipairs(bblData) do
        --print(i, bblEntry.refName) --<<<<<
        bblContents = bblContents .. bibStyle.genItem(bblEntry) .. "\n\n"
    end
    bblContents = bblContents .. "\\end{thebibliography}\n"

    return bblContents
end

