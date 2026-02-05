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

```lua
return {
  "AnthonyAstige/todo.txt.nvim",
  opts = {
    -- todo_file = "~/path/to/your/todo.txt",
  },
}
```

## Usage

### Keymap Grammar

The keymaps follow a consistent grammar that makes them easy to remember:

```
<leader>t    = Todo
<leader>tf   = Focus
<leader>tfX  = Focus category (p=Project, c=Context, d=Due, e=Estimate)
```

**Universal actions (same across all categories):**
- `a` = Any (clear filter, show all)
- `~` = Has (items with that attribute)
- `0` = None (items without that attribute)

**Category-specific actions:**
- Project/Context: `+` (add/focus specific), `-` (hide/exclude)
- Due: `c` (current), `d` (due)
- Estimate: `<` (max bound), `>` (min bound)

### Time Estimates

Add time estimates to your tasks using the `~` prefix:

- `~15m` - 15 minutes
- `~2h` - 2 hours
- `~3d` - 3 days
- `~1w` - 1 week
- `~1mo` - 1 month
- `~1y` - 1 year

### Commands and Keymaps

**Basic Operations:**
- `<leader>to` (`:TodoTxtOpen`): Open the configured `todo.txt` file.
- `<leader>tj` (`:TodoTxtJot`): Quickly jot down and append a new todo item.
- `<leader>tu` (`:TodoTxtUnfocus`): Clear all filters.
- `<leader>th` (`:TodoTxtHyperfocus`): Toggle hyperfocus mode (shows only current line).
- `<leader>tr` (`:TodoTxtRefresh`): Refresh sorting and folding.
- `<leader>tl` (`:TodoTxtOpenLink`): Open links on the current line.

**Project Filtering (`<leader>tfp`):**
| Key | Command | Description |
|-----|---------|-------------|
| `+` | `:TodoTxtProjectAdd` | Add/focus specific project |
| `-` | `:TodoTxtProjectHide` | Hide project(s) |
| `a` | `:TodoTxtProjectAny` | Any (clear filter) |
| `~` | `:TodoTxtProjectHas` | Has project |
| `0` | `:TodoTxtProjectNone` | No project |

**Context Filtering (`<leader>tfc`):**
| Key | Command | Description |
|-----|---------|-------------|
| `+` | `:TodoTxtContextAdd` | Add/focus specific context |
| `-` | `:TodoTxtContextHide` | Hide context(s) |
| `a` | `:TodoTxtContextAny` | Any (clear filter) |
| `~` | `:TodoTxtContextHas` | Has context |
| `0` | `:TodoTxtContextNone` | No context |

**Due Date Filtering (`<leader>tfd`):**
| Key | Command | Description |
|-----|---------|-------------|
| `a` | `:TodoTxtDueAny` | Any (clear filter) |
| `~` | `:TodoTxtDueHas` | Has due date |
| `0` | `:TodoTxtDueNone` | No due date |
| `c` | `:TodoTxtDueCurrent` | Current (today/past/undated) |
| `d` | `:TodoTxtDueDue` | Due (today/past only) |

**Estimate Filtering (`<leader>tfe`):**
| Key | Command | Description |
|-----|---------|-------------|
| `a` | `:TodoTxtEstimateAny` | Any (clear filter) |
| `~` | `:TodoTxtEstimateHas` | Has estimate |
| `0` | `:TodoTxtEstimateNone` | No estimate |
| `<` | `:TodoTxtEstimateMax` | Set max bound |
| `>` | `:TodoTxtEstimateMin` | Set min bound |

The estimate min/max bounds work together to create ranges. For example, `<leader>tfe>` with `30m` then `<leader>tfe<` with `2h` shows tasks estimated between 30 minutes and 2 hours.

### Default Keymaps

```lua
keymaps = {
  top = "<leader>t",
  open_file = "<leader>to",
  open_file_alt = "<leader>tt",
  focus = "<leader>tf",
  jot = "<leader>tj",
  hyperfocustoggle = "<leader>th",
  unfocus = "<leader>tu",
  refresh = "<leader>tr",
  open_link = "<leader>tl",

  -- Project: <leader>tfp
  project_menu = "<leader>tfp",
  project_add = "<leader>tfp+",
  project_hide = "<leader>tfp-",
  project_any = "<leader>tfpa",
  project_has = "<leader>tfp~",
  project_none = "<leader>tfp0",

  -- Context: <leader>tfc
  context_menu = "<leader>tfc",
  context_add = "<leader>tfc+",
  context_hide = "<leader>tfc-",
  context_any = "<leader>tfca",
  context_has = "<leader>tfc~",
  context_none = "<leader>tfc0",

  -- Due: <leader>tfd
  due_menu = "<leader>tfd",
  due_any = "<leader>tfda",
  due_has = "<leader>tfd~",
  due_none = "<leader>tfd0",
  due_current = "<leader>tfdc",
  due_due = "<leader>tfdd",

  -- Estimate: <leader>tfe
  estimate_menu = "<leader>tfe",
  estimate_any = "<leader>tfea",
  estimate_has = "<leader>tfe~",
  estimate_none = "<leader>tfe0",
  estimate_max = "<leader>tfe<",
  estimate_min = "<leader>tfe>",
}
```

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
