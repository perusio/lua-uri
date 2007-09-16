local M = { _MODULE_NAME = "URI.Escape" }

-- Build a char->hex map
local escapes = {}
M.escapes = escapes
for i = 0, 255 do
    escapes[string.char(i)] = string.format("%%%02X", i)
end

local subst     -- compiled patternes

function M.uri_escape (text, patn)
    if not text then return end
    if not patn then
        -- Default unsafe characters.  RFC 2732 ^(uric - reserved)
        patn = "^A-Za-z0-9%-_.!~*'()"
    end
    return (text:gsub("([" .. patn .. "])",
                      function (chr) return escapes[chr] end))
end

function M.uri_unescape (str)
    -- Note from RFC1630:  "Sequences which start with a percent sign
    -- but are not followed by two hexadecimal characters are reserved
    -- for future extension"
    if not str then return end
    return (str:gsub("%%(%x%x)", function (hex)
        return string.char(tonumber(hex, 16))
    end))
end

return M
-- vi:ts=4 sw=4 expandtab
