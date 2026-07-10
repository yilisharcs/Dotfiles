require("utils.cabbrev")({
        ["Guh"] = { "gh", "guh" },
})

vim.keymap.set("n", "<leader>oz", ":Guh ", { desc = "Run Guh command" })
vim.keymap.set("n", "<leader>os", "<CMD>Guh<CR>", { desc = "Open status" })

vim.keymap.set("n", "<leader>on", function()
        CME.compile({
                args = "gh api 'notifications?all=true' --paginate"
                        .. " --jq '.[] | [.repository.full_name, .subject.type, .subject.title] | @tsv'"
                        .. " | column -t -s '\t'",
        }, { cmd_display = "gh api notifications" })
end, { desc = "Open notifications" })

local jq_issue = '.[] | [.number, .state, .createdAt[:10], .title, (.labels | map(.name) | join(","))] | @tsv'
local jq_prs = '.[] | [.number, .createdAt[:10], .title, (.labels | map(.name) | join(","))] | @tsv'
local jq_repos = ".[] | . as $r"
        .. ' | [.nameWithOwner, ((.description // "") | if length > 50 then .[:47] + "..." else . end),'
        .. ' ([$r.visibility, if $r.isFork then "fork" else empty end, if $r.isArchived then "arch" else empty end]'
        .. ' | join(", ")), .pushedAt[:10]] | @tsv'

vim.keymap.set("n", "<leader>oi", function()
        CME.compile({
                args = "gh issue list --json number,state,createdAt,title,labels"
                        .. (" --jq '%s' | column -t -s '\t'"):format(jq_issue),
        }, { cmd_display = "gh issue list" })
end, { desc = "List open issues" })
vim.keymap.set("n", "<leader>oI", function()
        CME.compile({
                args = "gh issue list -s closed --json number,state,createdAt,title,labels"
                        .. (" --jq '%s' | column -t -s '\t'"):format(jq_issue),
        }, { cmd_display = "gh issue list -s closed" })
end, { desc = "List closed issues" })

vim.keymap.set("n", "<leader>op", function()
        CME.compile({
                args = "gh pr list -s open --json number,createdAt,title,labels"
                        .. (" --jq '%s' | column -t -s '\t'"):format(jq_prs),
        }, { cmd_display = "gh pr list -s open" })
end, { desc = "List open PRs" })
vim.keymap.set("n", "<leader>oP", function()
        CME.compile({
                args = "gh pr list -s closed --json number,createdAt,title,labels"
                        .. (" --jq '%s' | column -t -s '\t'"):format(jq_prs),
        }, { cmd_display = "gh pr list -s closed" })
end, { desc = "List closed and merged PRs" })

vim.keymap.set("n", "<leader>or", function()
        CME.compile({
                args = "gh repo list --json nameWithOwner,description,visibility,isFork,isArchived,pushedAt"
                        .. (" --jq '%s' | column -t -s '\t'"):format(jq_repos),
        }, { cmd_display = "gh repo list" })
end, { desc = "List repos" })

-- stylua: ignore
local cmd_discussion = {
        "gh", "repo", "view",
        "--json", "hasDiscussionsEnabled,nameWithOwner,parent",
        "--jq", 'if .hasDiscussionsEnabled then .nameWithOwner else (.parent.nameWithOwner // "") end',
}
vim.keymap.set("n", "<leader>od", function()
        vim.system(cmd_discussion, { text = true }, function(result)
                if result.code ~= 0 then
                        return
                end
                vim.schedule(function()
                        local repo = vim.trim(result.stdout)
                        CME.compile({
                                args = ("gh api repos/%s/discussions --paginate"):format(repo)
                                        .. [[ --jq '.[] | "\\(.number) \\(.title)"']],
                        }, { cmd_display = ("gh api repos/%s/discussions"):format(repo) })
                end)
        end)
end, { desc = "List discussions" })
