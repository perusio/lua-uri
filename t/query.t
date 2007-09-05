require "uri-test"
require "URI"
local testcase = TestCase("Test URI._query")

function testcase:test_query ()
    local u = URI:new("", "http")

    u:query_form({ a = 3, b = 4 })
    is("?a=3&b=4", tostring(u))
    u:query_form({ a = "" })
    is("?a=", tostring(u))
    u:query_form({ ["a[=&+#] "] = " [=&+#]" })
    is("?a%5B%3D%26%2B%23%5D+=+%5B%3D%26%2B%23%5D", tostring(u))

    local aq
    aq = u:query_form()
    assert_hash_shallow_equal({["a[=&+#] "] = " [=&+#]"}, aq)

    aq = u:query_keywords()
    assert_nil(aq)

    u:query_keywords({"a","b"})
    is("?a+b", tostring(u))

    u:query_keywords({" ","+","=","[", "]"})
    is("?%20+%2B+%3D+%5B+%5D", tostring(u))

    aq = u:query_keywords()
    assert_array_shallow_equal({" ","+","=","[","]"}, aq)

    aq = u:query_form()
    is(aq, nil)

    u:query(" +?=#")
    is("?%20+?=%23", tostring(u))

    u:query_keywords({})
    is("", tostring(u))

    u:query_form({ a = 1, b = 2 })
    assert_true("?a=1&b=2" == tostring(u) or "?b=2&a=1" == tostring(u))

    u:query_form({});
    is("", tostring(u))

    u:query_form({ a = {1,2,3,4} })
    is("?a=1&a=2&a=3&a=4", tostring(u))
end

lunit.run()
-- vim:ts=4 sw=4 expandtab filetype=lua
