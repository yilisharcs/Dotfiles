return {
  "echasnovski/mini.hipatterns", -- see `:h MiniHipatterns.config`.
  version = false,
  event = "BufReadPost [^:]*",
  config = function()
    require("mini.hipatterns").setup({
      highlighters = {
        fixme = { pattern = "%f[%w]()FIXME()%f[%W]", group = "MiniHipatternsFixme" },
        hack = { pattern = "%f[%w]()HACK()%f[%W]", group = "MiniHipatternsHack" },
        todo = { pattern = "%f[%w]()TODO()%f[%W]", group = "MiniHipatternsTodo" },
        todo_rust_macro = { pattern = "todo!%(%)", group = "MiniHipatternsFixme" },
        note = { pattern = "%f[%w]()NOTE()%f[%W]", group = "MiniHipatternsNote" },
        hex_color = require("mini.hipatterns").gen_highlighter.hex_color(),
      },
    })
  end
}
