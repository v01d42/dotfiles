return {
  "folke/snacks.nvim",
  priority = 1000,
  lazy = false,
  ---@type snacks.Config
  opts = {
		input = {
			enabled = true,
		},
		picker = {
			ui_select = true,
			formatters = {
				file = {
					filename_first = true,
					truncate = 400,
				},
			},
		},
		bigfile = {
			enabled = true,
		},
		scratch = {
			enabled = true,
		},
		debug = {
			enabled = true,
		},
		lazygit = {
			enabled = true,
		},
		zen = {
			enabled = true,
		},
		dashboard = require("plugins.snacks.dashboard"),
  },
}
