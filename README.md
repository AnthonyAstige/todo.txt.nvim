# todo.txt.nvim

A Neovim plugin to dynamically focus on todo's in your `todo.txt` file based on projects (`+Project`) and contexts (`@Context`).

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

    -- keymaps = {
    --   top = "<leader>t", -- Menu top
    --   due = "<leader>td", -- Menu top: due
    --   project = "<leader>t+", -- Set Project
    --   context = "<leader>t@", -- Set Context
    --   exit = "<leader>tx",
    --   all = "<leader>tda", -- Show Dates: All
    --   now = "<leader>tdn", -- Show Dates: Now
    -- },

    -- startup = {
    --   focus = {
    --     date = "now",
    --     project = nil, -- Focus on todo's with no project
    --     context = "",
    --   },
    --   hyperfocus_enabled = true,
    -- }

    -- Filetypes to activate folding and commands for
    -- filetypes = { "todo", "todos", "todo.txt" },
  },
}
```

You can override these defaults by passing an `opts` table to the `setup()` function or in your LazyVim configuration as shown above.

## Usage

1. Open your `todo.txt` file (or any file matching the configured `filetypes`).
2. Ensure you have a backend configured for `vim.ui.select` (like [dressing.nvim](https://github.com/stevearc/dressing.nvim) or use the default TUI).
3. Use the keymaps (or commands) to focus:
   - `<leader>t+` (or `:TodoTxtProject`): Prompts with `vim.ui.select` to choose a project (`+ProjectName`). Only lines containing the selected project will remain unfolded.
   - `<leader>t@` (or `:TodoTxtContext`): Prompts with `vim.ui.select` to choose a context (`@ContextName`). Only lines containing the selected context will remain unfolded.
   - `<leader>tu` (or `:TodoTxtUnfocus`): Clears the current focus and unfolds all lines (`zR`).

## Commands

- `:TodoTxtProject`: Focus by project.
- `:TodoTxtContext`: Focus by context.
- `:TodoTxtUnfocus`: Clear active focus.
