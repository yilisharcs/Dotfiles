return {
        cmd = {
                "clangd",
        },
        root_markers = {
                ".clangd",
                "compile_commands.json",
        },
        filetypes = {
                "c",
                -- FIXME: Breaks with header files. Investigate.
                -- "cpp",
        },
}
