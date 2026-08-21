-- Example nanOS plugin: prints the current git branch when the
-- "shell_prompt" hook fires. Uses nanos.exec_readonly because "git" is on
-- the built-in read-only whitelist — this plugin never needs permissions.exec.

nanos_hooks["shell_prompt"] = function()
    local branch = nanos.exec_readonly("git branch --show-current")
    branch = branch:gsub("%s+$", "") -- trim trailing newline

    if branch ~= "" then
        nanos.print("current branch: " .. branch)
    else
        nanos.print("not a git repository")
    end
end
