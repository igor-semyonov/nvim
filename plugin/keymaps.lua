local opts = { noremap = true, silent = true }
local opts_no_silent = { noremap = true, silent = false }

local send_to_tts = function(text)
	local tmp_file = vim.fn.tempname()
	vim.fn.writefile({ text }, tmp_file)

	local job_id = vim.fn.jobstart({ "sh", "-c", 'tts < "$1"; rm -f "$1"', "_", tmp_file })

	if job_id <= 0 then
		vim.notify("Failed to start background job", vim.log.levels.ERROR)
	end
end
vim.keymap.set("n", "<leader>t", function()
	local line = vim.api.nvim_get_current_line()
	send_to_tts(line)
end, { desc = "Text-to-speach Line" })
vim.keymap.set("v", "<leader>t", function()
	vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Esc>", true, false, true), "x", false)
	vim.schedule(function()
		local lines = vim.fn.getline("'<", "'>")
        vim.cmd("normal! gv")
		local selection = table.concat(lines, "\n")
		send_to_tts(selection)
	end)
end, { desc = "Text-to-speach Selection" })

-- Shorten function name
local keymap = vim.keymap.set

-- Modes
--   normal_mode = "n",
--   insert_mode = "i",
--   visual_mode = "v",
--   visual_block_mode = "x",
--   term_mode = "t",
--   command_mode = "c",

-- Normal --

-- navigate tabs
-- keymap("n", "<C-Tab>", "<cmd>tabnext<cr>", opts)
-- keymap("n", "<SC-Tab>", "<cmd>tabprevious<cr>", opts)
keymap("n", "<C-t>", "<cmd>tabnew<cr>", opts)
keymap("n", "<SC-t>", "<C-w><S-t>", opts)
keymap("n", "<A-q>", "<cmd>tabclose<cr>", opts)
keymap("n", "<A-o>", ":tabedit ", opts_no_silent)

-- Clipboard
keymap("n", "<leader>y", '"+y', opts)
keymap("n", "<leader>yy", '"+yy', opts)
keymap("n", "<leader>Y", '"+yg_', opts)
keymap("n", "<leader>p", '"+p', opts)
keymap("n", "<leader>P", '"+P', opts)

-- Resize with arrows
keymap("n", "<C-Up>", ":resize -1<CR>", opts)
keymap("n", "<C-Down>", ":resize +1<CR>", opts)
keymap("n", "<C-Left>", ":vertical resize -1<CR>", opts)
keymap("n", "<C-Right>", ":vertical resize +1<CR>", opts)

-- Move text up and down
keymap("n", "<A-j>", ":m .+1<CR>==", opts)
keymap("n", "<A-k>", ":m .-2<CR>==", opts)

-- Clear highlights
keymap("n", "<Esc>", "<cmd>nohlsearch<CR>")

-- Insert --
-- Press jk fast to exit insert mode
keymap("i", "jk", "<ESC>", opts)
keymap("i", "kj", "<ESC>", opts)

-- keymap("i", "<leader><right>", "<ESC>$a", opts)

-- Visual --
-- Clipboard
keymap("v", "<leader>y", '"+y')
keymap("v", "<leader>p", '"+p')
keymap("v", "<leader>P", '"+P')

-- Stay in indent mode
keymap("v", "<", "<gv^", opts)
keymap("v", ">", ">gv^", opts)

-- Move text up and down
keymap("v", "<A-j>", ":m '>+1<CR>gv=gv", opts)
keymap("v", "<A-k>", ":m '<-2<CR>gv=gv", opts)
keymap("v", "p", '"_dP', opts)

-- Visual Block --
-- Move text up and down
keymap("x", "J", ":m '>+1<CR>gv=gv", opts)
keymap("x", "K", ":m '<-2<CR>gv=gv", opts)
keymap("x", "<A-j>", ":m '>+1<CR>gv=gv", opts)
keymap("x", "<A-k>", ":m '<-2<CR>gv=gv", opts)

-- Better window/buffer navigation
-- keymap("n", "<C-h>", "<C-w>h", opts)
-- keymap("n", "<C-j>", "<C-w>j", opts)
-- keymap("n", "<C-k>", "<C-w>k", opts)
-- keymap("n", "<C-l>", "<C-w>l", opts)
for _, m in pairs({ "t", "i" }) do
	-- local term_opts = { silent = true }
	--     keymap(m, "<C-h>", "<C-\\><C-N><C-w>h", term_opts)
	--     keymap(m, "<C-j>", "<C-\\><C-N><C-w>j", term_opts)
	--     keymap(m, "<C-k>", "<C-\\><C-N><C-w>k", term_opts)
	--     keymap(m, "<C-l>", "<C-\\><C-N><C-w>l", term_opts)
	keymap(m, "<A-h>", "<C-\\><C-N>:bprev<CR>")
	keymap(m, "<A-l>", "<C-\\><C-N>:bnext<CR>")
	-- keymap(m, "<A-q>", "<C-\\><C-N>:bd #<CR>")
end

-- Navigate buffers
keymap("n", "<leader>bl", ":ls<CR>", opts)
keymap("n", "<A-l>", ":bnext<CR>", opts)
keymap("n", "<A-h>", ":bprevious<CR>", opts)
keymap("n", "<leader><Right>", ":bnext<CR>", opts)
keymap("n", "<leader><Left>", ":bprevious<CR>", opts)
keymap("n", "<leader>q", ":bd<CR>", opts)
keymap("n", "<leader>Q", ":bd!<CR>", opts)
-- keymap("n", "<A-q>", ":bd #<CR>", opts)
keymap("n", "<leader>o", ":ed ", opts_no_silent)
keymap("n", "<leader>s", ":w<CR>", opts)

-- quickfix
QF_KEY = "<leader>w"
QF_KEYMAP = function(lhs, rhs, desc)
	keymap("n", QF_KEY .. lhs, rhs, { noremap = true, desc = desc })
end
QF_KEYMAP("o", ":5copen<CR>", "Open quickfix list")
QF_KEYMAP("q", ":cclose<CR>", "Close quickfix list")
QF_KEYMAP("n", ":cnext<CR>", "Next quickfix item")
QF_KEYMAP("p", ":cprev<CR>", "Previous quickfix item")
QF_KEYMAP("d", ":cdo ", "Quickfix do")
