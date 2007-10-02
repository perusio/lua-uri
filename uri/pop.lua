-- RFC 2384
local M = { _NAME = "uri.pop" }
local URI = require "uri"
URI._subclass_of(M, "uri._server")

local Util = require "uri._util"

function M.default_port () return 110 end

--pop://<user>;auth=<auth>@<host>:<port>

function M.user (self, ...)
    local old = self:userinfo()

    if select('#', ...) > 0 then
        local new_info = old or ""
        new_info = new_info:gsub("^[^;]*", "", 1)

        local new = ...
        if not new and new_info == "" then
            self:userinfo(nil)
        else
            if not new then new = "" end
            new = new:gsub("%%", "%%25")
                     :gsub(";", "%%3B")
            self:userinfo(new .. new_info)
        end
    end

    if old then
        old = old:gsub(";.*", "", 1)
        return Util.uri_unescape(old)
    end
end

function M.auth (self, ...)
    local old = self:userinfo()

    if select('#', ...) > 0 then
        local new = old or ""
        local _, user_end, user = new:find("^([^;]*)")
        new = new:sub(user_end + 1)
        new = new:gsub(";[aA][uU][tT][hH]=[^;]*", "", 1)

        local auth = ...
        if auth then
            auth = auth:gsub("%%", "%%25")
                       :gsub(";", "%%3B")
            new = ";AUTH=" .. auth .. new
        end
        self:userinfo(user .. new)
    end

    if old then
        old = old:gsub("^[^;]*", "", 1)
        local _, _, oldauth = old:find(";[aA][uU][tT][hH]=(.*)")
        if oldauth then return Util.uri_unescape(oldauth) end
    end
end

return M
-- vi:ts=4 sw=4 expandtab
