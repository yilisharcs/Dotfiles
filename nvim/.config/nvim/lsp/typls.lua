return {
  cmd = { "tinymist" },
  filetypes = { "typst" },
  settings = {
    formatterMode = "typstyle",
    exportPdf = "onType",
    lint = {
      enabled = true,
      when = "onSave",
    }
  }
}
