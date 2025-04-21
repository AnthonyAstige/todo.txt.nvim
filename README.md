# todo.txt.nvim

A Neovim plugin to dynamically filter and fold your `todo.txt` file based on projects (`+Project`) and contexts (`@Context`).

Uses `vim.ui.select` for interactive selection and folding to hide non-matching lines.

## Features

- Filter `todo.txt` by a single project or context using `vim.ui.select`.
- Uses Neovim's folding mechanism (`foldmethod=expr`) to hide non-matching lines.

This tool is currently a personal project by Anthony, who is exploring using `todo.txt` for personal task management. As such, the functionality and maintenance of this plugin may vary.

- Provides commands and keymaps for easy access.
- Configurable `todo.txt` file path and key mappings.

## Dependencies

- [Neovim](https://neovim.io/) (0.8+) with a configured `vim.ui.select` backend (e.g., [dressing.nvim](https://github.com/stevearc/dressing.nvim) or the default TUI).

## Installation / configuration

### [Lazy.nvim](https://github.com/folke/lazy.nvim)

Place somewhere like `~/.config/nvim/lua/plugins/todo.txt.lua`:

The plugin comes with the following default configuration:

```lua
return {
  "AnthonyAstige/todo.txt.nvim",
  opts = {
    -- todo_file = "~/path/to/your/todo.txt",

    -- Keymaps for actions
    -- keymaps = {
    --   top = "<leader>t", -- Menu top
    --   due = "<leader>td", -- Menu top: due
    --   project = "<leader>t+", -- Set Project
    --   context = "<leader>t@", -- Set Context
    --   exit = "<leader>tx",
    --   all = "<leader>tda", -- Show Dates: All
    --   now = "<leader>tdn", -- Show Dates: Now
    -- },

    -- How to focus at app loading
    -- date_focus_start = "now",
    -- project_focus_start = nil, -- Focus on todo's with no project
    -- context_focus_start = "",

    -- Filetypes to activate folding and commands for
    filetypes = { "todo", "todos", "todo.txt" },
  },
}
```

You can override these defaults by passing an `opts` table to the `setup()` function or in your LazyVim configuration as shown above.

## Usage

1. Open your `todo.txt` file (or any file matching the configured `filetypes`).
2. Ensure you have a backend configured for `vim.ui.select` (like [dressing.nvim](https://github.com/stevearc/dressing.nvim) or use the default TUI).
3. Use the keymaps (or commands) to filter:
   - `<leader>t+` (or `:TodoTxtProject`): Prompts with `vim.ui.select` to choose a project (`+ProjectName`). Only lines containing the selected project will remain unfolded.
   - `<leader>t@` (or `:TodoTxtContext`): Prompts with `vim.ui.select` to choose a context (`@ContextName`). Only lines containing the selected context will remain unfolded.
   - `<leader>tu` (or `:TodoTxtUnfocus`): Clears the current filter and unfolds all lines (`zR`).

## Commands

- `:TodoTxtProject`: Filter by project.
- `:TodoTxtContext`: Filter by context.
- `:TodoTxtUnfocus`: Clear active filter.
