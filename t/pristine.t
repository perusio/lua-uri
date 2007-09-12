require "lunit"
local testcase = lunit.TestCase("Test library loading doesn't affect globals")

function testcase:test_no_global_clobbering ()
    local globals = {}
    for key in pairs(_G) do globals[key] = true end

    -- Load all the modules for the different types of URIs, in case any one
    -- of those treads on a global.  I keep them around in a table to make
    -- sure they're all loaded at the same time, just in case that does
    -- anything interesting.
    local schemes = {
        "Escape", "Split", "_foreign", "_generic", "_ldap",
        "_login", "_query", "_segment", "_server", "_userpass", "data",
        "file", "file.Base", "file.FAT", "file.Mac", "file.OS2", "file.QNX",
        "file.Win32", "ftp", "gopher", "http", "https", "ldap", "ldapi",
        "ldaps", "mailto", "mms", "news", "nntp", "pop", "rlogin", "rtsp",
        "rtspu", "sip", "sips", "snews", "ssh", "telnet", "tn3270", "urn",
        "urn.isbn", "urn.oid"
    }
    local loaded = {}
    local URI = require "URI"
    for _, name in ipairs(schemes) do
        loaded[name] = require("URI." .. name)
    end

    for key in pairs(_G) do
        lunit.assert_not_nil(globals[key],
                             "global '" .. key .. "' created by lib")
    end
    for key in pairs(globals) do
        lunit.assert_not_nil(_G[key],
                             "global '" .. key .. "' destroyed by lib")
    end
end

lunit.run()
-- vim:ts=4 sw=4 expandtab filetype=lua
