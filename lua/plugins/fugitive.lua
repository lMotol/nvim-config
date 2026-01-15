return {
    {
        "tpope/vim-fugitive",
        cmd = {
            "Git",
            "G",
            "Gvdiffsplit",
            "Gdiffsplit",
            "Gedit",
        },
        keys = {
            {
                "<leader>gd",
                function()
                    vim.cmd("Gvdiffsplit")
                end,
                desc = "Git diff (split)",
            },
        },
    },
}
