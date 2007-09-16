local M = { _MODULE_NAME = "URI.ldapi" }
local URI = require "URI"
URI._subclass_of(M, "URI._generic")
M:_mix_in("URI._ldap")

local Esc = require "URI.Escape"

function M.un_path (self, new)
    local old = Esc.uri_unescape(self:authority())
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
