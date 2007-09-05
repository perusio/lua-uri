-- RFC 2368
local _G = _G
module("URI.mailto", package.seeall)
URI._subclass_of(_M, "URI")
_M:_mix_in("URI._query")

function to (self, to)
    local old = self:headers()

    if to then
        local new = { to = to }
        for k, v in _G.pairs(old) do
            if k:lower() ~= "to" then new[k] = v end
        end

        self:headers(new)
    end

    local addrs = {}
    for k, v in _G.pairs(old) do
        if k:lower() == "to" then addrs[#addrs + 1] = v end
    end
    return _G.URI._join(",", addrs)
end

function headers (self, ...)
    -- The trick is to just treat everything as the query string...
    local opaque = "to=" .. self:opaque()
    opaque = opaque:gsub("%?", "&", 1)

    if _G.select('#', ...) > 0 then
        local new = ... or {}

        -- strip out any "to" fields
        local to_headers, to_addrs = {}, {}
        local set_query_string = false
        for k, v in _G.pairs(new) do
            if k:lower() == "to" then
                to_headers[#to_headers + 1] = k
                to_addrs[#to_addrs + 1] = v
            else
                set_query_string = true
            end
        end
        for _, v in _G.ipairs(to_headers) do new[v] = nil end

        local newstr = _G.URI._join(",", to_addrs)
        newstr = newstr:gsub("%%", "%%25")
                       :gsub("%?", "%%3F")
        self:opaque(newstr)
        if set_query_string then self:query_form(new) end
    end

    -- I am lazy today...
    return _G.URI:new("mailto:?" .. opaque):query_form()
end

-- vi:ts=4 sw=4 expandtab
