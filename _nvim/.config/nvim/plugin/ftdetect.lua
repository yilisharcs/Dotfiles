vim.filetype.add({
        extension = {
                log = "log",
                xxd = "xxd",
        },
        pattern = {
                ["/nix/store/.*%-bash_profile"] = "bash",
                ["/nix/store/.*%-bashrc"] = "bash",
                ["/nix/store/.*%-profile"] = "bash",
                ["/nix/store/.*.Xresources"] = "xdefaults",
        },
})
