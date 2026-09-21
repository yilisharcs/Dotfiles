if vim.g.shell_editor then
    return
end

vim.o.sessionoptions = vim.o.sessionoptions .. ",globals"

require("mini.sessions").setup({
    autoread = false,
    file = "",
    force = {
        read = false,
        write = true,
        delete = true,
    },
    hooks = {
        -- "global variables that start with an uppercase letter and contain at least one lowercase letter"
        pre = {
            write = function()
                vim.g.CmeLastCmd = require("cme").__INTERNAL_H.state.last_cmd
            end,
        },
        post = {
            read = function()
                require("cme").__INTERNAL_H.state.last_cmd = vim.g.CmeLastCmd
            end,
        },
    },
})

-- Save current session (or create one named after the directory)
vim.keymap.set("n", "<leader>ds", function()
    local name = vim.v.this_session ~= "" and vim.fs.basename(vim.v.this_session)
        or (vim.fs.basename(vim.uv.cwd()) .. ".vim")
    require("mini.sessions").write(name)
end, { desc = "Save current session" })
vim.keymap.set("n", "<leader>dl", function()
    require("mini.sessions").select()
end, { desc = "List sessions" })
vim.keymap.set("n", "<leader>dd", function()
    require("mini.sessions").select("delete")
end, { desc = "Delete session" })
vim.keymap.set("n", "<leader>dr", function()
    require("mini.sessions").restart()
end, { desc = "Restart with session" })
