-- Written by Ryan Kereliuk <ryker@ryker.org>.  This file may be
-- distributed under the same terms as Perl itself.
--
-- The RFC 3261 sip URI is <scheme>:<authority>;<params>?<query>.

local _G = _G
module("URI.sip", package.seeall)
URI._subclass_of(_M, "URI._server")
_M:_mix_in("URI._userpass")

function default_port () return 5060 end

local function _assemble (authority, params, query)
    local uri = authority
    if params and params ~= "" then uri = uri .. ";" .. params end
    if query and query ~= ""   then uri = uri .. "?" .. query end
    return uri
end

local function _disassemble (opaque)
    local semi = opaque:find(";")
    local ques = opaque:find("?")
    local len = opaque:len()
    if semi and ques and semi > ques then semi = nil end
    local authend = semi or ques or len + 1
    local authority = authend == 1 and nil or opaque:sub(1, authend - 1)
    local paramend = ques or len + 1
    local params = authend + 1 >= paramend and nil or
                   opaque:sub(authend + 1, paramend - 1)
    local query = ques and opaque:sub(ques + 1) or nil
    return authority, params, query
end

function authority (self, new)
    local authority, params, query = _disassemble(self:opaque())
    if new then
        new = _G.URI.Escape.uri_escape(new, "^" .. _G.URI.uric)
        self:opaque(_assemble(new, params, query))
    end
    return authority
end

-- TODO - shouldn't this return the _old_ value, not the new one we just set?
function params_form (self, args)
    local authority, params, query = _disassemble(self:opaque())

    if args then
        local new = {}
        for k, v in _G.pairs(args) do
            new[#new + 1] = k .. "=" .. v
        end
        params = _G.table.concat(new, ";")
        self:opaque(_assemble(authority, params, query))
    end

    local paramshash = {}
    for _, pair in _G.ipairs(_G.URI._split(";", params)) do
        local _, _, name, value = pair:find("(.+)=(.*)")
        if not name then error("badly formatted SIP parameter " .. pair) end
        if paramshash[name] then error("duplicate SIP parameter " .. name) end
        paramshash[name] = value
    end
    return paramshash
end

function params (self, new)
    local authority, params, query = _disassemble(self:opaque())
    if new then
        self:opaque(_assemble(authority, new, query))
    end
    return params
end

-- Inherited methods that make no sense for a SIP URI.
function path () end
function path_query () end
function path_segments () end
function abs (self) return self end
function rel (self) return self end
function query_keywords () end

-- vi:ts=4 sw=4 expandtab
