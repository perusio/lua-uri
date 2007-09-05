-- draft-gilman-news-url-01
local _G = _G
module("URI.news", package.seeall)
URI._subclass_of(_M, "URI._server")

function default_port () return 119 end

--   newsURL      =  scheme ":" [ news-server ] [ refbygroup | message ]
--   scheme       =  "news" | "snews" | "nntp"
--   news-server  =  "//" server "/"
--   refbygroup   = group [ "/" messageno [ "-" messageno ] ]
--   message      = local-part "@" domain

function _group (self, group, from, to)
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
            return _G.URI.Escape.uri_unescape(oldgroup),
                   _G.tonumber(oldfrom), _G.tonumber(oldto)
        end
    end
    return _G.URI.Escape.uri_unescape(old)
end


function group (self, group, from, to)
    if group and group:find("@") then
        error"Group name can't contain '@'"
    end
    local oldgroup, oldfrom, oldto = self:_group(group, from, to)
    if not oldgroup:find("@") then return oldgroup, oldfrom, oldto end
end

function message (self, message)
    if message and not message:find("@") then
        error"Message must contain '@'"
    end
    local old = self:_group(message)
    return old:find("@") and old or nil
end

-- vi:ts=4 sw=4 expandtab
