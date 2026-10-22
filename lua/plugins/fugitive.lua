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
                    local count = vim.v.count

                    if count > 0 then
                        vim.cmd("Gvdiffsplit HEAD~" .. count)
                    else
                        vim.cmd("Gvdiffsplit")
                    end
                end,
                desc = "Git diff (split)",
            },

            {
                "<leader>gD",
                function()
                    local root = vim.fs.root(0, ".git")
                    if not root then
                        vim.notify("Not inside a Git repository", vim.log.levels.ERROR)
                        return
                    end

                    local commits = vim.fn.systemlist({
                        "git",
                        "-C",
                        root,
                        "log",
                        "--oneline",
                        "--decorate",
                        "-100",
                    })

                    if vim.v.shell_error ~= 0 then
                        vim.notify("Failed to read Git log", vim.log.levels.ERROR)
                        return
                    end

                    vim.ui.select(commits, {
                        prompt = "Diff against commit",
                    }, function(choice)
                        if not choice then
                            return
                        end

                        local commit = choice:match("^([0-9a-f]+)")
                        if commit then
                            vim.cmd("Gvdiffsplit " .. commit)
                        end
                    end)
                end,
                desc = "Git diff against commit",
            },
        },
    },
}
