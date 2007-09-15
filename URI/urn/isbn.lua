-- RFC 3187
local _G = _G
module("URI.urn.isbn", package.seeall)
URI._subclass_of(_M, "URI.urn")

local ISBN = nil        -- load the 'ISBN' module into this on demand

function isbn (self, new)
    if not ISBN then ISBN = _G.require "isbn" end
    local isbn = ISBN:new(self:nss())
    if new then self:nss(_G.tostring(new)) end
    return isbn
end

function canonical (self)
    local canon = _SUPER.canonical(self)
    local isbn = canon:isbn()
    if not isbn or _G.tostring(isbn) == canon:nss() then return canon end
    canon:nss(_G.tostring(isbn))
    return canon
end

-- vi:ts=4 sw=4 expandtab
