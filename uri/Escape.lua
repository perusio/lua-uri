local M = { _NAME = "uri.Escape" }

-- Build a char->hex map
local escapes = {}
for i = 0, 255 do
    escapes[string.char(i)] = string.format("%%%02X", i)
end

function M.uri_escape (text, patn)
    if not text then return end
    if not patn then
        -- Default unsafe characters.  RFC 2732 ^(uric - reserved)
        patn = "^A-Za-z0-9%-_.!~*'()"
    end
    return (text:gsub("([" .. patn .. "])",
                      function (chr) return escapes[chr] end))
end

function M.uri_unescape (str, patn)
    -- Note from RFC1630:  "Sequences which start with a percent sign
    -- but are not followed by two hexadecimal characters are reserved
    -- for future extension"
    if not str then return end
    if patn then patn = "[" .. patn .. "]" end
    return (str:gsub("%%(%x%x)", function (hex)
        local char = string.char(tonumber(hex, 16))
        return (patn and not char:find(patn)) and "%" .. hex or char
    end))
end

return M
-- vi:ts=4 sw=4 expandtab
