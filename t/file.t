require "uri-test"
local URI = require "URI"
local URIFile = require "URI.file"
local testcase = TestCase("Test URI.file")

local tests = {
    { "file",          "unix",       "win32",         "mac" },
    -----------------  ------------  ---------------  --------------
    { "file://localhost/foo/bar",
                       "!/foo/bar",  "!\\foo\\bar",   "!foo:bar" },
    { "file:///foo/bar",
                       "/foo/bar",   "\\foo\\bar",    "!foo:bar" },
    { "file:/foo/bar", "!/foo/bar",  "!\\foo\\bar",   "foo:bar" },
    { "foo/bar",       "foo/bar",    "foo\\bar",      ":foo:bar" },
    { "file://foo/bar","!//foo/bar", "!\\\\foo\\bar", "!foo:bar" },
    { "file://a:/",    "!//a:/",     "!A:\\",         nil },
    { "file:///A:/",   "/A:/",       "A:\\",          nil },
    { "file:///",      "/",          "\\",            nil },
    { ".",             ".",          ".",             ":" },
    { "..",            "..",         "..",            "::" },
    { "%2E",           "!.",         "!.",            ":." },
    { "../%2E%2E",     "!../..",     "!..\\..",       "::.." },
}

function testcase:test_file ()
    local os_list = table.remove(tests, 1)
    table.remove(os_list, 1)    -- file

    for _, t in ipairs(tests) do
        local file = table.remove(t, 1)
        local err = 0

        local u = URI:new(file, "file")
        for i, os in ipairs(os_list) do
            local f = u:file(os)
            local expect = t[i]
            if not f then f = "<nil>" end
            if not expect then expect = "<nil>" end
            local loose
            expect, loose = expect:gsub("^!", "", 1)
            loose = loose > 0
            if expect ~= f then
                print("URI:new('" .. file .. "', 'file'):file('" .. os ..
                      "') ~= " .. expect .. ", got " .. f)
                err = err + 1
            end
            if t[i] and not loose then
                local u2 = URIFile:new(t[i], os)
                if u2:as_string() ~= file then
                    print("URI::file->new('" .. t[i] .. "', '" .. os ..
                          "') ne " .. file .. ", got " .. tostring(u2))
                    err = err + 1
                end
            end
        end
        is(0, err)
    end
end

lunit.run()
-- vim:ts=4 sw=4 expandtab filetype=lua
