local M = { _NAME = "uri.urn.oid" }
local Util = require "uri._util"
local URN = require "uri.urn"
Util.subclass_of(M, URN)

-- This implements RFC 3061.

function M.init (self)
    local nss = self:nss()
    if nss == "" then return nil, "OID can't be zero-length" end
    if not nss:find("^[.0-9]*$") then return nil, "bad character in OID" end
    if nss:find("%.%.") then return nil, "missing number in OID" end
    if nss:find("^0[^.]") or nss:find("%.0[^.]") then
        return nil, "OID numbers shouldn't have leading zeros"
    end
    return self
end

function M.oid_numbers (self, new)
    local old = Util.split("%.", self:nss())
    for i = 1, #old do old[i] = tonumber(old[i]) end

    if new then
        if type(new) ~= "table" then error("expected array of numbers") end
        local nss = ""
        for _, n in ipairs(new) do
            if type(n) == "string" and n:find("^%d+$") then n = tonumber(n) end
            if type(n) ~= "number" then error("bad type for number in OID") end
            n = n - n % 1
            if n < 0 then error("negative numbers not allowed in OID") end
            if nss ~= "" then nss = nss .. "." end
            nss = nss .. n
        end
        if nss == "" then error("no numbers in new OID value") end
        self:nss(nss)
    end

    return old
end

return M
-- vi:ts=4 sw=4 expandtab
