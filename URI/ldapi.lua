local _G = _G
module("URI.ldapi", package.seeall)
URI._subclass_of(_M, "URI._generic")
_M:_mix_in("URI._ldap")

_G.require "URI.Escape"

function un_path (self, new)
    local old = _G.URI.Escape.uri_unescape(self:authority())
    if new then
        new = new:gsub(":", "%%3A")
                 :gsub("@", "%%40")
        self:authority(new)
    end
    return old
end

function _nonldap_canonical (self)
    _G.URI._generic.canonical(self)
end

-- vi:ts=4 sw=4 expandtab
