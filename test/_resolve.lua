require "uri-test"
local URI = require "uri"
local testcase = TestCase("Test 'resolve' and 'relativize' methods")

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

    -- Test resolving relative URI using the constructor.
    local u = assert(URI:new(uref, base))
    local got = tostring(u)
    if got ~= expect then
        bad = true
        print("URI:new(" .. uref .. ", " .. base .. ") ==> " .. expect ..
              " (not " .. got .. ")")
    end

    return bad
end

function testcase:test_resolve ()
    local base = "x-foo://a/b/c/d;p?q"
    local testno = 1
    local bad = false

    local tests = require("test.data.abs-data")
    for rel, abs in pairs(tests) do
        if test_abs_rel(base, rel, abs) then bad = true end
    end

    if bad then assert_fail("one of the checks went wrong") end
end

local relativize_tests = {
    -- Empty path if the path is the same as the base URI's.
    { "http://ex/", "http://ex/", "" },
    { "http://ex/a/b", "http://ex/a/b", "" },
    { "http://ex/a/b/", "http://ex/a/b/", "" },
    -- Absolute path if the base URI's path doesn't help.
    { "http://ex/", "http://ex/a/b", "/" },
    { "http://ex/", "http://ex/a/b/", "/" },
    { "http://ex/x/y", "http://ex/", "/x/y" },
    { "http://ex/x/y/", "http://ex/", "/x/y/" },
    { "http://ex/x", "http://ex/a", "/x" },
    { "http://ex/x", "http://ex/a/", "/x" },
    { "http://ex/x/", "http://ex/a", "/x/" },
    { "http://ex/x/", "http://ex/a/", "/x/" },
    { "http://ex/x/y", "http://ex/a/b", "/x/y" },
    { "http://ex/x/y", "http://ex/a/b/", "/x/y" },
    { "http://ex/x/y/", "http://ex/a/b", "/x/y/" },
    { "http://ex/x/y/", "http://ex/a/b/", "/x/y/" },
    -- Add to the end of the base path.
    { "x-a://ex/a/b/c", "x-a://ex/a/b/", "c" },
    { "x-a://ex/a/b/c/", "x-a://ex/a/b/", "c/" },
    { "x-a://ex/a/b/c/d", "x-a://ex/a/b/", "c/d" },
    { "x-a://ex/a/b/c/d/", "x-a://ex/a/b/", "c/d/" },
    { "x-a://ex/a/b/c/d/e", "x-a://ex/a/b/", "c/d/e" },
    { "x-a://ex/a/b/c:foo/d/e", "x-a://ex/a/b/", "./c:foo/d/e" },
    -- Change last segment in base path, and add to it.
    { "x-a://ex/a/b/", "x-a://ex/a/b/c", "./" },
    { "x-a://ex/a/b/x", "x-a://ex/a/b/c", "x" },
    { "x-a://ex/a/b/x/", "x-a://ex/a/b/c", "x/" },
    { "x-a://ex/a/b/x/y", "x-a://ex/a/b/c", "x/y" },
    { "x-a://ex/a/b/x:foo/y", "x-a://ex/a/b/c", "./x:foo/y" },
    -- Use '..' segments.
    { "x-a://ex/a/b/c", "x-a://ex/a/b/c/d", "../c" },
    { "x-a://ex/a/b/c", "x-a://ex/a/b/c/", "../c" },
    { "x-a://ex/a/b/", "x-a://ex/a/b/c/", "../" },
    { "x-a://ex/a/b/", "x-a://ex/a/b/c/d", "../" },
    { "x-a://ex/a/b", "x-a://ex/a/b/c/", "../../b" },
    { "x-a://ex/a/b", "x-a://ex/a/b/c/d", "../../b" },
    { "x-a://ex/a/", "x-a://ex/a/b/c/", "../../" },
    { "x-a://ex/a/", "x-a://ex/a/b/c/d", "../../" },
    -- Preserve query and fragment parts.
    { "http://ex/a/b", "http://ex/a/b?baseq#basef", "b" },
    { "http://ex/a/b:c", "http://ex/a/b:c?baseq#basef", "./b:c" },
    { "http://ex/a/b?", "http://ex/a/b?baseq#basef", "?" },
    { "http://ex/a/b?foo", "http://ex/a/b?baseq#basef", "?foo" },
    { "http://ex/a/b?foo#", "http://ex/a/b?baseq#basef", "?foo#" },
    { "http://ex/a/b?foo#bar", "http://ex/a/b?baseq#basef", "?foo#bar" },
    { "http://ex/a/b#bar", "http://ex/a/b?baseq#basef", "b#bar" },
    { "http://ex/a/b:foo#bar", "http://ex/a/b:foo?baseq#basef", "./b:foo#bar" },
    { "http://ex/a/b:foo#bar", "http://ex/a/b:foo#basef", "#bar" },
}

function testcase:test_relativize ()
    for _, test in ipairs(relativize_tests) do
        local uri = assert(URI:new(test[1]))
        uri:relativize(test[2])
        is(test[3], tostring(uri))

        -- Make sure it will resolve back to the original value.
        uri:resolve(test[2])
        is(test[1], tostring(uri))
    end
end

function testcase:test_relativize_already_is ()
    local uri = assert(URI:new("../foo"))
    uri:relativize("http://host/")
    is("../foo", tostring(uri))
end

function testcase:test_relativize_urn ()
    local uri = assert(URI:new("urn:oid:1.2.3"))
    uri:relativize("urn:oid:1")
    is("urn:oid:1.2.3", tostring(uri))
end

lunit.run()
-- vi:ts=4 sw=4 expandtab
