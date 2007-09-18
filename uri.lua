local M = { _MODULE_NAME = "uri", VERSION = "1.0" }
M.__index = M

local Esc = require "URI.Escape"

local _UNRESERVED = "A-Za-z0-9%-._~"
local _GEN_DELIMS = ":/?#%[%]@"
local _SUB_DELIMS = "!$&'()*+,;="
local _RESERVED = _GEN_DELIMS .. _SUB_DELIMS
local _USERINFO = "^[" .. _UNRESERVED .. "%%" .. _SUB_DELIMS .. ":]*$"
local _REG_NAME = "^[" .. _UNRESERVED .. "%%" .. _SUB_DELIMS .. "]*$"
local _IP_FUTURE_LITERAL = "^v[0-9A-Fa-f]+%." ..
                           "[" .. _UNRESERVED .. _SUB_DELIMS .. "]+$"
local _QUERY_OR_FRAG = "^[" .. _UNRESERVED .. "%%" .. _SUB_DELIMS .. ":@/?]*$"
local _PATH_CHARS = "^[" .. _UNRESERVED .. "%%" .. _SUB_DELIMS .. ":@/]*$"

local function _normalize_percent_encoding (s)
    if s:find("%%$") or s:find("%%.$") then
        error("unfinished percent encoding at end of URI '" .. s .. "'")
    end

    return s:gsub("%%(..)", function (hex)
        if not hex:find("^[0-9A-Fa-f][0-9A-Fa-f]$") then
            error("invalid percent encoding '%" .. hex ..
                  "' in URI '" .. s .. "'")
        end

        -- Never percent-encode unreserved characters, and always use uppercase
        -- hexadecimal for percent encoding.  RFC 3986 section 6.2.2.2.
        local char = string.char(tonumber("0x" .. hex))
        return char:find("^[" .. _UNRESERVED .. "]") and char or "%" .. hex:upper()
    end)
end

local function _is_ip4_literal (s)
    if not s:find("^[0-9]+%.[0-9]+%.[0-9]+%.[0-9]+$") then return false end

    for dec_octet in s:gmatch("[0-9]+") do
        if dec_octet:len() > 3 or dec_octet:find("^0.") or
           tonumber(dec_octet) > 255 then
            return false
        end
    end

    return true
end

local function _is_ip6_literal (s)
    local had_elipsis = false       -- true when '::' found
    local num_chunks = 0
    while s ~= "" do
        num_chunks = num_chunks + 1
        local p1, p2 = s:find("::?")
        local chunk
        if p1 then
            chunk = s:sub(1, p1 - 1)
            s = s:sub(p2 + 1)
            if p2 ~= p1 then    -- found '::'
                if had_elipsis then return false end    -- two of '::'
                had_elipsis = true
                if chunk == "" then num_chunks = num_chunks - 1 end
            else
                if chunk == "" then return false end    -- ':' at start
                if s == "" then return false end        -- ':' at end
            end
        else
            chunk = s
            s = ""
        end

        -- Chunk is neither 4-digit hex num, nor IPv4address in last chunk.
        if (not chunk:find("^[0-9a-f]+$") or chunk:len() > 4) and
           (s ~= "" or not _is_ip4_literal(chunk)) and
           chunk ~= "" then
            return false
        end

        -- IPv4address in last position counts for two chunks of hex digits.
        if chunk:len() > 4 then num_chunks = num_chunks + 1 end
    end

    if had_elipsis then
        if num_chunks > 7 then return false end
    else
        if num_chunks ~= 8 then return false end
    end

    return true
end

local function _normalize_and_check_path (s)
    if not s:find(_PATH_CHARS) then return false end

    -- Remove unnecessary percent encoding for path values.
    -- TODO - I think this should be HTTP-specific (probably file also).
    --s = Esc.uri_unescape(s, _SUB_DELIMS .. ":@")

    -- This is the remove_dot_segments algorithm from RFC 3986 section 5.2.4.
    -- The input buffer is 's', the output buffer 'path'.
    local path = ""
    while s ~= "" do
        if s:find("^%.%.?/") then                       -- A
            s = s:gsub("^%.%.?/", "", 1)
        elseif s:find("^/%./") or s == "/." then        -- B
            s = s:gsub("^/%./?", "/", 1)
        elseif s:find("^/%.%./") or s == "/.." then     -- C
            s = s:gsub("^/%.%./?", "/", 1)
            if path:find("/") then
                path = path:gsub("/[^/]*$", "", 1)
            else
                path = ""
            end
        elseif s == "." or s == ".." then               -- D
            s = ""
        else                                            -- E
            local _, p, seg = s:find("^(/?[^/]*)")
            s = s:sub(p + 1)
            path = path .. seg
        end
    end

    return path
