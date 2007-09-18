require "uri-test"
local Util = require "URI._util"
local testcase = TestCase("Test utility functions in 'uri._util' module")

function testcase:test_split ()
    local list
    list = Util.split(";", "")
    assert_array_shallow_equal({}, list)
    list = Util.split(";", "foo")
    assert_array_shallow_equal({"foo"}, list)
    list = Util.split(";", "foo;bar")
    assert_array_shallow_equal({"foo","bar"}, list)
    list = Util.split(";", "foo;bar;baz")
    assert_array_shallow_equal({"foo","bar","baz"}, list)
    list = Util.split(";", ";")
    assert_array_shallow_equal({"",""}, list)
    list = Util.split(";", "foo;")
    assert_array_shallow_equal({"foo",""}, list)
    list = Util.split(";", ";foo")
    assert_array_shallow_equal({"","foo"}, list)
    -- TODO test with multi-char and more complex patterns
end

function testcase:test_split_with_max ()
    local list
    list = Util.split(";", "foo;bar;baz", 4)
    assert_array_shallow_equal({"foo","bar","baz"}, list)
    list = Util.split(";", "foo;bar;baz", 3)
    assert_array_shallow_equal({"foo","bar","baz"}, list)
    list = Util.split(";", "foo;bar;baz", 2)
    assert_array_shallow_equal({"foo","bar;baz"}, list)
    list = Util.split(";", "foo;bar;baz", 1)
    assert_array_shallow_equal({"foo;bar;baz"}, list)
end

lunit.run()
-- vi:ts=4 sw=4 expandtab
