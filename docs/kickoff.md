# Neovim \`todo.txt\` Filter & Folding Specification

This document outlines the requirements and implementation plan for a Neovim plugin/configuration (using LazyVim) to manage a single `todo.txt` with dynamic filtering by project and context.

---

## 1. Goals

1. **Single Source of Truth**: Always edit `~/todo.txt` directly.
2. **Dynamic Filtering**: Quickly toggle filters by project (`+Project`) or context (`@Context`).
3. **Folding-Based View**: Collapse non-matching lines; only matching tasks remain unfolded.
4. **FZF-Lua Integration**: Prompt user with a list of known projects/contexts.
5. **LazyVim Compatibility**: Integrate cleanly into existing LazyVim config.

---

## 2. Dependencies

- **Neovim 0.8+**
- **LazyVim**
- **fzf-lua** plugin installed and configured in LazyVim
- **LuaFileSystem** (optional, for file scanning)

---

## 3. Data Extraction

1. **Path**: `~/todo.txt` (configurable)
2. **Parse Known Tags**:
   - Projects: regex `/\+([A-Za-z0-9_:-]+)/g`
   - Contexts: regex `/@([A-Za-z0-9_:-]+)/g`
3. **Caching**: Build a deduplicated list on demand or on `BufReadPre`.

---

## 4. User Interface

| Command              | Description                               |
| -------------------- | ----------------------------------------- |
| `<leader>tfp`        | Prompt for **project** filter via fzf-lua |
| `<leader>tfc`        | Prompt for **context** filter via fzf-lua |
| `<leader>tfx`        | Clear all filters (eXpand all folds)      |
| `:TodoFilterProject` | Same as `<leader>tfp`                     |
| `:TodoFilterContext` | Same as `<leader>tfc`                     |
| `:TodoFilterClear`   | Same as `<leader>tfx`                     |

---

## 5. Implementation Details

### 5.1. State Management

- **Global Variables**:
  - `vim.g.todo_filter_pattern` – string or `nil`

### 5.2. Folding Setup

```lua
-- in ftplugin/todo.lua
vim.opt_local.foldmethod  = 'expr'
vim.opt_local.foldexpr    = 'TodoFilterFoldExpr(v:lnum)'
vim.opt_local.foldenable  = true

-- foldexpr function
_G.TodoFilterFoldExpr = function(ln)
  local pat = vim.g.todo_filter_pattern
  if not pat or pat == '' then
    return '0'  -- no folding
  end
  local line = vim.fn.getline(ln)
  return line:match(pat) and '0' or '1'
end
```

### 5.3. Filter Commands

_Note:_ The `<leader>tfx` mapping uses **x** as a mnemonic for **eXpand**, since clearing filters re‑opens all folds.

```lua
local fzf = require('fzf-lua')
local function scan_tags(sym)
  local tags = {}
  for line in io.lines(vim.env.HOME..'/todo.txt') do
    for tag in line:gmatch(sym..'([%w_:-]+)') do
      tags[tag] = true
    end
  end
  return vim.tbl_keys(tags)
end

-- Prompt and set filter by project
vim.api.nvim_create_user_command('TodoFilterProject', function()
  local projects = scan_tags('%+')
  fzf.fzf({
    source = projects,
    prompt = 'Project> ',
    sink  = function(choice)
      vim.g.todo_filter_pattern = '%+'..vim.fn.escape(choice, '+')
      vim.cmd('redraw!')
      vim.cmd('normal! zx')
    end,
  })
end, {})

-- Prompt and set filter by context
vim.api.nvim_create_user_command('TodoFilterContext', function()
  local contexts = scan_tags('@')
  fzf.fzf({
    source = contexts,
    prompt = 'Context> ',
    sink  = function(choice)
      vim.g.todo_filter_pattern = '@'..vim.fn.escape(choice, '@')
      vim.cmd('redraw!')
      vim.cmd('normal! zx')
    end,
  })
end, {})

-- Clear filters
vim.api.nvim_create_user_command('TodoFilterClear', function()
  vim.g.todo_filter_pattern = nil
  vim.cmd('normal! zR')  -- open all folds
end, {})
```

