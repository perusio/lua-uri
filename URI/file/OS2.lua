local M = { _MODULE_NAME = "URI.file.OS2" }
local URI = require "URI"
URI._subclass_of(M, "URI.file.Win32")

local URIFile = require "URI.file"

-- The Win32 version translates k:/foo to file://k:/foo  (?!)
-- We add an empty host

function M._file_extract_authority (class, path)
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

function M.file (self, os)
    local p = URIFile.Win32.file(self, os)
    if not p then return end
    return p:gsub("\\", "/")
end

return M
-- vi:ts=4 sw=4 expandtab
