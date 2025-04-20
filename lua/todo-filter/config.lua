-- Default configuration options for todo-filter.nvim
local M = {}

M.defaults = {
  -- Path to your todo.txt file
  todo_file = vim.fn.expand('~/todo.txt'),

  -- Keymaps for filtering actions
  keymaps = {
    project = '<leader>tfp', -- Filter by Project
    context = '<leader>tfc', -- Filter by Context
    clear   = '<leader>tfx', -- Clear filter (eXpand folds)
  },

  -- Filetypes to activate folding and commands for
  -- Ensure 'todo' or similar is set for your todo.txt files
  -- e.g., via vim.filetype.add() or an ftplugin
  filetypes = { 'todo', 'todos', 'todo.txt' },
}

return M
