-- stylua: ignore
require("utils.cabbrev")({
        ["w"] = { "W" },
        ["q"] = { "Q" },
        ["e"] = { "E" },
        ["wq"] = { "wQ", "Wq", "WQ" },
        ["wa"] = { "wA", "Wa", "WA" },
        ["qa"] = { "qA", "Qa", "QA" },
        ["bd"] = { "bD", "Bd", "BD" },
        ["w!"] = { "w1", "W1", "W!" },
        ["q!"] = { "q1", "Q1", "Q!" },
        ["e!"] = { "e1", "E1", "E!" },
        ["wq!"] = {
                "wq!", "wq1", "wQ!", "wQ1",
                "Wq!", "Wq1", "WQ!", "WQ1",
        },
        ["wa!"] = {
                "wa!", "wa1", "wA!", "wA1",
                "Wa!", "Wa1", "WA!", "WA1",
        },
        ["qa!"] = {
                "qa!", "qa1", "qA!", "qA1",
                "Qa!", "Qa1", "QA!", "QA1",
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
        ["noau w"] = { "nw", "Nw", "NW" },
        ["noau wa"] = {
                "nwA", "nwa", "nWA", "nWa",
                "NwA", "Nwa", "NWA", "NWa",
        },
        ["noau wq"] = {
                "nwQ", "nwq", "nWQ", "nWq",
                "NwQ", "Nwq", "NWQ", "NWq",
        },
        -- Extras
        ["Cfilter"]     = { "cfilter" },
        ["Cfilter!"]    = { "cfilter1" },
        ["Man"]         = { "man" },
})
