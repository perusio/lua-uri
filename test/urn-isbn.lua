require "uri-test"
local URI = require "uri"
local Util = require "URI._util"
local testcase = TestCase("Test uri.urn.isbn")

local have_isbn_module = Util.attempt_require("isbn")

function testcase:test_isbn ()
    -- Example from RFC 2288
    local u = URI:new("URN:ISBN:0-395-36341-1")
    is(have_isbn_module and "urn:isbn:0-395-36341-1" or "urn:isbn:0395363411",
       u:uri())
    is("urn", u:scheme())
    is("isbn", u:nid())
    is(have_isbn_module and "0-395-36341-1" or "0395363411", u:nss())
    is("0395363411", u:isbn_digits())

    u = URI:new("URN:ISBN:0395363411")
    is(have_isbn_module and "urn:isbn:0-395-36341-1" or "urn:isbn:0395363411",
       u:uri())
    is("urn", u:scheme())
    is("isbn", u:nid())
    is(have_isbn_module and "0-395-36341-1" or "0395363411", u:nss())
    is("0395363411", u:isbn_digits())

    if have_isbn_module then
        local isbn = u:isbn()
        assert_table(isbn)
        is("0-395-36341-1", tostring(isbn))
        is("0", isbn:group_code())
        is("395", isbn:publisher_code())
        is("978-0-395-36341-6", tostring(isbn:as_isbn13()))
    end

    assert_true(URI.eq("urn:isbn:088730866x", "URN:ISBN:0-88-73-08-66-X"))
end

function testcase:test_isbn_setting_digits ()
    local u = URI:new("URN:ISBN:0395363411")
    local old = u:isbn_digits("0-88730-866-x")
    is("0395363411", old)
    is("088730866X", u:isbn_digits())
    is(have_isbn_module and "0-88730-866-X" or "088730866X", u:nss())
    if have_isbn_module then
        is("0-88730-866-X", tostring(u:isbn()))
    end
end

function testcase:test_isbn_setting_object ()
    if have_isbn_module then
        local ISBN = require "isbn"
        local u = URI:new("URN:ISBN:0395363411")
        local old = u:isbn(ISBN:new("0-88730-866-x"))
        assert_table(old)
        is("0-395-36341-1", tostring(old))
        is("088730866X", u:isbn_digits())
        is("0-88730-866-X", u:nss())
        local new = u:isbn()
        assert_table(new)
        is("0-88730-866-X", tostring(new))
    end
end

function testcase:test_illegal_isbn ()
    is_bad_uri("invalid characters", "urn:ISBN:abc")
    if have_isbn_module then
        is_bad_uri("bad checksum", "urn:isbn:0395363412")
        is_bad_uri("wrong length", "urn:isbn:03953634101")
    end
end

lunit.run()
-- vi:ts=4 sw=4 expandtab
