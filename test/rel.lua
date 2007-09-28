require "uri-test"
local URI = require "uri"
local testcase = TestCase("Test 'rel' method on HTTP URLs")

function testcase:test_http_rel ()
    local uri = URI:new("http://www.example.com/foo/bar/")

    is("./", tostring(uri:rel("http://www.example.com/foo/bar/")))
    is("./", tostring(uri:rel("HTTP://WWW.EXAMPLE.COM/foo/bar/")))
    is("../../foo/bar/", tostring(uri:rel("HTTP://WWW.EXAMPLE.COM/FOO/BAR/")))
    is("./", tostring(uri:rel("HTTP://WWW.EXAMPLE.COM:80/foo/bar/")))
end

lunit.run()
-- vi:ts=4 sw=4 expandtab
