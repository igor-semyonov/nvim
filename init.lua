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
vim.api.nvim_create_autocmd("FileType", {
	pattern = {
		"rust",
		"python",
		"zig",
		"sh",
		"json",
		"docker",
		"yml",
		"yaml",
		"toml",
		"matlab",
		"nix",
	},
	callback = function()
		-- syntax highlighting, provided by Neovim
		vim.treesitter.start()
		-- folds, provided by Neovim
		vim.wo.foldexpr = "v:lua.vim.treesitter.foldexpr()"
		vim.wo.foldmethod = "expr"
		-- indentation, provided by nvim-treesitter
		vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
	end,
})

-- require("render-markdown").setup()
require("img-clip").setup()
vim.keymap.set("n", "<leader><leader>p", "<cmd>PasteImage<cr>", { desc = "Paste image from system clipboard" })

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

-- require("user.molten")

require("user.which-key")
