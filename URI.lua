local M = { _MODULE_NAME = "URI" }
M.__index = M
M.VERSION = "1.35"

local implements = {}   -- mapping from scheme to implementor class

-- Some "official" character classes
local reserved   = ";/?:@&=+$,[]"
local unreserved = "A-Za-z0-9_.!~*'()%-"
local uric       = ";/?:@&=+$,%[%]%%" .. unreserved
local scheme_re  = "[a-zA-Z][-a-zA-Z0-9.+]*"

M.uric = uric
M.scheme_re = scheme_re

local Esc = require "URI.Escape"

function M.__tostring (self)
    return self.uri
end

-- TODO - wouldn't this be better as a method on string?  s:split(patn)
function M._split (patn, s, max)
    if s == "" then return {} end

    local i, j = 1, string.find(s, patn)
    if not j then return { s } end

    local list = {}
    while true do
        if #list + 1 == max then list[max] = s:sub(i); return list end
        list[#list + 1] = s:sub(i, j - 1)
        i = j + 1
        j = string.find(s, patn, i)
        if not j then
            list[#list + 1] = s:sub(i)
            break
        end
    end
    return list
end

function M._attempt_require (modname)
    local ok, result = pcall(require, modname)
    if ok then
        return result
    elseif type(result) == "string" and
           result:find("module '.*' not found") then
        return nil
    else
        error(result)
    end
end

function M._subclass_of (class, baseclass_name)
    local baseclass = baseclass_name == "URI" and M or require(baseclass_name)
    class.__index = class
    class._SUPER = baseclass
    class.__tostring = M.__tostring     -- not inherited
    setmetatable(class, baseclass)
end

function M._mix_in (class, mixin_name)
    local mixin = require(mixin_name)
    for name, value in pairs(mixin) do
        if name:sub(1, 1) ~= "_" then
            class[name] = value
        end
    end
end

M._show_warnings = true
function M._warn (...)
    if M._show_warnings then io.stderr:write(...) end
end

local function implementor (scheme)
    if not scheme or not scheme:find("^" .. scheme_re .. "$") then
        return require "URI._generic"
    end

    scheme = scheme:lower(scheme)

    local ic = implements[scheme]
    if ic then return ic end

    -- turn scheme into a valid perl identifier by a simple tranformation...
    ic = scheme:gsub("%+", "_P")
               :gsub("%.", "_O")
               :gsub("%-", "_")

    -- check we actually have one for the scheme:
    local mod = M._attempt_require("URI." .. ic)
    if not mod then return end

    implements[scheme] = mod
    return mod
end

function M:new (uri, scheme)
    if uri and type(uri) ~= "string" then uri = tostring(uri) end

    -- Get rid of potential wrapping
    uri = uri:gsub("^<URL:(.*)>$", "%1", 1)
             :gsub("^<(.*)>$", "%1", 1)
             :gsub("^\"(.*)\"$", "%1", 1)
             :gsub("^%s+", "", 1)
             :gsub("%s+$", "", 1)

    local impclass
    local _, colon = uri:find("^" .. scheme_re .. ":")
    if colon then
        scheme = uri:sub(1, colon - 1)
    elseif scheme then
        if type(scheme) ~= "string" then
            impclass = getmetatable(scheme)
            scheme = scheme:scheme()
        else
            local _, colon = scheme:find("^" .. scheme_re .. ":")
            if colon then scheme = scheme:sub(1, colon - 1) end
        end
    end
    impclass = impclass or implementor(scheme) or require "URI._foreign"

    return impclass:_init(uri, scheme)
end

function M:new_abs (uri, base)
    return self:new(uri, base):abs(base)
end

function M:_no_scheme_ok () return false end

function M:_init (str, scheme)
    str = Esc.uri_escape(str, "^#" .. uric)
    if not str:find("^" .. scheme_re .. ":") and not self:_no_scheme_ok() then
        str = scheme .. ":" .. str
    end
    local o = { uri = str }
    setmetatable(o, self)
    return o
end

function M:clone ()
    local o = { uri = self.uri }
    setmetatable(o, getmetatable(self))
    return o
end

function M:_scheme (...)
    local _, colon, old = self.uri:find("^(" .. scheme_re .. "):")

    if select('#', ...) > 0 then
        local new = ... or ""
        local rest = colon and self.uri:sub(colon + 1) or self.uri
        if new ~= "" then
            -- Store a new scheme
            if not new:find("^" .. scheme_re .. "$") then
                error("Bad scheme '" .. new .. "'")
            end
            local newself = M:new(new .. ":" .. rest)
            self.uri = newself.uri
            setmetatable(self, getmetatable(newself))
        elseif colon and self:_no_scheme_ok() then
            -- Delete the existing scheme
            self.uri = rest
            if self.uri:find("^" .. scheme_re .. ":") then
                M._warn("Oops, opaque part now look like scheme")
            end
        end
    end

    return old
end

function M:scheme (...)
    local scheme = self:_scheme(...)
    return scheme and scheme:lower() or nil
end

function M:opaque (...)
    local uri = self.uri
    local _, colon = uri:find("^" .. scheme_re .. ":")
    local hash = uri:find("#")
    local old_opaque = uri:sub((colon and colon + 1 or 1),
                               (hash and hash - 1 or nil))

    if select('#', ...) > 0 then
        local new = ... or ""
        local old_scheme = colon and uri:sub(1, colon) or ""
        local old_frag = hash and uri:sub(hash) or ""
        new = Esc.uri_escape(new, "^" .. uric)
        self.uri = old_scheme .. new .. old_frag
    end

    return old_opaque
end
M.path = M.opaque       -- alias for simple default implementation

function M:fragment (...)
    local hash = self.uri:find("#")
    local old = hash and self.uri:sub(hash + 1) or nil

    if select('#', ...) > 0 then
        local new = ...
        local beforefrag = hash and self.uri:sub(1, hash - 1) or self.uri
        if new then
            new = Esc.uri_escape(new, "^" .. uric)
            self.uri = beforefrag .. "#" .. new
        else
            self.uri = beforefrag
        end
    end

    return old
end

-- TODO - might as well use Lua 'tostring' function instead of this
function M:as_string () return self.uri end

function M:canonical ()
    -- Make sure scheme is lowercased, that we don't escape unreserved chars,
    -- and that we use upcase escape sequences.
    local scheme = self:_scheme() or ""
    local uc_scheme = scheme:find("[A-Z]")
    local esc = self.uri:find("%%%x%x")
    if not uc_scheme and not esc then return self end

    local other = self:clone()
    if uc_scheme then
        other:_scheme(scheme:lower())
    end
    if esc then
        other.uri = other.uri:gsub("%%(%x%x)", function (hex)
            local chr = string.char(tonumber(hex, 16))
            if chr:find("^[" .. unreserved .. "]$") then
                return chr
            else
                return "%" .. hex:upper()
            end
        end)
    end
    return other
end

-- Compare two URIs, subclasses will provide a more correct implementation
-- TODO, doesn't seem to work in t/roy-test.t even without the __eq version
function M.eq (a, b)
    if type(a) == "string" then a = M:new(a, b) end
    if type(b) == "string" then b = M:new(b, a) end
    return getmetatable(a) == getmetatable(b) and       -- same class
           a:canonical():as_string() == b:canonical():as_string()
end
M.__eq = M.eq

-- generic-URI transformation methods
function M:abs () return self end
function M:rel () return self end

return M
-- vi:ts=4 sw=4 expandtab
