-- RFC 2397
local _G = _G
module("URI.data", package.seeall)
URI._subclass_of(_M, "URI")

function media_type (self, ...)
    local opaque = self:opaque()
    local _, _, old = opaque:find("^([^,]*),?")
    if not old then error"no media type in data URI" end
    local _, _, base64 = old:lower():find("(;base64)$")
    if base64 then old = old:sub(1, -8) end

    if _G.select('#', ...) > 0 then
        local new = ... or ""
        new = new:gsub("%%", "%%25")
                 :gsub(",", "%%2C")
        base64 = base64 or ""
        local opaque_comma = opaque:find(",") or opaque:len()
        opaque = new .. base64 .. "," .. opaque:sub(opaque_comma + 1)
        self:opaque(opaque)
    end

    if old and old ~= "" then
        return _G.URI.Escape.uri_unescape(old)
    else
        return "text/plain;charset=US-ASCII"    -- default type
    end
end

local urienc_safe_patn = "[" .. _G.URI.uric:gsub("%%%%", "", 1) .. "]"
local function _urienc_len (s)
    local num_unsafe_chars = s:gsub(urienc_safe_patn, ""):len()
    local num_safe_chars = s:len() - num_unsafe_chars
    return num_safe_chars + num_unsafe_chars * 3
end

local function _base64_len (s)
    local num_blocks = (s:len() + 2) / 3
    num_blocks = num_blocks - num_blocks % 1
    return num_blocks * 4
           + 7      -- because of ";base64" marker
end

local function _do_base64 (algorithm, input)
    local Filter = _G.require "data.filter"
    return Filter[algorithm](input)
end

function data (self, ...)
    local opaque = self:opaque()
    local _, _, enc, data = opaque:find("^([^,]*),(.*)")
    if not enc then enc = opaque end
    if not data then
        data = ""
        enc = enc or ""
    end
    local base64 = enc:lower():find(";base64$")

    if _G.select('#', ...) > 0 then
        local new = ... or ""
        if base64 then enc = enc:sub(1, -8) end
        local urienc_len = _urienc_len(new)
        local base64_len = _base64_len(new)
        if base64_len < urienc_len then
            enc = enc .. ";base64"
            new = _do_base64("base64_encode", new)
        else
            new = new:gsub("%%", "%%25")
        end
        self:opaque(enc .. "," .. new)
    end

    if base64 then
        return _do_base64("base64_decode", data)
    else
        return _G.URI.Escape.uri_unescape(data)
    end
end

-- vi:ts=4 sw=4 expandtab
