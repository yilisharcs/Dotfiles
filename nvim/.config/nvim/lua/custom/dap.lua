vim.fn.sign_define('DapBreakpoint', { text = '●', texthl = 'DapBreakpoint', linehl = '', numhl = '' })
vim.fn.sign_define('DapBreakpointCondition', { text = '●', texthl = 'DapBreakpointCondition', linehl = '', numhl = '' })
vim.fn.sign_define('DapLogPoint', { text = '◆', texthl = 'DapLogPoint', linehl = '', numhl = '' })

local dap = require('dap')
local dapui = require('dapui')

require('nvim-dap-virtual-text').setup()

dapui.setup({
  layouts = {
    {
      elements = {
        { id = 'scopes',      size = 0.25 },
        { id = 'breakpoints', size = 0.25 },
        { id = 'stacks',      size = 0.25 },
        { id = 'watches',     size = 0.25 },
      },
      position = 'right',
      size = 0.36,
    },
    {
      elements = {
        { id = 'console', size = 0.5 },
        { id = 'repl',    size = 0.5 },
      },
      position = 'bottom',
      size = 0.33,
    }
  },
})
dap.listeners.before.attach.dapui_config = function() dapui.open() end
dap.listeners.before.launch.dapui_config = function() dapui.open() end
dap.listeners.before.event_terminated['dapui_config'] = function() dapui.close() end
dap.listeners.before.event_exited['dapui_config'] = function() dapui.close() end

require('hydra')({
  name = '[DAP]',
  config = {
    color = 'pink',
    invoke_on_body = true,
  },
  mode = 'n',
  body = '<leader>d',
  heads = {
    { '1', function() dap.step_back() end, { desc = '' } },
    { '2', function() dap.step_into() end, { desc = '' } },
    { '3', function() dap.step_over() end, { desc = '' } },
    { '4', function() dap.step_out() end, { desc = '' } },
    { '5', function() dap.continue() end, { desc = '' } },
    { 'X', function() dap.terminate() end, { exit = true, desc = '' } },
    { 'B', function() dap.toggle_breakpoint() end, { desc = 'break' } },
    { 'M', function() dap.set_breakpoint(vim.fn.input '[DAP] Condition > ') end, { desc = 'cond' } },
    { 'L', function() dap.set_breakpoint(nil, nil, vim.fn.input('Log point message: ')) end, { desc = 'log' } },
    { 'C', function() dap.run_to_cursor() end, { desc = 'to cursor' } },
    { 'R', function() dap.repl.toggle() end, { desc = 'repl' } },
    { 'U', function() dapui.toggle({ reset = true }) end, { desc = 'dapui' } },
    { 'E', function() dapui.eval() end, { desc = 'eval' } },
    { 'q', nil, { exit = true, nowait = true } },
  }
})

local codelldb_bin = require('mason-registry').get_package('codelldb'):get_install_path() ..
    '/extension/adapter/codelldb'

dap.adapters.codelldb = {
  type = 'executable',
  command = codelldb_bin,
}

dap.configurations.rust = {
  {
    name = 'Launch file',
    type = 'codelldb',
    request = 'launch',
    program = vim.uv.cwd() .. '/target/debug/' .. string.match(vim.fn.getcwd(), '([^/]+)$'),
    cwd = '${workspaceFolder}',
    stopOnEntry = false,
  },
}

-- If it's ever necessary
dap.configurations.c = dap.configurations.rust
dap.configurations.cpp = dap.configurations.rust
