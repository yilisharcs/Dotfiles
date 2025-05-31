return {
  "chomosuke/typst-preview.nvim",
  ft = "typst",
  opts = {
    port = 8080,
    dependencies_bin = {
      ["tinymist"] = "tinymist",
      ["websocat"] = "websocat",
    },
  },
}
