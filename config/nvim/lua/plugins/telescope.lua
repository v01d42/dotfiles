return {
    'nvim-telescope/telescope.nvim',
    enabled = true,
    cmd = { "Telescope" },
    dependencies = {
        { 'nvim-lua/plenary.nvim' },
        {
            "nvim-telescope/telescope-fzf-native.nvim",
            dir = vim.env.TELESCOPE_FZF_NATIVE, -- Nix-provided pre-built binary
        },
    },
    config = function()
        require("telescope").load_extension("fzf")
    end,
}
