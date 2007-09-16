local M = { _MODULE_NAME = "URI._segment" }

-- Represents a generic path_segment so that it can be treated as
-- a string too.

function M.__tostring (self) return self[1] end

function M.new (class, path)
    local segments = URI._split(";", path)
    segments[1] = URI.Escape.uri_unescape(segments[1])
    setmetatable(segments, class)
    return segments
end

return M
-- vi:ts=4 sw=4 expandtab
