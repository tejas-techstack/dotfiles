local M = {}

M.general = {
  n = {
    ["\\"] = { ":", "Command mode", { noremap = true, silent = false } },
    ["<C-p>"] = {
      function()
        vim.api.nvim_buf_set_lines(
          0,           -- current buffer
          0,           -- start line
          -1,          -- end line (all lines)
          false,       -- strict indexing
          vim.fn.split(vim.fn.getreg('+'), '\n') -- clipboard lines
        )
      end,
      "Replace buffer with clipboard exactly"
    },
    ["<leader>cp"] = {
      function()
        local path = vim.fn.expand("%:p")
        local line = vim.fn.line(".")
        local full = path .. ":" .. line
        vim.fn.setreg("+", full)
        vim.notify("Copied: " .. full)
      end,
      "Copy file path and line",
    },
    ["<leader>rp"] = {
      function()
        vim.cmd("%delete _")   -- correct command
        vim.cmd("put +")
        vim.cmd("1delete _")
      end,
      "Replace file with clipboard"
    },
    ["<leader>pp"] = {
      function()
        vim.cmd("%delete _")  -- delete entire buffer without yanking
        vim.cmd("0put +")     -- paste clipboard at top
        vim.cmd("1delete _")  -- remove extra blank line
      end,
      "Replace entire buffer with clipboard"
    },
  },

  v = {
    ["<leader>p"] = {
      '"_dP',
      "Replace selection with clipboard (no register overwrite)",
    },
  },
}

M.dap = {
  plugin = true,
  n = {
    ["<leader>db"] = {
      "<cmd> DapToggleBreakpoint <CR>",
      "Add breakpoint at line",
    },
    ["<leader>dr"] = {
      "<cmd> DapContinue <CR>",
      "Start or continue the debugger",
    },
  },
}

return M
