vim.g.loaded_man = 1
vim.go.keywordprg = ":Batman"

vim.api.nvim_create_user_command("Batman", function(params)
        local manpage = "man"
        if #params.fargs > 0 then
                local args = vim.iter(params.fargs):map(vim.fn.shellescape):join(" ")
                manpage = ("%s %s"):format(manpage, args)
        else
                local word = vim.fn.expand("<cword>")
                if word == "" then
                        vim.notify("batman.lua: no identifier under cursor", vim.log.levels.ERROR)
                        return
                end
                manpage = ("%s %s"):format(manpage, vim.fn.shellescape(word))
        end

        local mods = params.smods
        local has_split_mod = mods.split ~= ""
                or mods.tab ~= -1
                or mods.vertical
                or mods.horizontal
                or mods.topleft
                or mods.botright

        if not has_split_mod then
                vim.cmd.split()
        end

        vim.cmd({
                cmd = "terminal",
                args = { manpage },
                mods = mods,
        })
        vim.cmd("startinsert")
end, {
        bar = true,
        nargs = "*",
        complete = function(...)
                return require("man").man_complete(...)
        end,
})

local group = vim.api.nvim_create_augroup("Batman", { clear = true })
vim.api.nvim_create_autocmd({ "TermClose" }, {
        desc = "Close man terminal buffers as if {cmd} wasn't supplied to :term",
        group = group,
        pattern = "*:man *",
        callback = function(args)
                if vim.v.event.status == 0 then
                        vim.cmd("silent! bwipeout! " .. args.buf)
                end
        end,
})
