return {
        "lambdalisue/suda.vim",
        init = function()
                require("utils.cabbrev")({
                        ["SudaRead"] = { "sudor" },
                        ["SudaWrite"] = { "sudow" },
                })
        end,
}
