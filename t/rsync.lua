require "uri-test"
local URI = require "URI"
local testcase = TestCase("Test URI.rsync")

function testcase:test_rsync ()
    local u = URI:new("rsync://gisle@perl.com/foo/bar")

    is("gisle", u:user())
    is(873, u:port())
    is("/foo/bar", u:path())

    u:port(8730)
    is("rsync://gisle@perl.com:8730/foo/bar", tostring(u))
    is(8730, u:port())
    u:port(3333)
    is("rsync://gisle@perl.com:3333/foo/bar", tostring(u))
end

lunit.run()
-- vi:ts=4 sw=4 expandtab
