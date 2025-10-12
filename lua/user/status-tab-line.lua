local custom_fname = require("lualine.components.filename"):extend()
local highlight = require("lualine.highlight")
local default_status_colors = {
	saved = {
		bg = "#353535",
		fg = "#20FF20",
	},
	modified = {
		bg = "#502899",
		fg = "#B0FF60",
	},
}

function custom_fname:init(options)
	custom_fname.super.init(self, options)
	self.status_colors = {
		saved = highlight.create_component_highlight_group(
			default_status_colors.saved,
			"filename_status_saved",
			self.options
		),
		modified = highlight.create_component_highlight_group(
			default_status_colors.modified,
			"filename_status_modified",
			self.options
		),
	}
	if self.options.color == nil then
		self.options.color = ""
	end
end

function custom_fname:update_status()
	local data = custom_fname.super.update_status(self)
	data = highlight.component_format_highlight(
		vim.bo.modified and self.status_colors.modified or self.status_colors.saved
	) .. data
	return data
end

local lualine = require("lualine")
vim.opt.showtabline = 1
vim.opt.laststatus = 2
lualine.setup({
	options = {
		icons_enabled = true,
		theme = "powerline",
		component_separators = { left = "", right = "" },
		section_separators = { left = "", right = "" },
		disabled_filetypes = {
			statusline = {},
			winbar = {},
		},
		ignore_focus = {},
		always_divide_middle = true,
		always_show_tabline = true,
		globalstatus = true,
		refresh = {
			statusline = 200,
			tabline = 200,
			winbar = 200,
		},
	},
	sections = {
		lualine_a = {
			{
				"mode",
				fmt = function(str)
					return str:sub(1, 3)
				end,
			},
		},
		lualine_b = {
			custom_fname,
            {
                function()
                    local reg = vim.fn.reg_recording()
                    if reg ~= "" then
                        return "Recording @" .. reg
                    else
                        return "" -- Return an empty string if not recording
                    end
                end,
                color = {
                    bg = "blue",
                    fg = "red",
                    gui = "bold",
                },
            },
		},
		lualine_c = { "diagnostics" },
		-- lualine_c = { "os.date('%a')", "data", "require'lsp-status'.status()" },
		lualine_x = { "searchcount", "encoding", "filetype" },
		lualine_y = { "progress" },
		lualine_z = { "location" },
	},
	inactive_sections = {
		lualine_a = {},
		lualine_b = {},
		lualine_c = {},
		lualine_x = {},
		lualine_y = {},
		lualine_z = {},
	},
	tabline = {
		lualine_a = {
			"tabs",
		},
		lualine_b = { "buffers" },
		lualine_y = {
			"diff",
		},
		lualine_z = {
			"branch",
		},
	},
	winbar = {
		lualine_a = {},
	},
	inactive_winbar = {},
	extensions = {},
})

vim.g.lualine_statusline_visible = true
vim.g.lualine_tabline_visible = true

local function toggle_statusline()
	if vim.g.lualine_statusline_visible then
		lualine.hide({
			place = { "statusline" },
		})
		vim.opt.laststatus = 0
		vim.g.lualine_statusline_visible = false
	else
		lualine.hide({
			place = { "statusline" },
			unhide = true,
		})
		vim.opt.laststatus = 3
		vim.g.lualine_statusline_visible = true
	end
end
local function toggle_tabline()
	if vim.g.lualine_tabline_visible then
		lualine.hide({
			place = { "tabline" },
		})
		vim.opt.showtabline = 0
		vim.g.lualine_tabline_visible = false
	else
		lualine.hide({
			place = { "tabline" },
			unhide = true,
		})
		vim.opt.showtabline = 2
		vim.g.lualine_tabline_visible = true
	end
end
local function toggle_cmdheight()
	if vim.opt.cmdheight._value == 0 then
		vim.opt.cmdheight = vim.v.count == 0 and 1 or vim.v.count
	else
		vim.opt.cmdheight = vim.v.count == 0 and 0 or vim.v.count
	end
end

vim.keymap.set("n", "<leader>vs", toggle_statusline, { desc = "Toggle lualine statusline", silent = true })
vim.keymap.set("n", "<leader>vt", toggle_tabline, { desc = "Toggle lualine tabline", silent = true })
vim.keymap.set("n", "<leader>vc", toggle_cmdheight, { desc = "Change/toggle cmdheight", silent = true })

toggle_tabline()
