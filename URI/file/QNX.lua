local _G = _G
module("URI.file.QNX", package.seeall)
URI._subclass_of(_M, "URI.file.Unix")

function _file_extract_path (class, path)
    -- tidy path
    path = path:gsub("(.)//+", "%1/")   -- ^// is correct
    while path:find("/%./") do path = path:gsub("/%./", "/") end
    if path:find("^[^:/]+:") then path = "./" .. path end -- look like "scheme:"
    return path, false
end

-- vi:ts=4 sw=4 expandtab
