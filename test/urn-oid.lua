require "uri-test"
local URI = require "uri"
local testcase = TestCase("Test uri.urn.oid")

function testcase:test_parse_and_normalize ()
    local uri = assert(URI:new("urn:OId:1.3.50403060.0.23"))
    is("uri.urn.oid", uri._NAME)
    is("urn:oid:1.3.50403060.0.23", uri:uri())
    is("urn:oid:1.3.50403060.0.23", tostring(uri))
    is("oid", uri:nid())
    is("1.3.50403060.0.23", uri:nss())
    is("oid:1.3.50403060.0.23", uri:path())
    assert_array_shallow_equal({ 1, 3, 50403060, 0, 23 }, uri:oid_numbers())

    -- Examples from RFC 3061 section 3
    uri = assert(URI:new("urn:oid:1.3.6.1"))
    is("urn:oid:1.3.6.1", tostring(uri))
    assert_array_shallow_equal({ 1, 3, 6, 1 }, uri:oid_numbers())
    uri = assert(URI:new("urn:oid:1.3.6.1.4.1"))
    is("urn:oid:1.3.6.1.4.1", tostring(uri))
    assert_array_shallow_equal({ 1, 3, 6, 1, 4, 1 }, uri:oid_numbers())
    uri = assert(URI:new("urn:oid:1.3.6.1.2.1.27"))
    is("urn:oid:1.3.6.1.2.1.27", tostring(uri))
    assert_array_shallow_equal({ 1, 3, 6, 1, 2, 1, 27 }, uri:oid_numbers())
    uri = assert(URI:new("URN:OID:0.9.2342.19200300.100.4"))
    is("urn:oid:0.9.2342.19200300.100.4", tostring(uri))
    assert_array_shallow_equal({ 0, 9, 2342, 19200300, 100, 4 },
                               uri:oid_numbers())
end

function testcase:test_bad_syntax ()
    is_bad_uri("empty nss", "urn:oid:")
    is_bad_uri("bad character", "urn:oid:1.2.x.3")
    is_bad_uri("missing number", "urn:oid:1.2..3")
    is_bad_uri("leading zero", "urn:oid:1.2.03.3")
    is_bad_uri("leading zero at start", "urn:oid:01.2.3.3")
end

function testcase:test_set_oid_numbers ()
    local uri = assert(URI:new("urn:oid:0.1.23"))
    assert_array_shallow_equal({ 0, 1, 23 }, uri:oid_numbers({ 1 }))
    is("urn:oid:1", tostring(uri))
    assert_array_shallow_equal({ 1 }, uri:oid_numbers({ 234252345, 340, 4, 0 }))
    is("urn:oid:234252345.340.4.0", tostring(uri))
    assert_array_shallow_equal({ 234252345, 340, 4, 0 },
                               uri:oid_numbers({ 23.42 }))
    is("urn:oid:23", tostring(uri))
    assert_array_shallow_equal({ 23 }, uri:oid_numbers())
end

function testcase:test_set_bad_oid_numbers ()
    local uri = assert(URI:new("urn:OID:0.1.23"))
    assert_error("set OID numbers to non-table value",
                 function () uri:oid_numbers("1") end)
    assert_error("set OID to empty list of numbers",
                 function () uri:oid_numbers({}) end)
    assert_error("set OID number to negative number",
                 function () uri:oid_numbers({ -23 }) end)
    assert_error("set OID number array containing bad type",
                 function () uri:oid_numbers({ "x" }) end)

    -- None of that should have had any affect
    is("urn:oid:0.1.23", tostring(uri))
    assert_array_shallow_equal({ 0, 1, 23 }, uri:oid_numbers())
    is("uri.urn.oid", uri._NAME)
end

lunit.run()
-- vi:ts=4 sw=4 expandtab
