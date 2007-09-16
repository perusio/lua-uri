require "uri-test"
local URI = require "URI"
local testcase = TestCase("Test URI.sip")

function testcase:test_sip ()
    local u = URI:new("sip:phone@domain.ext")
    is("phone", u:user())
    is("domain.ext", u:host())
    is(5060, u:port())
    is("sip:phone@domain.ext", tostring(u))

    u:host_port("otherdomain.int:9999")
    is("sip:phone@otherdomain.int:9999", tostring(u))
    is("otherdomain.int", u:host())
    is(9999, u:port())

    u:port(5060)
    u = u:canonical()
    is("otherdomain.int", u:host())
    is(5060, u:port())
    is("sip:phone@otherdomain.int", tostring(u))

    u:user("voicemail")
    is("voicemail", u:user())
    is("sip:voicemail@otherdomain.int", tostring(u))
end

function testcase:test_sip_query_form ()
    local u = URI:new("sip:phone@domain.ext?Subject=Meeting&Priority=Urgent")
    is("domain.ext", u:host())
    is("Subject=Meeting&Priority=Urgent", u:query())

    u:query_form({ Subject = "Lunch", Priority = "Low" })
    local aq = u:query_form()
    is("domain.ext", u:host())
    is("Subject=Lunch&Priority=Low", u:query())
    assert_hash_shallow_equal({ Subject = "Lunch", Priority = "Low" }, aq)
end

function testcase:test_sip_params ()
    local u = URI:new("sip:phone@domain.ext;maddr=127.0.0.1;ttl=16")
    is("domain.ext", u:host())
    is("maddr=127.0.0.1;ttl=16", u:params())
end

function testcase:test_sip_params_form ()
    local u = URI:new("sip:phone@domain.ext?Subject=Meeting&Priority=Urgent")
    u:params_form({ maddr = "127.0.0.1", ttl = "16" })
    local ap = u:params_form()
    is("domain.ext", u:host())
    is("Subject=Meeting&Priority=Urgent", u:query())
    is("maddr=127.0.0.1;ttl=16", u:params())
    assert_hash_shallow_equal({ maddr = "127.0.0.1", ttl = "16" }, ap)
end

function testcase:test_sip_new_abs ()
    local u = URI:new_abs("sip:phone@domain.ext", "sip:foo@domain2.ext")
    is("sip:phone@domain.ext", tostring(u))
end

function testcase:test_sip_abs_rel ()
    local u = URI:new("sip:phone@domain.ext")
    is(u, u:abs("http://www.cpan.org/"))
    is(u, u:rel("http://www.cpan.org/"))
end

lunit.run()
-- vi:ts=4 sw=4 expandtab
