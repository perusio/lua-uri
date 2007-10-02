require "uri-test"
local URI = require "uri"
local testcase = TestCase("Test uri._generic")

local function test_norm (expected, input)
    local uri = assert(URI:new(input))
    is(expected, uri:uri())
    is(expected, tostring(uri))
end

local function test_norm_already (input)
    test_norm(input, input)
end

function testcase:test_normalize_percent_encoding ()
    -- Don't use unnecessary percent encoding for unreserved characters.
    test_norm("x:ABCDEFGHIJKLM", "x:%41%42%43%44%45%46%47%48%49%4A%4b%4C%4d")
    test_norm("x:NOPQRSTUVWXYZ", "x:%4E%4f%50%51%52%53%54%55%56%57%58%59%5A")
    test_norm("x:abcdefghijklm", "x:%61%62%63%64%65%66%67%68%69%6A%6b%6C%6d")
    test_norm("x:nopqrstuvwxyz", "x:%6E%6f%70%71%72%73%74%75%76%77%78%79%7A")
    test_norm("x:0123456789", "x:%30%31%32%33%34%35%36%37%38%39")
    test_norm("x:-._~", "x:%2D%2e%5F%7e")

    -- Keep percent encoding for other characters in US-ASCII.
    test_norm_already("x:%00%01%02%03%04%05%06%07%08%09%0A%0B%0C%0D%0E%0F")
    test_norm_already("x:%10%11%12%13%14%15%16%17%18%19%1A%1B%1C%1D%1E%1F")
    test_norm_already("x:%20%21%22%23%24%25%26%27%28%29%2A%2B%2C")
    test_norm_already("x:%2F")
    test_norm_already("x:%3A%3B%3C%3D%3E%3F%40")
    test_norm_already("x:%5B%5C%5D%5E")
    test_norm_already("x:%60")
    test_norm_already("x:%7B%7C%7D")
    test_norm_already("x:%7F")

    -- Normalize hex digits in percent encoding to uppercase.
    test_norm("x:%0A%0B%0C%0D%0E%0F", "x:%0a%0b%0c%0d%0e%0f")
    test_norm("x:%AA%BB%CC%DD%EE%FF", "x:%aA%bB%cC%dD%eE%fF")

    -- Keep percent encoding, and normalize hex digit case, for all characters
    -- outside US-ASCII.
    for i = 0x80, 0xFF do
        test_norm_already(string.format("x:%%%02X", i))
        test_norm(string.format("x:%%%02X", i), string.format("x:%%%02x", i))
    end
end

function testcase:test_bad_percent_encoding ()
    assert_error("double percent", function () URI:new("x:foo%%2525") end)
    assert_error("no hex digits", function () URI:new("x:foo%") end)
    assert_error("no hex digits 2nd time", function () URI:new("x:f%20o%") end)
    assert_error("1 hex digit", function () URI:new("x:foo%2") end)
    assert_error("1 hex digit 2nd time", function () URI:new("x:f%20o%2") end)
    assert_error("bad hex digit 1", function () URI:new("x:foo%G2bar") end)
    assert_error("bad hex digit 2", function () URI:new("x:foo%2Gbar") end)
    assert_error("bad hex digit both", function () URI:new("x:foo%GGbar") end)
end

function testcase:test_scheme ()
    test_norm_already("foo:")
    test_norm_already("foo:-+.:")
    test_norm_already("foo:-+.0123456789:")
    test_norm_already("x:")
    test_norm("example:FooBar:Baz", "ExAMplE:FooBar:Baz")

    local uri = assert(URI:new("Foo-Bar:Baz%20Quux"))
    is("foo-bar", uri:scheme())
end

function testcase:test_change_scheme ()
    local uri = assert(URI:new("x-foo://example.com/blah"))
    is("x-foo://example.com/blah", tostring(uri))
    is("x-foo", uri:scheme())
    is("uri", uri._NAME)

    -- x-foo -> x-bar
    is("x-foo", uri:scheme("x-bar"))
    is("x-bar", uri:scheme())
    is("x-bar://example.com/blah", tostring(uri))
    is("uri", uri._NAME)

    -- x-bar -> http
    is("x-bar", uri:scheme("http"))
    is("http", uri:scheme())
    is("http://example.com/blah", tostring(uri))
    is("uri.http", uri._NAME)

    -- http -> x-foo
    is("http", uri:scheme("x-foo"))
    is("x-foo", uri:scheme())
    is("x-foo://example.com/blah", tostring(uri))
    is("uri", uri._NAME)
