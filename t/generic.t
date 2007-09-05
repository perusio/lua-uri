require "uri-test"
require "URI"
local testcase = TestCase("Test URI._generic")

function testcase:test_foreign ()
    local foo = URI:new("Foo:opaque#frag")

    is("URI._foreign", getmetatable(foo)._NAME)
    is("Foo:opaque#frag", foo:as_string())
    is("Foo:opaque#frag", tostring(foo))

    -- Try accessors
    is("Foo", foo:_scheme())
    is("foo", foo:scheme())
    is("opaque", foo:opaque())
    is("frag", foo:fragment())
    is("foo:opaque#frag", tostring(foo:canonical()))

    -- Try modificators
    local old = foo:scheme("bar")
    is("foo", old)
    is("bar:opaque#frag", tostring(foo))

    old = foo:scheme("")
    is("bar", old)
    is("opaque#frag", tostring(foo))

    foo:scheme("foo")
    old = foo:scheme(nil)
    is("foo", old)
    is("opaque#frag", tostring(foo))

    foo:scheme("foo")

    old = foo:opaque("xxx")
    is("opaque", old)
    is("foo:xxx#frag", tostring(foo))

    old = foo:opaque("")
    is("xxx", old)
    is("foo:#frag", tostring(foo))

    foo:opaque(" #?/")
    old = foo:opaque("")
    is("%20%23?/", old)
    is("foo:#frag", tostring(foo))

    foo:opaque("opaque")

    old = foo:fragment("x")
    is("frag", old)
    is("foo:opaque#x", tostring(foo))

    old = foo:fragment("")
    is("x", old)
    is("foo:opaque#", tostring(foo))

    old = foo:fragment(nil)
    is("", old)
    is("foo:opaque", tostring(foo))

    -- Compare
    assert_true(foo:eq("Foo:opaque"))
    assert_true(foo:eq(URI:new("FOO:opaque")))
    assert_true(foo:eq("foo:opaque"))
    assert_false(foo:eq("Bar:opaque"))
    assert_false(foo:eq("foo:opaque#"))
    -- TODO - compare with '==', and test more throgoughly boxing of strings, including calling as URI.eq(str,str)
end

function testcase:test_hierarchical ()
    local foo = URI:new("foo://host:80/path?query#frag")
    is("foo://host:80/path?query#frag", tostring(foo))

    -- Accessors
    is("foo", foo:scheme())
    is("host:80", foo:authority())
    is("/path", foo:path())
    is("query", foo:query())
    is("frag", foo:fragment())

    -- Modificators
    local old = foo:authority("xxx")
    is("host:80", old)
    is("foo://xxx/path?query#frag", tostring(foo))

    old = foo:authority("")
    is("xxx", old)
    is("foo:///path?query#frag", tostring(foo))

    old = foo:authority(nil)
    is("", old)
    is("foo:/path?query#frag", tostring(foo))

    old = foo:authority("/? #;@&")
    assert_nil(old)
    is("foo://%2F%3F%20%23;@&/path?query#frag", tostring(foo))

    old = foo:authority("host:80")
    is("%2F%3F%20%23;@&", old)
    is("foo://host:80/path?query#frag", tostring(foo))

    old = foo:path("/foo")
    is("/path", old)
    is("foo://host:80/foo?query#frag", tostring(foo))

    old = foo:path("bar")
    is("/foo", old)
    is("foo://host:80/bar?query#frag", tostring(foo))

    old = foo:path("")
    is("/bar", old)
    is("foo://host:80?query#frag", tostring(foo))

    old = foo:path(nil)
    is("", old)
    is("foo://host:80?query#frag", tostring(foo))

    old = foo:path("@;/?#")
    is("", old)
    is("foo://host:80/@;/%3F%23?query#frag", tostring(foo))

    old = foo:path("path")
    is("/@;/%3F%23", old)
    is("foo://host:80/path?query#frag", tostring(foo))

    old = foo:query("foo")
    is("query", old)
    is("foo://host:80/path?foo#frag", tostring(foo))

    old = foo:query("")
    is("foo", old)
    is("foo://host:80/path?#frag", tostring(foo))

    old = foo:query(nil)
    is("", old)
    is("foo://host:80/path#frag", tostring(foo))

    old = foo:query("/?&=# ")
    assert_nil(old)
    is("foo://host:80/path?/?&=%23%20#frag", tostring(foo))

    old = foo:query("query")
    is("/?&=%23%20", old)
    is("foo://host:80/path?query#frag", tostring(foo))
end

function testcase:test_build ()
    local foo = URI:new("")
    foo:path("path")
    foo:authority("auth")

    is("//auth/path", tostring(foo))

    foo = URI:new("", "http:")
    foo:query("query")
    foo:authority("auth")
    is("//auth?query", tostring(foo))

    foo:path("path")
    is("//auth/path?query", tostring(foo))

    foo = URI:new("")
    old = foo:path("foo")
    is("", old)
    is("foo", tostring(foo))

    old = foo:path("bar")
    is("foo", old)
    is("bar", tostring(foo))

    old = foo:opaque("foo")
    is("bar", old)
    is("foo", tostring(foo))

    old = foo:path("")
    is("foo", old)
    is("", tostring(foo))

    old = foo:query("q")
    assert_nil(old)
    is("?q", tostring(foo))
end

lunit.run()
-- vim:ts=4 sw=4 expandtab filetype=lua
