local M = { _MODULE_NAME = "URI.ssh" }
local URI = require "URI"
URI._subclass_of(M, "URI._login")

-- ssh://[USER@]HOST[:PORT]/SRC

function M.default_port () return 22 end

return M
-- vi:ts=4 sw=4 expandtab
