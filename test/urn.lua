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

lunit.run()
-- vi:ts=4 sw=4 expandtab
