local status_ok, telescope = pcall(require, "telescope")
if not status_ok then
    return
end

local actions = require("telescope.actions")

telescope.setup({
    defaults = {
        prompt_prefix = " ",
        selection_caret = " ",
        path_display = { "smart" },

        layout_strategy = "horizontal",
        layout_config = {
            horizontal = {
                width = 0.99,
                height = 0.99,
                preview_cutoff = 40,
                prompt_position = "top",
            },
            -- vertical = {
            --   size = {
            --     width = "90%",
            --     height = "90%",
            --   },
            -- },
        },

        mappings = {
            i = {
                ["<C-n>"] = actions.cycle_history_next,
                ["<C-p>"] = actions.cycle_history_prev,

                ["<C-j>"] = actions.move_selection_next,
                ["<C-k>"] = actions.move_selection_previous,

                ["<C-c>"] = actions.close,

                ["<Down>"] = actions.move_selection_next,
                ["<Up>"] = actions.move_selection_previous,

                ["<CR>"] = actions.select_default,
                ["<C-x>"] = actions.select_horizontal,
                ["<C-v>"] = actions.select_vertical,
                ["<C-t>"] = actions.select_tab,

                ["<C-u>"] = actions.preview_scrolling_up,
                ["<C-d>"] = actions.preview_scrolling_down,

                ["<PageUp>"] = actions.results_scrolling_up,
                ["<PageDown>"] = actions.results_scrolling_down,

                ["<Tab>"] = actions.toggle_selection + actions.move_selection_worse,
                ["<S-Tab>"] = actions.toggle_selection + actions.move_selection_better,
                ["<C-q>"] = actions.send_to_qflist + actions.open_qflist,
                ["<M-q>"] = actions.send_selected_to_qflist + actions.open_qflist,
                ["<C-l>"] = actions.complete_tag,
                ["<C-_>"] = actions.which_key, -- keys from pressing <C-/>
                ["<C-h>"] = "which_key",
            },

            n = {
                ["<esc>"] = actions.close,
                ["<CR>"] = actions.select_default,
                ["<C-x>"] = actions.select_horizontal,
                ["<C-v>"] = actions.select_vertical,
                ["<C-t>"] = actions.select_tab,

                ["<Tab>"] = actions.toggle_selection + actions.move_selection_worse,
                ["<S-Tab>"] = actions.toggle_selection + actions.move_selection_better,
                ["<C-q>"] = actions.send_to_qflist + actions.open_qflist,
                ["<M-q>"] = actions.send_selected_to_qflist + actions.open_qflist,

                ["j"] = actions.move_selection_next,
                ["k"] = actions.move_selection_previous,
                ["H"] = actions.move_to_top,
                ["M"] = actions.move_to_middle,
                ["L"] = actions.move_to_bottom,

                ["<Down>"] = actions.move_selection_next,
                ["<Up>"] = actions.move_selection_previous,
                ["gg"] = actions.move_to_top,
                ["G"] = actions.move_to_bottom,

                ["<C-u>"] = actions.preview_scrolling_up,
                ["<C-d>"] = actions.preview_scrolling_down,

                ["<PageUp>"] = actions.results_scrolling_up,
                ["<PageDown>"] = actions.results_scrolling_down,

                ["?"] = actions.which_key,
            },
        },
    },
    pickers = {
        -- Default configuration for builtin pickers goes here:
        -- picker_name = {
        --   picker_config_key = value,
        --   ...
        -- }
        -- Now the picker_config_key will be applied every time you call this
        -- builtin picker
        planets = {
            show_pluto = true,
        },
    },
    extensions = {
        -- Your extension configuration goes here:
        -- extension_name = {
        --   extension_config_key = value,
        -- }
        -- please take a look at the readme of the extension you want to configure
        fzf = {
            fuzzy = true,                   -- false will only do exact matching
            override_generic_sorter = true, -- override the generic sorter
            override_file_sorter = true,    -- override the file sorter
            case_mode = "smart_case",       -- or "ignore_case" or "respect_case"
            -- the default case_mode is "smart_case"
        },
        media_files = {
            -- filetypes whitelist
            -- defaults to {"png", "jpg", "mp4", "webm", "pdf"}
            filetypes = { "png", "webp", "jpg", "jpeg", "pdf" },
            -- find command (defaults to `fd`)
            find_cmd = "rg",
        },
    },
})

-- require("telescope").load_extension("fzf")

local builtin = require("telescope.builtin")
local opts = { noremap = true, silent = true }
local key_prefix = "<leader>r"
vim.keymap.set("n", key_prefix .. "f", builtin.find_files, opts)
vim.keymap.set("n", key_prefix .. "fg", builtin.git_files, opts)
vim.keymap.set("n", key_prefix .. "g", builtin.live_grep, opts)
vim.keymap.set("n", key_prefix .. "sg", builtin.grep_string, opts)

vim.keymap.set("n", key_prefix .. "b", builtin.buffers, opts)
vim.keymap.set("n", key_prefix .. "of", builtin.oldfiles, opts)
vim.keymap.set("n", key_prefix .. "cmd", builtin.commands, opts)
vim.keymap.set("n", key_prefix .. "ch", builtin.command_history, opts)

vim.keymap.set("n", key_prefix .. "h", builtin.help_tags, opts)
vim.keymap.set("n", key_prefix .. "mp", builtin.man_pages, opts)
vim.keymap.set("n", key_prefix .. "qf", builtin.quickfix, opts)
vim.keymap.set("n", key_prefix .. "qfh", builtin.quickfixhistory, opts)
vim.keymap.set("n", key_prefix .. "r", builtin.lsp_references, opts)

vim.keymap.set("n", key_prefix .. "eg", builtin.registers, opts)
vim.keymap.set("n", key_prefix .. "vo", builtin.vim_options, opts)
vim.keymap.set("n", key_prefix .. "s", builtin.spell_suggest, opts)

vim.keymap.set("n", key_prefix .. "km", builtin.keymaps, opts)
vim.keymap.set("n", key_prefix .. "t", builtin.filetypes, opts)
vim.keymap.set("n", key_prefix .. "ih", builtin.highlights, opts)

vim.keymap.set("n", key_prefix .. "/", builtin.current_buffer_fuzzy_find, opts)
-- vim.keymap.set("n", key_prefix .. "bt", builtin.current_buffer_tags, opts)

vim.keymap.set("n", key_prefix .. "en", function()
    require("telescope.builtin").find_files {
        cwd = vim.fn.stdpath("config")
    }
end)
