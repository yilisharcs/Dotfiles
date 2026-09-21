if vim.g.shell_editor then
    return
end

require("mini.hipatterns").setup({
    highlighters = {
        hex_color = require("mini.hipatterns").gen_highlighter.hex_color(),
        fixme = {
            pattern = "%f[%w]()FIXME()%f[%W]",
            group = "MiniHipatternsFixme",
        },
        hack = {
            pattern = "%f[%w]()HACK()%f[%W]",
            group = "MiniHipatternsHack",
        },
        todo = {
            pattern = "%f[%w]()TODO()%f[%W]",
            group = "MiniHipatternsTodo",
        },
        note = {
            pattern = "%f[%w]()NOTE()%f[%W]",
            group = "MiniHipatternsNote",
        },
        task = {
            pattern = "TASK%(%d+%-%d+%.%w+%)",
            group = "MiniHipatternsTodo",
        },
    },
})
