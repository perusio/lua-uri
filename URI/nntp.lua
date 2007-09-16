-- draft-gilman-news-url-01
local M = { _MODULE_NAME = "URI.nntp" }
local URI = require "URI"
URI._subclass_of(M, "URI.news")

return M
-- vi:ts=4 sw=4 expandtab
