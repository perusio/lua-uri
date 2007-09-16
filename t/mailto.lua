require "uri-test"
local URI = require "URI"
local testcase = TestCase("Test URI.mailto")

function testcase:test_mailto ()
    local u = URI:new("mailto:gisle@aas.no")

    is("gisle@aas.no", u:to())
    is("mailto:gisle@aas.no", tostring(u))

    local old = u:to("larry@wall.org")
    is("gisle@aas.no", old)
    is("larry@wall.org", u:to())
    is("mailto:larry@wall.org", tostring(u))

    u:to("?/#")
    is("?/#", u:to())
    is("mailto:%3F/%23", tostring(u))

    local ah = u:headers()
    assert_hash_shallow_equal({ to = "?/#" }, ah)

    u:headers({
        to      = "gisle@aas.no",
        cc      = "gisle@ActiveState.com,larry@wall.org",
        Subject = "How do you do?",
        garbage = "/;?#=&",
    })

    ah = u:headers()
    is("gisle@aas.no", u:to())
    assert_hash_shallow_equal({
        to      = "gisle@aas.no",
        cc      = "gisle@ActiveState.com,larry@wall.org",
        Subject = "How do you do?",
        garbage = "/;?#=&",
    }, ah)

    -- TODO - this test relies on known the hash order which will will be
    -- used to serialize the headers.  Maybe I should sort them or something
    -- to make the result more stable.
    is("mailto:gisle@aas.no?garbage=%2F%3B%3F%23%3D%26&Subject=How+do+you+do%3F&cc=gisle%40ActiveState.com%2Clarry%40wall.org", tostring(u))
end

function testcase:test_mailto_no_address ()
    local u = URI:new("mailto:")
    is("mailto:", tostring(u))
    u:to("gisle")
    is("mailto:gisle", tostring(u))
end

lunit.run()
-- vi:ts=4 sw=4 expandtab
