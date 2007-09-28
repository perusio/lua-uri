local M = { _NAME = "uri.file.Unix" }
local URI = require "uri"
URI._subclass_of(M, "uri.file.Base")

local Esc = require "uri.Escape"

function M._file_extract_path (class, path)
    -- tidy path
    path = path:gsub("//+", "/")
    while path:find("/%./") do path = path:gsub("/%./", "/") end
    if path:find("^[^:/]+:") then path = "./" .. path end -- look like "scheme:"
    return path, false
end

function M._file_is_absolute (class, path)
    return not not path:find("^/")
end

function M.file (class, uri)
    local path = {}

    local auth = uri:authority()
    if auth then
        if auth:lower() ~= "localhost" and auth ~= "" then
            auth = Esc.uri_unescape(auth)
            if not class:_file_is_localhost(auth) then
                path[#path + 1] = ""
                path[#path + 1] = ""
                path[#path + 1] = auth
            end
        end
    end

    local ps = uri:path_segments()
    if #path > 0 then table.remove(ps, 1) end
    for _, v in ipairs(ps) do path[#path + 1] = v end

    for _, v in ipairs(path) do
        -- Unix file/directory names are not allowed to contain '\0' or '/'
        -- should we really not allow slashes?
        if v:find("%z") or v:find("/") then return end
    end

    return table.concat(path, "/")
end

return M
-- vi:ts=4 sw=4 expandtab
