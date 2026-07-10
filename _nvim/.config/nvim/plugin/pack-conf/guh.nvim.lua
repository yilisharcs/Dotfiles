require("utils.cabbrev")({
        ["Guh"] = { "gh", "guh" },
})

vim.keymap.set("n", "<leader>oz", ":Guh ", { desc = "Run Guh command" })
vim.keymap.set("n", "<leader>os", "<CMD>Guh<CR>", { desc = "Open status" })

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

local on_exit = function(result)
        if result.code ~= 0 then
                return
        end

        vim.schedule(function()
                -- each key is a valid subject.type
                local notif_icons = {
                        Issue = "",
                        PullRequest = "",
                        Discussion = "",
                        Commit = "",
                        Release = "",
                        CheckSuite = "",
                }
                local entries = {}

                local notifications = vim.json.decode(result.stdout)
                for _, n in ipairs(notifications) do
                        local t = n.subject and n.subject.type
                        -- maybe github will add more types...?
                        if not notif_icons[t] then
                                goto continue
                        end

                        local repo = n.repository.full_name
                        local url = n.subject.url or ""
                        local num, slug

                        if t == "Commit" then
                                num = url:match("/commits/([a-f0-9]+)$"):sub(1, 7)
                                slug = url:gsub("api%.github%.com/repos/", "github.com/")
                        elseif t == "Release" or t == "CheckSuite" then
                                num = ""
                                slug = url:gsub("api%.github%.com/repos/", "github.com/")
                        else
                                num = url:match("/(%d+)$")
                                slug = ("%s#%s"):format(repo, num)
                        end

                        entries[#entries + 1] = {
                                icon = notif_icons[t],
                                num = num,
                                repo = repo,
                                title = n.subject.title,
                                slug = slug,
                                kind = t,
                                url = url,
                                unread = n.unread,
                        }

                        ::continue::
                end
                if #entries == 0 then
                        return
                end

                local num_pad, repo_pad = 0, 0
                for _, e in ipairs(entries) do
                        num_pad = math.max(num_pad, #e.num)
                        repo_pad = math.max(repo_pad, #e.repo)
                end

                local fzf = require("fzf-lua")
                vim.ui.select(entries, {
                        prompt = "Notifications> ",
                        format_item = function(e)
                                local hl = e.unread and "MiniIconsYellow" or "MiniIconsAzure"
                                local icon = fzf.utils.ansi_from_hl(hl, e.icon)
                                return ("%s  #%-" .. num_pad .. "s  %-" .. repo_pad .. "s  %s"):format(
                                        icon,
                                        e.num,
                                        e.repo,
                                        e.title
                                )
                        end,
                }, function(e)
                        if not e then
                                return
                        end

                        if e.kind == "Discussion" or e.kind == "Release" or e.kind == "CheckSuite" then
                                vim.ui.open(e.url:gsub("api%.github%.com/repos/", "github.com/"))
                        else
                                vim.cmd("Guh " .. e.slug)
                        end
                end)
        end)
end
vim.keymap.set("n", "<leader>on", function()
        vim.system({
                "gh",
                "api",
                "notifications?all=true",
                "--paginate",
        }, { text = true }, on_exit)
end, { desc = "Open notifications" })
