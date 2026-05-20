vim.filetype.add({
        extension = {
                xxd = "xxd",
                zc = "zc",
        },
        pattern = {
                ["/nix/store/.*%-bash_profile"] = "bash",
                ["/nix/store/.*%-bashrc"] = "bash",
                ["/nix/store/.*%-profile"] = "bash",
                ["/nix/store/.*.Xresources"] = "xdefaults",
        },
})