---

## 6. Key Mappings (LazyVim style)

```lua
-- in lua/plugins/todo-filter.lua
return {
  {
    'yourname/todo-filter', -- optional, if you wrap above as a plugin
    lazy = false,
    config = function()
      vim.keymap.set('n', '<leader>tfp', '<cmd>TodoFilterProject<CR>', { desc = 'Filter TODO by Project' })
      vim.keymap.set('n', '<leader>tfc', '<cmd>TodoFilterContext<CR>', { desc = 'Filter TODO by Context' })
      vim.keymap.set('n', '<leader>tfx', '<cmd>TodoFilterClear<CR>', { desc = 'Clear TODO Filters' })
    end,
  }
}
```

---

---

## 7. Neovim Plugin Implementation

We'll package the above into a self‑contained plugin. Create the file:

```text
<nvim-config-dir>/plugin/todo-filter.lua
```

```lua
-- plugin/todo-filter.lua
local fn = vim.fn
local api = vim.api
local fzf = require('fzf-lua')

-- Configuration
local cfg = {
  todo_file = fn.expand('~/todo.txt'),
  keymaps = {
    project = '<leader>tfp',
    context = '<leader>tfc',
    clear   = '<leader>tfx',
  }
}

-- Scan for tags (symbol: '+' for projects, '@' for contexts)
local function scan_tags(sym)
  local tags = {}
  for line in io.lines(cfg.todo_file) do
    for tag in line:gmatch(sym..'([%w_:-]+)') do
      tags[tag] = true
    end
  end
  return vim.tbl_keys(tags)
end

-- Fold expression: hide lines not matching current pattern
_G.TodoFilterFoldExpr = function(ln)
  local pat = vim.g.todo_filter_pattern
  if not pat or pat == '' then
    return '0'
  end
  local line = fn.getline(ln)
  return line:match(pat) and '0' or '1'
end

-- Setup folding on todo.txt buffers
api.nvim_create_autocmd({'BufRead','BufNewFile'}, {
  pattern = 'todo.txt',
  callback = function()
    vim.opt_local.foldmethod = 'expr'
    vim.opt_local.foldexpr   = 'TodoFilterFoldExpr(v:lnum)'
    vim.opt_local.foldenable = true
  end,
})

-- User commands
api.nvim_create_user_command('TodoFilterProject', function()
  local items = scan_tags('%+')
  fzf.fzf({
    source = items,
    prompt = 'Project> ',
    sink = function(choice)
      vim.g.todo_filter_pattern = '%+'..fn.escape(choice, '+')
      vim.cmd('redraw!')
      vim.cmd('normal! zx')
    end,
  })
end, {})

api.nvim_create_user_command('TodoFilterContext', function()
  local items = scan_tags('@')
  fzf.fzf({
    source = items,
    prompt = 'Context> ',
    sink = function(choice)
      vim.g.todo_filter_pattern = '@'..fn.escape(choice, '@')
      vim.cmd('redraw!')
      vim.cmd('normal! zx')
    end,
  })
end, {})

api.nvim_create_user_command('TodoFilterClear', function()
  vim.g.todo_filter_pattern = nil
  vim.cmd('normal! zR')
end, {})

-- Key mappings
api.nvim_set_keymap('n', cfg.keymaps.project, ':TodoFilterProject<CR>', { noremap=true, silent=true })
api.nvim_set_keymap('n', cfg.keymaps.context, ':TodoFilterContext<CR>', { noremap=true, silent=true })
api.nvim_set_keymap('n', cfg.keymaps.clear,   ':TodoFilterClear<CR>',   { noremap=true, silent=true })
```

**Usage:**

1. Open `~/todo.txt` in Neovim.
2. `<leader>tfp` → filter by project.
3. `<leader>tfc` → filter by context.
4. `<leader>tfx` → clear filter.

---

## 8. Iteration

‑ Test on real `todo.txt` files.\
‑ Adjust `todo_file` path if needed.\
‑ Add caching or async I/O for large files.\
‑ Multi‑tag filtering support (AND/OR) as future work.
