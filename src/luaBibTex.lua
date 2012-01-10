require"luno.argReader"
require"luno.tableEx"
require"luno.util"
require"luaBibTex.auxParser"
require"luaBibTex.bibParser"
require"luaBibTex.bibFunctions"
require"luaBibTex.bblGenerator"

--bibDir = [[C:\Eric\UFF\Mestrado\Dissertacao\Base\Dissertacao\trunk]]
--bibFile = bibDir .. "\\referencias.bib"
--auxFile = "dissertacao.aux"
--auxFileName = bibDir .. "\\" .. auxFile


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


function main(...)
    local arg = {...}
    local baseName = arg[1]

    -- Pegar as informações no arquivo .aux:
    local auxFileName = baseName .. ".aux"
    local auxContents = ioEx.getTextFromFile(auxFileName)
    local auxData = auxParser.parseContents(auxContents)

    -- Pegar as informações do arquivo .bib:
    --local bibFileName = bibDir .. "\\" .. auxData.bibData .. ".bib"
    local bibFileName = auxData.bibData .. ".bib"
    local bibContents = ioEx.getTextFromFile(bibFileName)
    local bibInfo = bibParser.parseContents(bibContents)

    --local bibStyleFileName = bibDir .. "\\" .. auxData.bibStyle .. ".lbst"
    --local bibStyleFileName = auxData.bibStyle .. ".lbst"
    --require(bibStyleFileName) --<<<<<
    dofile[[C:\usr\share\lua\luaBibTex\abnt.lbst]] --<<<<< Esta linha deve ser troacada pelas duas linhas acima.

    local bblContents = bblGenerator.createBblContents(auxData, bibInfo, bibStyles)

    ioEx.saveTextToFile(bblContents, baseName .. ".bbl")

    --printDeep(bibInfo)
    --printDeep(auxData)
    --printDeep(referenceList)
    --printDeep(bblItems)
    --print(bblContents)
end


main(...)

