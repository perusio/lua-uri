local _G = _G
module("URI.file.Unix", package.seeall)
URI._subclass_of(_M, "URI.file.Base")

function _file_extract_path (class, path)
    -- tidy path
    path = path:gsub("//+", "/")
    while path:find("/%./") do path = path:gsub("/%./", "/") end
    if path:find("^[^:/]+:") then path = "./" .. path end -- look like "scheme:"
    return path, false
end

function _file_is_absolute (class, path)
    return not not path:find("^/")
end

function file (class, uri)
    local path = {}

    local auth = uri:authority()
    if auth then
        if auth:lower() ~= "localhost" and auth ~= "" then
            auth = _G.URI.Escape.uri_unescape(auth)
            if not class:_file_is_localhost(auth) then
                path[#path + 1] = ""
                path[#path + 1] = ""
                path[#path + 1] = auth
            end
        end
    end

    local ps = uri:path_segments()
    if #path > 0 then _G.table.remove(ps, 1) end
    for _, v in _G.ipairs(ps) do path[#path + 1] = v end

    for _, v in _G.ipairs(path) do
        -- Unix file/directory names are not allowed to contain '\0' or '/'
        -- should we really not allow slashes?
        if v:find("%z") or v:find("/") then return end
    end

    return _G.table.concat(path, "/")
end

-- vi:ts=4 sw=4 expandtab
