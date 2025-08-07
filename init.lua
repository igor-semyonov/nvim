-- recommended by nvim-tree
-- disable netrw at the very start of your init.lua (strongly advised)
-- vim.g.loaded_netrw = 0
-- vim.g.loaded_netrwPlugin = 0

--Remap space as leader key
vim.keymap.set("", "<Space>", "<Nop>", opts)
vim.g.mapleader = " "
-- vim.g.maplocalleader = vim.api.nvim_replace_termcodes('<BS>', false, false, true)
vim.g.maplocalleader = ","

local plugins_dir = "lua/user/plugins"
local plugins_tbl = vim.fn.split(vim.fn.glob(plugins_dir .. "/*.lua"), "\n")


local function process_plugin(spec)
    if spec.enabled == false then
        return
    end

    if spec.config ~= nil then
        print(type(spec.config))
    elseif spec.opts ~= nil then
        print(type(spec.config))
    end
end

local plugin = string.sub(plugins_tbl[1], 5)
local plugin = string.gsub(plugin, "/", ".")
local plugin = string.sub(plugin, 0, #plugin - 4)
local plugin = require(plugin)

-- for _, plugin_spec in ipairs(plugin)do
--     process_plugin(plugin_spec)
-- end

require("user.colors")
require("user.status-tab-line")
require("user.completion")
require("user.rainbow-delim")
require("user.file-manager")
require("user.vimtex")
