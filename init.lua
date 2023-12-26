vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
	vim.fn.system({
		"git",
		"clone",
		"--filter=blob:none",
		"https://github.com/folke/lazy.nvim.git",
		"--branch=stable", -- latest stable release
		lazypath,
	})
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup({
	{
		'rose-pine/neovim',
		name = 'rose-pine'
	},
	{
		'neovim/nvim-lspconfig'
	}, -- gd lsp	
	{
		'nvim-treesitter/nvim-treesitter',
		build = ':TSUpdate'
	},
	{
		'akinsho/bufferline.nvim',
		version = "*",
		dependencies = 'nvim-tree/nvim-web-devicons'
	}, -- tab list
	{
		"folke/which-key.nvim",
		event = "VeryLazy",
		init = function()
		vim.o.timeout = true
		vim.o.timeoutlen = 300
		end,
		opts = {
			-- your configuration comes here
			-- or leave it empty to use the default settings
			-- refer to the configuration section below
		}
	}, -- popup with keybinds
	{
		'stevearc/stickybuf.nvim',
		opts = {},
	}, -- stickybuf fixes opening stuff in the wrong buffer
	{
		'stevearc/aerial.nvim',
		opts = {},
		-- Optional dependencies
		dependencies = {
			"nvim-treesitter/nvim-treesitter",
			"nvim-tree/nvim-web-devicons"
		},
	}, -- lets you browse all declared functions in a side pane
	{
		'nvim-tree/nvim-tree.lua',
	},
	{
		"lukas-reineke/indent-blankline.nvim", 
		main = "ibl", 
		opts = {}, 
	}, -- indent highlighting
	{
		'HiPhish/rainbow-delimiters.nvim',
	}, -- colors delimiters based on scope
	{
		'nvim-lualine/lualine.nvim',
		dependencies = { 
			'nvim-tree/nvim-web-devicons'
		},
	}, -- luwualine ;3
	{
		'echasnovski/mini.indentscope',
		version = '*'
	}, -- changes indent based on scope TODO too slow also ugly
	{
		'mvllow/modes.nvim',
		tag = 'v0.2.0',
		config = function()
			require('modes').setup()
		end
	}, -- changes line color based on mode
	{
		"NeogitOrg/neogit",
		dependencies = {
			"nvim-lua/plenary.nvim",         -- required
			"sindrets/diffview.nvim",        -- optional - Diff integration
			-- Only one of these is needed, not both.
			"nvim-telescope/telescope.nvim", -- optional
			"ibhagwan/fzf-lua",              -- optional
		},
		config = true
	}, -- git integration TODO look into, worth?
	{
		'rcarriga/nvim-notify'
	}, -- currently does nothing TODO coc.nvim integration maybe
	{
		"nvim-neorg/neorg",
		build = ":Neorg sync-parsers",
		dependencies = { "nvim-lua/plenary.nvim" },
		config = function()
		require("neorg").setup {
			load = {
        			["core.defaults"] = {},
        			["core.concealer"] = {},
        			["core.dirman"] = {
					config = {
						workspaces = {
							notes = "~/notes",
						},
						default_workspace = "notes",
					},
				},
			},
		}
		vim.wo.foldlevel = 99
		vim.wo.conceallevel = 2
		end,
	}, -- org mode TODO look into, worth? markdown broken lol (may be fixed thanks to TS grammar)
	{
		"folke/noice.nvim",
		event = "VeryLazy",
		opts = {
			-- add any options here
		},
		dependencies = {
			-- if you lazy-load any plugin below, make sure to add proper `module="..."` entries
			"MunifTanjim/nui.nvim",
			-- OPTIONAL:
			--   `nvim-notify` is only needed, if you want to use the notification view.
			--   If not available, we use `mini` as the fallback
			"rcarriga/nvim-notify",
		}
	}, -- TODO this builds on notify and is enough reason to keep it installed remember to configure and change comments
	{
		'akinsho/toggleterm.nvim',
		version = "*",
		config =  function()
			local highlights = require('rose-pine.plugins.toggleterm')
			require('toggleterm').setup({ highlights = highlights })
		end
	}, -- TODO toggleable terminals look into uwu :3
}) 

require("stickybuf").setup()

require'lspconfig'.pyright.setup{}

vim.opt.termguicolors = true -- needed for bufferline

local bufferline = require('bufferline')

bufferline.setup({
	options = {
		style_preset = bufferline.style_preset.default,
		tab_size = 18,
		max_name_length = 32,
		truncate_names = false,
		themable = false,
		numbers = "buffer_id",
		show_tab_indicators = true,
		indicator = {
			icon = '$',
			style = 'icon',
		},
		separator_style = "slant",
		offsets = {
                	{
                		filetype = "NvimTree",
                		text = "File Explorer",
                		text_align = "left",
                		separator = true,
                	},
			{
				filetype = "neo-tree",
				text = "File Explorer",
				text_align = "left",
				seperator = false,
			},
        	},
		diagnostics = "nvim_lsp",  --TODO check if working!
		-- TODO groups!
		-- TODO keybind mappings
	},
})

