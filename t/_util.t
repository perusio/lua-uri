require "uri-test"
require "URI"
local testcase = TestCase("Test utility functions in 'URI' module")

function testcase:test_split ()
    local list
    list = URI._split(";", "")
    assert_array_shallow_equal({}, list)
    list = URI._split(";", "foo")
    assert_array_shallow_equal({"foo"}, list)
    list = URI._split(";", "foo;bar")
    assert_array_shallow_equal({"foo","bar"}, list)
    list = URI._split(";", "foo;bar;baz")
    assert_array_shallow_equal({"foo","bar","baz"}, list)
    list = URI._split(";", ";")
    assert_array_shallow_equal({"",""}, list)
    list = URI._split(";", "foo;")
    assert_array_shallow_equal({"foo",""}, list)
    list = URI._split(";", ";foo")
    assert_array_shallow_equal({"","foo"}, list)
    -- TODO test with multi-char and more complex patterns
end

function testcase:test_join ()
    is("", URI._join(".", {}))
    is("foo", URI._join(".", {"foo"}))
    is("foo.bar", URI._join(".", {"foo","bar"}))
    is("foo.bar.baz", URI._join(".", {"foo","bar","baz"}))
end

lunit.run()
-- vim:ts=4 sw=4 expandtab filetype=lua
