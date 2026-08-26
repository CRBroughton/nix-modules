local commit_types = {
    { type = 'none',     emoji = '',   desc = 'Plain commit (no type/emoji)' },
    { type = 'feat',     emoji = '✨',  desc = 'A new feature' },
    { type = 'fix',      emoji = '🐛',  desc = 'A bug fix' },
    { type = 'docs',     emoji = '📚',  desc = 'Documentation only changes' },
    { type = 'style',    emoji = '💎',  desc = 'Code style (formatting, semicolons, etc)' },
    { type = 'refactor', emoji = '♻️',  desc = 'Code change that neither fixes a bug nor adds a feature' },
    { type = 'perf',     emoji = '⚡',  desc = 'Performance improvement' },
    { type = 'test',     emoji = '🧪',  desc = 'Adding or fixing tests' },
    { type = 'build',    emoji = '📦',  desc = 'Build system or dependencies' },
    { type = 'ci',       emoji = '🔧',  desc = 'CI configuration' },
    { type = 'chore',    emoji = '🔨',  desc = 'Other changes (no src or test)' },
    { type = 'revert',   emoji = '⏪',  desc = 'Reverts a previous commit' },
}

local function conventional_commit()
    local items = {}
    for _, ct in ipairs(commit_types) do
        local display = ct.type == 'none'
            and string.format('   %-10s %s', ct.type, ct.desc)
            or  string.format('%s %-10s %s', ct.emoji, ct.type, ct.desc)
        table.insert(items, { display = display, type = ct.type, emoji = ct.emoji })
    end

    vim.ui.select(items, {
        prompt = 'Commit type: ',
        format_item = function(item) return item.display end,
    }, function(choice)
        if not choice then return end

        if choice.type == 'none' then
            vim.ui.input({ prompt = 'Message: ' }, function(msg)
                if msg and msg ~= '' then
                    vim.cmd('!git commit -m ' .. vim.fn.shellescape(msg))
                end
            end)
        else
            vim.ui.input({ prompt = 'Scope (optional): ' }, function(scope)
                vim.ui.input({ prompt = 'Description: ' }, function(desc)
                    if not desc or desc == '' then return end
                    vim.ui.select({ 'No', 'Yes' }, { prompt = 'Breaking change?' }, function(breaking)
                        local bang       = breaking == 'Yes' and '!' or ''
                        local scope_str  = (scope and scope ~= '') and ('(' .. scope .. ')') or ''
                        local emoji_str  = choice.emoji ~= '' and (choice.emoji .. ' ') or ''
                        local msg        = string.format('%s%s%s: %s%s', choice.type, scope_str, bang, emoji_str, desc)
                        vim.cmd('!git commit -m ' .. vim.fn.shellescape(msg))
                    end)
                end)
            end)
        end
    end)
end

vim.api.nvim_create_user_command('ConventionalCommit', conventional_commit, {})
vim.keymap.set('n', '<leader>gc', conventional_commit, { desc = 'Conventional commit' })

local ok, wk = pcall(require, 'which-key')
if ok then
    wk.add({
        { '<leader>g',  group = 'Git' },
        { '<leader>gc', desc = 'Conventional commit' },
    })
end
