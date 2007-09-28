-- draft-gilman-news-url-01
local M = { _NAME = "uri.news" }
local URI = require "uri"
URI._subclass_of(M, "uri._server")

local Esc = require "uri.Escape"

function M.default_port () return 119 end

--   newsURL      =  scheme ":" [ news-server ] [ refbygroup | message ]
--   scheme       =  "news" | "snews" | "nntp"
--   news-server  =  "//" server "/"
--   refbygroup   = group [ "/" messageno [ "-" messageno ] ]
--   message      = local-part "@" domain

function M._group (self, group, from, to)
    local old = self:path()

    if group then
        if group:find("@") then
            -- "<" and ">" should not be part of it
            group = group:gsub("^<(.*)>$", "%1", 1)
        end
        group = group:gsub("%%", "%%25")
                     :gsub("/", "%%2F")
        local path = group
        if from then
            path = path .. "/" .. from
            if to then path = path .. "-" .. to end
        end
        self:path(path)
    end

    old = old:gsub("^/", "", 1)
    if not old:find("@") and old:find("/") then
        local _, _, oldgroup, extra = old:find("^(.*)/(.*)$")
        local _, _, oldfrom, oldto = extra:find("^(%d+)-(%d+)$")
        if not oldfrom and extra:find("^%d+$") then oldfrom = extra end
        if oldfrom then
            return Esc.uri_unescape(oldgroup),
                   tonumber(oldfrom), tonumber(oldto)
        end
    end
    return Esc.uri_unescape(old)
end


function M.group (self, group, from, to)
    if group and group:find("@") then
        error"Group name can't contain '@'"
    end
    local oldgroup, oldfrom, oldto = self:_group(group, from, to)
    if not oldgroup:find("@") then return oldgroup, oldfrom, oldto end
end

function M.message (self, message)
    if message and not message:find("@") then
        error"Message must contain '@'"
    end
    local old = self:_group(message)
    return old:find("@") and old or nil
end

return M
-- vi:ts=4 sw=4 expandtab
