if vim.g.shell_editor then
    return
end

require("mini.bufremove").setup()
_G.MiniBufremove = MiniBufremove

vim.keymap.set("n", "<M-q>", function()
    if vim.bo.filetype == "help" then
        vim.cmd.bdelete()
    elseif vim.bo.filetype == "man" then
        vim.cmd.quit()
    else
        MiniBufremove.delete()
    end
end, { desc = "Delete buffer" })