end

function testcase:test_change_scheme_bad ()
    local uri = assert(URI:new("x-foo://foo@bar/"))

    -- Try changing the scheme to something invalid
    assert_error("bad scheme '-x-foo'", function () uri:scheme("-x-foo") end)
    assert_error("bad scheme 'x,foo'", function () uri:scheme("x,foo") end)
    assert_error("bad scheme 'x:foo'", function () uri:scheme("x:foo") end)
    assert_error("bad scheme 'x-foo:'", function () uri:scheme("x-foo:") end)

    -- Change to valid scheme, but where the rest of the URI is not valid for it
    assert_error("bad HTTP URI", function () uri:scheme("http") end)

    -- Original URI should be left unchanged
    is("x-foo://foo@bar/", tostring(uri))
    is("x-foo", uri:scheme())
    is("uri", uri._NAME)
end

function testcase:test_auth_userinfo ()
    local uri = assert(URI:new("X://a-zA-Z09!$:&%40@FOO.com:80/"))
    is("x://a-zA-Z09!$:&%40@foo.com:80/", tostring(uri))
    is("x", uri:scheme())
    is("a-zA-Z09!$:&%40", uri:userinfo())
    is("foo.com", uri:host())
    is(80, uri:port())
end

function testcase:test_auth_set_userinfo ()
    local uri = assert(URI:new("X-foo://user:pass@FOO.com:80/"))
    is("user:pass", uri:userinfo("newuserinfo"))
    is("newuserinfo", uri:userinfo())
    is("x-foo://newuserinfo@foo.com:80/", tostring(uri))

    -- Userinfo should be supplied already percent-encoded, but the percent
    -- encoding should be normalized.
    is("newuserinfo", uri:userinfo("foo%3abar%3A:%78"))
    is("foo%3Abar%3A:x", uri:userinfo())

    -- It should be OK to use more than one colon in userinfo for generic URIs,
    -- although not for ones which specificly divide it into username:password.
    is("foo%3Abar%3A:x", uri:userinfo("foo:bar:baz::"))
    is("foo:bar:baz::", uri:userinfo())
end

function testcase:test_auth_set_bad_userinfo ()
    local uri = assert(URI:new("X-foo://user:pass@FOO.com:80/"))
    assert_error("/ in userinfo", function () uri:userinfo("foo/bar") end)
    assert_error("@ in userinfo", function () uri:userinfo("foo@bar") end)
    is("user:pass", uri:userinfo())
    is("x-foo://user:pass@foo.com:80/", tostring(uri))
end

function testcase:test_auth_reg_name ()
    local uri = assert(URI:new("x://azAZ0-9--foo.bqr_baz~%20!$;/"))
    -- TODO - %20 should probably be rejected.  Apparently only UTF-8 pctenc
    -- should be produced, so after unescaping unreserved chars there should
    -- be nothing left percent encoded other than valid UTF-8 sequences.  If
    -- that's right I could safely decode the host before returning it.
    is("azaz0-9--foo.bqr_baz~%20!$;", uri:host())
end

function testcase:test_auth_ip4 ()
    local uri = assert(URI:new("x://0.0.0.0/path"))
    is("0.0.0.0", uri:host())
    uri = assert(URI:new("x://192.168.0.1/path"))
    is("192.168.0.1", uri:host())
    uri = assert(URI:new("x://255.255.255.255/path"))
    is("255.255.255.255", uri:host())
end

