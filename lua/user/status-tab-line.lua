local custom_fname = require("lualine.components.filename"):extend()
local highlight = require("lualine.highlight")

-- Shared palette. Backgrounds are pure black by default; "unsaved" state uses
-- bright orange for high contrast against the dark foreground.
local colors = {
	fg_active = "#EEEEEE", -- bright fg for selected / focused text
	fg_inactive = "#8FA8C8", -- dimmer (but still legible) fg for unselected tabs
	black = "#000000",
	filetype_bg = "#303030", -- keep filetype at its previous default-ish gray
	tab_sel = "#E64DFF", -- selected, unmodified tab number: bright vivid purple
	tab_unsel_fg = "#FF7AD9", -- unselected, unmodified tab number fg: bright pink

	-- unsaved state: bright green, paired with a dark fg for high contrast
	-- against the bright background.
	modified_fg = "#000000",
	modified_stl = "#80FF80", -- statusline filename when the buffer is unsaved
	modified_sel = "#80FF80", -- selected tab, unsaved: full bright green
	modified_unsel = "#3F8F3F", -- unselected tab, unsaved: dimmer
}

local default_status_colors = {
	saved = {
		bg = colors.black,
		fg = colors.fg_active,
	},
	modified = {
		bg = colors.modified_stl,
		fg = colors.modified_fg,
	},
}

