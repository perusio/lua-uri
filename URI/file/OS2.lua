local _G = _G
module("URI.file.OS2", package.seeall)
URI._subclass_of(_M, "URI.file.Win32")

-- The Win32 version translates k:/foo to file://k:/foo  (?!)
-- We add an empty host

function _file_extract_authority (class, path)
    local _, skipchars, auth = path:find("^\\\\([^\\]+)")   -- UNC
    if auth then return path:sub(skipchars + 1), auth end
    _, skipchars, auth = path:find("^//([^/]+)")            -- UNC too?
    if auth then return path:sub(skipchars + 1), auth end

    -- allow for ab: drives as well as a: ones
    if path:find("^[a-zA-Z]:") or path:find("^[a-zA-Z][a-zA-Z]:") then
        return path, ""
    end
    return path, nil
end

function file (self, os)
    local p = _G.URI.file.Win32.file(self, os)
    if not p then return end
    return p:gsub("\\", "/")
end

-- vi:ts=4 sw=4 expandtab
