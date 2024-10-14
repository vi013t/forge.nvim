![banner](./docs/forge-banner.png)

<center>

`Forge.nvim` provides a GUI organizing and collecting several essential plugins including `mason.nvim`, `nvim-treesitter`, and many more, as well as managing compiler and interpreter installations. `Forge.nvim` also automatically sets up language servers, autocomplete, and autoformatters with no configuration necessary. The goal of Forge.nvim is to remove the hassle of setting up LSPs in Neovim.

</center>

## Demo

![demo](./docs/demo.png)

`Forge.nvim` provides this window in which you can install language servers, formatters, highlighters, and more with a single button press. Forge will automatically set up your LSP and related tools. The only reason you'd have to write any LSP configuration at all would be if you wanted to customize the appearance, such as changing borders or colors or icons. Otherwise, you don't have to write a single line of LSP setup.

## Requirements 

`Forge.nvim` currently **only works with lazy.nvim**. Forge has the ability to install plugins, and currently only has this ability with `lazy.nvim`. More package managers may be supported in the future.

Furthermore, **you must be using a "structured setup" for lazy.nvim. This means passing a directory name to `lazy.setup(...)`, *NOT* a table of plugins.** See [the relevant part of the `lazy.nvim` documentation](https://lazy.folke.io/usage/structuring) for more information.

Additionally, if you're on Windows, you need [gsudo](https://github.com/gerardog/gsudo) or something similar that allows running commands prefixed with `sudo` as an administrator.

## Example Installation & Configuration

```lua
{
    "vi013t/Forge.nvim",
    dependencies = {
        "nvim-treesitter/nvim-treesitter", 
        "williamboman/mason.nvim", 
        "neovim/nvim-lspconfig", 
        "williamboman/mason-lspconfig.nvim", 
        "stevearc/conform.nvim", 
    },
    opts = {},
}
```

<details>
	<summary>Advanced configuration (default options)</summary>

```lua
{
    "vi013t/Forge.nvim",
    dependencies = {
        "nvim-treesitter/nvim-treesitter", 
        "williamboman/mason.nvim", 
        "neovim/nvim-lspconfig", 
        "williamboman/mason-lspconfig.nvim", 
        "stevearc/conform.nvim", 
    },
    opts = {

        --- The path to the file which saves what you have installed, so that we don't need to check every time.
        lockfile = vim.fn.stdpath("data") .. "/forge.lock",

        --- The name of the plugin directory, relative to `~/.config/nvim/lua`. This is the directory where your
        --- plugin files are stored, and it should be the same as the directory passed to `lazy.nvim`'s `setup()`.
        plugin_directory = "plugins",

        --- Whether to autoformat buffers on save.
        format_on_save = true,

        --- Tools to "ensure installed". Every time you start Neovim, if any of these aren't installed, they will be installed automatically.
        --- By default, this installs all of autocomplete, `LuaSnip`, and `fidget.nvim`
        install = {
            global_tools = {
                "autocomplete",
                snippets = {
                    "luasnip",
                },
                lsp_status = {
                    "fidget",
                },
            },
        },

        -- UI --
        ui = {

            --- Whether to hide the cursor in the Forge window. This can be either `true`, `false`, or `nil`. If it
            --- is `nil`, which is the default, the cursor will be hidden only if `opts.ui.window_options.cursorline`
            --- is set to `true` (which is also default).
            hide_cursor = nil,

            mappings = {
                q = "close_window",
                e = "expand",
                c = "configure",
                j = "move_cursor_down",
                k = "move_cursor_up",
                gg = "set_cursor_to_top",
                G = "set_cursor_to_bottom",
                i = "toggle_install",
                u = "toggle_install",
                r = "refresh",
                o = "open_options",
                ["<C-d>"] = "do_nothing",
                ["<CR>"] = "move_cursor_down",
                ["<Up>"] = "move_cursor_up",
                ["<Down>"] = "move_cursor_down",
            },

            --- Configuration for the symbols displayed on the Forge window.
            symbols = {

                --- Icon presets. These are collections of icons that the Forge buffer will use. By default, there's the `default` preset,
                --- which has the default icons, and there's `ascii`, which has ASCII-only icons for non-nerd font users. You can set
                --- the preset with `preset = "presetname"`. You can also edit existing presets by adding a preset with an existing name
                --- and changing a key to your desired value; The remaining keys will fallback to the preset's original value.
                ---
                --- All custom presets should match the formats of existing presets. I recommend just copy-pasting an original preset and
                --- changing it to suit your preferences to avoid errors.
                ---
                --- # Example configuration - Exising preset:
                --- opts = {
                ---		ui = {
                ---			symbols = {
                ---				preset = "ascii"
                ---			}
                ---		}
                --- }
                ---
                --- # Example configuration - Modified preset
                --- opts = {
                ---		ui = {
                ---			symbols = {
                ---				presets = {
                ---					ascii = {
                ---						right_arrow = ">>"
                ---						down_arrow = "vv"
                ---					}
                ---				}
                ---				preset = "ascii"
                ---			}
                ---		}
                --- }
                ---
                --- # Example configuration - Custom preset
                --- opts = {
                ---		ui = {
                ---			symbols = {
                ---				presets = {
                ---					my_preset = {
                ---						right_arrow = "➡▸",
                ---						down_arrow = "⬇",
                ---						progress = {
                ---							{ "a" },
                ---							{ "a", "b" },
                ---							{ "a", "b", "c" },
                ---							{ "a", "b", "c", "d" },
                ---							{ "a", "b", "c", "d", "e" },
                ---							{ "a", "b", "c", "d", "e", "f" },
                ---						},
                ---						installed = "",
                ---						not_installed = "×",
                ---						none_available = "∅",
                ---					}
                ---				}
                ---				preset = "my_preset"
                ---			}
                ---		}
                --- }
                presets = {

                    --- The default preset, if `nvim-web-devicons` is installed. This preset uses the default icons for Forge.nvim, and
                    --- requires a nerd font or a glyph-rendering terminal (like Kitty) to render correctly. If you don't want to use a
                    --- nerd font, consider using `preset = "ascii"` or making your own preset.
                    default = {
                        --- The default right arrow icon to display when languages or tools are not expanded.
                        right_arrow = "▸",

                        --- The default down arrow icon to display when languages or tools are expanded.
                        down_arrow = "▾",

                        --- The default icons that appear next to languages showing how many tools have been installed relative to the number
                        --- of available tools. This is an array of 6 elements, each listing the icons that should appear for languages that have
                        --- 0, 1, 2, 3, 4, and 5 available tools. Each sub-array contains the icon present when you've installed 1 tool, 2 tools,
                        --- etc.
                        progress = {
                            { "" },
                            { "", "" },
                            { "", "", "" },
                            { "", "", "", "" },
                            { "", "", "", "", "" },
                            { "", "", "", "", "", "" },
                        },

                        --- The default icon for when a tool is already installed, a checkmark.
                        installed = "",
                        --- The default icon for when a tool is not installed, an "X".
                        not_installed = "",
                        --- The default icon for when there is no tool available, an empty circle.
                        none_available = "󰽤",
                        --- The default icon for an "additional tool" thats a Neovim plugin.
                        plugin = "",
                        --- The default icon for an "additional tool" thats a `mason.nvim` installation.
                        mason = "󱌣",
                        --- The default icon for an "additional tool" thats a CLI tool installation.
                        cli = "",
                        --- The default icon to display on the left side of "instruction" (the keybind visuals at the top of the window)
                        instruction_left = "",
                        --- The default icon to display on the right side of "instruction" (the keybind visuals at the top of the window)
                        instruction_right = "",
                    },

                    --- An ASCII-only preset. Use this preset (with `preset = "ascii"`) if you don't want to use a nerd font or a terminal
                    --- that renders glyps (such as Kitty). Alternatively, you can create your own preset and use that.
                    ascii = {
                        right_arrow = ">",
                        down_arrow = "v",
                        progress = {
                            { "0/0" },
                            { "0/1", "1/1" },
                            { "0/2", "1/2", "2/2" },
                            { "0/3", "1/3", "2/3", "3/3" },
                            { "0/4", "1/4", "2/4", "3/4", "4/4" },
                            { "0/5", "1/5", "2/5", "3/5", "4/5", "5/5" },
                        },
                        installed = "*",
                        not_installed = "X",
                        none_available = "O",
                        plugin = "P",
                        mason = ">_",
                        instruction_left = "",
                        instruction_right = "",
                    },
                },

                --- The icons preset. This should be a string such as "ascii". If this is `nil`, it will fallback to `"default"`
                --- *if* `nvim-web-devicons` is installed, and `"ascii"` if not. To use a custom preset, create one in the
                --- `presets` table, and use the name of it here.
                preset = nil,
            },

            --- Color configuration. This configures what colors are shown by the Forge buffer. The colors use the same preset
            --- system as icons; See the documentation for `options.ui.symbols.presets` for more information. Each color can
            --- be specified as a hex color, or the name of an *existing* highlight group, such as "Comment".
            colors = {
                presets = {

                    --- The default preset, which has bright saturated colors. This will be used by default if your colorscheme doesn't have a preset
                    --- associated with it and you haven't set a particular preset.
                    default = {
                        progress = {
                            { "#FF0000" }, -- Language has no tools available
                            { "#FF0000", "#00FF00" }, -- Language has 1 tool available
                            { "#FF0000", "#FFFF00", "#00FF00" }, -- Language has 2 tools available
                            { "#FF0000", "#FFAA00", "#BBFF00", "#00FF00" }, -- Language has 3 tools available
                            { "#FF0000", "#FF8800", "#FFFF00", "#BBFF00", "#00FF00" }, -- Language has 4 tools available
                            { "#FF0000", "#FF6600", "#FFAA00", "#FFFF00", "#BBFF00", "#00FF00" }, -- Language has 5 tools available
                        },
                        installed = "#00FF00",
                        not_installed = "#FF0000",
                        none_available = "#FFFF00",
                        window_title = "#CC99FF",
                        instructions = "#00FFFF",
                    },
                    ["catppuccin-mocha"] = {
                        progress = {
                            { "#F38BA8" }, -- Language has no tools available
                            { "#F38BA8", "#A6E3A1" }, -- Language has 1 tool available
                            { "#F38BA8", "#F9E2AF", "#A6E3A1" }, -- Language has 2 tools available
                            { "#F38BA8", "#FAB387", "#DDF7A1", "#A6E3A1" }, -- Language has 3 tools available
                            { "#F38BA8", "#FA9D87", "#F9E2AF", "#DDF7A1", "#A6E3A1" }, -- Language has 4 tools available
                            { "#F38BA8", "#FA8387", "#FAB387", "#F9E2AF", "#DDF7A1", "#A6E3A1" }, -- Language has 5 tools available
                        },

                        --- The color of the icon shown when a tool is installed.
                        installed = "#A6E3A1",

                        --- The color of the icon shown when a tool is available for installation, but none is installed.
                        not_installed = "#F38BA8",

                        --- The color of the icon shown when no tool is available for installation.
                        none_available = "#F9E2AF",

                        --- The background color of the title at the top of the window that says "Forge".
                        window_title = "#B4BEFE",

                        --- The background of the instructions at the top of the window that say "Expand", "Install", etc.
                        instructions = "#89DCEB",
                    },
                },

                --- The colors preset. This should be a string such as "ascii". If this is `nil`, it will fallback to `"default"`. To use a
                --- custom preset, create one in the `presets` table, and use the name of it here.
                preset = nil,
            },

            --- Options passed to the Forge window. These can be any options from vim.opt that are window-specific,
            --- as opposed to buffer-specific options.
            window_options = {
                cursorline = true,
            },

            --- Options passed to the Forge window upon creation. For a full list of available keys and values, see
            --- the last parameter of `:h nvim_open_win`.
            window_config = {
                style = "minimal",
                relative = "editor",
            },
        },

        -- LSP --
        lsp = {

            --- Diagnostic sign icons. These are the icons that'll appear next to virutal text, as well as in your
            --- sign column.
            icons = {
                Error = "",
                Warn = "",
                Hint = "󰌵",
                Info = "",
            },

            --- Diagnostic configuration. This is
            diagnostics = {
                underline = true, --- Whether to underline things like errors and warnings
                update_in_insert = false, --- Whether to update diagnostics while you're typing
                virtual_text = {
                    spacing = 4,
                    source = "if_many",
                },
                severity_sort = true, --- Sort diagnostics by severity (error > warning > info etc.)
            },

            --- Inlay hint configuration. Inlay hints are virtual text snippets that show things such as the type
            --- of a variable, the name of a function parameter, etc.
            inlay_hints = {

                --- Whether inlay hints are enabled.
                enabled = true,
            },
            capabilities = {},

            --- Autoformatting options. These are options passed directly to `conform.nvim`, so see the `conform` spec
            --- for possible keys and values here.
            format = {
                formatting_options = nil,
                timeout_ms = nil,
            },

            -- Language Servers
            servers = {

                -- Lua
                lua_ls = {
                    settings = {
                        Lua = {
                            workspace = {
                                checkThirdParty = false,
                            },
                            completion = {
                                callSnippet = "Replace",
                            },
                        },
                    },
                },

                -- C#
                omnisharp_mono = {
                    cmd = {
                        vim.fn.stdpath("data") .. "/mason/bin/omnisharp-mono",
                        "--assembly-loader=strict",
                    },
                    use_mono = true,
                },
            },
            setup = {},
        },

        -- Autocomplete options
        autocomplete = {
            format = {

                --- What to display on the autocomplete menu. The default is `symbol_text`, which displays both icons
                --- and text. For more information, see the `lspkind` documentation. If you're choosing not to use
                --- `lspkind` as a dependency for `Forge`, then this will do nothing.
                mode = "symbol_text",

                --- Map of symbols for the autocomplete menu. See the `lspkind` documentation for more information.
                --- If you're choosing not to use `lspkind` as a dependency for `Forge`, then this will do nothing.
                symbol_map = {
                    Text = "",
                    Method = "∷",
                    Function = "λ",
                    Constructor = "",
                    Field = "",
                    Variable = "󰫧",
                    Class = "",
                    Interface = "",
                    Module = "",
                    Property = "∷",
                    Unit = "",
                    Value = "",
                    Enum = "",
                    Keyword = "",
                    Snippet = "➡️",
                    Color = "",
                    File = "",
                    Reference = "&",
                    Folder = "",
                    EnumMember = "",
                    Constant = "𝛫",
                    Struct = "",
                    Event = "",
                    Operator = "",
                    TypeParameter = "",
                },
            },
        },
    }
}
```

</details>

<br/>

That's it! `Forge.nvim` will automatically handle the hassle of setting up `lspconfig`, language servers, autocomplete, autoformatting, and more. If you do choose, you can set up specific options as well; See the advanced configuration above.

Other plugins can be installed through `Forge.nvim`, and they don't need to be stated in your `dependencies`; `Forge.nvim` will automatically place them in your `lazy.nvim` config when you install them through `Forge.nvim`.

## What is `Forge.nvim`?

`Forge.nvim` comes with a GUI floating window with a list of over 20 programming languages. Each language can have its compiler, syntax highlighter, linter, and formatter installed through the UI with no commands or manual downloads necessary. When multiple options are available (e.g. `gcc` vs `clang` vs `zig`), the user can pick a specific one, or install the recommended automatically.

Syntax highlighters are mostly installed through `nvim-treesitter`, and linters (LSPs) are mostly installed through `mason.nvim`, which is why they are both dependencies to the plugin.

`Forge.nvim` automatically runs the setup for `mason.nvim`, `nvim-cmp`, `nvim-lspconfig`, `nvim-treesitter`, `conform.nvim`, and more.

## Why `Forge.nvim`?

A fair question might be what the purpose of making `Forge.nvim` is when tools like `mason.nvim` and `nvim-treesitter` already exist. The reality is, learning to program is overwhelming, especially in Neovim; The amount of tools available is huge and understanding how to set up and use these tools can take a long time. The purpose of `Forge.nvim` is to streamline the devtools installation and setup process. 

Want to write C, but you've never installed anything before? Press one button, and all the power of the language is at your fingertips: The compiler, LSP, semantic highlighter, auto-formatter, debugger, and additional support plugins can all be installed with a single button press. 

`Forge.nvim` also aims to eliminate the "what's the name of the tool?" process, such as scrolling up and down `mason.nvim` looking for a Python debugger, when searching "Python" and checking under "P" doesn't seem to be helpful. Often, you'd have to search the web to discover that it's called `debugpy`. In some cases of poorly-named tools, this process is repeated for every tool of the language: the LSP, the formatter, the debugger, etc. `Forge.nvim` aims to wash away that headache by providing easy tool installation *under the name of the language*. 

In general, `Forge.nvim` does not aim to provide any new or groundbreaking functionality to Neovim; Instead, it aims simply to streamline the complex process of installing developer tools. Much of this is already possible and even simple using just `mason.nvim` and `nvim-treesitter`, but `Forge.nvim` aims to be so dead simple that even a five year old could figure it out without looking anything up.

Additionally, `Forge.nvim` aims to minimize LSP setup in Neovim. Most users want the same features- diagnostics with virtual text, autocomplete, snippets, etc., and it's silly for every Neovim user to have to learn how to configure all of that. `Forge.nvim` attempts to setup all of the standard LSP tools without any configuration, and instead allowing users to opt *out* of features like autocomplete and snippets. The general philosophy is that *the most common preferences should be the default*.

## Issues

`Forge.nvim` is still in a pre-alpha state, and much of the promised functionality is not yet implemented. As such, many issues, bugs, and lacking features are known. However, feel free to make an issue regardless, and progress on that feature/bug can be tracked there.

## Contributing

### Language Support

`Forge.nvim` will happily accept submissions for new languages/tools. Use the "New Language/Tool" issue template to create a new issue regarding the language or tool.

### Themes

`Forge.nvim` has a number of built-in presets for common themes, such as Catppuccin. If you'd like to add a new theme, submit an issue or a pull request adding your colors. However, note that only quite popular themes will likely be accepted. We can't add every theme under the sun, but we'd like to provide common ones that lots of people use, such as Catppuccin, Gruvbox, Neovim default, One Dark, etc.
