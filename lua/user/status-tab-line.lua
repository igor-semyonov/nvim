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
        saved = highlight.create_component_highlight_group(default_status_colors.saved, "filename_status_saved",
            self.options),
        modified = highlight.create_component_highlight_group(default_status_colors.modified, "filename_status_modified",
            self.options),
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

require("lualine").setup({
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
        always_show_tabline = false,
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
        lualine_b = { custom_fname },
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
