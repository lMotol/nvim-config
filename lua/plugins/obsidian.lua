return {
    "obsidian-nvim/obsidian.nvim",
    branch = "main", -- 最新リリースを追従
    lazy = true, -- 明示しなくても true だが念のため
    ft = "markdown", -- ⑴: どの MD でも読み込む
    -- ⑵: 特定 Vault 内だけで読み込みたい場合は ↓ を使う
    -- event = {
    --   "BufReadPre " .. vim.fn.expand "~" .. "/Users/suzukimotomasa/Library/Mobile Documents/iCloud~md~obsidian/Documents/main/lab/research/lab_note/*.md",
    --   "BufNewFile  "/Users/suzukimotomasa/Library/Mobile Documents/iCloud~md~obsidian/Documents/main/lab/research/lab_note/*.md",
    -- },
    dependencies = {
        "nvim-lua/plenary.nvim",
        "ibhagwan/fzf-lua",
        "saghen/blink.cmp",
    },
    opts = {
        workspaces = {
            {
                name = "main",
                path = vim.fn.expand("~/Library/Mobile Documents/iCloud~md~obsidian/Documents/main"),
            },
        },
        completion = {
            completion = {
                nvim_cmp = false, -- ← 無効化
                blink = true, -- ← 有効化
                min_chars = 2,
            },
        },
        daily_notes = {
            -- 日次ノートを保存するフォルダ（Vault からの相対パス）
            folder = "daily memo",
            -- テンプレートファイルのパス（template subdir からの相対パス）
            template = "yyyy-mm-dd.md",
        },
        templates = {
            -- 一般的なテンプレートを置くフォルダ（Vault からの相対パス）
            folder = "template",
            -- テンプレート内で使う日付書式（Lua の os.date フォーマット）
            date_format = "%Y-%m-%d",
            time_format = "%H:%M",
            customizations = {
                ["yyyy-mm-dd"] = {
                    notes_subdir = "daily memo",
                },
                ["lab_note"] = {
                    notes_subdir = "lab/lab_note",
                },
            },
        },
        note_frontmatter_func = function(note)
            -- note.date / note.time は daily_notes 設定から来る値です
            local date = (type(note.date) == "string" and note.date ~= "") and note.date or os.date("%Y-%m-%d") -- フォールバック
            local time = (type(note.time) == "string" and note.time ~= "") and note.time or os.date("%H:%M") -- フォールバック
            local tags = {} -- デフォルト空
            if note.template then
                -- note.template は "template/meeting.md" のような相対パス文字列
                if note.template:match("yyyy-mm-dd") then
                    tags = { "daily" }
                elseif note.template:match("lab_note") then
                    tags = { "lab_note" }
                else
                    tags = { "misc" } -- その他テンプレ用
                end
            else
                tags = { "misc" } -- テンプレート指定なし＝日次ノート系
            end
            return {
                created_at = date .. "_" .. time,
                updated_at = date .. "_" .. time,
                tags = tags,
            }
        end,
        callbacks = {
            pre_write_note = function(_, note)
                -- frontmatter 内の updated_at を上書き
                note.metadata.updated_at = os.date("%Y-%m-%d_%H:%M")
            end,
        },
        -- お好みで他の設定…
    },
    keys = {
        { "<leader>on", "<cmd>Obsidian new<cr>", desc = "新規ノート" },
        { "<leader>oq", "<cmd>Obsidian quick_switch<cr>", desc = "ノート検索" },
        { "<leader>od", "<cmd>Obsidian today<cr>", desc = "daily note" },
        { "<leader>ot", "<cmd>Obsidian new_from_template<cr>", desc = "New daily note from template" },
        {
            "<leader>og",
            function()
                local new_from_template = require("obsidian.commands.new_from_template")
                local follow_link = require("obsidian.commands.follow_link")
                local client = require("obsidian").get_client()
                local api = require("obsidian.api")
                local Workspace = require("obsidian.workspace")
                -- 1) Obsidian リンク下ならフォロー
                if api.cursor_on_markdown_link(nil, nil, true) then
                    -- args では ファイルの開き方を指定できる(画面分割して表示など)
                    local file = vim.fn.expand("<cfile>") -- "FooBar.md" 等
                    if not file:match("%.md$") then
                        file = file .. ".md"
                    end
                    local ws = Workspace.new(vim.fn.getcwd())
                    local vault_root = tostring(ws.root)
                    local matches = vim.fs.find(file, { path = vault_root, type = "file", limit = 1 })
                    local fullpath = matches[1]
                    if matches and #matches ~= 0 then
                        if api.path_is_note(fullpath) then
                            follow_link(client, { args = "vsplit" })
                        end
                    else
                        -- new_from_template の自前実装
                        local picker = Obsidian.picker
                        local log = require("obsidian.log")
                        local Note = require("obsidian.note")
                        if not picker then
                            log.err("No picker configured")
                            return
                        end

                        picker:find_templates({
                            callback = function(template_name)
                                if template_name == nil or template_name == "" then
                                    log.warn("Aborted")
                                    return
                                end

                                ---@type obsidian.Note
                                local note =
                                    Note.create({ title = file, template = template_name, should_write = true })
                                note:open({ sync = false })
                            end,
                        })
                    end
                end
                -- 2) そうでなければカーソル下ファイル名でテンプレート新規作成
            end,
            desc = "Obsidian: Smart gf",
            mode = "n",
            buffer = true,
        },
    },
}
