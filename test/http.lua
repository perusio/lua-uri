require "uri-test"
local URI = require "uri"

module("test.http", lunit.testcase, package.seeall)

function test_http ()
    local uri = assert(URI:new("HTtp://FOo/Blah?Search#Id"))
    is("uri.http", uri._NAME)
    is("http://foo/Blah?Search#Id", uri:uri())
    is("http://foo/Blah?Search#Id", tostring(uri))
    is("http", uri:scheme())
    is("foo", uri:host())
    is(80, uri:port())
    is("/Blah", uri:path())
    is(nil, uri:userinfo())
    is("Search", uri:query())
    is("Id", uri:fragment())
end

function test_https ()
    local uri = assert(URI:new("HTtpS://FOo/Blah?Search#Id"))
    is("uri.https", uri._NAME)
    is("https://foo/Blah?Search#Id", uri:uri())
    is("https://foo/Blah?Search#Id", tostring(uri))
    is("https", uri:scheme())
    is("foo", uri:host())
    is(443, uri:port())
    is("/Blah", uri:path())
    is(nil, uri:userinfo())
    is("Search", uri:query())
    is("Id", uri:fragment())
end

function test_http_port ()
    local uri = assert(URI:new("http://example.com:8080/foo"))
    is(8080, uri:port())
    local old = uri:port(1234)
    is(8080, old)
    is(1234, uri:port())
    is("http://example.com:1234/foo", tostring(uri))
    old = uri:port(80)
    is(1234, old)
    is(80, uri:port())
    is("http://example.com/foo", tostring(uri))
end

function test_normalize_port ()
    local uri = assert(URI:new("http://foo:80/"))
    is("http://foo/", tostring(uri))
    is(80, uri:port())
    uri = assert(URI:new("http://foo:443/"))
    is("http://foo:443/", tostring(uri))
    is(443, uri:port())
    uri = assert(URI:new("https://foo:443/"))
    is("https://foo/", tostring(uri))
    is(443, uri:port())
    uri = assert(URI:new("https://foo:80/"))
    is("https://foo:80/", tostring(uri))
    is(80, uri:port())
end

function test_set_userinfo ()
    local uri = assert(URI:new("http://host/path"))
    assert_error("can't set userinfo", function () uri:userinfo("x") end)
end

-- vi:ts=4 sw=4 expandtab
