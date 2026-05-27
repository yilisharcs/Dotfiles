-- -- https://github.com/folke/snacks.nvim/blob/ad9ede6a9cddf16cedbd31b8932d6dcdee9b716e/lua/snacks/quickfile.lua

-- Skip if we already entered vim
if vim.v.vim_did_enter == 1 then
        return
end
if vim.bo.filetype == "bigfile" then
        return
end

local buf = vim.api.nvim_get_current_buf()

-- Try to guess the filetype (may change later on during Neovim startup)
local ft = vim.filetype.match({ buf = buf })
if ft then
        -- Add treesitter highlights and fallback to syntax
        local lang = vim.treesitter.language.get_lang(ft)

        -- disable treesitter for some langs
        if vim.tbl_contains({
                "latex",
        }, lang) then
                lang = nil
        end

        if not (lang and pcall(vim.treesitter.start, buf, lang)) then
                vim.bo[buf].syntax = ft
        end

        -- Trigger early redraw
        vim.cmd([[redraw]])
end
