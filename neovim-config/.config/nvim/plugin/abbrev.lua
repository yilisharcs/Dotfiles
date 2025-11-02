-- stylua: ignore
require("utils.cabbrev")({
        ["w"] = { "W" },
        ["q"] = { "Q" },
        ["wq"] = { "wQ", "Wq", "WQ" },
        ["wa"] = { "wA", "Wa", "WA" },
        ["qa"] = { "qA", "Qa", "QA" },
        ["bd"] = { "bD", "Bd", "BD" },
        ["wq!"] = {
                "wq!", "wq1", "wQ!", "wQ1",
                "Wq!", "Wq1", "WQ!", "WQ1",
        },
        ["wa!"] = {
                "wa!", "wa1", "wA!", "wA1",
                "Wa!", "Wa1", "WA!", "WA1",
        },
        ["bd!"] = {
                "bd!", "bd1", "bD!", "bD1",
                "Bd!", "Bd1", "BD!", "BD1",
        },
        ["wqa"] = {
                "wqA", "wqa", "wQA", "wQa",
                "WqA", "Wqa", "WQA", "WQa",
        },
        ["wqa!"] = {
                "wqa!", "wqa1", "wqA!", "wqA1",
                "wQa!", "wQa1", "wQA!", "wQA1",
                "Wqa!", "Wqa1", "WqA!", "WqA1",
                "WQa!", "WQa1", "WQA!", "WQA1",
        },
        -- Extras
        ["Cfilter"]     = { "cfilter" },
        ["Cfilter!"]    = { "cfilter1" },
        ["silent grep"] = { "grep" },
        ["Man"]         = { "man" },
        ["make"]        = { "mask" },
        ["!task"]       = { "task" },
})
