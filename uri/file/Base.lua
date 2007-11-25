local M = { _NAME = "uri.file.Base" }
M.__index = M

local URI = require "uri"
local URIFile = require "uri.file"
local Util = require "uri._util"

function M.new (class, path)
    if not path then path = "" end
    if type(path) ~= "string" then path = tostring(path) end

    local auth, escaped_path
    path, auth = class:_file_extract_authority(path)
    path, escaped_path = class:_file_extract_path(path)

    if auth then
        auth = auth:gsub("%%", "%%25")
        auth = "//" .. Util.uri_encode(auth, "/?#")
        if path then
            if not path:find("^/") then path = "/" .. path end
        else
            path = ""
        end
    else
        if not path then return end
        auth = ""
    end

    if not escaped_path then path = Util.uri_encode(path, "%%;?") end
    path = path:gsub("#", "%%23")

    local uri = auth .. path
    if uri:find("^/") then uri = "file:" .. uri end

    return URI:new(uri, "file")
end

function M._file_extract_authority (class, path)
    if not class:_file_is_absolute(path) then return path, nil end
    return path, URIFile.DEFAULT_AUTHORITY
end

function M._file_extract_path () end
function M._file_is_absolute () end

function M._file_is_localhost (class, host)
    host = host:lower()
    if host == "localhost" then return true end
    -- TODO - don't know if Lua has the libraries for this, so for now just
    -- kludge in '127.0.0.1' as a stop-gap measure.
    --eval {
    --    require Net::Domain;
    --    lc(Net::Domain::hostfqdn()) eq $host ||
    --    lc(Net::Domain::hostname()) eq $host;
    --};
    return host == "127.0.0.1"
end

function M.file () end
function M.dir (self, os) return self:file(os) end

return M
-- vi:ts=4 sw=4 expandtab