require("aerial").setup({
	backends = { "lsp", "treesitter", "markdown", "man" },
	layout = {
		max_width = {40, 0.2},
		width = nil,
		min_width = {10, 0.1},
	},
	resize_to_content = true,
	filter_kind = false,
	show_guides = true,
	nerd_font = "auto",
	-- optionally use on_attach to set keymaps when aerial has attached to a buffer
	on_attach = function(bufnr)
	-- Jump forwards/backwards with '{' and '}'
	vim.keymap.set("n", "{", "<cmd>AerialPrev<CR>", { buffer = bufnr })
	vim.keymap.set("n", "}", "<cmd>AerialNext<CR>", { buffer = bufnr })
	end,
})
-- You probably also want to set a keymap to toggle aerial
vim.keymap.set("n", "<leader>a", "<cmd>AerialToggle!<CR>")

require("nvim-tree").setup({
	sort = {
		sorter = "case_sensitive",
	},
	view = {
		width = 30,
	},
	renderer = {
		group_empty = true,
	},
	filters = {
		dotfiles = true,
	},
	diagnostics = {
        	enable = true,
        	show_on_dirs = false,
        	show_on_open_dirs = true,
        	debounce_delay = 50,
        	severity = {
        		min = vim.diagnostic.severity.HINT,
        		max = vim.diagnostic.severity.ERROR,
        	},
        	icons = {
        		hint = "",
        		info = "",
        		warning = "",
        		error = "",
        	},
	},
	modified = {
        	enable = true,
        	show_on_dirs = true,
        	show_on_open_dirs = true,
	},
})

vim.keymap.set("n", "|", "<cmd>NvimTreeToggle<CR>")

require("ibl").setup{
	scope = { enabled = false },
}

require('lualine').setup {
	options = {
		icons_enabled = true,
		theme = 'rose-pine',
		component_separators = {
			left = '',
			right = ''
		},
		section_separators = {
			left = '',
			right = ''
		},
		disabled_filetypes = {
			statusline = {},
			winbar = {},
		},
		ignore_focus = {'NvimTree'},
		always_divide_middle = true,
		globalstatus = true,
		refresh = {
			statusline = 1000,
			tabline = 1000,
			winbar = 1000,
		}
	},
	sections = {
		lualine_a = {'mode'},
		lualine_b = {'branch', 'diff', 'diagnostics'},
		lualine_c = {'filename'},
		lualine_x = {'encoding', 'fileformat', 'filetype'},
		lualine_y = {'progress'},
		lualine_z = {'location'}
	},
	inactive_sections = {
		lualine_a = {},
		lualine_b = {},
		lualine_c = {'filename'},
		lualine_x = {'location'},
		lualine_y = {},
		lualine_z = {}
	},
	tabline = {},
	winbar = {},
	inactive_winbar = {},
	extensions = {},
	--TODO configure!!
}

require('mini.indentscope').setup{
	symbol = '󱋱',
}

require('neorg').setup {
    load = {
        ["core.defaults"] = {},
        ["core.dirman"] = {
            config = {
                workspaces = {
                    work = "~/notes/work",
                    home = "~/notes/home",
                }
            }
        },
	["core.concealer"] = {},
	["core.completion"] = {},
    }
}

vim.notify = require("notify")

require("noice").setup({
  lsp = {
    -- override markdown rendering so that **cmp** and other plugins use **Treesitter**
    override = {
      ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
      ["vim.lsp.util.stylize_markdown"] = true,
      ["cmp.entry.get_documentation"] = true,
    },
  },
  -- you can enable a preset for easier configuration
  presets = {
    bottom_search = true, -- use a classic bottom cmdline for search
    command_palette = true, -- position the cmdline and popupmenu together
    long_message_to_split = true, -- long messages will be sent to a split
    inc_rename = false, -- enables an input dialog for inc-rename.nvim
    lsp_doc_border = false, -- add a border to hover docs and signature help
  },
})

require("toggleterm").setup{}

require('rose-pine').setup({
	--- @usage 'auto'|'main'|'moon'|'dawn'
	variant = 'auto',
	--- @usage 'main'|'moon'|'dawn'
	dark_variant = 'main',
	bold_vert_split = false,
	dim_nc_background = false,
	disable_background = false,
	disable_float_background = false,
	disable_italics = false,

	--- @usage string hex value or named color from rosepinetheme.com/palette
	groups = {
		background = 'base',
		background_nc = '_experimental_nc',
		panel = 'surface',
		panel_nc = 'base',
		border = 'highlight_med',
		comment = 'muted',
		link = 'iris',
		punctuation = 'subtle',

		error = 'love',
		hint = 'iris',
		info = 'foam',
		warn = 'gold',

		headings = {
			h1 = 'iris',
			h2 = 'foam',
			h3 = 'rose',
			h4 = 'gold',
			h5 = 'pine',
		h6 = 'foam',
		}
		-- or set all headings at once
		-- headings = 'subtle'
	},

	-- Change specific vim highlight groups
	-- https://github.com/rose-pine/neovim/wiki/Recipes
	highlight_groups = {
		ColorColumn = { bg = 'rose' },

		-- Blend colours against the "base" background
		CursorLine = { bg = 'foam', blend = 10 },
		StatusLine = { fg = 'love', bg = 'love', blend = 10 },

		-- By default each group adds to the existing config.
		-- If you only want to set what is written in this config exactly,
		-- you can set the inherit option:
		Search = { bg = 'gold', fg = 'base', inherit = false },
	}
})

-- Set colorscheme after options
vim.cmd('colorscheme rose-pine')
