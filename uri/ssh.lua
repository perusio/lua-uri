local M = { _NAME = "uri.ssh" }
local URI = require "uri"
URI._subclass_of(M, "uri._login")

-- ssh://[USER@]HOST[:PORT]/SRC

function M.default_port () return 22 end

return M
-- vi:ts=4 sw=4 expandtab
