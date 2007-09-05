-- RFC 2141
local _G = _G
module("URI.urn")
_G.URI._subclass_of(_M, "URI")

local implementor = {}

function _init (class, uri, scheme)
    local self = _SUPER._init(class, uri, scheme)
    local nid = self:nid()

    local impclass = implementor[nid]
    if impclass then return impclass:_urn_init(self, nid) end

    impclass = _G.URI.urn
    if nid:find("^[A-Za-z%d][A-Za-z%d%-]*$") then
        -- make it a legal perl identifier
        local id = nid:gsub("-", "_")
        if id:find("^%d") then id = "_" .. id end

        local mod = _G.URI._attempt_require("URI.urn." .. id)
        if mod then impclass = mod end
    else
        _G.URI._warn("Illegal namespace identifier '" .. nid .. "' for URN '" ..
                     _G.tostring(self))
    end
    implementor[nid] = impclass

    return impclass:_urn_init(self, nid)
end

function _urn_init (class, self, nid)
    _G.setmetatable(self, class)
    return self
end

function _nid (self, new)
    local opaque = self:opaque()
    local _, colon = opaque:find("^[^:]*:")
    if new then
        local rest = colon and opaque:sub(colon) or ""
        self:opaque(new .. rest)
        -- TODO possible rebless
    end
    return colon and opaque:sub(1, colon - 1) or opaque
end

function nid (self, new)        -- namespace identifier
    local nid = self:_nid(new)
    return nid and nid:lower() or nil
end

function nss (self, new)        -- namespace specific string
    local opaque = self:opaque()
    local _, colon = opaque:find("^[^:]*:")
    local nid_end = colon and colon - 1 or opaque:len()
    if new then
        self:opaque(opaque:sub(1, nid_end) .. ":" .. new)
    end
    return colon and opaque:sub(colon + 1) or ""
end

function canonical (self)
    local new = _SUPER.canonical(self)
    local nid = self:_nid()
    if not nid:find("[A-Z]") or nid:find("%%") then return new end
    if new == self then new = new:clone() end
    new:nid(nid:lower())
    return new
end

-- vi:ts=4 sw=4 expandtab
