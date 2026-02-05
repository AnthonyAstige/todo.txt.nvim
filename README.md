# todo.txt.nvim

A Neovim plugin to dynamically focus on todo's in your `todo.txt` file based on projects (`+Project`) and contexts (`@Context`).

## Features

- **Project and Context Filtering**: Focus on specific projects (`+Project`) or contexts (`@Context`)
- **Date-based Filtering**: View tasks by due date (current, due, scheduled, unscheduled)
- **Time Estimates**: Filter tasks by estimated time using `~` tags (e.g., `~30m`, `~2h`)
- **Hyperfocus Mode**: Show only the current line for distraction-free editing
- **Smart Sorting**: Automatically sorts by focus status, priority, estimate, then alphabetically
- **Quick Capture**: Jot down new todos with project selection
- **State Persistence**: Remember your focus settings across sessions

## Dependencies

- [Neovim](https://neovim.io/) (0.8+) with a configured `vim.ui.select` backend (e.g., [dressing.nvim](https://github.com/stevearc/dressing.nvim) or the default TUI).
- (Optional) [which-key.nvim](https://github.com/folke/which-key.nvim) for improved keymap descriptions.

## Installation / configuration

### [Lazy.nvim](https://github.com/folke/lazy.nvim)

Place somewhere like `~/.config/nvim/lua/plugins/todo.txt.lua`:

The plugin comes with the following default configuration:

```lua
return {
  "AnthonyAstige/todo.txt.nvim",
  opts = {
    -- todo_file = "~/path/to/your/todo.txt",

    -- Keymap Grammar: <leader>tf = Focus, then category (p/c/d/e), then action (+/-/a/0)
    -- keymaps = {
    --   top = "<leader>t", -- Base menu key
    --   open_file = "<leader>to", -- Open todo.txt file
    --   open_file_alt = "<leader>tt", -- Alternative open shortcut
    --   focus = "<leader>tf", -- Focus submenu key
    --   jot = "<leader>tj", -- Jot down a new todo
    --   hyperfocustoggle = "<leader>th", -- Toggle hyperfocus mode
    --   unfocus = "<leader>tu", -- Clear all focus
    --   refresh = "<leader>tr", -- Refresh view
    --   open_link = "<leader>tl", -- Open link on current line
    --
    --   -- Project: <leader>tfp
    --   project_menu = "<leader>tfp", -- Project submenu
    --   project_add = "<leader>tfp+", -- Add/select project
    --   project_hide = "<leader>tfp-", -- Hide project
    --   project_any = "<leader>tfpa", -- Any project
    --   project_none = "<leader>tfp0", -- No project
    --
    --   -- Context: <leader>tfc
    --   context_menu = "<leader>tfc", -- Context submenu
    --   context_add = "<leader>tfc+", -- Add context
    --   context_hide = "<leader>tfc-", -- Hide context
    --   context_any = "<leader>tfca", -- Any context
    --   context_none = "<leader>tfc0", -- No context
    --
    --   -- Due: <leader>tfd
    --   due_menu = "<leader>tfd", -- Due submenu
    --   due_any = "<leader>tfda", -- Any due status
    --   due_current = "<leader>tfdc", -- Current (today/past/undated)
    --   due_due = "<leader>tfdd", -- Due (today/past only)
    --   due_scheduled = "<leader>tfds", -- Scheduled (has due date)
    --   due_unscheduled = "<leader>tfdu", -- Unscheduled (no due date)
    --
    --   -- Estimate: <leader>tfe
    --   estimate_menu = "<leader>tfe", -- Estimate submenu
    --   estimate_has = "<leader>tfe~", -- Has estimate
    --   estimate_none = "<leader>tfe0", -- No estimate
    --   estimate_max = "<leader>tfe<", -- Set max bound
    --   estimate_min = "<leader>tfe>", -- Set min bound
    --   estimate_any = "<leader>tfea", -- Any estimate
    -- },

    -- startup = {
    --   focus = {
    --     date = "current",
    --     project = nil, -- Focus on todo's with no project
    --     context = {}, -- Optionally put a list of contexts here like { "home", "quick" }
    --   },
    --   load_focus_state = true,
    --   hyperfocus_enabled = true,
    -- }

    -- filetypes = { "todo", "todos", "todo.txt" },
  },
}
```

## Usage

### Time Estimates

Add time estimates to your tasks using the `~` prefix:

- `~15m` - 15 minutes
- `~2h` - 2 hours
- `~3d` - 3 days
- `~1w` - 1 week
- `~1mo` - 1 month
- `~1y` - 1 year

The plugin converts all estimates to minutes internally:
- `m` suffix: minutes
- `h` suffix: hours (multiplied by 60)
- `d` suffix: days (multiplied by 240, assuming 4 hours of productive work per day)
- `w` suffix: weeks (multiplied by 1200, assuming 5 days * 4 hours per week)
- `mo` suffix: months (multiplied by 4800, assuming 4 weeks per month)
- `y` suffix: years (multiplied by 57600, assuming 12 months per year)

### Keymap Grammar

The keymaps follow a consistent grammar:
- `<leader>t` - Todo menu
- `<leader>tf` - Focus submenu
- `<leader>tfX` - Focus category (p=Project, c=Context, d=Due, e=Estimate)
- `<leader>tfX+` - Add/include specific item
- `<leader>tfX-` - Hide/exclude specific item
- `<leader>tfXa` - Any (clear filter)
- `<leader>tfX0` - None (items without that attribute)

### Commands and Keymaps

**Basic Operations:**
- `<leader>to` (`:TodoTxtOpen`): Open the configured `todo.txt` file.
- `<leader>tj` (`:TodoTxtJot`): Quickly jot down and append a new todo item.
- `<leader>tu` (`:TodoTxtUnfocus`): Clear all filters.
- `<leader>th` (`:TodoTxtHyperfocus`): Toggle hyperfocus mode (shows only current line).
- `<leader>tr` (`:TodoTxtRefresh`): Refresh sorting and folding.
- `<leader>tl` (`:TodoTxtOpenLink`): Open links on the current line.

**Project Filtering (`<leader>tfp`):**
- `<leader>tfp+` (`:TodoTxtProjectAdd`): Select a project to focus on.
- `<leader>tfp-` (`:TodoTxtProjectHide`): Hide project(s) from view.
- `<leader>tfpa` (`:TodoTxtProjectAny`): Clear project filter (show any).
- `<leader>tfp0` (`:TodoTxtProjectNone`): Focus tasks without projects.

**Context Filtering (`<leader>tfc`):**
- `<leader>tfc+` (`:TodoTxtContextAdd`): Add a context to focus on.
- `<leader>tfc-` (`:TodoTxtContextHide`): Hide context(s) from view.
- `<leader>tfca` (`:TodoTxtContextAny`): Clear context filter (show any).
- `<leader>tfc0` (`:TodoTxtContextNone`): Focus tasks without contexts.

**Due Date Filtering (`<leader>tfd`):**
- `<leader>tfda` (`:TodoTxtDueAny`): Any due status (show all).
- `<leader>tfdc` (`:TodoTxtDueCurrent`): Current (today, past due, or no due date).
- `<leader>tfdd` (`:TodoTxtDueDue`): Due (today or past due, excludes undated).
- `<leader>tfds` (`:TodoTxtDueScheduled`): Scheduled (has any due date).
- `<leader>tfdu` (`:TodoTxtDueUnscheduled`): Unscheduled (no due date).

**Estimate Filtering (`<leader>tfe`):**
- `<leader>tfe~` (`:TodoTxtEstimateHas`): Focus tasks with any estimate.
- `<leader>tfe0` (`:TodoTxtEstimateNone`): Focus tasks without estimates.
- `<leader>tfe<` (`:TodoTxtEstimateMax`): Set max bound (prompts for value like `2h`).
- `<leader>tfe>` (`:TodoTxtEstimateMin`): Set min bound (prompts for value like `30m`).
- `<leader>tfea` (`:TodoTxtEstimateAny`): Clear estimate filter (show any).

The min/max bounds work together to create ranges. For example, `<leader>tfe>` with `30m` then `<leader>tfe<` with `2h` shows tasks estimated between 30 minutes and 2 hours.

### Sorting

Tasks are automatically sorted using the following priority order:

1. **Focus status**: Focused tasks appear before unfocused tasks
2. **Priority**: Tasks with priorities (A) come before (B), (B) before (C), etc.
3. **Estimate size**: Smaller estimates appear before larger ones
4. **Alphabetically**: Tasks are sorted alphabetically as a final tiebreaker

### Combining Filters

Filters work together to help you find exactly what you need. For example:
- Focus on `+work` project AND set estimate max to `15m` for quick wins
- Set estimate range `30m-2h` to find medium-sized tasks
- View current tasks (due today/overdue/undated) in `@home` context
- Hide `@work` context while viewing all projects
- Find all unestimated tasks in a specific project to plan your time
