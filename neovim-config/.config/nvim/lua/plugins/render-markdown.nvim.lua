return {
        "https://github.com/MeanderingProgrammer/render-markdown.nvim",
        -- enabled = false,
        cond = os.getenv("DISPLAY") ~= nil,
        ft = "markdown",
        keys = {
                {
                        "<leader>y",
                        "<CMD>RenderMarkdown toggle<CR>",
                        desc = "Toggle markdown rendering",
                },
        },
        opts = {
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
                link = {
                        custom = {
                                twitter1 = {
                                        pattern = "^x%.com",
                                        icon = " ",
                                },
                                twitter2 = {
                                        pattern = "^https?://x%.com",
                                        icon = " ",
                                },
                        },
                },
        },
}
