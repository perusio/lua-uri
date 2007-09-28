require "uri-test"
local URI = require "uri"
local testcase = TestCase("Test uri.http and uri.https")

-- TODO - many more tests

function testcase:test_http ()
    local uri = assert(URI:new("HTtp://FOo/Blah?Search#Id"))
    is("uri.http", uri._NAME)
    is("http://foo/Blah?Search#Id", uri:uri())
    is("http", uri:scheme())
    is("foo", uri:host())
    is(80, uri:port())
    is("/Blah", uri:path())
    is(nil, uri:userinfo())
    is("Search", uri:query())
    is("Id", uri:fragment())
end

function testcase:test_https ()
    local uri = assert(URI:new("HTtpS://FOo/Blah?Search#Id"))
    is("uri.https", uri._NAME)
    is("https://foo/Blah?Search#Id", uri:uri())
    is("https", uri:scheme())
    is("foo", uri:host())
    is(443, uri:port())
    is("/Blah", uri:path())
    is(nil, uri:userinfo())
    is("Search", uri:query())
    is("Id", uri:fragment())
end

lunit.run()
-- vi:ts=4 sw=4 expandtab
