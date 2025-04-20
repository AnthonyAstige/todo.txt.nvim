# todo.txt.nvim

A Neovim plugin to dynamically filter and fold your `todo.txt` file based on projects (`+Project`) and contexts (`@Context`).

Uses `fzf-lua` for interactive selection and folding to hide non-matching lines.

## Features

- Filter `todo.txt` by a single project or context.
- Uses Neovim's folding mechanism (`foldmethod=expr`) to hide non-matching lines.
- Integrates with [fzf-lua](https://github.com/ibhagwan/fzf-lua) for selecting filters.

This tool is currently a personal project by Anthony, who is exploring using `todo.txt` for personal task management. As such, the functionality and maintenance of this plugin may vary.

- Provides commands and keymaps for easy access.
- Configurable `todo.txt` file path and key mappings.

## Dependencies

- [Neovim](https://neovim.io/) (0.8+)
- [fzf-lua](https://github.com/ibhagwan/fzf-lua)

## Installation

### [Lazy.nvim](https://github.com/folke/lazy.nvim)

Place somewhere like `~/.config/nvim/lua/plugins/todo.txt.lua`:

```lua
return {
  "AnthonyAstige/todo.txt.nvim",
  dependencies = { "ibhagwan/fzf-lua" },
  opts = {
    -- Optional: Configure the path to your todo file
    -- todo_file = "~/path/to/your/todo.txt",
    -- Optional: Override default keymaps
    -- keymaps = {
    --   project = "<leader>fp",
    --   context = "<leader>fc",
    --   clear = "<leader>fx",
    -- }
  },
  -- Optional: Only load when editing todo.txt files
  -- ft = { "todo", "todos" },
  -- Or uncomment the line below to load it eagerly
  -- lazy = false,
}
```

_(Replace `"your-github-username/todo-filter.nvim"` with the actual plugin repository path once published.)_

## Configuration

The plugin comes with the following default configuration:

```lua
{
  -- Path to your todo.txt file
  todo_file = vim.fn.expand('~/todo.txt'),

  -- Keymaps for filtering actions
  keymaps = {
    project = '<leader>tfp', -- Filter by Project
    context = '<leader>tfc', -- Filter by Context
    clear   = '<leader>tfx', -- Clear filter (eXpand folds)
  },

  -- Filetypes to activate folding and commands for
  filetypes = { 'todo', 'todos', 'todo.txt' },
}
```

You can override these defaults by passing an `opts` table to the `setup()` function or in your LazyVim configuration as shown above.

## Usage

1. Open your `todo.txt` file (or any file matching the configured `filetypes`).
2. Use the keymaps (or commands) to filter:
   - `<leader>tfp` (or `:TodoFilterProject`): Prompts with `fzf-lua` to select a project (`+ProjectName`). Only lines containing the selected project will remain unfolded.
   - `<leader>tfc` (or `:TodoFilterContext`): Prompts with `fzf-lua` to select a context (`@ContextName`). Only lines containing the selected context will remain unfolded.
   - `<leader>tfx` (or `:TodoFilterClear`): Clears the current filter and unfolds all lines (`zR`).

## Commands

- `:TodoFilterProject`: Filter by project.
- `:TodoFilterContext`: Filter by context.
- `:TodoFilterClear`: Clear active filter.

## How it Works

- The plugin scans the `todo_file` for `+Project` and `@Context` tags when you trigger a filter command.
- It uses `fzf-lua` to present the found tags for selection.
- Once a tag is selected, it sets a global pattern (`vim.g.todo_filter_pattern`).
- A buffer-local `foldexpr` (`TodoFilterFoldExpr`) is set for files matching the configured `filetypes`.
- This `foldexpr` checks each line against the `vim.g.todo_filter_pattern`. If the pattern exists, the fold level is `0` (unfolded); otherwise, it's `1` (folded).
- Clearing the filter sets the pattern to `nil` and opens all folds (`zR`).

## Future Improvements

- Caching of tags for large files.
- Support for filtering by multiple tags (AND/OR logic).
- Async tag scanning.
