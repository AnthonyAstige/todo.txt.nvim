# Time‑Estimate Feature — Specification Draft (v0.2)

_This document defines the enhanced “time estimate” capability for **todo.txt.nvim**._

---

## 1  User‑Facing Syntax

### 1.1  Estimate Tag

- **Format** : `est:<minutes>` (numeric) — e.g. `est:5`, `est:90`.
- Optional suffixes accepted (plugin always stores as minutes internally):

  - `h` → hours  (`est:2h` = 120 m).
  - `d` → days   (`est:1d` = 4 h = 240 m).
  - `w` → weeks  (`est:1w` = 5 days × 4 h = 1200 m).
- Only one `est:` tag per task is supported.

---

## 2  Focus / Filter Model

| Filter Name       | Definition (normalised minutes)               | Typical Use                |
| ----------------- | --------------------------------------------- | -------------------------- |
| **all** (default) | No filtering on estimate.                     | See everything.            |
| **has estimate**  | Has any `est:` tag.                           | See all estimated tasks.   |
| **no estimate**   | Has no `est:` tag.                            | See all unestimated tasks. |
| **short**         |  ≤ 15 m.                                      | Quick wins / micro‑tasks.  |
| **medium**        |  16 – 60 m.                                   | Moderate blocks.           |
| **long**          |  > 60 m and ≤ 4 h (240 m).                    | Deep‑work sessions.        |
| **days**          |  > 4 h and ≤ 5 days (1200 m) _or_ `d` suffix. | Multi‑session day‑sized.   |
| **weeks**         |  > 5 days (>1200 m) _or_ `w` suffix.          | Multi‑day / week‑long.     |

> \*\***Implementation note** — a line with `est:1d` always belongs to _day_ filter; `est:1w` belongs to _week_ filter.

_Filtering remains additive with project/context/date rules._

---

## 3  Commands & Keymaps

| Command (:`…`)              | Default Keymap | Effect                               |
| --------------------------- | -------------- | ------------------------------------ |
| **TodoTxtAll** _(existing)_ | `<leader>tfda` | Clears estimate filter (and others). |
| **TodoTxtHasEstimate**      | `<leader>tfea` | Focus → _has estimate_.              |
| **TodoTxtNoEstimate**       | `<leader>tfen` | Focus → _no estimate_.               |
| **TodoTxtShort**            | `<leader>tfes` | Focus → _short_.                     |
| **TodoTxtMedium**           | `<leader>tfem` | Focus → _medium_.                    |
| **TodoTxtLong**             | `<leader>tfel` | Focus → _long_.                      |
| **TodoTxtDays**             | `<leader>tfed` | Focus → _day_.                       |
| **TodoTxtWeeks**            | `<leader>tfew` | Focus → _week_.                      |

_All commands persist focus state just like current project/context/date filters._

---

## 4  Sorting Behaviour

1. Primary sort: _focused vs. unfocused_ (existing logic).
2. Secondary: _Priority_ (A, B, C, etc., then no priority).
3. Tertiary: **smaller estimate first** (numeric minutes after normalisation).
4. Quaternary: alphabetical.

---

## 5  FoldText Annotation

- Fold summary appends active estimate filter when ≠ **all** (e.g. `Focus: est:week`).

---

## 6  State Persistence

- `estimate_filter` key already added; accepted values now: `all` | `short` | `medium` | `long` | `day` | `week`.

---

## 7  Configuration Extension

```lua
keymaps = {
  estimate_short  = "<leader>tfes", -- ≤15 m
  estimate_medium = "<leader>tfem", -- 16–60 m
    estimate_long   = "<leader>tfel", -- >60 m ≤4 h
    estimate_day    = "<leader>tfed", -- >4 h ≤5 days or d‑suffix
    estimate_week   = "<leader>tfew", -- >5 days or w‑suffix
  estimate_has    = "<leader>tfea", -- has any estimate
  estimate_none   = "<leader>tfen", -- has no estimate
}
```

_Users may override any key._
