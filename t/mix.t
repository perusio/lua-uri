require "uri-test"
local URI = require "URI"
local URIWithBase = require "URI.WithBase"
local testcase = TestCase("Test mixing of URI and URI.WithBase objects")

function testcase:test_mix ()
    local str = "http://www.sn.no/"
    local rel = "path/img.gif"

    local u  = URI:new(str)
    local uw = URIWithBase:new(str, "http:")

    local a = URI:new(rel, u)
    local b = URI:new(rel, uw)
    local d = URI:new(rel, str)

    assert_isa(a, URI)
    is(getmetatable(uw), getmetatable(b))
    assert_isa(d, URI)
end

lunit.run()
-- vim:ts=4 sw=4 expandtab filetype=lua
