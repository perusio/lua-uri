-- draft-gilman-news-url-01
module("URI.snews", package.seeall)
URI._subclass_of(_M, "URI.news")

function default_port () return 563 end

-- vi:ts=4 sw=4 expandtab
