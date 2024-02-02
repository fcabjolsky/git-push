local M = {}
GitPushConfig = GitPushConfig or {}

--[[
-- usage
-- Using nui:
-- require("git-push").show_push_dialog()
-- this will display the dialog with the branches
-- Using native input:
-- local git_push = require("git-push")
-- git_push.setup({ use_nui = false })
-- git_push.show_push_dialog()
]]


local function is_git_repo()
    local git_dir = vim.fn.system('git rev-parse --is-inside-work-tree')
    return string.find(git_dir, "true") ~= nil
end

local function get_git_branches()
    local out = vim.fn.system "git branch --list | cut -c 3- | sed -e 's/^\\*//' | tr -s '\n' ','"
    local current_branch = vim.fn.system "git rev-parse --abbrev-ref HEAD | tr -d '\n'"
    local branches = {}
    for substring in out:gmatch("([^,]+)") do
        if (substring ~= nil or substring ~= '') then
            if substring == current_branch then
                table.insert(branches, 1, substring)
            else
                table.insert(branches, substring)
            end
        end
    end
    return branches
end

local function show_with_nui(branches, action, submit)
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
                top = "Choose branch to " .. action,
                top_align = "center",
                bottom = "Space or Enter to " .. action,
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
          submit(item.text)
        end,
    })
    menu:mount()
end

local function show_with_native_input(branches, submit)
    local prompt = ''
    for i, branch in pairs(branches) do
        prompt = prompt .. branch .. ' (' .. i .. ')\n'
    end

    local selected

    vim.ui.input({ prompt = prompt .. 'Select: ' },
        function(input) selected = branches[tonumber(input)] end)
    if selected == nil then
        return
    end
    submit(selected)
    M.push_to_branch(selected)
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
    local use_nui = true
    if config.use_nui ~= nil then
        use_nui = config.use_nui
    end
    GitPushConfig.with_menu = use_nui
    GitPushConfig.remote = config.origin or 'origin'
end

function M.push_to_branch(branch)
    local cmd = "push " .. GitPushConfig.remote .. " "
    vim.cmd.Git({ args = { cmd .. branch } })
end

function M.pull_from_branch(branch)
    local cmd = "pull " .. GitPushConfig.remote .. " "
    vim.cmd.Git({ args = { cmd .. branch } })
end


function M.show_push_dialog()
    if not GitPushConfig.is_git_repo then
        error("This is not a git repository")
        return
    end

    local branches = get_git_branches()

    if (GitPushConfig.with_menu) then
        show_with_nui(branches, "push", M.push_to_branch)
    else
        show_with_native_input(branches, M.push_to_branch)
    end
end

function M.show_pull_dialog()
    if not GitPushConfig.is_git_repo then
        error("This is not a git repository")
        return
    end

    local branches = get_git_branches()

    if (GitPushConfig.with_menu) then
        show_with_nui(branches, "pull", M.pull_from_branch)
    else
        show_with_native_input(branches, M.pull_from_branch)
    end
end

M.setup()


return M
