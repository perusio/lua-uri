-- http://rsync.samba.org/
local M = { _MODULE_NAME = "URI.rsync" }
local URI = require "URI"
URI._subclass_of(M, "URI._server")
M:_mix_in("URI._userpass")

-- rsync://[USER@]HOST[:PORT]/SRC

function M.default_port () return 873 end

return M
-- vi:ts=4 sw=4 expandtab
