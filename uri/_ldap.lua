-- Copyright (c) 1998 Graham Barr <gbarr@pobox.com>. All rights reserved.
-- This program is free software; you can redistribute it and/or
-- modify it under the same terms as Perl itself.

local M = { _NAME = "uri._ldap" }
local URI = require "uri"

local Util = require "uri._util"

local function _ldap_elem (self, elem, ...)
    local query = self:query()
    local bits  = URI._split("%?", (query or ""))
    while #bits < 4 do bits[#bits + 1] = "" end
    local old = bits[elem]

    if select('#', ...) > 0 then
        local new = ...
        new = new:gsub("%?", "%%3F")
        bits[elem] = new
        query = table.concat(bits, "?"):gsub("%?+$", "", 1)
        if query == "" then query = nil end
        self:query(query)
    end

    return old
end

local function _normalize_dn (dn)     -- RFC 2253
    return dn
    -- The code below will fail if the "+" or "," is embedding in a quoted
    -- string or simply escaped...
--    my @dn = split(/([+,])/, $dn);
--    for (@dn) {
--        s/^([a-zA-Z]+=)/lc($1)/e;
--    }
--    return join("", @dn);
end

function M.dn (self, ...)
    local old = self:path(...)
    return Util.uri_unescape(old:gsub("^/", "", 1))
end

function M.attributes_encoded (self, ...)
    if select('#', ...) > 0 then
        local new = ...
        for i, v in ipairs(new) do
            new[i] = v:gsub(",", "%%2C")
        end
        return _ldap_elem(self, 1, table.concat(new, ","))
    else
        return _ldap_elem(self, 1)
    end
end

function M.attributes (self, ...)
    local old = self:attributes_encoded(...)

    local oldtbl = URI._split(",", old)
    for i, v in ipairs(oldtbl) do
        oldtbl[i] = Util.uri_unescape(v)
    end

    return oldtbl
end

function M.TODO_scope (self, ...)
    local old = _ldap_elem(self, 2, ...)
    if old then return Util.uri_unescape(old) end
end

function M.scope (self, ...)
    local old = self:TODO_scope(...)
    if old and old ~= "" then return old else return "base" end
end

function M.TODO_filter (self, ...)
    local old = _ldap_elem(self, 3, ...)
    if old then return Util.uri_unescape(old) end
end

function M.filter (self, ...)
    local old = self:TODO_filter(...)
    if old and old ~= "" then return old else return "(objectClass=*)" end
end

function M.extensions (self, new)
    local ext = {}
    if new then
        for key, val in pairs(new) do
            key = key:gsub(",", "%%2C")
            val = val:gsub(",", "%%2C")
            ext[#ext + 1] = key .. "=" .. val
        end
    end

    local old
    if #ext > 0 then
        old = _ldap_elem(self, 4, table.concat(ext, ","))
    else
        old = _ldap_elem(self, 4)
    end

    local olditems = URI._split(",", old)
    local oldmap = {}
    for _, v in ipairs(olditems) do
        local _, _, key, val = v:find("^([^=]+)=(.*)$")
        if key then
            key = Util.uri_unescape(key)
            val = Util.uri_unescape(val)
            oldmap[key] = val
        end
    end
    return oldmap
end

function M.canonical (self)
    local other = self:_nonldap_canonical()

    -- The stuff below is not as efficient as one might hope...

    if other == self then other = other:clone() end

    other:dn(_normalize_dn(other:dn()))

    -- Should really know about mixed case "postalAddress", etc...
    local attrs = other:attributes()
    for i, v in ipairs(attrs) do attrs[i] = v:lower() end
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
    for key, val in pairs(ext) do
        key = key:lower()
        if key:find("^!?bindname$") then val = _normalize_dn(val) end
        canonext[key] = val
    end
    if next(canonext) then other:extensions(canonext) end

    return other
end

return M
-- vi:ts=4 sw=4 expandtab
