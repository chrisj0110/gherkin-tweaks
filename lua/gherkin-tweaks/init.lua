local M = {}

vim = vim

-- add @cj and comment out all but current cucumber test
function M.isolate_test()
    -- add tag
    local starting_line = vim.fn.line('.')
    vim.cmd('normal! {')
    vim.cmd('normal! o@cj')
    local section_start_line = vim.fn.line(".")

    -- got the start line above, now get the end line
    vim.cmd('normal! }')
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
                local line = vim.fn.getline(i)
                local updated_line = line:gsub("|", "# |", 1)
                vim.fn.setline(i, updated_line)
            end
        end
    end

    vim.api.nvim_win_set_cursor(0, {starting_line + 1, 0})
    vim.cmd(':w')
end

-- add tag to the top of the current section
function M.add_tag_to_section()
    local starting_line = vim.fn.line('.')
    vim.cmd('normal! {')
    vim.cmd('normal! o@cj')
    vim.api.nvim_win_set_cursor(0, {starting_line + 1, 0})
    vim.cmd(':w')
end

-- add Example lines in cucumber file
function M.copy_table_header()
    local starting_line = vim.fn.line('.')

    vim.cmd('normal! {')
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
    vim.cmd(':w')
end

return M
