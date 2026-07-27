vim.cmd.packadd("yazi.nvim")

vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

require("yazi").setup({
        open_for_directories = false,
        open_multiple_tabs = true,
        yazi_floating_window_border = "none",
        floating_window_scaling_factor = {
                height = 0.99,
                width = 1,
        },
        keymaps = {
                open_file_in_vertical_split = "<C-v>",
                open_file_in_horizontal_split = "<C-s>",
                grep_in_directory = "<C-x>",
                replace_in_directory = false,
                cycle_open_buffers = false,
        },
        integrations = {
                grep_in_directory = "fzf-lua",
                grep_in_selected_files = "fzf-lua",
        },
})

vim.keymap.set("n", "-", "<CMD>Yazi<CR>", { desc = "Open yazi at the current file" })
vim.keymap.set("n", "<leader>-", "<CMD>Yazi cwd<CR>", { desc = "Open yazi in the working directory" })
vim.keymap.set("n", "<leader>_", "<CMD>Yazi toggle<CR>", { desc = "Resume the last yazi session" })
