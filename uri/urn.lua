local M = { _NAME = "uri.urn" }
local Util = require "uri._util"
local URI = require "uri"
Util.subclass_of(M, URI)

-- This implements RFC 2141, and attempts to change the class of the URI object
-- to one of its subclasses for further validation and normalization of the
-- namespace-specific string.

-- Check NID syntax matches RFC 2141 section 2.1.
local function _valid_nid (nid)
    if nid == "" then return nil, "missing completely" end
    if nid:len() > 32 then return nil, "too long" end
    if not nid:find("^[A-Za-z0-9][-A-Za-z0-9]*$") then
        return nil, "contains illegal character"
    end
    if nid:lower() == "urn" then return nil, "'urn' is reserved" end
    return true
end

-- Check NSS syntax matches RFC 2141 section 2.2.
local function _valid_nss (nss)
    if nss == "" then return nil, "can't be empty" end
    if nss:find("[^A-Za-z0-9()+,%-.:=@;$_!*'/%%]") then
        return nil, "contains illegal character"
    end
    return true
end

local function _validate_and_normalize_path (path)
    local _, _, nid, nss = path:find("^([^:]+):(.*)$")
    if not nid then return nil, "illegal path syntax for URN" end

    local ok, msg = _valid_nid(nid)
    if not ok then
        return nil, "invalid namespace identifier (" .. msg .. ")"
    end
    ok, msg = _valid_nss(nss)
    if not ok then
        return nil, "invalid namespace specific string (" .. msg .. ")"
    end

    return nid:lower() .. ":" .. nss
end

-- TODO - this should check that percent-encoded bytes are valid UTF-8
function M.init (self)
    if self:query() then return nil, "URNs may not have query parts" end
    if self:host() then return nil, "URNs may not have authority parts" end

    local path, msg = _validate_and_normalize_path(self:path())
    if not path then return nil, msg end
    M._SUPER.path(self, path)

    local nid_class
        = Util.attempt_require("uri.urn." .. self:nid():gsub("%-", "_"))
    if nid_class then
        setmetatable(self, nid_class)
        if self.init ~= M.init then return self:init() end
    end

    return self
end

function M.nid (self, new)
    local _, _, old = self:path():find("^([^:]+)")

    if new then
        new = new:lower()
        if new ~= old then
            local ok, msg = _valid_nid(new)
            if not ok then
                error("invalid namespace identifier (" .. msg .. ")")
            end
            self:path(new .. ":" .. self:nss())

            -- Object might have a different class now, and there might be
            -- new NID-specific validation or normalization to be done.
            setmetatable(self, M)
            self:init()
        end
    end

    return old
end

function M.nss (self, new)
    local _, _, old = self:path():find(":(.*)")

    if new and new ~= old then
        local ok, msg = _valid_nss(new)
        if not ok then
            error("invalid namespace specific string (" .. msg .. ")")
        end
        M._SUPER.path(self, self:nid() .. ":" .. new)
    end

    return old
end

function M.path (self, new)
    local old = M._SUPER.path(self)

    if new then
        local path, msg = _validate_and_normalize_path(new)
        if not path then return nil, msg end
        M._SUPER.path(self, path)
    end

    return old
end

for _, method in ipairs({ "userinfo", "host", "port", "query" }) do
    M[method] = function (self, new)
        if new then error("URNs may not have " .. method) end
    end
end

return M
-- vi:ts=4 sw=4 expandtab
