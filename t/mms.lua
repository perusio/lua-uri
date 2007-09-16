require "uri-test"
local URI = require "URI"
local testcase = TestCase("Test URI.mms")

function testcase:test_mms ()
    local u = URI:new("<mms://66.250.188.13/KFOG_FM>")

    is("mms://66.250.188.13/KFOG_FM", tostring(u))
    is(1755, u:port())

    -- play with port
    local old = u:port(8755)
    is(1755, old)
    is("mms://66.250.188.13:8755/KFOG_FM", tostring(u))

    u:port(1755)
    is("mms://66.250.188.13:1755/KFOG_FM", tostring(u))

    u:port("")
    -- TODO: is this test right, or is the empty port a bug in the Perl version?
    is("mms://66.250.188.13:/KFOG_FM", tostring(u))
    is(1755, u:port())

    u:port(nil)
    is("mms://66.250.188.13/KFOG_FM", tostring(u))
    is("66.250.188.13", u:host())
    is("/KFOG_FM", u:path())
end

lunit.run()
-- vi:ts=4 sw=4 expandtab
