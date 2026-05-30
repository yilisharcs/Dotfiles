if vim.g.shell_editor then
        return
end

vim.cmd.packadd("quarrel.nvim")

---@type quarrel.Opts
vim.g.quarrel = {
        notify = true,
}
