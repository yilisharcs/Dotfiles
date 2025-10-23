vim.pack.add({
        {
                src = "https://github.com/chomosuke/typst-preview.nvim",
                version = vim.version.range("1.*"),
        }
}, { load = true })

require("typst-preview").setup({
        port = 8080,
        dependencies_bin = {
                ["tinymist"] = "tinymist",
                ["websocat"] = nil,
        }
})
