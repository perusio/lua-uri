-- This tests the resolution of abs path for all examples given
-- in the "Uniform Resource Identifiers (URI): Generic Syntax" document.

require "uri-test"
local URI = require "uri"
local testcase = TestCase("Test 'abs' method against examples in syntax spec")

local function test_abs_rel (base, uref, expect)
    local bad = false

    -- Test 'resolve' method with object as argument.
    local u = assert(URI:new(uref))
    local b = assert(URI:new(base))
    u:resolve(b)
    local got = tostring(u)
    if got ~= expect then
        bad = true
        print("URI:new(" .. uref .. "):resolve(URI:new(" .. base .. ") ===> " ..
              expect .. " (not " .. got .. ")")
    end

    -- Test 'resolve' method with string as argument.
    u = assert(URI:new(uref))
    u:resolve(base)
    local got = tostring(u)
    if got ~= expect then
        bad = true
        print("URI:new(" .. uref .. "):resolve(URI:new(" .. base .. ") ===> " ..
              expect .. " (not " .. got .. ")")
    end

    -- Let's test another version of the same thing
    local u = assert(URI:new(uref, base))
    local got = tostring(u)
    if got ~= expect then
        bad = true
        print("URI:new(" .. uref .. ", " .. base .. ") ==> " .. expect ..
              " (not " .. got .. ")")
    end

    -- Let's try the other way
    --u = URI:new(expect):rel(base)
    --if tostring(u) ~= uref then
--      Commented out because I don't think these are serious problems, just
--      things for someone to check.  The results of printing this are
--      exactly the same as the Perl version I ported from.
--        print("URI->new(\"" .. expect .. "\", \"" .. base ..
--              "\")->rel ==> \"" .. tostring(u) .. '" (not "' .. uref .. '")')
    --end

    return bad
end

function testcase:test_abs ()
    local base = "x-foo://a/b/c/d;p?q"
    local testno = 1
    local bad = false

    local tests = require("test.data.abs-data")
    for rel, abs in pairs(tests) do
        if test_abs_rel(base, rel, abs) then bad = true end
    end

    if bad then assert_fail("one of the checks went wrong") end
end

lunit.run()
-- vi:ts=4 sw=4 expandtab
