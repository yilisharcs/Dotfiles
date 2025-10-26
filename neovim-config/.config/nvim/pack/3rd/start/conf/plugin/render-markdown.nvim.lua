if not os.getenv("DISPLAY") then return end

vim.pack.add({
        "https://github.com/MeanderingProgrammer/render-markdown.nvim",
}, { load = true })

require("render-markdown").setup({
        render_modes = true,
        anti_conceal = {
                enabled = true,
                above = 1,
                below = 1,
        },
        pipe_table = { preset = "round" },
        html = { comment = { conceal = false } },
        sign = { enabled = false },
        code = { border = "thin" },
})

vim.keymap.set("n", "<leader>y", "<CMD>RenderMarkdown toggle<CR>", { desc = "Toggle markdown rendering" })
