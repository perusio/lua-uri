-- Copyright (c) 1998 Graham Barr <gbarr@pobox.com>. All rights reserved.
-- This program is free software; you can redistribute it and/or
-- modify it under the same terms as Perl itself.

local _G = _G
module("URI.ldap", package.seeall)
URI._subclass_of(_M, "URI._server")
_M:_mix_in("URI._ldap")

function default_port () return 389 end

function _nonldap_canonical (self)
    return _G.URI._server.canonical(self)
end

-- vi:ts=4 sw=4 expandtab
