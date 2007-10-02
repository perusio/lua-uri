local M = { _NAME = "uri.Split" }

local Util = require "uri._util"

-- TODO this doesn't unescape things, even though uri_join escapes them, is
-- that the right thing?
function M.uri_split (uri)
    local _, p, nxt, scheme, auth, path, query, frag
    _, p, scheme = uri:find("^([^:/?#]+):")
    if p then uri = uri:sub(p + 1) end
    _, p, auth   = uri:find("^//([^/?#]*)")
    if p then uri = uri:sub(p + 1) end
    _, p, path   = uri:find("^([^?#]*)")
    if p then uri = uri:sub(p + 1) end
    _, p, query  = uri:find("^%?([^#]*)")
    if p then uri = uri:sub(p + 1) end
    _, p, frag   = uri:find("^#(.*)")
    return scheme, auth, path, query, frag
end

function M.uri_join (scheme, auth, path, query, frag)
    local uri = scheme and scheme .. ":" or ""
    if not path then path = "" end
    if auth then
        auth = Util.uri_escape(auth, "/?#")
        uri = uri .. "//" .. auth
        if path ~= "" and not path:find("^/") then path = "/" .. path end
    elseif path:find("^//") then
        uri = uri .. "//"   -- XXX force empty auth
    end
    if uri == "" then
        while path:find("^[^:/?#]+:") do path = path:gsub("(:)", "%%3A", 1) end
    end
    path = Util.uri_escape(path, "?#")
    uri = uri .. path
    if query then
        query = Util.uri_escape(query, "#")
        uri = uri .. "?" .. query
    end
    if frag then uri = uri .. "#" .. frag end
    return uri
end

return M
-- vi:ts=4 sw=4 expandtab
