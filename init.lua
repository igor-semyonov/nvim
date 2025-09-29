-- recommended by nvim-tree
-- disable netrw at the very start of your init.lua (strongly advised)
-- vim.g.loaded_netrw = 0
-- vim.g.loaded_netrwPlugin = 0

--Remap space as leader key
vim.keymap.set("", "<Space>", "<Nop>", opts)
vim.g.mapleader = " "
-- vim.g.maplocalleader = vim.api.nvim_replace_termcodes('<BS>', false, false, true)
vim.g.maplocalleader = ","

require("user.colors")
require("user.status-tab-line")
require("user.completion")
require("user.rainbow-delim")
require("user.file-manager")
require("user.vimtex")
require("user.ufo")

vim.g.NERDCreateDefaultMappings = 1
vim.g.NERDSpaceDelims = 1
vim.g.NERDCompactSexyComs = 1
vim.g.NERDDefaultAlign = "left"

require("user.git")
require("user.telescope")

local ts_update = require("nvim-treesitter.install").update({ with_sync = true })
-- ts_update() -- not needed since treesitter parsers are  managed by nix
require("nvim-treesitter.configs").setup({
	highlight = {
		enable = true,
		additional_vim_regex_highlighting = false,
	},
	indent = { enable = true },
	-- rainbow = {
	--     enable = true,
	--     extended_mode = true,
	--     max_file_lines = nil,
	-- }
})

require("user.lsp")

local keys = {
	{ "<c-h>", "<cmd><C-U>TmuxNavigateLeft<cr>", "Tmux Move Left" },
	{ "<c-j>", "<cmd><C-U>TmuxNavigateDown<cr>", "Tmux Move Down" },
	{ "<c-k>", "<cmd><C-U>TmuxNavigateUp<cr>", "Tmux Move Up" },
	{ "<c-l>", "<cmd><C-U>TmuxNavigateRight<cr>", "Tmux Move Right" },
	{ "<c-\\>", "<cmd><C-U>TmuxNavigatePrevious<cr>", "Tmux Move Previous" },
}
for _, k in ipairs(keys) do
	vim.keymap.set("n", k[1], k[2], { desc = k[3] })
end

require("user.which-key")
