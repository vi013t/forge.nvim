![banner](./docs/forge-banner.png)

![demo](./docs/demo.png)

## !!WARNING!!

**Forge.nvim is still in an alpha state and does not have all of the listed functionality.**

## Forge.nvim

`Forge.nvim` provides a UI interface organizing and collecting several eseential plugins including `mason.nvim`, `nvim-treesitter`, and many more, as well as managing compiler and interpreter installations. 

## What is it?

`Forge.nvim` comes with a UI floating window with a list of over 50 programming languages. Each language can have its compiler, syntax highlighter, linter, and formatter installed through the UI with no commands or manual downloads necessary. When multiple options are available (e.g. `gcc` vs `clang` vs `zig`), the user can pick a specific one, or install the recommended automatically.

Syntax highlighters are mostly installed through `nvim-treesitter`, and linters (LSPs) are mostly installed through `mason.nvim`, which is why they are both dependencies to the plugin.

## Example Installation & Configuration

- With `lazy.nvim`:
```lua
{
    "neph-iap/forge.nvim",
    dependencies = { "nvim-treesitter/nvim-treesitter", "williamboman/mason.nvim" },
    config = function() require("forge").setup({}) end,
    keys = { { "<leader>fr", "<cmd>Forge<cr>", desc = "Forge" } }
}
```