function testcase:test_auth_ip6 ()
    -- The example addresses in here are all from RFC 4291 section 2.2, except
    -- that they get normalized to lowercase here in the results.
    local uri = assert(URI:new("x://[ABCD:EF01:2345:6789:ABCD:EF01:2345:6789]"))
    is("[abcd:ef01:2345:6789:abcd:ef01:2345:6789]", uri:host())
    uri = assert(URI:new("x://[ABCD:EF01:2345:6789:ABCD:EF01:2345:6789]/"))
    is("[abcd:ef01:2345:6789:abcd:ef01:2345:6789]", uri:host())
    uri = assert(URI:new("x://[ABCD:EF01:2345:6789:ABCD:EF01:2345:6789]:"))
    is("[abcd:ef01:2345:6789:abcd:ef01:2345:6789]", uri:host())
    uri = assert(URI:new("x://[ABCD:EF01:2345:6789:ABCD:EF01:2345:6789]:/"))
    is("[abcd:ef01:2345:6789:abcd:ef01:2345:6789]", uri:host())
    uri = assert(URI:new("x://[ABCD:EF01:2345:6789:ABCD:EF01:2345:6789]:0/"))
    is("[abcd:ef01:2345:6789:abcd:ef01:2345:6789]", uri:host())
    uri = assert(URI:new("x://y:z@[ABCD:EF01:2345:6789:ABCD:EF01:2345:6789]:80/"))
    is("[abcd:ef01:2345:6789:abcd:ef01:2345:6789]", uri:host())
    uri = assert(URI:new("x://[2001:DB8:0:0:8:800:200C:417A]/"))
    is("[2001:db8:0:0:8:800:200c:417a]", uri:host())
    uri = assert(URI:new("x://[FF01:0:0:0:0:0:0:101]/"))
    is("[ff01:0:0:0:0:0:0:101]", uri:host())
    uri = assert(URI:new("x://[ff01::101]/"))
    is("[ff01::101]", uri:host())
    uri = assert(URI:new("x://[0:0:0:0:0:0:0:1]/"))
    is("[0:0:0:0:0:0:0:1]", uri:host())
    uri = assert(URI:new("x://[::1]/"))
    is("[::1]", uri:host())
    uri = assert(URI:new("x://[0:0:0:0:0:0:0:0]/"))
    is("[0:0:0:0:0:0:0:0]", uri:host())
    uri = assert(URI:new("x://[0:0:0:0:0:0:13.1.68.3]/"))
    is("[0:0:0:0:0:0:13.1.68.3]", uri:host())
    uri = assert(URI:new("x://[::13.1.68.3]/"))
    is("[::13.1.68.3]", uri:host())
    uri = assert(URI:new("x://[0:0:0:0:0:FFFF:129.144.52.38]/"))
    is("[0:0:0:0:0:ffff:129.144.52.38]", uri:host())
    uri = assert(URI:new("x://[::FFFF:129.144.52.38]/"))
    is("[::ffff:129.144.52.38]", uri:host())

    -- These try all the cominations of abbreviating using '::'.
    uri = assert(URI:new("x://[08:19:2a:3B:4c:5D:6e:7F]/"))
    is("[08:19:2a:3b:4c:5d:6e:7f]", uri:host())
    uri = assert(URI:new("x://[::19:2a:3B:4c:5D:6e:7F]/"))
    is("[::19:2a:3b:4c:5d:6e:7f]", uri:host())
    uri = assert(URI:new("x://[::2a:3B:4c:5D:6e:7F]/"))
    is("[::2a:3b:4c:5d:6e:7f]", uri:host())
    uri = assert(URI:new("x://[::3B:4c:5D:6e:7F]/"))
    is("[::3b:4c:5d:6e:7f]", uri:host())
    uri = assert(URI:new("x://[::4c:5D:6e:7F]/"))
    is("[::4c:5d:6e:7f]", uri:host())
    uri = assert(URI:new("x://[::5D:6e:7F]/"))
    is("[::5d:6e:7f]", uri:host())
    uri = assert(URI:new("x://[::6e:7F]/"))
    is("[::6e:7f]", uri:host())
    uri = assert(URI:new("x://[::7F]/"))
    is("[::7f]", uri:host())
    uri = assert(URI:new("x://[::]/"))
    is("[::]", uri:host())
    uri = assert(URI:new("x://[08::]/"))
    is("[08::]", uri:host())
    uri = assert(URI:new("x://[08:19::]/"))
    is("[08:19::]", uri:host())
    uri = assert(URI:new("x://[08:19:2a::]/"))
    is("[08:19:2a::]", uri:host())
    uri = assert(URI:new("x://[08:19:2a:3B::]/"))
    is("[08:19:2a:3b::]", uri:host())
    uri = assert(URI:new("x://[08:19:2a:3B:4c::]/"))
    is("[08:19:2a:3b:4c::]", uri:host())
    uri = assert(URI:new("x://[08:19:2a:3B:4c:5D::]/"))
    is("[08:19:2a:3b:4c:5d::]", uri:host())
    uri = assert(URI:new("x://[08:19:2a:3B:4c:5D:6e::]/"))
    is("[08:19:2a:3b:4c:5d:6e::]", uri:host())

    -- Try extremes of good IPv4 addresses mapped to IPv6.
    uri = assert(URI:new("x://[::FFFF:0.0.0.0]/path"))
    is("[::ffff:0.0.0.0]", uri:host())
    uri = assert(URI:new("x://[::ffff:255.255.255.255]/path"))
    is("[::ffff:255.255.255.255]", uri:host())
