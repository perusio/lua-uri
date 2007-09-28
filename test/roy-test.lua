require "uri-test"
local URI = require "URI"
local testcase = TestCase("Test uri:abs() method with data in test/roytest*.html")

local no = 1
local function test_html_file (filename)
    local file = assert(io.open("test/data/" .. filename, "rb"))
    local base
    local line_num = 1

    for s in file:lines() do
        local _, _, base_href = s:find('^<BASE href="([^"]+)">')
        local _, _, href, exp = s:find('^<a href="([^"]*)">.*</a>%s*=%s*(%S+)')
        if base_href then
            base = URI:new(base_href)
        elseif href then
            if not base then error("Missing base at line " .. line_num) end
            if exp:find("current") then exp = base end  -- special case test 22

            -- rfc2396bis restores the rfc1808 behaviour
            if no == 7 or no == 48 then
                exp = "http://a/b/c/d;p?y"
            end

            local abs  = URI:new(href):abs(base)
            no = no + 1
            if tostring(abs) ~= tostring(exp) then
                assert_fail(filename .. ":" .. line_num ..
                            ": expected: " .. exp ..
                            "\nabs(" .. href .. ", " .. tostring(base) ..
                            " ==> " .. tostring(abs))
            end
        end

        line_num = line_num + 1
    end

    file:close()
end

function testcase:test_roytest_abs_1 () test_html_file("roytest1.html") end
function testcase:test_roytest_abs_2 () test_html_file("roytest2.html") end
function testcase:test_roytest_abs_3 () test_html_file("roytest3.html") end
function testcase:test_roytest_abs_4 () test_html_file("roytest4.html") end
function testcase:test_roytest_abs_5 () test_html_file("roytest5.html") end

lunit.run()
-- vi:ts=4 sw=4 expandtab