end

function M.new (class, uri)
    if not uri then error"usage: Class:new(uristring)" end
    if type(uri) ~= "string" then uri = tostring(uri) end
    local s = _normalize_percent_encoding(uri)

    local _, p
    local scheme, authority, userinfo, host, port, path, query, fragment

    _, p, scheme = s:find("^([a-zA-Z][-+.a-zA-Z0-9]*):")
    if not scheme then error"TODO - relative references" end
    scheme = scheme:lower()
    s = s:sub(p + 1)

    _, p, authority = s:find("^//([^/?#]*)")
    if authority then
        s = s:sub(p + 1)

        _, p, userinfo = authority:find("^([^@]*)@")
        if userinfo then
            if not userinfo:find(_USERINFO) then
                error("invalid userinfo value '" .. userinfo ..
                      "' in URI '" .. uri .. "'")
            end
            authority = authority:sub(p + 1)
        end

        p, _, port = authority:find(":([0-9]*)$")
        if port then
            port = (port ~= "") and tonumber(port) or nil
            authority = authority:sub(1, p - 1)
        end

        host = authority:lower()
        if host:find("^%[.*%]$") then
            local ip_literal = host:sub(2, -2)
            if ip_literal:find("^v") then
                if not s:find(_IP_FUTURE_LITERAL) then
                    error("invalid IPvFuture literal '" .. ip_literal ..
                          "' in URI '" .. uri .. "'")
                end
            else
                if not _is_ip6_literal(ip_literal) then
                    error("invalid IPv6 address '" .. ip_literal ..
                          "' in URI '" .. uri .. "'")
                end
            end
        elseif not _is_ip4_literal(host) and not host:find(_REG_NAME) then
            error("invalid host value '" .. host .. "' in URI '" .. uri .. "'")
        end
    end

    _, p, path = s:find("^([^?#]*)")
    if path ~= "" then
        local normpath = _normalize_and_check_path(path)
        if not normpath then error("invalid path '" .. path .. "' in URI") end
        path = normpath
        s = s:sub(p + 1)
    end

    _, p, query = s:find("^%?([^#]*)")
    if query then
        s = s:sub(p + 1)
        if not query:find(_QUERY_OR_FRAG) then
            error("invalid query value '?" .. query ..
                  "' in URI '" .. uri .. "'")
        end
    end

    _, p, fragment = s:find("^#(.*)")
    if fragment then
        if not fragment:find(_QUERY_OR_FRAG) then
            error("invalid fragment value '#" .. fragment ..
                  "' in URI '" .. uri .. "'")
        end
    end

    local o = {
        _scheme = scheme,
        _userinfo = userinfo,
        _host = host,
        _port = port,
        _path = path,
        _query = query,
        _fragment = fragment,
    }
    setmetatable(o, class)
    return o
end

function M.uri (self)
    local uri = self._uri

    if not uri then
        uri = self:scheme() .. ":"

        local host, port, userinfo = self:host(), self:port(), self:userinfo()
        if host or port or userinfo then
            uri = uri .. "//"
            if userinfo then uri = uri .. userinfo .. "@" end
            if host then uri = uri .. host end
            if port then uri = uri .. ":" .. port end
        end

        uri = uri .. self:path()
        if self:query() then uri = uri .. "?" .. self:query() end
        if self:fragment() then uri = uri .. "#" .. self:fragment() end

        self._uri = uri     -- cache
    end

    return uri
end

local function _mutator (self, field, ...)
    local old = self[field]

    if select("#", ...) > 0 then
        self[field] = ...   -- TODO - validate first, and encode as necessary
        uri._uri = nil
    end

    return old
end

function M.scheme (self, ...)   return _mutator(self, "_scheme", ...)   end
function M.userinfo (self, ...) return _mutator(self, "_userinfo", ...) end
function M.host (self, ...)     return _mutator(self, "_host", ...)     end
function M.port (self, ...)     return _mutator(self, "_port", ...)     end
function M.path (self, ...)     return _mutator(self, "_path", ...)     end
function M.query (self, ...)    return _mutator(self, "_query", ...)    end
function M.fragment (self, ...) return _mutator(self, "_fragment", ...) end

return M
-- vi:ts=4 sw=4 expandtab
