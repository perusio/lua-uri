module("URI.http", package.seeall)
URI._subclass_of(_M, "URI._server")

function default_port () return 80 end

function canonical (self)
    local other = _SUPER.canonical(self)

    local slash_path = other:authority() and other:path() == "" and
                       not other:query()
    if slash_path then
        if other == self then other = other:clone() end
        other:path("/")
    end

    return other
end

-- vi:ts=4 sw=4 expandtab
