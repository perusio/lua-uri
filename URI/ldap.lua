-- Copyright (c) 1998 Graham Barr <gbarr@pobox.com>. All rights reserved.
-- This program is free software; you can redistribute it and/or
-- modify it under the same terms as Perl itself.

local M = { _MODULE_NAME = "URI.ldap" }
local URI = require "URI"
URI._subclass_of(M, "URI._server")
M:_mix_in("URI._ldap")

local URIServer = require "URI._server"

function M.default_port () return 389 end

function M._nonldap_canonical (self)
    return URIServer.canonical(self)
end

return M
-- vi:ts=4 sw=4 expandtab
