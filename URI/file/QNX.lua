local M = { _MODULE_NAME = "URI.file.QNX" }
local URI = require "URI"
URI._subclass_of(M, "URI.file.Unix")

function M._file_extract_path (class, path)
    -- tidy path
    path = path:gsub("(.)//+", "%1/")   -- ^// is correct
    while path:find("/%./") do path = path:gsub("/%./", "/") end
    if path:find("^[^:/]+:") then path = "./" .. path end -- look like "scheme:"
    return path, false
end

return M
-- vi:ts=4 sw=4 expandtab
