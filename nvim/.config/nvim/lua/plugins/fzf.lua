local fd_exclude = "--exclude={Trash,.git,.cache,state/undo,target}"

local icons_cond
if vim.env.DISPLAY == nil then
  icons_cond = false
else
  icons_cond = true
end


return {
  "ibhagwan/fzf-lua",
  keys = {
    { "<leader>fi", "<CMD>FzfLua files<CR>",            desc = "[FZF] List all files" },
    { "<leader>fl", "<CMD>FzfLua git_files<CR>",        desc = "[FZF] List tracked files" },
    { "<leader>fh", "<CMD>FzfLua oldfiles<CR>",         desc = "[FZF] File history" },
    { "<leader>fb", "<CMD>FzfLua buffers<CR>",          desc = "[FZF] Buffers" },
    { "<leader>fc", "<CMD>FzfLua git_commits<CR>",      desc = "[FZF] Commits" },
    { "<leader>fg", "<CMD>FzfLua live_grep_native<CR>", desc = "[FZF] Live grep" },
    { "<leader>fk", "<CMD>FzfLua helptags<CR>",         desc = "[FZF] Help tags" },
    { "<leader>fK", "<CMD>FzfLua keymaps<CR>",          desc = "[FZF] List mappings" },
    { "<C-h>",      "<CMD>FzfLua marks<CR>",            desc = "[FZF] Get global marks" },
    {
      "<C-r>",
      "<CMD>FzfLua command_history<CR>",
      mode = { "n", "x" },
      desc = "[FZF] Search command history"
    },
    {
      "<C-x><C-f>",
      function()
        require("fzf-lua").complete_path({
          cmd = table.concat({
            "fd",
            "--color=never",
            "--hidden",
            "--follow",
            "--no-ignore",
            fd_exclude
          }, " "),
        })
      end,
      mode = "i",
      desc = "[FZF] Complete Path"
    },
    { "<C-Space>g", "<CMD>lua _G.fzf_dirs()<CR>", desc = "[FZF] New project tab" },
  },
  init = function()
    _G.fzf_dirs = function(opts)
      opts = opts or {}
      opts.winopts = { title = " Projects " }
      opts.actions = {
        ["default"] = function(selected)
          vim.cmd("tabnew " .. selected[1])
          vim.cmd("tcd " .. selected[1])
        end
      }
      local dirs = {
        "~/Projects/",
        "~/Projects/plugins-nvim/",
        "~/.local/share/nvim/lazy/",
        "~/Projects/_src/neovim/runtime/",
        "~/"
      }
      require("fzf-lua").fzf_exec(
        table.concat({
          "fd",
          "--hidden",
          "--follow",
          "--type d",
          "--exact-depth 1",
          ". "
        }, " ") ..
        table.concat(dirs, " "), opts
      )
    end
  end,
  opts = {
    keymap = {
      builtin = {
        ["<C-k>"] = "preview-page-up",
        ["<C-j>"] = "preview-page-down",
        ["<F1>"] = "toggle-help",
        ["<F2>"] = "toggle-fullscreen",
        ["<F4>"] = "toggle-preview",
      },
      fzf = {
        ["ctrl-q"] = "select-all+accept",
        ["alt-a"] = "toggle-all",
        ["alt-g"] = "last",
        ["alt-G"] = "first",
      },
    },
    winopts = {
      height   = 0.80,
      width    = 0.90,
      row      = 0.50,
      col      = 0.55,
      border   = "rounded",
      backdrop = 100,
    },
    git = { files = { file_icons = icons_cond } },
    files = {
      file_icons = icons_cond,
      fd_opts = table.concat({
        "--color=never",
        "--hidden",
        "--no-ignore",
        "--type f",
        "--type l",
        fd_exclude
      }, " "),
      winopts = { preview = { layout = "vertical" } },
    },
    grep = {
      rg_opts =
        table.concat({
          "--color=always",
          "--column",
          "--line-number",
          "--no-heading",
          "--smart-case",
          "--max-columns=4096",
          "--hidden",
          "-g=!.git",
          "-g=!flake.lock",
          "-e",
        }, " ")
    },
    helptags = {
      winopts = { height = 0.5 },
    },
    marks = {
      marks = "[A-Z]",
      fzf_opts = {
        ["--cycle"] = true,
        ["--tiebreak"] = "begin",
      },
      winopts = {
        title = " Global marks ",
        preview = { layout = "vertical" },
      }
    }
  }
}
