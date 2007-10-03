local M = { _NAME = "uri._relative" }
local Util = require "uri._util"
local URI = require "uri"
Util.subclass_of(M, URI)

-- There needs to be an 'init' method in this class, to because the base-class
-- one expects there to be a 'scheme' value.
function M.init (self)
    return self
end

function M.scheme (self, ...)
    if select("#", ...) > 0 then
        error("relative URI references can't have a scheme, perhaps you" ..
              " need to resolve this against an absolute URI instead")
    end
    return nil
end

function M.is_relative () return true end

return M
-- vi:ts=4 sw=4 expandtab
