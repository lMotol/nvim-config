if vim.fn.has("mac") == 0 then
    return {}
end

local obsidian = require("config.obsidian")

return {
    "obsidian-nvim/obsidian.nvim",
    branch = "main", -- 最新リリースを追従
    lazy = true,
    ft = "markdown",
    event = "VimEnter",
    cond = obsidian.is_obsidian_workspace,
    dependencies = {
        "nvim-lua/plenary.nvim",
        "ibhagwan/fzf-lua",
        "hrsh7th/nvim-cmp",
    },
    opts = {
        workspaces = obsidian.workspaces,
        completion = {
            completion = {
                nvim_cmp = true,
                blink = false,
                min_chars = 2,
            },
        },
        checkbox = {
            order = { " ", "x" },
        },
        ui = {
            checkboxes = {
                [" "] = { char = "▢", hl_group = "obsidiantodo" },
                ["x"] = { char = "󰱒", hl_group = "obsidiandone" },
            },
        },
        daily_notes = {
            folder = "daily memo",
            template = "yyyy-mm-dd.md",
            default_tags = {},
        },
        templates = {
            folder = "template",
            date_format = "%Y-%m-%d",
            time_format = "%H:%M",
            customizations = {
                ["yyyy-mm-dd"] = {
                    notes_subdir = "daily memo",
                },
                ["lab_note"] = {
                    notes_subdir = "lab/lab_note",
                },
                ["other_note"] = {
                    notes_subdir = "other_note",
                },
                ["paper_template"] = {
                    notes_subdir = "lab/paper",
                },
                ["tips"] = {
                    notes_subdir = "lab/tips",
                },
                ["chatgpt"] = {
                    notes_subdir = "lab/chatgpt",
                },
            },
        },
        note_frontmatter_func = function(note)
            local out = { tags = note.tags }

            if note.metadata ~= nil and not vim.tbl_isempty(note.metadata) then
                for k, v in pairs(note.metadata) do
                    out[k] = v
                end
            end

            return out
        end,
        callbacks = {
            pre_write_note = function(_, note)
                if note.metadata and note.metadata.updated_at ~= nil then
                    note.metadata.updated_at = os.date("%Y-%m-%d_%H:%M")
                end
            end,
        },
        attachments = {
            img_folder = "picture",
            img_name_func = function()
                return ("img_%s.png"):format(os.date("%Y%m%d_%H%M%S"))
            end,
            confirm_img_paste = true,
        },
    },
    keys = {
        { "<leader>on", "<cmd>Obsidian new<cr>", desc = "新規ノート" },
        { "<leader>oq", "<cmd>Obsidian quick_switch<cr>", desc = "ノート検索" },
        { "<leader>od", "<cmd>Obsidian today<cr>", desc = "daily note" },
        { "<leader>op", "<cmd>Obsidian paste_img<cr>", desc = "画像の挿入" },
        { "<leader>ot", "<cmd>Obsidian new_from_template<cr>", desc = "New daily note from template" },
        { "<leader>oc", "<cmd>Obsidian toggle_checkbox<cr>", desc = "toggle checkboxes" },
        {
            "<leader>og",
            obsidian.smart_gf,
            desc = "Obsidian: Smart gf",
            mode = "n",
            buffer = true,
        },
    },
}
