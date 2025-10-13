local opt = vim.opt
local cmd = vim.cmd
local api = vim.api
local nvim_create_autocmd = api.nvim_create_autocmd
local nvim_set_hl = api.nvim_set_hl

local options = {
	backup = false, -- creates a backup file
	-- clipboard = "unnamedplus",               -- allows neovim to access the system clipboard
	cmdheight = 1, -- more space in the neovim command line for displaying messages
	completeopt = { "menuone", "noselect", "noinsert", "preview" }, -- mostly just for cmp
	conceallevel = 0, -- so that `` is visible in markdown files
	fileencoding = "utf-8", -- the encoding written to a file
	hlsearch = true, -- highlight all matches on previous search pattern
	ignorecase = true, -- ignore case in search patterns
	smartcase = true, -- smart case
	mouse = "", -- allow the mouse to be used in neovim
	pumheight = 6, -- pop up menu height
	showmode = false, -- we don't need to see things like -- INSERT -- anymore
	autoindent = true,
	smartindent = true, -- make indenting smarter again
	splitbelow = true, -- force all horizontal splits to go below current window
	splitright = true, -- force all vertical splits to go to the right of current window
	swapfile = false, -- creates a swapfile
	termguicolors = true, -- set term gui colors (most terminals support this)
	timeoutlen = 500, -- time to wait for a mapped sequence to complete (in milliseconds)
	undofile = true, -- enable persistent undo
	updatetime = 200, -- faster completion (4000ms default)
	writebackup = false, -- if a file is being edited by another program (or was written to file while editing with another program), it is not allowed to be edited
	expandtab = true, -- convert tabs to spaces
	shiftwidth = 4, -- the number of spaces inserted for each indentation
	tabstop = 4, -- insert 2 spaces for a tab
	-- softtabstop = 4,
	cursorline = true, -- highlight the current line
	cursorcolumn = true, -- highlight the current line
	number = true, -- set numbered lines
	relativenumber = true, -- set relative numbered lines
	numberwidth = 2, -- set number column width to 2 {default 4}
	inccommand = "split",

	signcolumn = "yes", -- always show the sign column, otherwise it would shift the text each time
	wrap = true, -- display lines as one long line
	linebreak = false, -- companion to wrap, don't split words
	scrolloff = 2, -- minimal number of screen lines to keep above and below the cursor
	sidescrolloff = 6, -- minimal number of screen columns either side of cursor if wrap is `false`
	guifont = "monospace:h17", -- the font used in graphical neovim applications
	-- whichwrap = "bs<>[]hl",                  -- which "horizontal" keys are allowed to travel to prev/next line
	guicursor = { "a:block-Cursor", "i:blinkon250", "a:blinkoff100" },
	hidden = true,
	spelllang = "en",
	spellfile = vim.fn.stdpath("config") .. "/spell/en.utf-8.add",
}
for k, v in pairs(options) do
	opt[k] = v
end

vim.api.nvim_create_autocmd({ "BufEnter", "BufFilePost", "BufNewFile", "BufRead" }, {
	pattern = { "*.md", "*.tex" },
	callback = function()
		vim.opt_local.spelllang = en_us
		-- vim.opt_local.spell = true
	end,
})
vim.api.nvim_create_autocmd("TextYankPost", {
	desc = "Highlight when yanking (copying) text",
	group = vim.api.nvim_create_augroup("kickstart-highlight-yank", { clear = true }),
	callback = function()
		vim.highlight.on_yank({
			timeout = 300,
		})
	end,
})

-- vim.opt.shortmess = "ilmnrx"                        -- flags to shorten vim messages, see :help 'shortmess'
opt.shortmess:append("c") -- don't give |ins-completion-menu| messages
opt.iskeyword:append("-") -- hyphenated words recognized by searches
opt.formatoptions:remove({ "c", "r", "o" }) -- don't insert the current comment leader automatically for auto-wrapping comments using 'textwidth', hitting <Enter> in insert mode, or hitting 'o' or 'O' in normal mode.
opt.runtimepath:remove("/usr/share/vim/vimfiles") -- separate vim plugins from neovim in case vim still in use

