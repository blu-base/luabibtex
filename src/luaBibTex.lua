require"lfs"

require"luno.argReader"
require"luno.table"
require"luno.util"

require"luaBibTex.bibFunctions"
require"luaBibTex.auxParser"
require"luaBibTex.bibParser"
require"luaBibTex.bblGenerator"
require"luaBibTex.logger"
fsh = require"luaBibTex.fileSystemHelper"

--##############################################################################
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

--------------------------------------------------------------------------------
function searchBibStyles(bibStyleFileName, bibSearchPath)
    local bibStyles
    local styleFile
    for i, dir in ipairs(bibSearchPath) do
        styleFile = dir .. "/" .. bibStyleFileName
        if fsh.pathExists(styleFile) then
            bibStyles = dofile(styleFile)
            break
        end
    end

    return bibStyles, styleFile
end

--------------------------------------------------------------------------------
function main(...)

    bibSearchPath = {".", "../src"}

    local arg = {...}
    local baseName = arg[1]

    -- Pegar as informações no arquivo .aux:
    local auxFileName = baseName .. ".aux"
    local auxContents = luno.io.getTextFromFile(auxFileName)
    local auxData = auxParser.parseContents(auxContents)
    logger.logEvent("Usando arquivo aux: " .. auxFileName)

    -- Pegar as informações do arquivo .bib:
    local bibFileName = auxData.bibData .. ".bib"
    local bibContents = luno.io.getTextFromFile(bibFileName)
    local bibInfo = bibParser.parseContents(bibContents)

    -- Carregar estilos:
    local bibStyleFileName = auxData.bibStyle .. ".lbst"
    local bibStyle, styleFile = searchBibStyles(bibStyleFileName, bibSearchPath)
    logger.logEvent("Usando arquivo de estilos : " .. styleFile)

    -- Gerar .bbl:
    --bblGenerator.init(bibStyle)
    --local bblContents = bblGenerator.createBblContents(auxData, bibInfo)
    local bblContents = bibStyle:createBblContents(auxData, bibInfo)
    luno.io.saveTextToFile(bblContents, baseName .. ".bbl")

    --printDeep(bibInfo)
    --printDeep(auxData)
    --printDeep(referenceList)
    --printDeep(bblItems)
    --print(bblContents)
end


main(...)

