-- draft-gilman-news-url-01
local M = { _NAME = "uri.snews" }
local URI = require "uri"
URI._subclass_of(M, "uri.news")

function M.default_port () return 563 end

return M
-- vi:ts=4 sw=4 expandtab
