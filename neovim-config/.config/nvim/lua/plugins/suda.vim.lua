return {
        "lambdalisue/suda.vim",
        init = function()
                require("utils.cabbrev")({
                        ["SudaWrite"] = { "sudo" },
                })
        end,
}
