require "uri-test"
local URI = require "URI"
local testcase = TestCase("Test URI.urn.isbn")

function testcase:test_isbn ()
    local u = URI:new("URN:ISBN:0395363411")

    is("URN:ISBN:0395363411", tostring(u))
    is("urn", u:scheme())
    is("isbn", u:nid())
    is("0395363411", u:nss())
    is("urn:isbn:0-395-36341-1", tostring(u:canonical()))

    local isbn = u:isbn()
    assert_table(isbn)
    is("0-395-36341-1", tostring(isbn))
    is("0", isbn:group_code())
    is("395", isbn:publisher_code())
    is("978-0-395-36341-6", tostring(isbn:as_isbn13()))

    local old = u:isbn("0-88730-866-x")
    is(tostring(isbn), tostring(old))
    is("0-88730-866-x", u:nss())
    is("0-88730-866-X", tostring(u:isbn()))

    assert_true(URI.eq("urn:isbn:088730866x", "URN:ISBN:0-88-73-08-66-X"))
end

function testcase:test_illegal_isbn ()
    local u = URI:new("urn:ISBN:abc")
    is("urn:ISBN:abc", tostring(u))
    is("abc", u:nss())
    assert_nil(u:isbn())
end

if URI._attempt_require("isbn") then
    lunit.run()
else
    print("Skipped t/urn-isbn.t: needs the lua-isbn module installed, you" ..
          " can get it from here: http://www.daizucms.org/lua/library/isbn/")
end

-- vi:ts=4 sw=4 expandtab
