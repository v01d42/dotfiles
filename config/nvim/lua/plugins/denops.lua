return {
  {
    "vim-denops/denops.vim",
    version = "v8.0.1",
    config = function()
      vim.g["denops#debug"] = 0
    end,
  },
  -- { "vim-denops/denops-helloworld.vim", depends = { "vim-denops/denops.vim" } },
}
