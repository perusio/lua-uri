require "uri-test"
local URI = require "uri"
local testcase = TestCase("Test uri.urn")

function testcase:test_urn_parsing ()
    local uri = assert(URI:new("urn:x-FOO-01239-:Nss"))
    is("urn:x-foo-01239-:Nss", uri:uri())
    is("urn", uri:scheme())
    is("x-foo-01239-:Nss", uri:path())
    is("x-foo-01239-", uri:nid())
    is("Nss", uri:nss())
    is(nil, uri:userinfo())
    is(nil, uri:host())
    is(nil, uri:port())
    is(nil, uri:query())
    is(nil, uri:fragment())
end

function testcase:test_bad_urn_syntax ()
    is_bad_uri("missing nid", "urn::bar")
    is_bad_uri("hyphen at start of nid", "urn:-x-foo:bar")
    is_bad_uri("plus in middle of nid", "urn:x+foo:bar")
    is_bad_uri("underscore in middle of nid", "urn:x_foo:bar")
    is_bad_uri("dot in middle of nid", "urn:x.foo:bar")
    is_bad_uri("nid too long", "urn:x-012345678901234567890123456789x:bar")
    is_bad_uri("reserved 'urn' nid", "urn:urn:bar")
    is_bad_uri("missing nss", "urn:x-foo:")
    is_bad_uri("bad char in nss", "urn:x-foo:bar&")
end

function testcase:test_change_nid ()
    local urn = assert(URI:new("urn:x-foo:14734966"))
    is("urn:x-foo:14734966", tostring(urn))
    is("x-foo", urn:nid())
    is("uri.urn", urn._NAME)

    -- x-foo -> x-bar
    is("x-foo", urn:nid("x-bar"))
    is("x-bar", urn:nid())
    is("urn:x-bar:14734966", tostring(urn))
    is("uri.urn", urn._NAME)

    -- x-bar -> issn
    is("x-bar", urn:nid("issn"))
    is("issn", urn:nid())
    is("urn:issn:1473-4966", tostring(urn))
    is("uri.urn.issn", urn._NAME)

    -- issn -> x-foo
    is("issn", urn:nid("x-foo"))
    is("x-foo", urn:nid())
    is("urn:x-foo:1473-4966", tostring(urn))
    is("uri.urn", urn._NAME)
end

function testcase:test_change_nid_bad ()
    local urn = assert(URI:new("urn:x-foo:frob"))

    -- Try changing the NID to something invalid
    assert_error("bad NID 'urn'", function () urn:nid("urn") end)
    assert_error("bad NID '-x-foo'", function () urn:nid("-x-foo") end)
    assert_error("bad NID 'x+foo'", function () urn:nid("x+foo") end)

    -- Change to valid NID, but where the NSS is not valid for it
    assert_error("bad NSS for ISSN URN", function () urn:nid("issn") end)

    -- Original URN should be left unchanged
    is("urn:x-foo:frob", tostring(urn))
    is("x-foo", urn:nid())
    is("uri.urn", urn._NAME)
end

lunit.run()
-- vi:ts=4 sw=4 expandtab
