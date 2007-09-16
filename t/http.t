require "uri-test"
local URI = require "URI"
local testcase = TestCase("Test URI.http and URI.https")

function testcase:test_http ()
    local u = URI:new("<http://www.perl.com/path?q=f\244o>")

    is("http://www.perl.com/path?q=f%F4o", tostring(u))
    is(80, u:port())

    -- play with port
    local old = u:port(8080)
    is(80, old)
    is("http://www.perl.com:8080/path?q=f%F4o", tostring(u))

    u:port(80)
    is("http://www.perl.com:80/path?q=f%F4o", tostring(u))

    -- TODO - this is probably not the result you want, but it's what the
    -- Perl version of the code has, and how it currently behaves.
    u:port("")
    is("http://www.perl.com:/path?q=f%F4o", tostring(u))
    is(80, u:port())

    u:port(nil)
    is("http://www.perl.com/path?q=f%F4o", tostring(u))

    local aq = u:query_form()
    assert_hash_shallow_equal({ q = "f\244o" }, aq)

    u:query_form({foo = "bar", bar = "baz"})
    is_one_of({"foo=bar&bar=baz","bar=baz&foo=bar"}, u:query())
    is("www.perl.com", u:host())
    is("/path", u:path())

    u:scheme("https")
    is(443, u:port())
    is_one_of({"https://www.perl.com/path?foo=bar&bar=baz",
               "https://www.perl.com/path?bar=baz&foo=bar"},
              tostring(u))

    u = URI:new("http://%77%77%77%2e%70%65%72%6c%2e%63%6f%6d/%70%75%62/%61/%32%30%30%31/%30%38/%32%37/%62%6a%6f%72%6e%73%74%61%64%2e%68%74%6d%6c")
    is("http://www.perl.com/pub/a/2001/08/27/bjornstad.html", tostring(u:canonical()))
end

lunit.run()
-- vim:ts=4 sw=4 expandtab filetype=lua
