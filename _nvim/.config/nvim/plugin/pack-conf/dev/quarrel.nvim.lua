if vim.g.shell_editor then
        return
end

---@type quarrel.Opts
vim.g.quarrel = {
        use_vcs = true,
        notify = true,
        blacklist = {
                "/home/yilisharcs/.local/state/nvim/quarrel",
        },
}

vim.cmd.packadd("quarrel.nvim")
