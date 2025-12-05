if vim.g.neovide then
        vim.api.nvim_create_autocmd({ "UIEnter" }, {
                desc = "Set default cwd to Dotfiles if opened with no file arguments",
                group = vim.api.nvim_create_augroup("Neovide_Default_Dir", { clear = true }),
                callback = function()
                        if string.match(vim.v.argv[#vim.v.argv], "^%-+") ~= nil then
                                vim.cmd.cd("~/Dotfiles")
                                if vim.g.loaded_quarrel == 1 then require("quarrel").argread() end
                        end
                end,
        })

        vim.g.neovide_padding_top = 0
        vim.g.neovide_padding_left = 2
        vim.g.neovide_hide_mouse_when_typing = true
        vim.g.neovide_confirm_quit = true
        vim.g.neovide_detach_on_quit = "always_detach"
        vim.g.neovide_cursor_smooth_blink = true
        vim.g.neovide_cursor_animate_in_insert_mode = true
        vim.g.neovide_cursor_animate_command_line = true
        vim.o.winblend = 1
        vim.g.neovide_floating_shadow = false

        vim.g.neovide_scale_factor = 1.0
        vim.keymap.set(
                { "n", "t" },
                "<C-->",
                "<CMD>let g:neovide_scale_factor-=0.1<CR>",
                { desc = "Reduce font size" }
        )
        vim.keymap.set(
                { "n", "t" },
                "<C-=>",
                "<CMD>let g:neovide_scale_factor+=0.1<CR>",
                { desc = "Increase font size" }
        )
        vim.keymap.set(
                { "n", "t" },
                "<C-0>",
                "<CMD>let g:neovide_scale_factor=1.0<CR>",
                { desc = "Restore default font size" }
        )

        vim.g.neovide_fullscreen = false
        vim.go.linespace = 0
        function Neovide_F11()
                if vim.g.neovide_fullscreen == false then
                        vim.g.neovide_fullscreen = true
                else
                        vim.g.neovide_fullscreen = false
                end
        end

        vim.keymap.set(
                { "n", "x", "i", "c", "t" },
                "<F11>",
                "<CMD>lua Neovide_F11()<CR>",
                { desc = "Toggle fullscreen" }
        )

        vim.keymap.set({ "n", "t" }, "<C-S-n>", "<CMD>tabnext<CR>", { desc = "Go to next tab" })
        vim.keymap.set({ "n", "t" }, "<C-S-p>", "<CMD>tabprev<CR>", { desc = "Go to prev tab" })
end
