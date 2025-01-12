---@class Config
---@field tag string|nil custom tag to use
---@field auto_save boolean|nil whether to save the buffer once tweaking it
local M = {}

---@string string|nil default tag to use if nothing else specified
local default_tag = '@mycustomtag'

---@string string|nil tag to use from user's config
local user_tag = nil

---@string boolean whether to save the buffer once tweaking it
local auto_save = false

---Set values based on user's configuration
---@param config Config
function M.setup(config)
    if config and config.tag then
        user_tag = config.tag
    end

    if config and config.auto_save ~= nil then
        auto_save = config.auto_save
    end
end

vim = vim

---get tag to use
---@return string
local function get_defualt_tag()
    return user_tag or default_tag
end

---add a tag to the top of the current section and comment out all but current test
---@param tag string|nil optional tag to use, overwrites defaults
function M.isolate_test(tag)
    local tag_to_use = tag or get_defualt_tag()

    -- add tag
    ---@type integer
    local starting_line = vim.fn.line('.')
    vim.cmd('normal! {')
    vim.cmd('normal! o' .. tag_to_use)
    ---@type integer
    local section_start_line = vim.fn.line(".")

    -- got the start line above, now get the end line
    vim.cmd('normal! }')
    ---@type integer
    local section_end_line = vim.fn.line(".")

    -- comment out all tests, but not the first line which has the column headers
    local first_example_line_found = false
    for i = section_start_line, section_end_line do
        -- loop through the lines, get the content of each, comment out all except the first one
        if not first_example_line_found and vim.api.nvim_buf_get_lines(0, i - 1, i, false)[1]:find("|", 1, true) then
            first_example_line_found = true
        else
            -- also don't comment out the test we want to run
            if i ~= starting_line + 1 then
                ---@type string
                local line = vim.fn.getline(i)
                local updated_line = line:gsub("|", "# |", 1)
                vim.fn.setline(i, updated_line)
            end
        end
    end

    vim.api.nvim_win_set_cursor(0, {starting_line + 1, 0})
    if auto_save then
        vim.cmd(':w')
    end
end

---add tag to the top of the current section
---@param tag string|nil optional tag to use, overwrites defaults
function M.add_tag_to_section(tag)
    local tag_to_use = tag or get_defualt_tag()

    ---@type integer
    local starting_line = vim.fn.line('.')
    vim.cmd('normal! {')
    vim.cmd('normal! o' .. tag_to_use)
    vim.api.nvim_win_set_cursor(0, {starting_line + 1, 0})
    if auto_save then
        vim.cmd(':w')
    end
end

---add Example lines in cucumber file
function M.copy_table_header()
    ---@type integer
    local starting_line = vim.fn.line('.')

    vim.cmd('normal! {')
    ---@type integer
    local empty_line_above_section = vim.fn.line(".")

    -- find the next line that starts with "|", which is the header row
    local header_row = 0
    for i = empty_line_above_section, vim.api.nvim_buf_line_count(0) do
        if vim.api.nvim_buf_get_lines(0, i - 1, i, false)[1]:find("|", 1, true) then
            header_row = i
            break
        end
    end

    -- yank the lines we want
    vim.cmd(':' .. empty_line_above_section .. ',' .. header_row .. 'y')

    -- go to our test line and paste it in
    vim.api.nvim_win_set_cursor(0, {starting_line, 0})
    vim.cmd('normal! P')

    -- now go to the new test line, and save
    vim.api.nvim_win_set_cursor(0, {1 + starting_line + header_row - empty_line_above_section, 0})
    if auto_save then
        vim.cmd(':w')
    end
end

return M
