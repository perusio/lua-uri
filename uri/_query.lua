local M = { _NAME = "uri._query" }

local URI = require "uri"
local Util = require "uri._util"

function M.query (self, ...)
    local uri = self.uri
    local _, before_end, before = uri:find("^([^?#]*)")
    local query_end, old
    if uri:sub(before_end + 1, before_end + 1) == "?" then
        _, query_end, old = uri:find("([^#]*)", before_end + 2)
    else
        query_end = before_end
    end

    if select('#', ...) > 0 then
        local q = ...
        if q then
            self.uri = before .. "?" ..
                       Util.uri_escape(q, "^" .. URI.uric) ..
                       uri:sub(query_end + 1)
        else
            self.uri = before .. uri:sub(query_end + 1)
        end
    end

    return old
end

local function _query_escape (val)
    if type(val) ~= "string" then val = tostring(val) end
    return Util.uri_escape(val, ";/?:@&=+,$%[%]%%"):gsub(" ", "+")
end

local function _query_unescape (val)
    return Util.uri_unescape(val:gsub("%+", " "))
end

-- Handle ...?foo=bar&bar=foo type of query
function M.query_form (self, ...)
    local old = self:query()

    if select('#', ...) > 0 then
        -- Try to set query string
        local new = ... or {}
        local copy = {}
        for key, vals in pairs(new) do
            key = _query_escape(key)
            if type(vals) == "table" then
                for _, val in ipairs(vals) do
                    copy[#copy + 1] = key .. "=" .. _query_escape(val)
                end
            else
                copy[#copy + 1] = key .. "=" .. _query_escape(vals)
            end
        end
        if #copy == 0 then copy = nil else copy = table.concat(copy, "&") end
        self:query(copy)
    end

    if not old or old == "" or not old:find("=") then return end -- not a form

    local result = {}
    for _, nameval in ipairs(URI._split("&", old)) do
        local _, _, name, val = nameval:find("^([^=]*)=(.*)$")
        if not name then name = nameval; val = "" end
        result[_query_unescape(name)] = _query_unescape(val)
    end
    return result
end

-- Handle ...?dog+bones type of query
function M.query_keywords (self, ...)
    local old = self:query()

    if select('#', ...) > 0 then
        -- Try to set query string
        local keywords = ... or {}
        local copy = {}
        for i, v in ipairs(keywords) do
            copy[i] = Util.uri_escape(v, ";/?:@&=+,$%[%]%%")
        end
        if #copy == 0 then copy = nil else copy = table.concat(copy, "+") end
        self:query(copy)
    end

    if not old or old:find("=") then return end -- no query, or not keywords

    local result = {}
    for i, v in ipairs(URI._split("+", old)) do
        result[i] = Util.uri_unescape(v)
    end
    return result
end

return M
-- vi:ts=4 sw=4 expandtab
