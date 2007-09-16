require "uri-test"
local URI = require "URI"
local testcase = TestCase("Test 'clone' method")

function testcase:test_clone ()
    local u1 = URI:new("http://www/foo")
    local u2 = u1:clone()
    u1:path("bar")

    is("http://www/bar", tostring(u1))
    is("http://www/foo", tostring(u2))
end

lunit.run()
-- vim:ts=4 sw=4 expandtab filetype=lua
