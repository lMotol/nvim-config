-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
-- Add any additional autocmds here

vim.api.nvim_create_autocmd("BufEnter", {
    callback = function(args)
        if vim.api.nvim_buf_get_name(args.buf):match("^fugitive://") then
            vim.b[args.buf].snacks_words = false
            for _, client in ipairs(vim.lsp.get_clients({ bufnr = args.buf })) do
                vim.lsp.buf_detach_client(args.buf, client.id)
            end
        end
    end,
})
