-- draft-gilman-news-url-01
local M = { _NAME = "uri.nntp" }
local URI = require "uri"
URI._subclass_of(M, "uri.news")

return M
-- vi:ts=4 sw=4 expandtab
