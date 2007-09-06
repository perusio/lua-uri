-- <draft-murali-url-gopher>, Dec 4, 1996
local _G = _G
module("URI.gopher", package.seeall)
URI._subclass_of(_M, "URI._server")

--  A Gopher URL follows the common internet scheme syntax as defined in
--  section 4.3 of [RFC-URL-SYNTAX]:
--
--        gopher://<host>[:<port>]/<gopher-path>
--
--  where
--
--        <gopher-path> :=  <gopher-type><selector> |
--                          <gopher-type><selector>%09<search> |
--                          <gopher-type><selector>%09<search>%09<gopher+_string>
--
--        <gopher-type> := '0' | '1' | '2' | '3' | '4' | '5' | '6' | '7'
--                         '8' | '9' | '+' | 'I' | 'g' | 'T'
--
--        <selector>    := *pchar     Refer to RFC 1808 [4]
--        <search>      := *pchar
--        <gopher+_string> := *uchar  Refer to RFC 1738 [3]
--
--  If the optional port is omitted, the port defaults to 70.

function default_port () return 70 end

function _gopher_type (self, ...)
    local path = self:path_query()
    path = path:gsub("^/", "", 1)       -- TODO - 3 lines duplicated below
    local _, _, gtype = path:find("^(.)")
    if gtype then path = path:sub(2) end
    if _G.select('#', ...) > 0 then
        local new_type = ...
        if new_type then
            if new_type:len() ~= 1 then
                error("Bad gopher type '" .. new_type .. "'")
            end
            path = new_type .. path
            self:path_query(path)
        else
            if path ~= "" then
                error("Can't delete gopher type when selector is present")
            end
            self:path_query(nil)
        end
    end
    return gtype
end

function gopher_type (self, ...)
    local gtype = self:_gopher_type(...)
    return gtype or "1"
end

local function _gfield (self, fno, ...)
    local path = self:path_query()

    -- not according to spec., but many popular browsers accept
    -- gopher URLs with a '?' before the search string.
    path = path:gsub("%?", "\t", 1)
    path = _G.URI.Escape.uri_unescape(path)
    path = path:gsub("^/", "", 1)
    local _, _, gtype = path:find("^(.)")
    if gtype then path = path:sub(2) end
    local pathsegs = _G.URI._split("\t", path, 3)
    if _G.select('#', ...) > 0 then
        -- modify
        pathsegs[fno] = ...
        while #pathsegs > 0 and not pathsegs[#pathsegs] do
            _G.table.remove(pathsegs)
        end
        for i, v in _G.ipairs(pathsegs) do
            if not v then pathsegs[i] = "" end
        end
        path = gtype
        if not path then path = "1" end
        path = path .. _G.table.concat(pathsegs, "\t")
        self:path_query(path)
    end
    return pathsegs[fno]
end

function selector (self, ...) return _gfield(self, 1, ...) or "" end
function search   (self, ...) return _gfield(self, 2, ...) end
function string   (self, ...) return _gfield(self, 3, ...) end

-- vi:ts=4 sw=4 expandtab
