require "uri-test"
require "URI"
local testcase = TestCase("Test URI.data")

function testcase:test_data_uri_encoded ()
    local u = URI:new("data:,A%20brief%20note")
    is(",A%20brief%20note", u:opaque())
    is("data", u:scheme())

    is("text/plain;charset=US-ASCII", u:media_type())
    is("A brief note", u:data())

    local old = u:data("F\229r-i-k\229l er tingen!")
    is("A brief note", old)
    is("data:,F%E5r-i-k%E5l%20er%20tingen!", tostring(u))

    old = u:media_type("text/plain;charset=iso-8859-1")
    is("text/plain;charset=US-ASCII", old)
    is("data:text/plain;charset=iso-8859-1,F%E5r-i-k%E5l%20er%20tingen!",
       tostring(u))
end

function testcase:test_data_big_base64_chunk ()
    local imgdata = "R0lGODdhMAAwAPAAAAAAAP///ywAAAAAMAAwAAAC8IyPqcvt3wCcDkiLc7C0qwyGHhSWpjQu5yqmCYsapyuvUUlvONmOZtfzgFzByTB10QgxOR0TqBQejhRNzOfkVJ+5YiUqrXF5Y5lKh/DeuNcP5yLWGsEbtLiOSpa/TPg7JpJHxyendzWTBfX0cxOnKPjgBzi4diinWGdkF8kjdfnycQZXZeYGejmJlZeGl9i2icVqaNVailT6F5iJ90m6mvuTS4OK05M0vDk0Q4XUtwvKOzrcd3iq9uisF81M1OIcR7lEewwcLp7tuNNkM3uNna3F2JQFo97Vriy/Xl4/f1cf5VWzXyym7PHhhx4dbgYKAAA7"
    local u = URI:new("data:image/gif;base64," .. imgdata)

    is("image/gif", u:media_type())

    local gotdata = u:data()
    is(273, gotdata:len())
    local Filter = require "datafilter"
    is(imgdata, Filter.base64_encode(gotdata))
end

function testcase:test_type_with_charset_and_bad_uri_encoding ()
    local u = URI:new("data:text/plain;charset=iso-8859-7,%be%fg%be")
    is("\190%fg\190", u:data())
end

function testcase:test_data_containing_commas ()
    local u = URI:new("data:application/vnd-xxx-query,select_vcount,fcol_from_fieldtable/local")
    is("select_vcount,fcol_from_fieldtable/local", u:data())
    u:data("")
    is("data:application/vnd-xxx-query,", tostring(u))

    u:data("a,b")
    u:media_type(nil)
    is("data:,a,b", tostring(u))
end

function testcase:test_automatic_selection_of_uri_or_base64_encoding ()
    local u = URI:new("data:")
    u:data("")
    is("data:,", tostring(u))

    u:data(">")
    is("data:,%3E", tostring(u))
    is(">", u:data())

    u:data(">>>>>")
    is("data:,%3E%3E%3E%3E%3E", tostring(u))

    u:data(">>>>>>")
    is("data:;base64,Pj4+Pj4+", tostring(u))

    u:media_type("text/plain;foo=bar")
    is("data:text/plain;foo=bar;base64,Pj4+Pj4+", tostring(u))

    u:media_type("foo")
    is("data:foo;base64,Pj4+Pj4+", tostring(u))

    u:data((">"):rep(3000))
    is("data:foo;base64," .. ("Pj4+"):rep(1000), tostring(u))
    is((">"):rep(3000), u:data())

    u:media_type(nil)
    u:data(nil)
    is("data:,", tostring(u))
end

function testcase:test_missing_comma ()
    local u = URI:new("data:foo")
    is("foo", u:media_type("bar,b\229z"))
    is("bar,b\229z", u:media_type())

    local old = u:data("new")
    is("", old)
    is("data:bar%2Cb%E5z,new", tostring(u))
end

if URI._attempt_require("datafilter") then
    lunit.run()
else
    print("Skipped t/data.t: needs the Lua-DataFilter module installed," ..
          " you can get it from here:" ..
          " http://www.daizucms.org/lua/library/datafilter/")
end

-- vim:ts=4 sw=4 expandtab filetype=lua
