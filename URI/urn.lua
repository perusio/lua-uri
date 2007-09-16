-- RFC 2141
local M = { _MODULE_NAME = "URI.urn" }
local URI = require "URI"
URI._subclass_of(M, "URI")

local implementor = {}

function M._init (class, uri, scheme)
    local self = M._SUPER._init(class, uri, scheme)
    local nid = self:nid()

    local impclass = implementor[nid]
    if impclass then return impclass:_urn_init(self, nid) end

    impclass = URI.urn
    if nid:find("^[A-Za-z%d][A-Za-z%d%-]*$") then
        -- make it a legal perl identifier
        local id = nid:gsub("-", "_")
        if id:find("^%d") then id = "_" .. id end

        local mod = URI._attempt_require("URI.urn." .. id)
        if mod then impclass = mod end
    else
        URI._warn("Illegal namespace identifier '" .. nid .. "' for URN '" ..
                     tostring(self))
    end
    implementor[nid] = impclass

    return impclass:_urn_init(self, nid)
end

function M._urn_init (class, self, nid)
    setmetatable(self, class)
    return self
end

function M._nid (self, new)
    local opaque = self:opaque()
    local _, colon = opaque:find("^[^:]*:")
    if new then
        local rest = colon and opaque:sub(colon) or ""
        self:opaque(new .. rest)
        -- TODO possible rebless
    end
    return colon and opaque:sub(1, colon - 1) or opaque
end

function M.nid (self, new)        -- namespace identifier
    local nid = self:_nid(new)
    return nid and nid:lower() or nil
end

function M.nss (self, new)        -- namespace specific string
    local opaque = self:opaque()
    local _, colon = opaque:find("^[^:]*:")
    local nid_end = colon and colon - 1 or opaque:len()
    if new then
        self:opaque(opaque:sub(1, nid_end) .. ":" .. new)
    end
    return colon and opaque:sub(colon + 1) or ""
end

function M.canonical (self)
    local new = M._SUPER.canonical(self)
    local nid = self:_nid()
    if not nid:find("[A-Z]") or nid:find("%%") then return new end
    if new == self then new = new:clone() end
    new:nid(nid:lower())
    return new
end

return M
-- vi:ts=4 sw=4 expandtab
