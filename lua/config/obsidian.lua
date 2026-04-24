local M = {}

local main_vault = vim.fn.expand("~/Library/Mobile Documents/iCloud~md~obsidian/Documents/main")
local normal_vault = vim.fn.expand("~/Library/Mobile Documents/iCloud~md~obsidian/Documents/normal")

M.workspaces = {
    {
        name = "main",
        path = main_vault,
    },
    {
        name = "normal",
        path = normal_vault,
        overrides = {
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
                    ["music_detail"] = {
                        notes_subdir = "Music_memo",
                    },
                },
            },
        },
    },
}

local function current_working_directory()
    if vim.uv then
        return vim.uv.cwd() or vim.fn.getcwd()
    end

    return vim.loop.cwd() or vim.fn.getcwd()
end

function M.is_obsidian_workspace()
    local cwd = current_working_directory()

    for _, workspace in ipairs(M.workspaces) do
        if cwd:find(workspace.path, 1, true) ~= nil then
            return true
        end
    end

    return false
end

function M.smart_gf()
    local follow_link = require("obsidian.commands.follow_link")
    local client = require("obsidian").get_client()
    local api = require("obsidian.api")
    local Workspace = require("obsidian.workspace")
    local util = require("obsidian.util")

    if not api.cursor_on_markdown_link(nil, nil, true) then
        return
    end

    local s_col, e_col = api.cursor_on_markdown_link(nil, nil, true)
    local line = vim.api.nvim_get_current_line()
    local raw_link = line:sub(s_col, e_col)
    local _, link_name = util.parse_link(raw_link)

    if link_name == nil or link_name == "" then
        return
    end

    local file = link_name

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
        return
    end

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
            local note = Note.create({ title = file, template = template_name, should_write = true })
            note:open({ sync = false })
        end,
    })
end

return M
