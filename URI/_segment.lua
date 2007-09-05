module("URI._segment", package.seeall)

-- Represents a generic path_segment so that it can be treated as
-- a string too.

function __tostring (self) return self[1] end

function new (class, path)
    local segments = URI._split(";", path)
    segments[1] = URI.Escape.uri_unescape(segments[1])
    setmetatable(segments, class)
    return segments
end

-- vi:ts=4 sw=4 expandtab
