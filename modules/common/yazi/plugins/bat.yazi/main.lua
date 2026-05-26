-- https://github.com/mgumz/yazi-plugin-bat/commit/e23776c125dd3589086e8e32e5f14a6370b6372d
--- @since 25.5.28

_G.Command = Command
_G.cx = cx
_G.rt = rt
_G.ui = ui
_G.ya = ya

local M = {}

function M:peek(job)
        -- check if file exists
        if not job.file then
                return
        end

        local start = job.skip + 1
        local finish = job.skip + job.area.h

        local output, err = Command("bat")
                :arg("--style=plain")
                :arg("--color=always")
                :arg("--paging=never")
                :arg(("--line-range=%d:%d"):format(start, finish))
                :arg(tostring(job.file.url))
                :output()

        if not output then
                return ya.preview_widget(
                        job,
                        ui.Text("Error: " .. tostring(err)):area(job.area):wrap(ui.Wrap.YES)
                )
        end

        local s = output.stdout:gsub("\t", string.rep(" ", rt.preview.tab_size))

        if job.skip > 0 and s == "" then
                ya.emit("peek", {
                        math.max(0, job.skip - job.area.h),
                        only_if = job.file.url,
                        upper_bound = false,
                })
                return
        end

        local wrap = rt.preview.wrap == "yes" and ui.Wrap.YES or ui.Wrap.NO
        ya.preview_widget(job, ui.Text.parse(s):area(job.area):wrap(wrap))
end

function M:seek(job)
        local h = cx.active.current.hovered
        if h and h.url == job.file.url then
                ya.emit("peek", {
                        math.max(0, cx.active.preview.skip + job.units),
                        only_if = job.file.url,
                })
        end
end

return M
