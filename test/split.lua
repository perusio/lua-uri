require "uri-test"
local URISplit = require "URI.Split"
local testcase = TestCase("Test functions in URI.Split module")

local uri_split = URISplit.uri_split
local uri_join = URISplit.uri_join

local function str (v) return v or "<nil>" end
local function j (a, b, c, d, e, f)
    if f then error"uri_split() returned more than five values" end
    local t = { str(a), str(b), str(c), str(d), str(e) }
    return table.concat(t, "-")
end

function testcase:test_uri_split ()
    is("<nil>-<nil>-p-<nil>-<nil>", j(uri_split("p")))
    is("<nil>-<nil>-p-q-<nil>", j(uri_split("p?q")))
    is("<nil>-<nil>-p-<nil>-f", j(uri_split("p#f")))
    is("<nil>-<nil>-p-q/-f/?", j(uri_split("p?q/#f/?")))
    is("s-a-/p-q-f", j(uri_split("s://a/p?q#f")))
end

function testcase:test_uri_join ()
    is("s://a/p?q#f", uri_join("s", "a", "/p", "q", "f"))
    is("s://a/p?q#f", uri_join("s", "a", "p", "q", "f"))
    is("", uri_join(nil, nil, "", nil, nil))
    is("p", uri_join(nil, nil, "p", nil, nil))
    is("s:p", uri_join("s", nil, "p"))
    is("s:", uri_join("s"))
    is("", uri_join())
    is("s://a", uri_join("s", "a"))
    is("s://a%2Fb", uri_join("s", "a/b"))
    is("s://:%2F%3F%23/:/%3F%23?:/?%23#:/?#",
       uri_join("s", ":/?#", ":/?#", ":/?#", ":/?#"))
    is("a%3Ab", uri_join(nil, nil, "a:b"))
    is("s:////foo//bar", uri_join("s", nil, "//foo//bar"))
end

lunit.run()
-- vi:ts=4 sw=4 expandtab
