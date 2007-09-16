-- RFC 3187
local M = { _MODULE_NAME = "URI.urn.isbn" }
local URI = require "URI"
URI._subclass_of(M, "URI.urn")

local ISBN = nil        -- load the 'ISBN' module into this on demand

function M.isbn (self, new)
    if not ISBN then ISBN = require "isbn" end
    local isbn = ISBN:new(self:nss())
    if new then self:nss(tostring(new)) end
    return isbn
end

function M.canonical (self)
    local canon = M._SUPER.canonical(self)
    local isbn = canon:isbn()
    if not isbn or tostring(isbn) == canon:nss() then return canon end
    canon:nss(tostring(isbn))
    return canon
end

return M
-- vi:ts=4 sw=4 expandtab
