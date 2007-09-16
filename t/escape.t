require "uri-test"
local Esc = require "URI.Escape"
local testcase = TestCase("Test URI.Escape")

function testcase:test_uri_escape ()
    is("%7Cabc%E5", Esc.uri_escape("|abc\229"))
    is("a%62%63", Esc.uri_escape("abc", "b-d"))
    assert_nil(Esc.uri_escape(nil))
end

function testcase:test_uri_unescape ()
    is("|abc\229", Esc.uri_unescape("%7Cabc%e5"))
    is("@AB", Esc.uri_unescape("%40A%42"))
    is("CDE", Esc.uri_unescape("CDE"))
end

function testcase:test_escapes_table ()
    is("%25", Esc.escapes["%"])
end

lunit.run()
-- vim:ts=4 sw=4 expandtab filetype=lua
