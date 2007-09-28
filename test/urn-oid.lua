require "uri-test"
local URI = require "URI"
local testcase = TestCase("Test URI.urn.oid")

function testcase:test_oid ()
    local u = URI:new("urn:oid")
    is("urn:oid", tostring(u))
    is("urn", u:scheme())
    is("oid", u:nid())
    is("", u:nss())
    assert_array_shallow_equal({}, u:oid())

    u:nss("1.2.3")
    is("urn", u:scheme())
    is("oid", u:nid())
    is("1.2.3", u:nss())
    assert_array_shallow_equal({1,2,3}, u:oid())

    u:oid({1,2,3,4,5,6,7,8,9,10})
    is("urn:oid:1.2.3.4.5.6.7.8.9.10", tostring(u))
    is("urn", u:scheme())
    is("oid", u:nid())
    is("1.2.3.4.5.6.7.8.9.10", u:nss())
    assert_array_shallow_equal({1,2,3,4,5,6,7,8,9,10}, u:oid())
end

lunit.run()
-- vi:ts=4 sw=4 expandtab
