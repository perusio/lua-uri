local _G = _G
module("URI.ftp", package.seeall)
URI._subclass_of(_M, "URI._server")

_G.require "URI._userpass"

function default_port () return 21 end

function path (self, ...) return self:path_query(...) end  -- XXX

function _user     (...) return _G.URI._userpass.user(...)     end
function _password (...) return _G.URI._userpass.password(...) end

-- TODO - possible bug in Perl version: does substituing 'anonymous' for a
-- missing user make this non-idempotent?  What if we pass it it's own return
-- value, will that change the canonical URL string?
function user (self, ...) return self:_user(...) or "anonymous" end

function password (self, ...)
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

-- vi:ts=4 sw=4 expandtab
