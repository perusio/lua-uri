-- RFC 3061
local _G = _G
module("URI.urn.oid", package.seeall)
URI._subclass_of(_M, "URI.urn")

function oid (self, new)
    local old = self:nss()
    if new then
        if _G.type(new) ~= "string" then new = _G.URI._join(".", new) end
        self:nss(new)
    end

    local result = _G.URI._split("%.", old)
    for i, v in _G.ipairs(result) do
        result[i] = _G.tonumber(v)
    end
    return result
end

-- vi:ts=4 sw=4 expandtab
