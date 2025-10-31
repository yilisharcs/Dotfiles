return {
        "https://github.com/chomosuke/typst-preview.nvim",
        version = "1.*",
        ft = "typst",
        opts = {
                port = 8080,
                dependencies_bin = {
                        ["tinymist"] = "tinymist",
                        ["websocat"] = nil,
                },
        },
}