end

function testcase:test_auth_ip6_bad ()
    assert_error("empty brackets", function () URI:new("x://[]") end)
    assert_error("just colon", function () URI:new("x://[:]") end)
    assert_error("3 colons only", function () URI:new("x://[:::]") end)
    assert_error("3 colons at start", function () URI:new("x://[:::1234]") end)
    assert_error("3 colons at end", function () URI:new("x://[1234:::]") end)
    assert_error("3 colons in middle", function () URI:new("x://[1234:::5678]") end)
    assert_error("non-hex char", function () URI:new("x://[ABCD:EF01:2345:6789:ABCD:EG01:2345:6789]") end)
    assert_error("chunk too big", function () URI:new("x://[ABCD:EF01:2345:6789:ABCD:EFF01:2345:6789]") end)
    assert_error("too many chunks", function () URI:new("x://[ABCD:EF01:2345:6789:ABCD:EF01:2345:6789:1]") end)
    assert_error("not enough chunks", function () URI:new("x://[ABCD:EF01:2345:6789:ABCD:EF01:2345]") end)
    assert_error("too many chunks with ellipsis in middle", function () URI:new("x://[ABCD:EF01:2345:6789:ABCD::EF01:2345:6789]") end)
    assert_error("too many chunks with ellipsis at end", function () URI:new("x://[ABCD:EF01:2345:6789:ABCD:EF01:2345:6789::]") end)
    assert_error("too many chunks with ellipsis at start", function () URI:new("x://[::ABCD:EF01:2345:6789:ABCD:EF01:2345:6789]") end)
    assert_error("two elipses, middle and end", function () URI:new("x://[EF01:2345::6789:ABCD:EF01:2345::]") end)
    assert_error("two elipses, start and middle", function () URI:new("x://[::EF01:2345::6789:ABCD:EF01:2345]") end)
    assert_error("two elipses, both ends", function () URI:new("x://[::EF01:2345:6789:ABCD:EF01:2345::]") end)
    assert_error("two elipses, both middle", function () URI:new("x://[EF01:2345::6789:ABCD:::EF01:2345]") end)
    assert_error("extra colon at start", function () URI:new("x://[:ABCD:EF01:2345:6789:ABCD:EF01:2345:6789]") end)
    assert_error("missing chunk at start", function () URI:new("x://[:EF01:2345:6789:ABCD:EF01:2345:6789]") end)
    assert_error("extra colon at end", function () URI:new("x://[ABCD:EF01:2345:6789:ABCD:EF01:2345:6789:]") end)
    assert_error("missing chunk at end", function () URI:new("x://[ABCD:EF01:2345:6789:ABCD:EF01:2345:]") end)

    -- Bad IPv4 addresses mapped to IPv6.
    assert_error("octet 1 too big", function () URI:new("x://[::FFFF:256.2.3.4]/") end)
    assert_error("octet 2 too big", function () URI:new("x://[::FFFF:1.256.3.4]/") end)
    assert_error("octet 3 too big", function () URI:new("x://[::FFFF:1.2.256.4]/") end)
    assert_error("octet 4 too big", function () URI:new("x://[::FFFF:1.2.3.256]/") end)
    assert_error("octet 1 leading zeroes", function () URI:new("x://[::FFFF:01.2.3.4]/") end)
    assert_error("octet 2 leading zeroes", function () URI:new("x://[::FFFF:1.02.3.4]/") end)
    assert_error("octet 3 leading zeroes", function () URI:new("x://[::FFFF:1.2.03.4]/") end)
    assert_error("octet 4 leading zeroes", function () URI:new("x://[::FFFF:1.2.3.04]/") end)
    assert_error("only 2 octets", function () URI:new("x://[::FFFF:1.2]/") end)
    assert_error("only 3 octets", function () URI:new("x://[::FFFF:1.2.3]/") end)
    assert_error("5 octets", function () URI:new("x://[::FFFF:1.2.3.4.5]/") end)
end

