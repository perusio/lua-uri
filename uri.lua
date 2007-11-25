local M = { _NAME = "uri", VERSION = "1.0" }
M.__index = M

local Util = require "uri._util"

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

local function _normalize_and_check_path (s, normalize)
    if not s:find(_PATH_CHARS) then return false end
    if not normalize then return s end

    -- Remove unnecessary percent encoding for path values.
    -- TODO - I think this should be HTTP-specific (probably file also).
    --s = Util.uri_decode(s, _SUB_DELIMS .. ":@")

    return Util.remove_dot_segments(s)
end

-- TODO the things in here throwing exceptions should instead return an error
function M.new (class, uri, base)
    if not uri then error"usage: URI:new(uristring, [baseuri])" end
    if type(uri) ~= "string" then uri = tostring(uri) end

    if base then
        local uri, err = M.new(class, uri)
        if not uri then return nil, err end
        if type(base) ~= "table" then
            base, err = M.new(class, base)
            if not base then return nil, "error parsing base URI: " .. err end
        end
        if base:is_relative() then return nil, "base URI must be absolute" end
        -- TODO if an error occurs in resolve it might throw an exception,
        -- but perhaps it should be caught and returned instead?
        uri:resolve(base)
        return uri
    end

    local s = _normalize_percent_encoding(uri)

    local _, p
    local scheme, authority, userinfo, host, port, path, query, fragment

    _, p, scheme = s:find("^([a-zA-Z][-+.a-zA-Z0-9]*):")
    if scheme then
        scheme = scheme:lower()
        s = s:sub(p + 1)
    end

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
        local normpath = _normalize_and_check_path(path, scheme)
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
    setmetatable(o, scheme and class or (require "uri._relative"))

    return o:init()
end

function M.uri (self, ...)
    local uri = self._uri

    if not uri then
        local scheme = self:scheme()
        if scheme then
            uri = scheme .. ":"
        else
            uri = ""
        end

        local host, port, userinfo = self:host(), self._port, self:userinfo()
        if host or port or userinfo then
            uri = uri .. "//"
            if userinfo then uri = uri .. userinfo .. "@" end
            if host then uri = uri .. host end
            if port then uri = uri .. ":" .. port end
        end

        local path = self:path()
        if uri == "" and path:find("^[^/]*:") then
            path = "./" .. path
        end

        uri = uri .. path
        if self:query() then uri = uri .. "?" .. self:query() end
        if self:fragment() then uri = uri .. "#" .. self:fragment() end

        self._uri = uri     -- cache
    end

    if select("#", ...) > 0 then
        local new = ...
        if not new then error("URI can't be set to nil") end
        local newuri, err = M:new(new)
        if not newuri then
            error("new URI string is invalid (" .. err .. ")")
        end
        setmetatable(self, getmetatable(newuri))
        for k in pairs(self) do self[k] = nil end
        for k, v in pairs(newuri) do self[k] = v end
    end

    return uri
end

function M.__tostring (self) return self:uri() end

function M.eq (a, b)
    -- TODO - should throw exception if either is a string but not valid
    if type(a) == "string" then a = M:new(a) end
    if type(b) == "string" then b = M:new(b) end
    return a:uri() == b:uri()
end

local function _mutator (self, field, ...)
    local old = self[field]

    if select("#", ...) > 0 then
        self[field] = ...   -- TODO - validate first, and encode as necessary
        self._uri = nil
    end

    return old
end

-- TODO: host should throw exception if:
--   * new value is not valid host syntax
--   * new value is nil but userinfo and/or port is present
function M.host (self, ...)     return _mutator(self, "_host", ...)     end
function M.query (self, ...)    return _mutator(self, "_query", ...)    end
function M.fragment (self, ...) return _mutator(self, "_fragment", ...) end

function M.scheme (self, ...)
    local old = self._scheme

    if select("#", ...) > 0 then
        local new = ...
        if not new then error("can't remove scheme from absolute URI") end
        if type(new) ~= "string" then new = tostring(new) end
        if not new:find("^[a-zA-Z][-+.a-zA-Z0-9]*$") then
            error("invalid scheme '" .. new .. "'")
        end
        Util.do_class_changing_change(self, M, "scheme", new,
                                      function (uri, new) uri._scheme = new end)
    end

    return old
end

function M.userinfo (self, ...)
    local old = self._userinfo

    if select("#", ...) > 0 then
        local new = ...
        if new then
            if not new:find(_USERINFO) then
                error("invalid userinfo value '" .. new .. "'")
            end
            new = _normalize_percent_encoding(new)
        end
        self._userinfo = new
        self._uri = nil
    end

    return old
end

function M.port (self, ...)
    local old = self._port or self:default_port()

    if select("#", ...) > 0 then
        local new = ...
        if new then
            if type(new) == "string" then new = tonumber(new) end
            if new < 0 then error("port number must not be negative") end
            local newint = new - new % 1
            if newint ~= new then error("port number not integer") end
            if new == self:default_port() then new = nil end
        end
        self._port = new
        self._uri = nil
    end

    return old
end

function M.path (self, ...)
    local old = self._path

    if select("#", ...) > 0 then
        local new = ... or ""
        new = _normalize_percent_encoding(new)
        new = Util.uri_encode(new, "^A-Za-z0-9%-._~%%!$&'()*+,;=:@/")
        if self._host then
            if new ~= "" and not new:find("^/") then
                error("path must begin with '/' when there is an authority")
            end
        else
            if new:find("^//") then new = "/%2F" .. new:sub(3) end
        end
        self._path = new
        self._uri = nil
    end

    return old
end

function M.init (self)
    local scheme_class
        = Util.attempt_require("uri." .. self._scheme:gsub("[-+.]", "_"))
    if scheme_class then
        setmetatable(self, scheme_class)
        if self._port and self._port == self:default_port() then
            self._port = nil
        end
        -- TODO - will this cause an infinite loop if a subclass doesn't
        -- override init?
        if scheme_class ~= M then return self:init() end
    end
    return self
end

function M.default_port () return nil end
function M.is_relative () return false end
function M.resolve () end   -- only does anything in uri._relative

return M
-- vi:ts=4 sw=4 expandtab
