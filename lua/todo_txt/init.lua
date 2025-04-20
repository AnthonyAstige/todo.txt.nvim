local M = {}

local config = require('todo_txt.config')
local cfg -- Holds merged user and default config

local fn = vim.fn
local api = vim.api

-- Store the active filter pattern globally for foldexpr access
vim.g.todo_filter_pattern = nil

-- Scan for tags (symbol: '+' for projects, '@' for contexts)
-- Returns a list of unique tags found in the configured todo_file.
local function scan_tags(sym)
  local tags = {}
  local file = io.open(cfg.todo_file, 'r')
  if not file then
    vim.notify('todo-filter: Could not open todo file: ' .. cfg.todo_file, vim.log.levels.ERROR)
    return {}
  end

  for line in file:lines() do
    -- Match tags containing alphanumeric characters, underscores, colons, and hyphens
    for tag in line:gmatch(sym .. '([%w_:-]+)') do
      tags[tag] = true
    end
  end
  file:close()

  local tag_list = {}
  for tag, _ in pairs(tags) do
    table.insert(tag_list, tag)
  end
  table.sort(tag_list) -- Sort for consistent order in fzf
  return tag_list
end

-- Fold expression function:
-- Determines fold level based on the global filter pattern.
-- Lines matching the pattern get level '0' (visible), others get '1' (folded).
_G.TodoFilterFoldExpr = function(lnum)
  local pattern = vim.g.todo_filter_pattern
  -- If no pattern is set, don't fold anything
  if not pattern or pattern == '' then
    return '0'
  end

  local line = fn.getline(lnum)
  -- Check if the line contains the pattern
  -- Use vim.regex to handle potential magic characters in the pattern
  local regex = vim.regex(pattern)
  return regex:match_str(line) and '0' or '1'
end

-- Sets up buffer-local options for folding when a relevant file is opened.
local function setup_buffer_folding()
  vim.opt_local.foldmethod = 'expr'
  vim.opt_local.foldexpr = 'v:lua.TodoFilterFoldExpr(v:lnum)'
  vim.opt_local.foldenable = true
  vim.opt_local.foldlevel = 0 -- Start with folds closed
  -- Trigger an initial fold calculation after setting options
  vim.cmd('normal! zx')
end

-- Creates the user commands for filtering.
local function create_commands()
  local fzf_lua_ok, fzf = pcall(require, 'fzf-lua')
  if not fzf_lua_ok then
    vim.notify('todo-filter: fzf-lua is required for filtering commands.', vim.log.levels.ERROR)
    return
  end

  -- Command to filter by project
  api.nvim_create_user_command('TodoFilterProject', function()
    local items = scan_tags('%+')
    if #items == 0 then
      vim.notify('todo-filter: No projects (+) found in ' .. cfg.todo_file, vim.log.levels.WARN)
      return
    end
    fzf.fzf(items, {
      prompt = 'Project> ',
      actions = {
        ['default'] = function(selected)
          if selected[1] then
            -- Escape '+' for Lua pattern matching and create the search pattern
            vim.g.todo_filter_pattern = '%+' .. fn.escape(selected[1], '+')
            vim.cmd('redraw!') -- Redraw to apply potential syntax changes
            vim.cmd('normal! zx') -- Recalculate folds and apply them
            vim.notify('todo-filter: Filtering by project: +' .. selected[1])
          end
        end,
      },
    })
  end, { desc = 'Filter todo list by project (+Tag)' })

  -- Command to filter by context
  api.nvim_create_user_command('TodoFilterContext', function()
    local items = scan_tags('@')
    if #items == 0 then
      vim.notify('todo-filter: No contexts (@) found in ' .. cfg.todo_file, vim.log.levels.WARN)
      return
    end
    fzf.fzf(items, {
      prompt = 'Context> ',
      actions = {
        ['default'] = function(selected)
          if selected[1] then
            -- Escape '@' for Lua pattern matching and create the search pattern
            vim.g.todo_filter_pattern = '@' .. fn.escape(selected[1], '@')
            vim.cmd('redraw!')
            vim.cmd('normal! zx') -- Recalculate folds
            vim.notify('todo-filter: Filtering by context: @' .. selected[1])
          end
        end,
      },
    })
  end, { desc = 'Filter todo list by context (@Tag)' })

  -- Command to clear the filter
  api.nvim_create_user_command('TodoFilterClear', function()
    if vim.g.todo_filter_pattern then
      vim.g.todo_filter_pattern = nil
      vim.cmd('normal! zR') -- Open all folds
      vim.notify('todo-filter: Filter cleared.')
    else
      vim.notify('todo-filter: No filter active.', vim.log.levels.INFO)
    end
  end, { desc = 'Clear current todo filter' })
end

-- Sets up the keymaps based on the configuration.
local function create_keymaps()
  local map_opts = { noremap = true, silent = true }

  if cfg.keymaps.project then
    vim.keymap.set('n', cfg.keymaps.project, '<Cmd>TodoFilterProject<CR>',
      vim.tbl_extend('force', map_opts, { desc = 'Filter TODO by Project' }))
  end
  if cfg.keymaps.context then
    vim.keymap.set('n', cfg.keymaps.context, '<Cmd>TodoFilterContext<CR>',
      vim.tbl_extend('force', map_opts, { desc = 'Filter TODO by Context' }))
  end
  if cfg.keymaps.clear then
    vim.keymap.set('n', cfg.keymaps.clear, '<Cmd>TodoFilterClear<CR>',
      vim.tbl_extend('force', map_opts, { desc = 'Clear TODO Filters (eXpand)' }))
  end
end

-- Main setup function, called by users (e.g., via LazyVim opts)
-- Merges user options with defaults and initializes the plugin features.
M.setup = function(user_opts)
  -- Merge user options with defaults
  cfg = vim.tbl_deep_extend('force', {}, config.defaults, user_opts or {})

  -- Validate todo_file existence (optional, provides early feedback)
  if vim.fn.filereadable(cfg.todo_file) == 0 then
     vim.notify('todo_txt: todo_file not found or readable: ' .. cfg.todo_file, vim.log.levels.WARN)
  end

  -- Create commands and keymaps
  create_commands()
  create_keymaps()

  -- Setup autocommands for buffer folding
  local group = api.nvim_create_augroup('TodoFilterFolding', { clear = true })
  api.nvim_create_autocmd('FileType', {
    pattern = cfg.filetypes,
    group = group,
    callback = setup_buffer_folding,
    desc = 'Setup todo_txt folding for relevant filetypes',
  })

  vim.notify('todo_txt.nvim loaded successfully!', vim.log.levels.INFO)
end

return M
