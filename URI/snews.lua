-- draft-gilman-news-url-01
local M = { _MODULE_NAME = "URI.snews" }
local URI = require "URI"
URI._subclass_of(M, "URI.news")

function M.default_port () return 563 end

return M
-- vi:ts=4 sw=4 expandtab
