return {
    {
        "nvim-treesitter/nvim-treesitter",
        lazy = false,
        build = ":TSUpdate",
        opts = function(_, opts)
            opts.ensure_installed = opts.ensure_installed or {}
            opts.auto_install = true
            vim.list_extend(opts.ensure_installed, {
                "bash",
                "cpp",
                "json",
                "lua",
                "markdown",
                "markdown_inline",
                "python",
                "query",
                "toml",
                "vim",
                "yaml",
            })
        end,
    },
}
