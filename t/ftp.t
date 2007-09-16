require "uri-test"
local URI = require "URI"
local testcase = TestCase("Test URI.ftp")

function testcase:test_ftp ()
    local uri = URI:new("ftp://ftp.example.com/path")

    is("ftp", uri:scheme())
    is("ftp.example.com", uri:host())
    is(21, uri:port())
    is("anonymous", uri:user())
    is("anonymous@", uri:password())

    uri:userinfo("gisle@aas.no")
    is("ftp://gisle%40aas.no@ftp.example.com/path", tostring(uri))
    is("gisle@aas.no", uri:user())
    assert_nil(uri:password())

    uri:password("secret")
    is("ftp://gisle%40aas.no:secret@ftp.example.com/path", tostring(uri))

    uri = URI:new("ftp://gisle@aas.no:secret@ftp.example.com/path")
    is("ftp://gisle@aas.no:secret@ftp.example.com/path", tostring(uri))
    is("gisle@aas.no:secret", uri:userinfo())
    is("gisle@aas.no", uri:user())
    is("secret", uri:password())
end

lunit.run()
-- vim:ts=4 sw=4 expandtab filetype=lua
