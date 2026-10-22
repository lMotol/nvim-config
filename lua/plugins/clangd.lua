-- agent:codex
return {
  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      local clangd = opts.servers.clangd
      for i, arg in ipairs(clangd.cmd or {}) do
        if arg == "--function-arg-placeholders" then
          clangd.cmd[i] = "--function-arg-placeholders=true"
        end
      end
      -- Neovim negotiates position encodings using the standard LSP capability.
      if clangd.capabilities then
        clangd.capabilities.offsetEncoding = nil
      end
    end,
  },
}
