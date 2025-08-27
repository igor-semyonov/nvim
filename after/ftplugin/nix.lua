vim.bo.shiftwidth = 2
vim.bo.tabstop = 2

local opt = vim.opt
opt.listchars:append({
	leadmultispace = "│ ",
})
