require("typst-preview").setup({
    port = 8080,
    dependencies_bin = {
        ["tinymist"] = "tinymist",
        ["websocat"] = "websocat",
    },
})
