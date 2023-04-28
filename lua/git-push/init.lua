local M = {}
GitPushConfig = GitPushConfig or {}

--[[ 
-- usage
-- require("git-push").show_push_dialog()
-- this will display the dialog with the branches
]]


local function is_git_repo()
    local git_dir = vim.fn.finddir('.git', vim.fn.getcwd() .. ";")
    return git_dir ~= ""
end

local function get_git_branches()
    local out = vim.fn.system "git branch | tr -d '\n'"
    local current_branch = vim.fn.system "git rev-parse --abbrev-ref HEAD | tr -d '\n'"
    local branches = {}
    for substring in out:gmatch("%S+") do
        if (substring ~= nil or substring ~= '') and (substring ~= '*') then
            substring = string.gsub(substring, "*", "")
            if substring == current_branch then
                table.insert(branches, 1, substring)
            else
                table.insert(branches, substring)
            end
        end
    end
    return branches
end

function M.setup(config)
    if not config then
        config = {}
    end
    if not vim.g.loaded_fugitive then
        error("Fugitive is needed for this plugin")
        return
    end
    GitPushConfig.is_git_repo = is_git_repo()
    GitPushConfig.with_menu = config.use_nui or true
    GitPushConfig.remote = config.use_nui or 'origin'
end

function M.push_to_branch(branch)
    local cmd = "push " .. GitPushConfig.remote .. " "
    vim.cmd.Git({ args = { cmd .. branch } })
end

function M.show_push_dialog()
    if not GitPushConfig.is_git_repo then
        error("This is not a git repository")
        return
    end

    local branches = get_git_branches()
    if (GitPushConfig.with_menu) then
        local Menu = require("nui.menu")
        local menu_items = {}
        for _, branch in ipairs(branches) do
            table.insert(menu_items, Menu.item(branch))
        end

        local menu = Menu({
            position = "50%",
            size = {
                width = 25,
                height = 5,
            },
            border = {
                style = "rounded",
                padding = { 1 },
                text = {
                    top = "Choose branch to push",
                    top_align = "center",
                    bottom = "Space or Enter to push",
                },
            },
            win_options = {
                winhighlight = "Normal:Normal,FloatBorder:Normal",
            },
        }, {
            lines = menu_items,
            max_width = 20,
            keymap = {
                focus_next = { "j", "<Down>", "<Tab>" },
                focus_prev = { "k", "<Up>", "<S-Tab>" },
                close = { "<Esc>", "<C-c>" },
                submit = { "<CR>", "<Space>" },
            },
            on_submit = function(item)
                M.push_to_branch(item.text)
            end,
        })
        menu:mount()
    end
end

M.setup()

return M
