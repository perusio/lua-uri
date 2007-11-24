-- Test data from RFC 3986.  The 'http' prefix has been changed throughout
-- to 'x-foo' so as not to trigger any scheme-specific normalization.

return {
    -- 5.4.1.  Normal Examples
    ["g:h"]             =  "g:h",
    ["g"]               =  "x-foo://a/b/c/g",
    ["./g"]             =  "x-foo://a/b/c/g",
    ["g/"]              =  "x-foo://a/b/c/g/",
    ["/g"]              =  "x-foo://a/g",
    ["//g"]             =  "x-foo://g",
    ["?y"]              =  "x-foo://a/b/c/d;p?y",
    ["g?y"]             =  "x-foo://a/b/c/g?y",
    ["#s"]              =  "x-foo://a/b/c/d;p?q#s",
    ["g#s"]             =  "x-foo://a/b/c/g#s",
    ["g?y#s"]           =  "x-foo://a/b/c/g?y#s",
    [";x"]              =  "x-foo://a/b/c/;x",
    ["g;x"]             =  "x-foo://a/b/c/g;x",
    ["g;x?y#s"]         =  "x-foo://a/b/c/g;x?y#s",
    [""]                =  "x-foo://a/b/c/d;p?q",
    ["."]               =  "x-foo://a/b/c/",
    ["./"]              =  "x-foo://a/b/c/",
    [".."]              =  "x-foo://a/b/",
    ["../"]             =  "x-foo://a/b/",
    ["../g"]            =  "x-foo://a/b/g",
    ["../.."]           =  "x-foo://a/",
    ["../../"]          =  "x-foo://a/",
    ["../../g"]         =  "x-foo://a/g",

    -- 5.4.2.  Abnormal Examples
    ["../../../g"]      =  "x-foo://a/g",
    ["../../../../g"]   =  "x-foo://a/g",
    ["/./g"]            =  "x-foo://a/g",
    ["/../g"]           =  "x-foo://a/g",
    ["g."]              =  "x-foo://a/b/c/g.",
    [".g"]              =  "x-foo://a/b/c/.g",
    ["g.."]             =  "x-foo://a/b/c/g..",
    ["..g"]             =  "x-foo://a/b/c/..g",
    ["./../g"]          =  "x-foo://a/b/g",
    ["./g/."]           =  "x-foo://a/b/c/g/",
    ["g/./h"]           =  "x-foo://a/b/c/g/h",
    ["g/../h"]          =  "x-foo://a/b/c/h",
    ["g;x=1/./y"]       =  "x-foo://a/b/c/g;x=1/y",
    ["g;x=1/../y"]      =  "x-foo://a/b/c/y",
    ["g?y/./x"]         =  "x-foo://a/b/c/g?y/./x",
    ["g?y/../x"]        =  "x-foo://a/b/c/g?y/../x",
    ["g#s/./x"]         =  "x-foo://a/b/c/g#s/./x",
    ["g#s/../x"]        =  "x-foo://a/b/c/g#s/../x",
    ["x-foo:g"]         =  "x-foo:g",

    -- Some extra tests for good measure
    [""]                = "x-foo://a/b/c/d;p?q",
    ["#foo?"]           = "x-foo://a/b/c/d;p?q#foo?",
    ["?#foo"]           = "x-foo://a/b/c/d;p?#foo",
}

-- vi:ts=4 sw=4 expandtab
