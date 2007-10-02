local M = { _NAME = "uri.ldapi" }
local URI = require "uri"
URI._subclass_of(M, "uri._generic")
M:_mix_in("uri._ldap")

local Util = require "uri._util"

function M.un_path (self, new)
    local old = Util.uri_unescape(self:authority())
    if new then
        new = new:gsub(":", "%%3A")
                 :gsub("@", "%%40")
        self:authority(new)
    end
    return old
end

function M._nonldap_canonical (self)
    URI._generic.canonical(self)
end

return M
-- vi:ts=4 sw=4 expandtab
