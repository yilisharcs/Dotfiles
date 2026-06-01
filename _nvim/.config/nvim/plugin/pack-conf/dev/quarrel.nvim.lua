if vim.g.shell_editor then
        return
end

---@type quarrel.Opts
vim.g.quarrel = {
        notify = true,
}

vim.cmd.packadd("quarrel.nvim")
