local cmp_status_ok, cmp = pcall(require, "cmp")
if not cmp_status_ok then
	return
end

local snip_status_ok, ls = pcall(require, "luasnip")
if not snip_status_ok then
	return
end

local lspkind = require("lspkind")
lspkind.init({
	-- defines how annotations are shown
	-- default: symbol
	-- options: 'text', 'text_symbol', 'symbol_text', 'symbol'
	mode = "symbol_text",

	-- default symbol map
	-- can be either 'default' (requires nerd-fonts font) or
	-- 'codicons' for codicon preset (requires vscode-codicons font)
	--
	-- default: 'default'
	-- preset = "codicons",
	preset = "default",

	-- override preset symbols
	--
	-- default: {}
	symbol_map = {
		Text = "󰉿",
		Method = "󰆧",
		Function = "󰊕",
		Constructor = "",
		Field = "󰜢",
		Variable = "󰀫",
		Class = "󰠱",
		Interface = "",
		Module = "",
		Property = "󰜢",
		Unit = "󰑭",
		Value = "󰎠",
		Enum = "",
		Keyword = "󰌋",
		Snippet = "",
		Color = "󰏘",
		File = "󰈙",
		Reference = "󰈇",
		Folder = "󰉋",
		EnumMember = "",
		Constant = "󰏿",
		Struct = "󰙅",
		Event = "",
		Operator = "󰆕",
		TypeParameter = "",
	},
})

require("luasnip/loaders/from_vscode").lazy_load()

local check_backspace = function()
	local col = vim.fn.col(".") - 1
	return col == 0 or vim.fn.getline("."):sub(col, col):match("%s")
end

local kind_icons = {
	Text = "󰉿",
	Method = "󰆧",
	Function = "󰊕",
	Constructor = "",
	Field = " ",
	Variable = "󰀫",
	Class = "󰠱",
	Interface = "",
	Module = "",
	Property = "󰜢",
	Unit = "󰑭",
	Value = "󰎠",
	Enum = "",
	Keyword = "󰌋",
	Snippet = "",
	Color = "󰏘",
	File = "󰈙",
	Reference = "",
	Folder = "󰉋",
	EnumMember = "",
	Constant = "󰏿",
	Struct = "",
	Event = "",
	Operator = "󰆕",
	TypeParameter = " ",
	Misc = " ",
}
-- find more here: https://www.nerdfonts.com/cheat-sheet

cmp.setup({
	snippet = {
		expand = function(args)
			ls.lsp_expand(args.body) -- For `luasnip` users.
		end,
	},
	-- window = {
	--     documentation = {
	--         border = { "╭", "─", "╮", "│", "╯", "─", "╰", "│" },
	--     },
	-- },
	window = {
		completion = vim.tbl_extend(
			"keep",
			{ border = "rounded", col_offset = 0 },
			cmp.config.window.bordered("double")
		),
		documentation = vim.tbl_extend(
			"keep",
			{ border = "rounded", max_width = 40, max_height = 7 },
			cmp.config.window.bordered()
		),
	},
	mapping = {
		-- ["<CR>"] = cmp.mapping.confirm({ select = false }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
		["<leader><CR>"] = cmp.mapping.confirm({ select = true }),
		["<C-Space>"] = cmp.mapping(cmp.mapping.complete(), { "i", "c" }),
		["<C-k>"] = cmp.mapping.select_prev_item(),
		["<C-j>"] = cmp.mapping.select_next_item(),
		["<C-e>"] = cmp.mapping(cmp.mapping.scroll_docs(-1), { "i", "c" }),
		["<C-n>"] = cmp.mapping(cmp.mapping.scroll_docs(1), { "i", "c" }),
		["<C-y>"] = cmp.config.disable, -- Specify `cmp.config.disable` if you want to remove the default `<C-y>` mapping.
		["<C-h>"] = cmp.mapping({
			i = cmp.mapping.abort(), -- insert mode
			c = cmp.mapping.close(), -- command mode
		}),
		["<Tab>"] = cmp.mapping(function(fallback)
			if cmp.visible() then
				cmp.select_next_item()
			elseif ls.expandable() then
				ls.expand()
			elseif ls.expand_or_jumpable() then
				ls.expand_or_jump()
			elseif check_backspace() then
				fallback()
			else
				fallback()
			end
		end, {
			"i",
			"s",
		}),
		["<S-Tab>"] = cmp.mapping(function(fallback)
			if cmp.visible() then
				cmp.select_prev_item()
			elseif ls.jumpable(-1) then
				ls.jump(-1)
			else
				fallback()
			end
		end, {
			"i",
			"s",
		}),
	},
	view = {
		entries = "custom", -- can be "custom", "wildmenu" or "native"
	},
	-- formatting = {
	--     fields = { "kind", "abbr", "menu" },
	--     format = function(entry, vim_item)
	--         -- Kind icons
	--         vim_item.kind = string.format("%s", kind_icons[vim_item.kind])
	--         -- vim_item.kind = string.format('%s %s', kind_icons[vim_item.kind], vim_item.kind) -- This concatonates the icons with the name of the item kind
	--         vim_item.menu = ({
	--             -- nvim_lsp_signature_help = "Sig",
	--             nvim_lsp = "[LSP]",
	--             calc = "Calc",
	--             nvim_lua = "nvim",
	--             buffer = "[Buffer]",
	--             path = "[Path]",
	--             luasnip = "[Snippet]",
	--         })[entry.source.name]
	--         return vim_item
	--     end,
	-- },
	formatting = {
		expandable_indicator = true,
		-- fields = { "kind", "abbr", "menu" },
		-- fields = { "abbr", "icon", "kind", "menu" },
		fields = { "icon", "abbr", "menu" },
		format = lspkind.cmp_format({
			mode = "symbol",
			menu = {
				buffer = "[Buf]",
				nvim_lsp = "[LSP]",
				luasnip = "[Snip]",
				nvim_lua = "[Lua]",
				latex_symbols = "[LTX]",
			},
			maxwidth = {
				-- prevent the popup from showing more than provided characters (e.g 50 will not show more than 50 characters)
				-- can also be a function to dynamically calculate max width such as
				-- menu = function() return math.floor(0.45 * vim.o.columns) end,
				menu = 8, -- leading text (labelDetails)
				abbr = 20, -- actual suggestion item
			},
			ellipsis_char = "…", -- when popup menu exceed maxwidth, the truncated part would show ellipsis_char instead (must define maxwidth first)
			-- show_labelDetails = true, -- show labelDetails in menu. Disabled by default

			-- The function below will be called before any actual modifications from lspkind
			-- so that you can provide more controls on popup customization. (See [#30](https://github.com/onsails/lspkind-nvim/pull/30))
			before = function(entry, vim_item)
				-- ...
				return vim_item
			end,
		}),
	},
	sources = {
		{ name = "nvim_lsp" },
		{ name = "nvim_lua" },
        { name = "path" },
		{ name = "luasnip" },
		{ name = "buffer" },
		{ name = "nvim_lsp_signature_help" }, -- display function signatures with current parameter emphasized
		{ name = "calc" },
	},
	confirm_opts = {
		behavior = cmp.ConfirmBehavior.Replace,
		select = false,
	},
	experimental = {
		ghost_text = false,
		native_menu = false,
	},
})
vim.keymap.set("i", "<leader><cr>", cmp.mapping.confirm({ select = true }))
