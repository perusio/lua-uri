local _G = _G
module("URI.file.FAT", package.seeall)
URI._subclass_of(_M, "URI.file.Win32")

-- Takes an array of path segments and modifies it in-place.  Returns true
-- if it's OK.
function fix_path (class, segs)
    for i, v in _G.pairs(segs) do
        -- turn it into 8.3 names
        local p = _G.URI._split("%.", v)
        for j, w in p do p[i] = w:upper() end
        if #p == 2 then return false end    -- more than 1 dot is not allowed
        if #p == 0 then p[1] = "" end
        v = p[1]:sub(1, 8)
        if #p > 1 then
            local ext = p[1]:sub(1, 3)
            if ext ~= "" then v = v .. "." .. ext end
        end
        segs[i] = v
    end
    return true
end

-- vi:ts=4 sw=4 expandtab
