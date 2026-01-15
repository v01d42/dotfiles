-- @type vim.lsp.Config
return {
  setting = {
    Lua = {
      diagnostics = {
        globals = { "vim" },
      },
    },
  },
}
