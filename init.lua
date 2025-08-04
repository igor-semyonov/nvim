-- recommended by nvim-tree
-- disable netrw at the very start of your init.lua (strongly advised)
-- vim.g.loaded_netrw = 0
-- vim.g.loaded_netrwPlugin = 0

--Remap space as leader key
vim.keymap.set("", "<Space>", "<Nop>", opts)
vim.g.mapleader = " "
-- vim.g.maplocalleader = vim.api.nvim_replace_termcodes('<BS>', false, false, true)
vim.g.maplocalleader = ","

local plugins_dir = vim.fs.joinpath(vim.fn.stdpath("config"),
    "lua/user/plugins"
)
local plugins_tbl = vim.fn.glob(plugins_dir .. "/*.lua")
vim.print(plugins_tbl)