function testcase:test_auth_port ()
    local uri = assert(URI:new("x://localhost:0/path"))
    is(0, uri:port())
    uri = assert(URI:new("x://localhost:0"))
    is(0, uri:port())
    uri = assert(URI:new("x://foo:bar@localhost:0"))
    is(0, uri:port())
    uri = assert(URI:new("x://localhost:00/path"))
    is(0, uri:port())
    uri = assert(URI:new("x://localhost:00"))
    is(0, uri:port())
    uri = assert(URI:new("x://foo:bar@localhost:00"))
    is(0, uri:port())
    uri = assert(URI:new("x://localhost:54321/path"))
    is(54321, uri:port())
    uri = assert(URI:new("x://localhost:54321"))
    is(54321, uri:port())
    uri = assert(URI:new("x://foo:bar@localhost:54321"))
    is(54321, uri:port())
    uri = assert(URI:new("x://foo:bar@localhost:"))
    is(nil, uri:port())
    uri = assert(URI:new("x://foo:bar@localhost:/"))
    is(nil, uri:port())
    uri = assert(URI:new("x://foo:bar@localhost"))
    is(nil, uri:port())
    uri = assert(URI:new("x://foo:bar@localhost/"))
    is(nil, uri:port())
end

function testcase:test_path ()
    local uri = assert(URI:new("x:"))
    is("", uri:path())
    uri = assert(URI:new("x:?"))
    is("", uri:path())
    uri = assert(URI:new("x:#"))
    is("", uri:path())
    uri = assert(URI:new("x:/"))
    is("/", uri:path())
    uri = assert(URI:new("x://"))
    is("", uri:path())
    uri = assert(URI:new("x://?"))
    is("", uri:path())
    uri = assert(URI:new("x://#"))
    is("", uri:path())
    uri = assert(URI:new("x:///"))
    is("/", uri:path())
    uri = assert(URI:new("x:////"))
    is("//", uri:path())
    uri = assert(URI:new("x:foo"))
    is("foo", uri:path())
    uri = assert(URI:new("x:/foo"))
    is("/foo", uri:path())
    uri = assert(URI:new("x://foo"))
    is("", uri:path())
    uri = assert(URI:new("x://foo?"))
    is("", uri:path())
    uri = assert(URI:new("x://foo#"))
    is("", uri:path())
    uri = assert(URI:new("x:///foo"))
    is("/foo", uri:path())
    uri = assert(URI:new("x:////foo"))
    is("//foo", uri:path())
    uri = assert(URI:new("x://foo/"))
    is("/", uri:path())
    uri = assert(URI:new("x://foo/bar"))
    is("/bar", uri:path())
end

function testcase:test_query ()
    local uri = assert(URI:new("x:?"))
    is("", uri:query())
    uri = assert(URI:new("x:"))
    is(nil, uri:query())
    uri = assert(URI:new("x:/foo"))
    is(nil, uri:query())
    uri = assert(URI:new("x:/foo#"))
    is(nil, uri:query())
    uri = assert(URI:new("x:/foo#bar?baz"))
    is(nil, uri:query())
    uri = assert(URI:new("x:/foo?"))
    is("", uri:query())
    uri = assert(URI:new("x://foo?"))
    is("", uri:query())
    uri = assert(URI:new("x://foo/?"))
    is("", uri:query())
    uri = assert(URI:new("x:/foo?bar"))
    is("bar", uri:query())
    uri = assert(URI:new("x:?foo?bar?"))
    is("foo?bar?", uri:query())
    uri = assert(URI:new("x:?foo?bar?#quux?frob"))
    is("foo?bar?", uri:query())
    uri = assert(URI:new("x://foo/bar%3Fbaz?"))
    is("", uri:query())
    uri = assert(URI:new("x:%3F?foo"))
    is("%3F", uri:path())
    is("foo", uri:query())
end

function testcase:test_fragment ()
    local uri = assert(URI:new("x:"))
    is(nil, uri:fragment())
    uri = assert(URI:new("x:#"))
    is("", uri:fragment())
    uri = assert(URI:new("x://#"))
    is("", uri:fragment())
    uri = assert(URI:new("x:///#"))
    is("", uri:fragment())
    uri = assert(URI:new("x:////#"))
    is("", uri:fragment())
    uri = assert(URI:new("x:#foo"))
    is("foo", uri:fragment())
    uri = assert(URI:new("x:%23#foo"))
    is("%23", uri:path())
    is("foo", uri:fragment())
    uri = assert(URI:new("x:?foo?bar?#quux?frob"))
    is("quux?frob", uri:fragment())
end

function testcase:test_bad_usage ()
    assert_error("missing uri arg", function () URI:new() end)
    assert_error("nil uri arg", function () URI:new(nil) end)
end

lunit.run()
-- vi:ts=4 sw=4 expandtab
