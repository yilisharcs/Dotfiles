local PREV = 0
local NEXT = 1

local qf_cache = { id = 0, changedtick = 0, map = {}, total = 0 }

local function qf_nav(direction)
        local cmd = direction == PREV and "cprev" or direction == NEXT and "cnext"
        cmd = "silent " .. cmd

        local ok, err = pcall(vim.api.nvim_command, cmd)
        if not ok then
                ---@diagnostic disable-next-line: param-type-mismatch
                vim.api.nvim_echo({ { string.match(err, "E%d+:.*"), "ErrorMsg" } }, false, {})
                return false
        end

        local info = vim.fn.getqflist({ id = 0, changedtick = 0, idx = 0 })
        if info.id ~= qf_cache.id or info.changedtick ~= qf_cache.changedtick then
                local list = vim.fn.getqflist()
                qf_cache.id = info.id
                qf_cache.tick = info.changedtick
                qf_cache.map = {}
                qf_cache.total = 0

                for i, item in ipairs(list) do
                        if item.valid == 1 then qf_cache.total = qf_cache.total + 1 end
                        qf_cache.map[i] = qf_cache.total
                end
        end

        local logical_current = qf_cache.map[info.idx] or 0
        local item = vim.fn.getqflist({ idx = info.idx, items = 1 }).items[1]
        local text = item.text
        local type_map = { E = "error", W = "warning", I = "info", N = "note" }
        local label = type_map[item.type]

        if label then text = label .. ": " .. text end

        local chunks = {}
        if qf_cache.total > 0 then
                table.insert(chunks, {
                        string.format("(%d of %d) ", logical_current, qf_cache.total),
                        "Title",
                })
        end
        table.insert(chunks, { text, "Normal" })

        vim.api.nvim_echo(chunks, false, {})

        return true
end

local function loclist_open()
        return vim.fn.empty(vim.fn.filter(vim.fn.getwininfo(), "v:val.loclist")) == 1 and true
                or false
end

vim.keymap.set("n", "<C-p>", function()
        local center
        if loclist_open() then
                center = qf_nav(PREV)
        else
                local _, err = pcall(vim.cmd.lprev)
                if err == "" then center = true end
        end
        if center then vim.cmd("norm! zz") end
end, { desc = "Previous error" })

vim.keymap.set("n", "<C-n>", function()
        local center
        if loclist_open() then
                center = qf_nav(NEXT)
        else
                local _, err = pcall(vim.cmd.lnext)
                if err == "" then center = true end
        end
        if center then vim.cmd("norm! zz") end
end, { desc = "Next error" })
