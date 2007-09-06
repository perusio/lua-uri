-- Copyright (c) 1998 Graham Barr <gbarr@pobox.com>. All rights reserved.
-- This program is free software; you can redistribute it and/or
-- modify it under the same terms as Perl itself.

local _G = _G
module("URI._ldap")

local function _ldap_elem (self, elem, ...)
    local query = self:query()
    local bits  = _G.URI._split("%?", (query or ""))
    while #bits < 4 do bits[#bits + 1] = "" end
    local old = bits[elem]

    if _G.select('#', ...) > 0 then
        local new = ...
        new = new:gsub("%?", "%%3F")
        bits[elem] = new
        query = _G.table.concat(bits, "?"):gsub("%?+$", "", 1)
        if query == "" then query = nil end
        self:query(query)
    end

    return old
end

function dn (self, ...)
    local old = self:path(...)
    return _G.URI.Escape.uri_unescape(old:gsub("^/", "", 1))
end

function attributes_encoded (self, ...)
    if _G.select('#', ...) > 0 then
        local new = ...
        for i, v in _G.ipairs(new) do
            new[i] = v:gsub(",", "%%2C")
        end
        return _ldap_elem(self, 1, _G.URI._join(",", new))
    else
        return _ldap_elem(self, 1)
    end
end

function attributes (self, ...)
    local old = self:attributes_encoded(...)

    local oldtbl = _G.URI._split(",", old)
    for i, v in _G.ipairs(oldtbl) do
        oldtbl[i] = _G.URI.Escape.uri_unescape(v)
    end

    return oldtbl
end

function TODO_scope (self, ...)
    local old = _ldap_elem(self, 2, ...)
    if old then return _G.URI.Escape.uri_unescape(old) end
end

function scope (self, ...)
    local old = self:TODO_scope(...)
    if old and old ~= "" then return old else return "base" end
end

function TODO_filter (self, ...)
    local old = _ldap_elem(self, 3, ...)
    if old then return _G.URI.Escape.uri_unescape(old) end
end

function filter (self, ...)
    local old = self:TODO_filter(...)
    if old and old ~= "" then return old else return "(objectClass=*)" end
end

function extensions (self, new)
    local ext = {}
    if new then
        for key, val in _G.pairs(new) do
            key = key:gsub(",", "%%2C")
            val = val:gsub(",", "%%2C")
            ext[#ext + 1] = key .. "=" .. val
        end
    end

    local old
    if #ext > 0 then
        old = _ldap_elem(self, 4, _G.table.concat(ext, ","))
    else
        old = _ldap_elem(self, 4)
    end

    local olditems = _G.URI._split(",", old)
    local oldmap = {}
    for _, v in _G.ipairs(olditems) do
        local _, _, key, val = v:find("^([^=]+)=(.*)$")
        if key then
            key = _G.URI.Escape.uri_unescape(key)
            val = _G.URI.Escape.uri_unescape(val)
            oldmap[key] = val
        end
    end
    return oldmap
end

function canonical (self)
    local other = self:_nonldap_canonical()

    -- The stuff below is not as efficient as one might hope...

    if other == self then other = other:clone() end

    other:dn(_normalize_dn(other:dn()))

    -- Should really know about mixed case "postalAddress", etc...
    local attrs = other:attributes()
    for i, v in _G.ipairs(attrs) do attrs[i] = v:lower() end
    other:attributes(attrs)

    -- Lowecase scope, remove default
    local old_scope = other:scope()
    local new_scope = old_scope:lower()
    if new_scope == "base" then new_scope = "" end
    if new_scope ~= old_scope then other:scope(new_scope) end

    -- Remove filter if default
    local old_filter = other:filter()
    if old_filter:lower() == "(objectclass=*)" or
       old_filter:lower() == "objectclass=*" then
        other:filter("")
    end

    -- Lowercase extensions types and deal with known extension values
    local ext = other:extensions()
    local canonext = {}
    for key, val in _G.pairs(ext) do
        key = key:lower()
        if key:find("^!?bindname$") then val = _normalize_dn(val) end
        canonext[key] = val
    end
    if _G.next(canonext) then other:extensions(canonext) end

    return other
end

function _normalize_dn (dn)     -- RFC 2253
    return dn
    -- The code below will fail if the "+" or "," is embedding in a quoted
    -- string or simply escaped...
--    my @dn = split(/([+,])/, $dn);
--    for (@dn) {
--        s/^([a-zA-Z]+=)/lc($1)/e;
--    }
--    return join("", @dn);
end

-- vi:ts=4 sw=4 expandtab
