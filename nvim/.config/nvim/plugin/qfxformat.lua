-- https://github.com/kevinhwang91/nvim-bqf/?tab=readme-ov-file#customize-quickfix-window-easter-egg

function _G.qfx(info)
  local items
  local ret = {}
  if info.quickfix == 1 then
    items = vim.fn.getqflist({ id = info.id, items = 0 }).items
  else
    items = vim.fn.getloclist(info.winid, { id = info.id, items = 0 }).items
  end

  -- truncate file names
  local limit = 31
  local fnameFmt1, fnameFmt2 = "%-" .. limit .. "s", "…%." .. (limit - 1) .. "s"

  local validFmt = ""
  for i = info.start_idx, info.end_idx do
    local e = items[i]
    local fname = ""
    local str
    if e.valid == 1 then
      if e.bufnr > 0 then
        fname = vim.fn.bufname(e.bufnr)
        if fname == "" then
          fname = "[No Name]"
        else
          fname = fname:gsub("^" .. vim.env.HOME, "~")
        end
        -- char in fname may occur more than 1 width, ignore this issue in order to keep performance
        if #fname <= limit then
          fname = fnameFmt1:format(fname)
        else
          fname = fnameFmt2:format(fname:sub(1 - limit))
        end
      end
      local lnum = e.lnum > 99999 and -1 or e.lnum
      local col = e.col > 999 and -1 or e.col
      local qtype = e.type == "" and "" or e.type:sub(1, 1):upper() .. "|"
      if e.type == "" and "" then
        validFmt = "%s%s | %5d:%-3d | %s"
      else
        validFmt = "%s %s | %5d:%-3d | %s"
      end
      if qtype == "E|" then
        qtype = ""
      elseif qtype == "W|" then
        qtype = ""
      elseif qtype == "I|" then
        qtype = ""
      elseif qtype == "N|" or qtype == "H|" then
        qtype = "󰌶"
      end
      str = validFmt:format(qtype, fname, lnum, col, e.text)
    else
      str = e.text
    end
    table.insert(ret, str)
  end
  return ret
end

vim.o.qftf = "{info -> v:lua._G.qfx(info)}"
