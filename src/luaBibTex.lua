require"luno/argReader"
require"luno/tableEx"
require"auxParser"
require"bibParser"
require"bibFunctions"

bibDir = [[C:\Eric\UFF\Mestrado\Dissertacao\Base\Dissertacao\trunk]]
--bibFile = bibDir .. "\\referencias.bib"
auxFile = "dissertacao.aux"
auxFileName = bibDir .. "\\" .. auxFile


--##############################################################################
fieldTypes =
{
    article       = {"author", "title", "journal",
                     "volume", "number", "pages",
                     "year", "month", "note"},

    book          = {"author", "title", "publisher",
                     "volume", "number", "series",
                     "address", "edition", "year", "month", "note"},

    incollection  = {"author", "title", "booktitle", "publisher",
                     "year", "editor", "volume", "number",
                     "series", "type", "chapter", "pages",
                     "address", "edition", "month", "note"},

    techreport    = {"author", "title", "institution", "year",
                     "type", "number", "address", "month", "note"},

    booklet       = {"title", "author", "howpublished", "address",
                     "month", "year", "note"},

    conference    = {"author", "title", "booktitle", "editor",
                    "volume", "number", "series", "pages",
                    "address", "year", "month", "publisher", "note"},

    mastersthesis = {"author", "title", "school", "type",
                     "address", "year", "month", "note"},

    phdthesis     = {"author", "title", "year", "school",
                     "address", "month", "keywords", "note"},

    inbook        = {"author", "title", "editor", "booktitle", "chapter",
                     "pages", "publisher", "year", "volume", "number",
                     "series", "type", "address", "edition", "month", "note"},

    misc          = {"author", "title", "howpublished",
                     "year", "month", "note"},
}
fieldTypes.inproceedings = fieldTypes.conference


--##############################################################################


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
            fields[key] = joinAuthors(F.map(F.pipe(unpack(processors)), value))
        else
            fields[key] = F.pipe(unpack(processors))(value)
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
    local bblHeader = [[\begin{thebibliography}{#n}
\providecommand{\natexlab}[1]{#1}
\providecommand{\url}[1]{\texttt{#1}}
\expandafter\ifx\csname urlstyle\endcsname\relax
  \providecommand{\doi}[1]{doi: #1}\else
  \providecommand{\doi}{doi: \begingroup \urlstyle{rm}\Url}\fi

]]
    bblHeader = string.gsub(bblHeader, "#n", #bblItems)

    bblContents = bblContents .. bblHeader
    for i, item in ipairs(bblItems) do
        bblContents = bblContents .. writeBblItem(item) .. "\n\n"
    end

    bblContents = bblContents .. "\n\n\\end{thebibliography}\n"

    --printDeep(bibInfo)
    --printDeep(auxData)
    --printDeep(referenceList)
    --printDeep(bblItems)
    print(bblContents)
end

main()