-- reopen at last line

nvim_create_autocmd({ "BufReadPost" }, {
	pattern = { "*" },
	callback = function()
		if vim.fn.line("'\"") > 1 and vim.fn.line("'\"") <= vim.fn.line("$") then
			vim.api.nvim_command("normal! g'\"")
		end
	end,
})

opt.list = true
local space = "☠"

opt.listchars:append({
	eol = "↲",
	tab = "│ ",
	leadmultispace = "│   ",
	-- multispace = space,
	trail = space,
	-- nbsp = space
})

cmd([[match TrailingWhitespace /\s\+$/]])

nvim_set_hl(0, "TrailingWhitespace", { link = "Error" })

nvim_create_autocmd("InsertEnter", {
	callback = function()
		opt.listchars.trail = nil
		nvim_set_hl(0, "TrailingWhitespace", { link = "Whitespace" })
	end,
})

nvim_create_autocmd("InsertLeave", {
	callback = function()
		opt.listchars.trail = space
		nvim_set_hl(0, "TrailingWhitespace", { link = "Error" })
	end,
})

-- Set the char for the indent line
-- vim.g.indentline_char = "|"
--     -- By default I am using space style indentation and 2 spaces for it
--     -- vim.o.listchars = "trail:•,extends:#,nbsp:.,precedes:❮,extends:❯,tab:› ,leadmultispace:"
--     .. vim.g.indentline_char
--     .. "  "

-- -- I am using tab and leadmultispace in listchars to display the indent line. The chars for tab and
-- -- leadmultispace should be updated based on whether the indentation has been changed.
-- -- * If using space as indentation: set tab to a special character for denotation and leadmultispace
-- -- to the indent line character followed by multiple spaces whose amounts depends on the number of
-- -- spaces to use in each step of indent.
-- -- * If using tab as indentation: set leadmultispace to a special character for denotation and tab
-- -- to the indent line character.
-- local function update_indent_char(is_local)
--     local listchars_update = function(items)
--         local listchars = vim.api.nvim_get_option_value("listchars", {})
--         for item, val in pairs(items) do
--             if listchars:match(item) then
--                 listchars = listchars:gsub("(" .. item .. ":)[^,]*", "%1" .. val)
--             else
--                 listchars = listchars .. "," .. item .. ":" .. val
--             end
--         end
--         return listchars
--     end
--     local new_listchars = ""
--     if vim.api.nvim_get_option_value("expandtab", {}) then
--         local spaces = vim.api.nvim_get_option_value("shiftwidth", {})
--         -- When shiftwidth is 0, vim will use tabstop value
--         if spaces == 0 then
--             spaces = vim.api.nvim_get_option_value("tabstop", {})
--         end
--         new_listchars = listchars_update({
--             tab = "› ",
--             leadmultispace = vim.g.indentline_char .. string.rep(" ", spaces - 1),
--         })
--     else
--         new_listchars = listchars_update({
--             tab = vim.g.indentline_char .. " ",
--             leadmultispace = "␣",
--         })
--     end
--     local opts = {}
--     if is_local then
--         opts.scope = "local"
--     end
--     vim.api.nvim_set_option_value("listchars", new_listchars, opts)
-- end

-- vim.api.nvim_create_augroup("indent_line", { clear = true })
-- vim.api.nvim_create_autocmd({ "OptionSet" }, {
--     group = "indent_line",
--     pattern = { "shiftwidth", "expandtab", "tabstop" },
--     callback = function()
--         update_indent_char(vim.v.option_type == "local")
--     end,
-- })
-- -- OptionSet is not triggered on startup
-- -- This may be not needed. The listchars has been set properly in options.vim and it will be sourced
-- -- on startup.
-- vim.api.nvim_create_autocmd({ "VimEnter" }, {
--     group = "indent_line",
--     callback = function()
--         update_indent_char(false)
--     end,
-- })
