local M = { _NAME = "uri.urn.isbn" }
local Util = require "uri._util"
local URN = require "uri.urn"
Util.subclass_of(M, URN)

-- This implements the 'isbn' NID defined in RFC 3187, and is consistent
-- with the same NID suggested in RFC 2288.

local function _valid_isbn (isbn)
    if not isbn:find("^[-%d]+[%dXx]$") then return false end
    local ISBN = Util.attempt_require("isbn")
    if ISBN then return ISBN:new(isbn) end
    return isbn
end

local function _normalize_isbn (isbn)
    isbn = isbn:gsub("%-", ""):upper()
    local ISBN = Util.attempt_require("isbn")
    if ISBN then return tostring(ISBN:new(isbn)) end
    return isbn
end

function M.init (self)
    local nss = self:nss()
    if not _valid_isbn(nss) then return nil, "invalid ISBN value" end
    self:nss(_normalize_isbn(nss))
    return self
end

function M.isbn_digits (self, new)
    local old = self:nss():gsub("%-", "")

    if new then
        if not _valid_isbn(new) then error("bad ISBN value '" .. new .. "'") end
        self:nss(_normalize_isbn(new))
    end

    return old
end

function M.isbn (self, new)
    local ISBN = require "isbn"
    local old = ISBN:new(self:nss())
    if new then self:nss(tostring(new)) end
    return old
end

return M
-- vi:ts=4 sw=4 expandtab
