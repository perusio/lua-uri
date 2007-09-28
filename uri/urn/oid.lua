-- RFC 3061
local M = { _NAME = "uri.urn.oid" }
local URI = require "uri"
URI._subclass_of(M, "uri.urn")

function M.oid (self, new)
    local old = self:nss()
    if new then
        if type(new) ~= "string" then new = table.concat(new, ".") end
        self:nss(new)
    end

    local result = URI._split("%.", old)
    for i, v in ipairs(result) do
        result[i] = tonumber(v)
    end
    return result
end

return M
-- vi:ts=4 sw=4 expandtab
