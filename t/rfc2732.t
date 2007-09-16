require "uri-test"
local URI = require "URI"
local testcase = TestCase("Test URLs containing IPv6 addresses")

function testcase:test_with_http_urls ()
    local uri = URI:new("http://[FEDC:BA98:7654:3210:FEDC:BA98:7654:3210]:80/index.html")

    is("http://[FEDC:BA98:7654:3210:FEDC:BA98:7654:3210]:80/index.html", uri:as_string())
    is("[FEDC:BA98:7654:3210:FEDC:BA98:7654:3210]", uri:host())
    is("[FEDC:BA98:7654:3210:FEDC:BA98:7654:3210]:80", uri:host_port())
    is(80, uri:_port())
    is(80, uri:port())

    uri:host("host")
    is("http://host:80/index.html", uri:as_string())
end

function testcase:test_with_ftp_urls ()
    local uri = URI:new("ftp://ftp:@[3ffe:2a00:100:7031::1]")
    is("ftp://ftp:@[3ffe:2a00:100:7031::1]", uri:as_string())
    is(21, uri:port())
    assert_nil(uri:_port())
    is("[3ffe:2a00:100:7031::1]", uri:host("ftp"))
    is("ftp://ftp:@ftp", tostring(uri))
end

-- TODO, stuff left over from the Perl 'END' section, maybe intended for
--   these to be turned into more tests:
-- http://[FEDC:BA98:7654:3210:FEDC:BA98:7654:3210]:80/index.html
-- http://[1080:0:0:0:8:800:200C:417A]/index.html
-- http://[3ffe:2a00:100:7031::1]
-- http://[1080::8:800:200C:417A]/foo
-- http://[::192.9.5.5]/ipng
-- http://[::FFFF:129.144.52.38]:80/index.html
-- http://[2010:836B:4179::836B:4179]

lunit.run()
-- vim:ts=4 sw=4 expandtab filetype=lua