-- Truncate a filename to a fixed width: keep the first 9 chars of the stem,
-- then a single-char ellipsis, then the extension (itself capped at 4 chars).
-- "longnixfilename.nix" -> "longnixfi…nix". Only the final dot-segment counts
-- as the extension, so "archive.tar.gz" has stem "archive.tar" and ext "gz",
-- yielding "archive.t…gz". Trailing status markers (e.g. the readonly "[-]")
-- and any trailing whitespace are preserved untouched.
local function truncate_fname(str)
	local base, suffix = str:match("^(.-)(%s*%[[^%]]*%]%s*)$")
	if not base then
		base = str:gsub("%s+$", "")
		suffix = str:sub(#base + 1)
	end
	local stem, ext = base:match("^(.*)%.([^%.]+)$")
	if stem and ext then
		ext = vim.fn.strcharpart(ext, 0, 4)
		if vim.fn.strchars(stem) > 9 then
			-- truncated: ellipsis replaces the dot -> "longnixfi…nix"
			base = vim.fn.strcharpart(stem, 0, 9) .. "…" .. ext
		else
			-- short stem: keep the dot -> "short.nix"
			base = stem .. "." .. ext
		end
	elseif vim.fn.strchars(base) > 9 then
		base = vim.fn.strcharpart(base, 0, 9) .. "…"
	end
	return base .. suffix
end

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
	-- the background color already signals modified state, so drop the "[+]" marker
	self.options.symbols = vim.tbl_deep_extend("force", self.options.symbols or {}, { modified = "" })
end

function custom_fname:update_status()
	local data = truncate_fname(custom_fname.super.update_status(self))
	data = highlight.component_format_highlight(
		vim.bo.modified and self.status_colors.modified or self.status_colors.saved
	) .. data
	return data
end

-- Custom tabline "buffers" component: each buffer entry colors itself from its
-- own modified state. Saved buffers keep the default (theme) look; unsaved ones
-- turn blue -- more saturated when selected, less when not -- mirroring how the
-- statusline filename reacts.
local Buffer = require("lualine.components.buffers.buffer")
local CustomBuffer = Buffer:extend()

function CustomBuffer:render()
	local name = truncate_fname(self:name())
	if self.options.fmt then
		name = self.options.fmt(name or "", self)
	end
	if self.ellipse then
		name = "..."
	else
		name = self:apply_mode(name)
	end
	name = Buffer.apply_padding(name, self.options.padding)
	self.len = vim.fn.strchars(name)

	local line = self:configure_mouse_click(name)

	-- pick highlight from (selected?, modified?)
	local modified = self.options.show_modified_status and vim.api.nvim_buf_get_option(self.bufnr, "modified")
	local key
	if self.current then
		key = modified and "active_modified" or "active"
	else
		key = modified and "inactive_modified" or "inactive"
	end
	line = highlight.component_format_highlight(self.highlights[key]) .. line

	if self.options.self.section < "x" and not self.first then
		local sep_before = self:separator_before()
		line = sep_before .. line
		self.len = self.len + vim.fn.strchars(sep_before)
	elseif self.options.self.section >= "x" and not self.last then
		local sep_after = self:separator_after()
		line = line .. sep_after
		self.len = self.len + vim.fn.strchars(sep_after)
	end
	return line
end

local custom_buffers = require("lualine.components.buffers"):extend()

function custom_buffers:init(options)
	options = options or {}
	-- force the parent to build its default active/inactive highlights
	options.component_name = "buffers"
	-- the background color already signals modified state, so drop the "●" marker
	options.symbols = vim.tbl_deep_extend("force", options.symbols or {}, { modified = "" })
	custom_buffers.super.init(self, options)
	-- unmodified buffers sit on black; selected gets bright fg, unselected dimmer
	self.highlights.active = self:create_hl({ fg = colors.fg_active, bg = colors.black }, "active")
	self.highlights.inactive = self:create_hl({ fg = colors.fg_inactive, bg = colors.black }, "inactive")
	-- add the "unsaved" variants
	self.highlights.active_modified =
		self:create_hl({ fg = colors.modified_fg, bg = colors.modified_sel }, "active_modified")
	self.highlights.inactive_modified =
		self:create_hl({ fg = colors.fg_active, bg = colors.modified_unsel }, "inactive_modified")
end

function custom_buffers:new_buffer(bufnr, buf_index)
	bufnr = bufnr or vim.api.nvim_get_current_buf()
	buf_index = buf_index or ""
	return CustomBuffer:new({
		bufnr = bufnr,
		buf_index = buf_index,
		options = self.options,
		highlights = self.highlights,
	})
end

-- Custom tabline "tabs" component: the tab NUMBER follows the same
-- modified/selected scheme as the buffer entries. Unmodified -> selected is
-- purple, unselected is black. Modified -> the green modified colors (selected
-- brighter, unselected dimmer), mirroring the buffer entries.
local Tab = require("lualine.components.tabs.tab")

-- shorten_path is local to tabs/tab.lua; copied here so the reimplemented
-- render below behaves identically for non-default tab modes.
local function shorten_path(path, sep, max_len)
	local len = #path
	if len <= max_len then
		return path
	end
	local segments = vim.split(path, sep)
	for idx = 1, #segments - 1 do
		if len <= max_len then
			break
		end
		local segment = segments[idx]
		local shortened = segment:sub(1, vim.startswith(segment, ".") and 2 or 1)
		segments[idx] = shortened
		len = len - (#segment - #shortened)
	end
	return table.concat(segments, sep)
end

-- is any buffer displayed in this tab modified?
local function tab_is_modified(tabnr)
	for _, b in ipairs(vim.fn.tabpagebuflist(tabnr)) do
		if vim.api.nvim_buf_get_option(b, "modified") then
			return true
		end
	end
	return false
end

function Tab:render()
	local name = self:label()
	if self.options.tab_max_length ~= 0 then
		name = shorten_path(name, package.config:sub(1, 1), self.options.tab_max_length)
	end
	if self.options.fmt then
		name = self.options.fmt(name or "", self)
	end
	if self.ellipse then
		name = "..."
	elseif self.options.mode == 0 then
		name = tostring(self.tabnr)
	elseif self.options.mode == 1 then
		-- name only
	else
		name = string.format("%s %s", tostring(self.tabnr), name)
	end

	name = Tab.apply_padding(name, self.options.padding)
	self.len = vim.fn.strchars(name)

	local line = string.format("%%%s@LualineSwitchTab@%s%%T", self.tabnr, name)

	-- pick highlight from (selected?, modified?)
	local modified = self.options.show_modified_status and tab_is_modified(self.tabnr)
	local key
	if self.current then
		key = modified and "active_modified" or "active"
	else
		key = modified and "inactive_modified" or "inactive"
	end
	line = highlight.component_format_highlight(self.highlights[key]) .. line

	if self.options.self.section < "x" and not self.first then
		local sep_before = self:separator_before()
		line = sep_before .. line
		self.len = self.len + vim.fn.strchars(sep_before)
	elseif self.options.self.section >= "x" and not self.last then
		local sep_after = self:separator_after()
		line = line .. sep_after
		self.len = self.len + vim.fn.strchars(sep_after)
	end
	return line
end

local custom_tabs = require("lualine.components.tabs"):extend()

function custom_tabs:init(options)
	options = options or {}
	options.component_name = "tabs"
	-- the background color signals modified state; no "[+]" marker on the number
	options.symbols = vim.tbl_deep_extend("force", options.symbols or {}, { modified = "" })
	custom_tabs.super.init(self, options)
	-- tab number fg is black everywhere except unselected+unmodified (dim fg on black)
	-- unmodified: selected -> bright purple, unselected -> black
	self.highlights.active = self:create_hl({ fg = colors.black, bg = colors.tab_sel }, "active")
	self.highlights.inactive = self:create_hl({ fg = colors.tab_unsel_fg, bg = colors.black }, "inactive")
	-- modified: follow the green modified colors
	self.highlights.active_modified =
		self:create_hl({ fg = colors.black, bg = colors.modified_sel }, "active_modified")
	self.highlights.inactive_modified =
		self:create_hl({ fg = colors.black, bg = colors.modified_unsel }, "inactive_modified")
end

-- Base theme with the `c` group (both statusline & tabline interstitial fills,
-- plus diagnostics/searchcount/encoding) forced to solid black. `a` (mode) and
-- `b` (progress) keep their mode-reactive theme colors.
local theme = vim.deepcopy(require("lualine.themes.powerline"))
for _, mode_colors in pairs(theme) do
	if mode_colors.c then
		mode_colors.c = { fg = colors.fg_active, bg = colors.black }
	end
end

local lualine = require("lualine")
vim.opt.showtabline = 1
vim.opt.laststatus = 2
lualine.setup({
	options = {
		icons_enabled = true,
		theme = theme,
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
		lualine_x = {
			"searchcount",
			"encoding",
			-- keep filetype on its previous default gray background
			{ "filetype", color = { fg = colors.fg_active, bg = colors.filetype_bg } },
		},
		lualine_y = { "progress" },
		lualine_z = {
			-- "the rest" -> black, not the bright mode color
			{ "location", color = { fg = colors.fg_active, bg = colors.black } },
		},
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
			custom_tabs,
		},
		lualine_b = { custom_buffers },
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
