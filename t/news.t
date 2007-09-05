require "uri-test"
require "URI"
local testcase = TestCase("Test URI.news, URI.snews, and URI.nntp")

function testcase:test_news ()
    local u = URI:new("news:comp.lang.perl.misc")

    is("comp.lang.perl.misc", u:group())
    assert_nil(u:message())
    is(119, u:port())
    is("news:comp.lang.perl.misc", tostring(u))

    u:host("news.online.no")
    is("comp.lang.perl.misc", u:group())
    is(119, u:port())
    is("news://news.online.no/comp.lang.perl.misc", tostring(u))

    u:group("no.perl", 1, 10)
    is("news://news.online.no/no.perl/1-10", tostring(u))

    ag = u:group()
    local name, from, to = u:group()
    is("no.perl", name)
    is(1, from)
    is(10, to)

    u:message("42@g.aas.no")
    is("42@g.aas.no", u:message())
    assert_nil(u:group())
    is("news://news.online.no/42@g.aas.no", tostring(u))
end

function testcase:test_nntp ()
    u = URI:new("nntp:no.perl")
    is("no.perl", u:group())
    is(119, u:port())
end

function testcase:test_snews ()
    u = URI:new("snews://snews.online.no/no.perl")
    is("no.perl", u:group())
    is("snews.online.no", u:host())
    is(563, u:port())
end

lunit.run()
-- vim:ts=4 sw=4 expandtab filetype=lua
