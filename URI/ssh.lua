module("URI.ssh", package.seeall)
URI._subclass_of(_M, "URI._login")

-- ssh://[USER@]HOST[:PORT]/SRC

function default_port () return 22 end

-- vi:ts=4 sw=4 expandtab
