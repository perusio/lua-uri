require "uri-test"
require "URI"
local testcase = TestCase("Test URI.Escape")

function testcase:test_uri_escape ()
    is("%7Cabc%E5", URI.Escape.uri_escape("|abc\229"))
    is("a%62%63", URI.Escape.uri_escape("abc", "b-d"))
    assert_nil(URI.Escape.uri_escape(nil))
end

function testcase:test_uri_unescape ()
    is("|abc\229", URI.Escape.uri_unescape("%7Cabc%e5"))
    is("@AB", URI.Escape.uri_unescape("%40A%42"))
    is("CDE", URI.Escape.uri_unescape("CDE"))
end

function testcase:test_escapes_table ()
    is("%25", URI.Escape.escapes["%"])
end

lunit.run()
-- vim:ts=4 sw=4 expandtab filetype=lua
