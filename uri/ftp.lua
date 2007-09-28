local M = { _NAME = "uri.ftp" }
local URI = require "uri"
URI._subclass_of(M, "uri._server")

local UserPass = require "uri._userpass"

function M.default_port () return 21 end

function M.path (self, ...) return self:path_query(...) end  -- XXX

function M._user     (...) return UserPass.user(...)     end
function M._password (...) return UserPass.password(...) end

-- TODO - possible bug in Perl version: does substituing 'anonymous' for a
-- missing user make this non-idempotent?  What if we pass it it's own return
-- value, will that change the canonical URL string?
function M.user (self, ...) return self:_user(...) or "anonymous" end

function M.password (self, ...)
    local pass = self:_password(...)
    if not pass then
        local user = self:user()
        if user == "anonymous" or user == "ftp" then
            -- anonymous ftp login password
            -- If there is no ftp anonymous password specified
            -- then we'll just use 'anonymous@'
            -- We don't try to send the read e-mail address because:
            -- - We want to remain anonymous
            -- - We want to stop SPAM
            -- - We don't want to let ftp sites to discriminate by the user,
            --   host, country or ftp client being used.
            pass = "anonymous@"
        end
    end
    return pass
end

return M
-- vi:ts=4 sw=4 expandtab
