if vim.g.shell_editor then
    return
end

local hi = require("mini.extra").gen_highlighter.words

require("mini.hipatterns").setup({
    highlighters = {
        hex_color = require("mini.hipatterns").gen_highlighter.hex_color(),
        fixme = hi({ "FIXME" }, "MiniHipatternsFixme"),
        hack = hi({ "HACK" }, "MiniHipatternsHack"),
        todo = hi({ "TODO" }, "MiniHipatternsTodo"),
        note = hi({ "NOTE" }, "MiniHipatternsNote"),
        task = {
            pattern = "TASK%(%d+%-%d+%.%w+%)",
            group = "MiniHipatternsTodo",
        },
    },
})
