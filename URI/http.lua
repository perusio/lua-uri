local M = { _MODULE_NAME = "URI.http" }
local URI = require "URI"
URI._subclass_of(M, "URI._server")

function M.default_port () return 80 end

function M.canonical (self)
    local other = M._SUPER.canonical(self)

    local slash_path = other:authority() and other:path() == "" and
                       not other:query()
    if slash_path then
        if other == self then other = other:clone() end
        other:path("/")
    end

    return other
end

return M
-- vi:ts=4 sw=4 expandtab
