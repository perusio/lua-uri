require "uri-test"
local URI = require "URI"
local testcase = TestCase("Test URI.rtsp and URI.rtspu")

function testcase:test_rtsp ()
    local u = URI:new("<rtsp://media.perl.com/f\244o.smi/>")

    is("rtsp://media.perl.com/f%F4o.smi/", tostring(u))
    is(554, u:port())

    -- play with port
    local old = u:port(8554)
    is(554, old)
    is("rtsp://media.perl.com:8554/f%F4o.smi/", tostring(u))

    u:port(554)
    is("rtsp://media.perl.com:554/f%F4o.smi/", tostring(u))

    u:port("")
    is("rtsp://media.perl.com:/f%F4o.smi/", tostring(u))
    is(554, u:port())

    u:port(nil)
    is("rtsp://media.perl.com/f%F4o.smi/", tostring(u))
    is("media.perl.com", u:host())
    is("/f%F4o.smi/", u:path())

    old = u:scheme("rtspu")
    is("rtsp", old)
    is("rtspu", u:scheme())
end

function testcase:test_rtspu ()
    local u = URI:new("<rtspu://media.perl.com/f\244o.smi/>")
    is("rtspu://media.perl.com/f%F4o.smi/", tostring(u))

    local old = u:scheme("rtsp")
    is("rtspu", old)
    is("rtsp", u:scheme())
end

lunit.run()
-- vi:ts=4 sw=4 expandtab
