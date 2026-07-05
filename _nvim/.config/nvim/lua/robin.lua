-- robin.lua: the successor to batman.lua

-- filesystem cache for :Man that avoids re-running man(1) on
-- subsequent opens of the same page, even across Neovim sessions

local cache_dir = vim.fn.stdpath("cache") .. "/man"
vim.fn.mkdir(cache_dir, "p")

-- capture `nvim_buf_add_highlight` calls during original
-- `read_page` so they can be replayed on cache hit
local capturing = false
local captured = {}
local orig_hl = vim.api.nvim_buf_add_highlight
---@diagnostic disable-next-line: duplicate-set-field
vim.api.nvim_buf_add_highlight = function(buf, ns, group, row, s, e)
        if capturing and buf == 0 then
                captured[#captured + 1] = { attr = group, row = row, start = s, final = e }
        end
        return orig_hl(buf, ns, group, row, s, e)
end

local function get_key(path)
        local stat = vim.uv.fs_stat(path)
        if not stat then
                return nil
        end
        return vim.fn.sha256(path .. ":" .. tostring(stat.mtime.sec))
end

local function get_page_slow(path, silent, manwidth)
        local cmd = { "man", "-l", path }
        if vim.fn.executable(cmd[1]) == 0 then
                error(string.format('executable not found: "%s"', cmd[1]), 0)
        end

        local r = vim.system(cmd, {
                env = {
                        MANPAGER = "cat",
                        MANWIDTH = tostring(manwidth),
                        MAN_KEEP_FORMATTING = "1",
                },
                -- longer timeout version of man.lua's get_page. 10 seconds
                -- is too short for large manpages like configuration.nix(5)
                timeout = 30000,
        }):wait()

        if not silent then
                if r.code ~= 0 then
                        local cmd_str = table.concat(cmd, " ")
                        error(string.format("command error '%s': %s", cmd_str, r.stderr))
                end
                assert(r.stdout ~= "")
        end

        return assert(r.stdout)
end

local function cache_load(key)
        local f = io.open(cache_dir .. "/" .. key, "rb")
        if not f then
                return nil
        end
        local content = f:read("*a")
        f:close()
        local ok, cached = pcall(vim.json.decode, content)
        return ok and cached or nil
end

local function cache_save(key, data)
        local f = io.open(cache_dir .. "/" .. key, "wb")
        if not f then
                return
        end
        f:write(vim.json.encode(data))
        f:close()
end

local function upvalue(fn, name)
        local i = 1
        while true do
                local n, v = debug.getupvalue(fn, i)
                if not n then
                        return nil, nil
                end
                if n == name then
                        return v, i
                end
                i = i + 1
        end
end

-- monkey-patch `man.read_page`
local man = require("man")
local original = man.read_page
local gp, gp_idx = upvalue(original, "get_page")
local pf = upvalue(original, "parse_ref")
local pp = upvalue(original, "parse_path")
local gw = upvalue(original, "get_manwidth")
local so = upvalue(original, "set_options")

if not (gp and gp_idx and pf and pp and gw and so) then
        return
end

---@diagnostic disable-next-line: duplicate-set-field
man.read_page = function(ref)
        local name, sect = pf(ref)
        if not name then
                return original(ref)
        end

        local path = man._find_path(name, sect)
        if not path then
                return "no manual entry for " .. name
        end

        local _, sect1 = pp(path)
        local key = get_key(path)

        if key then
                local cached = cache_load(key)
                if cached then
                        vim.b.manwidth = gw()
                        vim.b.man_sect = sect1
                        vim.bo.modifiable = true
                        vim.bo.readonly = false
                        vim.api.nvim_buf_set_lines(0, 0, -1, false, cached.lines)
                        for _, hl in ipairs(cached.hls) do
                                orig_hl(0, -1, hl.attr, hl.row, hl.start, hl.final)
                        end
                        so()
                        return
                end
        end

        -- cache miss: swap get_page for longer timeout, run original, capture
        debug.setupvalue(original, gp_idx, get_page_slow)
        capturing = true
        captured = {}
        original(ref)
        local hls = captured
        capturing = false

        if key then
                cache_save(key, {
                        lines = vim.api.nvim_buf_get_lines(0, 0, -1, false),
                        hls = hls,
                })
        end
end
