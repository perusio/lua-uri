require "uri-test"
local URI = require "uri"
local testcase = TestCase("Test uri._ldap and its subclasses")

function testcase:test_ldap_1 ()
    local uri = URI:new("ldap://host/dn=base?cn,sn?sub?objectClass=*")

    is("host", uri:host())
    is("dn=base", uri:dn())
    assert_array_shallow_equal({"cn","sn"}, uri:attributes())
    is("objectClass=*", uri:filter())
    is("sub", uri:scope())
end

function testcase:test_ldap_2 ()
    local uri = URI:new("ldap:")

    uri:dn("o=University of Michigan,c=US")
    is("ldap:o=University%20of%20Michigan,c=US", tostring(uri))
    is("o=University of Michigan,c=US", uri:dn())

    uri:host("ldap.itd.umich.edu")
    is("ldap://ldap.itd.umich.edu/o=University%20of%20Michigan,c=US",
        tostring(uri))

    -- check defaults
    is("", uri:TODO_scope())
    is("base", uri:scope())
    is("", uri:TODO_filter())
    is("(objectClass=*)", uri:filter())

    -- attribute
    uri:attributes({"postalAddress"})
    is("ldap://ldap.itd.umich.edu/o=University%20of%20Michigan,c=US?postalAddress",
       tostring(uri))
    assert_array_shallow_equal({"postalAddress"}, uri:attributes())

    -- does attribute escapeing work as it should
    uri:attributes({"postalAddress", "foo", ",", "*", "?", "#", "\0"})
    is("postalAddress,foo,%2C,*,%3F,%23,%00", uri:attributes_encoded())
    assert_array_shallow_equal({"postalAddress","foo",",","*","?","#","\0"},
                               uri:attributes())
    uri:attributes({})

    uri:scope("sub?#")
    is("?sub%3F%23", uri:query())
    is("sub?#", uri:scope())
    uri:scope("")

    uri:filter("f=?,#")
    is("??f=%3F,%23", uri:query())
    is("f=?,#", uri:filter())

    uri:filter("(int=\\00\\00\\00\\04)")
    is("??(int=%5C00%5C00%5C00%5C04)", uri:query())

    uri:filter("")

    uri:extensions({ ["!bindname"] = "cn=Manager,co=Foo" })
    local ext = uri:extensions()
    is("???!bindname=cn=Manager%2Cco=Foo", uri:query())
    assert_hash_shallow_equal({ ["!bindname"] = "cn=Manager,co=Foo" }, ext)
end

function testcase:test_ldap_3 ()
    local uri = URI:new("ldap://LDAP-HOST:389/o=University%20of%20Michigan,c=US?postalAddress?base?ObjectClass=*?FOO=Bar,bindname=CN%3DManager%CO%3dFoo")

    is("/o=University%20of%20Michigan,c=US", uri:path())
    is("postalAddress?base?ObjectClass=*?FOO=Bar,bindname=CN%3DManager%CO%3dFoo", uri:query())
    assert_array_shallow_equal({"postalAddress"}, uri:attributes())
    is("base", uri:scope())
    is("ObjectClass=*", uri:filter())
    assert_hash_shallow_equal({ ["FOO"] = "Bar",
                                ["bindname"] = "CN=Manager%CO=Foo" },
                              uri:extensions())
    is("ldap://ldap-host/o=University%20of%20Michigan,c=US?postaladdress???bindname=CN=Manager%CO=Foo,foo=Bar", tostring(uri:canonical()))
end

function testcase:test_ldaps ()
    local uri = URI:new("ldaps://host/dn=base?cn,sn?sub?objectClass=*")

    is("host", uri:host())
    is(636, uri:port())
    is("dn=base", uri:dn())
end

function testcase:test_ldapi ()
    local uri = URI:new("ldapi://%2Ftmp%2Fldap.sock/????x-mod=-w--w----")
    is("%2Ftmp%2Fldap.sock", uri:authority())
    is("/tmp/ldap.sock", uri:un_path())

    uri:un_path("/var/x\@foo:bar/")
    is("ldapi://%2Fvar%2Fx%40foo%3Abar%2F/????x-mod=-w--w----", tostring(uri))

    local ext = uri:extensions()
    is("-w--w----", ext["x-mod"])
end

lunit.run()
-- vi:ts=4 sw=4 expandtab
