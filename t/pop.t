require "uri-test"
local URI = require "URI"
local testcase = TestCase("Test URI.pop")

function testcase:test_pop ()
    local u = URI:new("pop://aas@pop.sn.no")

    is("aas", u:user())
    assert_nil(u:auth())
    is("pop.sn.no", u:host())
    is(110, u:port())
    is("pop://aas@pop.sn.no", tostring(u))

    u:auth("+APOP")
    is("+APOP", u:auth())
    is("pop://aas;AUTH=+APOP@pop.sn.no", tostring(u))

    u:user("gisle")
    is("gisle", u:user())
    is("pop://gisle;AUTH=+APOP@pop.sn.no", tostring(u))

    u:port(4000)
    is("pop://gisle;AUTH=+APOP@pop.sn.no:4000", tostring(u))
end

function testcase:test_pop_build ()
    local u = URI:new("pop:")
    u:host("pop.sn.no")
    u:user("aas")
    u:auth("*")
    is("pop://aas;AUTH=*@pop.sn.no", tostring(u))

    u:auth(nil)
    is("pop://aas@pop.sn.no", tostring(u))

    u:user(nil)
    is("pop://pop.sn.no", tostring(u))

    -- Try some funny characters too
    u:user("f\229r;k@l")
    is("f\229r;k@l", u:user())
    is("pop://f%E5r%3Bk%40l@pop.sn.no", tostring(u))
end

lunit.run()
-- vim:ts=4 sw=4 expandtab filetype=lua
