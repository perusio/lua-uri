local _G = _G
module("URI._query")

function query (self, ...)
    local uri = self.uri
    local _, before_end, before = uri:find("^([^?#]*)")
    local query_end, old
    if uri:sub(before_end + 1, before_end + 1) == "?" then
        _, query_end, old = uri:find("([^#]*)", before_end + 2)
    else
        query_end = before_end
    end

    if _G.select('#', ...) > 0 then
        local q = ...
        if q then
            self.uri = before .. "?" ..
                       _G.URI.Escape.uri_escape(q, "^" .. _G.URI.uric) ..
                       uri:sub(query_end + 1)
        else
            self.uri = before .. uri:sub(query_end + 1)
        end
    end

    return old
end

local function _query_escape (val)
    if _G.type(val) ~= "string" then val = _G.tostring(val) end
    return _G.URI.Escape.uri_escape(val, ";/?:@&=+,$%[%]%%"):gsub(" ", "+")
end

local function _query_unescape (val)
    return _G.URI.Escape.uri_unescape(val:gsub("%+", " "))
end

-- Handle ...?foo=bar&bar=foo type of query
function query_form (self, ...)
    local old = self:query()

    if _G.select('#', ...) > 0 then
        -- Try to set query string
        local new = ... or {}
        local copy = {}
        for key, vals in _G.pairs(new) do
            key = _query_escape(key)
            if _G.type(vals) == "table" then
                for _, val in _G.ipairs(vals) do
                    copy[#copy + 1] = key .. "=" .. _query_escape(val)
                end
            else
                copy[#copy + 1] = key .. "=" .. _query_escape(vals)
            end
        end
        if #copy == 0 then copy = nil else copy = _G.URI._join("&", copy) end
        self:query(copy)
    end

    if not old or old == "" or not old:find("=") then return end -- not a form

    local result = {}
    for _, nameval in _G.ipairs(_G.URI._split("&", old)) do
        local _, _, name, val = nameval:find("^([^=]*)=(.*)$")
        if not name then name = nameval; val = "" end
        result[_query_unescape(name)] = _query_unescape(val)
    end
    return result
end

-- Handle ...?dog+bones type of query
function query_keywords (self, ...)
    local old = self:query()

    if _G.select('#', ...) > 0 then
        -- Try to set query string
        local keywords = ... or {}
        local copy = {}
        for i, v in _G.ipairs(keywords) do
            copy[i] = _G.URI.Escape.uri_escape(v, ";/?:@&=+,$%[%]%%")
        end
        if #copy == 0 then copy = nil else copy = _G.URI._join("+", copy) end
        self:query(copy)
    end

    if not old or old:find("=") then return end -- no query, or not keywords

    local result = {}
    for i, v in _G.ipairs(_G.URI._split("+", old)) do
        result[i] = _G.URI.Escape.uri_unescape(v)
    end
    return result
end

-- vi:ts=4 sw=4 expandtab
