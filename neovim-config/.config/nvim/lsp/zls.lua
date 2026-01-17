return {
        cmd = { "zls" },
        filetypes = {
                "zig",
                "zir",
        },
        root_markers = {
                "build.zig",
                "build.zig.zon",
        },
        settings = {
                zls = {
                        highlight_global_var_declarations = true,
                        inlay_hints_hide_redundant_param_names = true,
                },
        },
}
