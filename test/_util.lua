require "uri-test"
local Util = require "uri._util"
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

function testcase:test_attempt_require ()
    local mod = Util.attempt_require("string")
    assert_table(mod)
    mod = Util.attempt_require("lua-module-which-doesn't-exist")
    assert_nil(mod)
end

function testcase:test_subclass_of ()
    local baseclass = {}
    baseclass.__index = baseclass
    baseclass.overridden = function () return "baseclass" end
    baseclass.inherited = function () return "inherited" end

    local subclass = {}
    Util.subclass_of(subclass, baseclass)
    subclass.overridden = function () return "subclass" end

    assert(getmetatable(subclass) == baseclass)
    assert(subclass._SUPER == baseclass)

    local baseobject, subobject = {}, {}
    setmetatable(baseobject, baseclass)
    setmetatable(subobject, subclass)

    is("baseclass", baseobject:overridden())
    is("subclass", subobject:overridden())
    is("inherited", baseobject:inherited())
    is("inherited", subobject:inherited())
end

lunit.run()
-- vi:ts=4 sw=4 expandtab