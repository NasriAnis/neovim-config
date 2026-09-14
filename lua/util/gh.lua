-- lua/util/gh.lua
-- Comprehensive interactive gh CLI wrapper for Neovim.
-- Requires: gh CLI authenticated, fzf-lua, Neovim 0.10+ (vim.system).
--
-- Entry points:
--   require("util.gh").menu()   -- top-level category picker
--   require("util.gh").help()   -- full command reference in a scratch buffer
--
-- Everything here shells out to `gh`/`git` async and reports results via
-- vim.notify. Anything Octo already covers (PR/issue CRUD, reviews,
-- comments) is intentionally NOT duplicated here.

local M = {}
local fzf = function() return require("fzf-lua") end

local BACK = "« Back"

-- ============================================================
-- Core runner helpers
-- ============================================================

local function run(cmd, opts)
  opts = opts or {}
  vim.system(cmd, { text = true }, function(result)
    vim.schedule(function()
      if result.code == 0 then
        local msg = result.stdout ~= "" and result.stdout or "Done"
        vim.notify(msg, vim.log.levels.INFO, { title = opts.title or "gh" })
        if opts.on_success then opts.on_success(result.stdout) end
      else
        local msg = result.stderr ~= "" and result.stderr or "Command failed"
        vim.notify(msg, vim.log.levels.ERROR, { title = opts.title or "gh" })
      end
    end)
  end)
end

local function run_json(cmd, callback)
  vim.system(cmd, { text = true }, function(result)
    vim.schedule(function()
      if result.code ~= 0 then
        vim.notify(result.stderr, vim.log.levels.ERROR, { title = "gh" })
        return
      end
      local ok, data = pcall(vim.json.decode, result.stdout)
      if ok then callback(data) else vim.notify("Failed to parse JSON", vim.log.levels.ERROR) end
    end)
  end)
end

local function ask(prompt, cb)
  vim.ui.input({ prompt = prompt }, function(input)
    if input and input ~= "" then cb(input) end
  end)
end

--- fzf picker with an optional "on_back" callback wired to a "« Back" entry
--- so every level of the menu can bubble up cleanly.
local function pick(items, prompt, cb, on_back)
  local display = items
  if on_back then
    display = { BACK }
    vim.list_extend(display, items)
  end

  fzf().fzf_exec(display, {
    prompt = prompt,
    fzf_opts = {
      ["--header"] = ":: <Enter> select  ·  <Esc> cancel  ·  pick « Back » to go up a level",
    },
    actions = {
      ["default"] = function(selected)
        local sel = selected[1]
        if sel == BACK then
          on_back()
        else
          cb(sel)
        end
      end,
    },
  })
end

-- ============================================================
-- Action registry
-- Each action is { desc = "one line help text", fn = function() ... end }
-- ============================================================

local repo = {
  set_default = {
    desc = "Pick one of your repos and set it as gh's default for this directory",
    fn = function()
      run_json({ "gh", "repo", "list", "--limit", "200", "--json", "nameWithOwner" }, function(repos)
        local names = vim.tbl_map(function(r) return r.nameWithOwner end, repos)
        pick(names, "Set default repo> ", function(name)
          run({ "gh", "repo", "set-default", name }, { title = "gh repo set-default" })
        end, M.menu)
      end)
    end,
  },
  sync_fork = {
    desc = "Sync your fork's default branch with upstream",
    fn = function() run({ "gh", "repo", "sync" }, { title = "gh repo sync" }) end,
  },
  view = {
    desc = "Show current repo's name, default branch, fork status, and URL",
    fn = function()
      run_json({ "gh", "repo", "view", "--json", "nameWithOwner,defaultBranchRef,url,description,isFork" }, function(d)
        local lines = {
          d.nameWithOwner,
          "Default branch: " .. d.defaultBranchRef.name,
          "Fork: " .. tostring(d.isFork),
          d.description or "",
          d.url,
        }
        vim.notify(table.concat(lines, "\n"), vim.log.levels.INFO, { title = "gh repo view" })
      end)
    end,
  },
  fork = {
    desc = "Fork the current repo and add it as a remote",
    fn = function() run({ "gh", "repo", "fork", "--remote=true" }, { title = "gh repo fork" }) end,
  },
  clone = {
    desc = "Clone a repo by owner/name",
    fn = function()
      ask("Repo to clone (owner/name): ", function(name)
        run({ "gh", "repo", "clone", name }, { title = "gh repo clone" })
      end)
    end,
  },
  create = {
    desc = "Create a new GitHub repo from the current directory and push",
    fn = function()
      ask("New repo name: ", function(name)
        pick({ "public", "private", "internal" }, "Visibility> ", function(vis)
          run({ "gh", "repo", "create", name, "--" .. vis, "--source=.", "--push" }, { title = "gh repo create" })
        end)
      end)
    end,
  },
  delete = {
    desc = "Permanently delete the current repo (asks for name confirmation)",
    fn = function()
      run_json({ "gh", "repo", "view", "--json", "nameWithOwner" }, function(d)
        vim.ui.input({ prompt = 'Type "' .. d.nameWithOwner .. '" to confirm delete: ' }, function(confirm)
          if confirm == d.nameWithOwner then
            run({ "gh", "repo", "delete", d.nameWithOwner, "--yes" }, { title = "gh repo delete" })
          else
            vim.notify("Delete cancelled", vim.log.levels.WARN)
          end
        end)
      end)
    end,
  },
  add_upstream = {
    desc = "Add a git remote named 'upstream' pointing at another owner/repo",
    fn = function()
      ask("Upstream repo (owner/name): ", function(input)
        run({ "git", "remote", "add", "upstream", "https://github.com/" .. input .. ".git" }, { title = "git remote add upstream" })
      end)
    end,
  },
  set_visibility = {
    desc = "Change the current repo's visibility (public/private/internal)",
    fn = function()
      pick({ "public", "private", "internal" }, "New visibility> ", function(vis)
        run({ "gh", "repo", "edit", "--visibility", vis, "--accept-visibility-change-consequences" }, { title = "gh repo edit" })
      end)
    end,
  },
  archive_toggle = {
    desc = "Archive or unarchive the current repo",
    fn = function()
      pick({ "archive", "unarchive" }, "Action> ", function(action)
        run({ "gh", "repo", action }, { title = "gh repo " .. action })
      end)
    end,
  },
}

local release = {
  list = {
    desc = "List all releases for the current repo",
    fn = function() run({ "gh", "release", "list" }, { title = "gh release list" }) end,
  },
  view = {
    desc = "Pick a release and view its notes",
    fn = function()
      run_json({ "gh", "release", "list", "--json", "tagName" }, function(tags)
        local names = vim.tbl_map(function(t) return t.tagName end, tags)
        pick(names, "View release> ", function(tag) run({ "gh", "release", "view", tag }) end)
      end)
    end,
  },
  create = {
    desc = "Create a new release with auto-generated notes",
    fn = function()
      ask("Tag name (e.g. v1.2.0): ", function(tag)
        ask("Release title: ", function(title)
          run({ "gh", "release", "create", tag, "--title", title, "--generate-notes" }, { title = "gh release create" })
        end)
      end)
    end,
  },
  delete = {
    desc = "Pick a release and delete it",
    fn = function()
      run_json({ "gh", "release", "list", "--json", "tagName" }, function(tags)
        local names = vim.tbl_map(function(t) return t.tagName end, tags)
        pick(names, "Delete release> ", function(tag)
          run({ "gh", "release", "delete", tag, "--yes" }, { title = "gh release delete" })
        end)
      end)
    end,
  },
  upload_asset = {
    desc = "Upload a local file as an asset on an existing release",
    fn = function()
      run_json({ "gh", "release", "list", "--json", "tagName" }, function(tags)
        local names = vim.tbl_map(function(t) return t.tagName end, tags)
        pick(names, "Upload asset to release> ", function(tag)
          ask("Path to asset file: ", function(path)
            run({ "gh", "release", "upload", tag, path }, { title = "gh release upload" })
          end)
        end)
      end)
    end,
  },
}

local actions_ = {
  list_runs = {
    desc = "Show recent CI runs; pick one to view its details",
    fn = function()
      run_json({ "gh", "run", "list", "--limit", "30", "--json", "databaseId,status,conclusion,name,headBranch" }, function(runs)
        local items = {}
        for _, r in ipairs(runs) do
          table.insert(items, string.format("%s [%s/%s] (%s) #%d", r.name, r.status, r.conclusion or "-", r.headBranch, r.databaseId))
        end
        pick(items, "Runs> ", function(selection)
          local id = selection:match("#(%d+)$")
          if id then run({ "gh", "run", "view", id }, { title = "gh run view" }) end
        end)
      end)
    end,
  },
  watch_latest = {
    desc = "Stream live output of the most recent CI run",
    fn = function()
      run_json({ "gh", "run", "list", "--limit", "1", "--json", "databaseId" }, function(runs)
        if runs[1] then run({ "gh", "run", "watch", tostring(runs[1].databaseId) }, { title = "gh run watch" }) end
      end)
    end,
  },
  rerun_failed = {
    desc = "Pick a failed run and rerun only its failed jobs",
    fn = function()
      run_json({ "gh", "run", "list", "--status", "failure", "--limit", "20", "--json", "databaseId,name,headBranch" }, function(runs)
        local items = {}
        for _, r in ipairs(runs) do table.insert(items, string.format("%s (%s) #%d", r.name, r.headBranch, r.databaseId)) end
        pick(items, "Rerun failed run> ", function(selection)
          local id = selection:match("#(%d+)$")
          if id then run({ "gh", "run", "rerun", id, "--failed" }, { title = "gh run rerun" }) end
        end)
      end)
    end,
  },
  cancel_run = {
    desc = "Pick an in-progress run and cancel it",
    fn = function()
      run_json({ "gh", "run", "list", "--status", "in_progress", "--json", "databaseId,name,headBranch" }, function(runs)
        local items = {}
        for _, r in ipairs(runs) do table.insert(items, string.format("%s (%s) #%d", r.name, r.headBranch, r.databaseId)) end
        pick(items, "Cancel run> ", function(selection)
          local id = selection:match("#(%d+)$")
          if id then run({ "gh", "run", "cancel", id }, { title = "gh run cancel" }) end
        end)
      end)
    end,
  },
  list_workflows = {
    desc = "List all workflow files defined in this repo",
    fn = function() run({ "gh", "workflow", "list" }, { title = "gh workflow list" }) end,
  },
  trigger_workflow = {
    desc = "Pick a workflow and manually trigger it (workflow_dispatch)",
    fn = function()
      run_json({ "gh", "workflow", "list", "--json", "name,id" }, function(wfs)
        local items = {}
        for _, w in ipairs(wfs) do table.insert(items, w.name .. " #" .. w.id) end
        pick(items, "Trigger workflow> ", function(selection)
          local id = selection:match("#(%d+)$")
          if id then run({ "gh", "workflow", "run", id }, { title = "gh workflow run" }) end
        end)
      end)
    end,
  },
}

local gist = {
  create_from_buffer = {
    desc = "Create a gist from the file currently open in the buffer",
    fn = function()
      local path = vim.fn.expand("%:p")
      if path == "" then vim.notify("No file in buffer", vim.log.levels.WARN); return end
      pick({ "public", "secret" }, "Visibility> ", function(vis)
        local cmd = { "gh", "gist", "create", path }
        if vis == "public" then table.insert(cmd, "--public") end
        run(cmd, { title = "gh gist create" })
      end)
    end,
  },
  list = {
    desc = "List your gists",
    fn = function() run({ "gh", "gist", "list" }, { title = "gh gist list" }) end,
  },
  view = {
    desc = "Pick a gist and view its contents",
    fn = function()
      run_json({ "gh", "gist", "list", "--json", "id,description" }, function(gists)
        local items = {}
        for _, g in ipairs(gists) do table.insert(items, (g.description ~= "" and g.description or "(no description)") .. " #" .. g.id) end
        pick(items, "View gist> ", function(selection)
          local id = selection:match("#(%S+)$")
          if id then run({ "gh", "gist", "view", id }) end
        end)
      end)
    end,
  },
  delete = {
    desc = "Pick a gist and delete it",
    fn = function()
      run_json({ "gh", "gist", "list", "--json", "id,description" }, function(gists)
        local items = {}
        for _, g in ipairs(gists) do table.insert(items, (g.description ~= "" and g.description or "(no description)") .. " #" .. g.id) end
        pick(items, "Delete gist> ", function(selection)
          local id = selection:match("#(%S+)$")
          if id then run({ "gh", "gist", "delete", id, "--yes" }, { title = "gh gist delete" }) end
        end)
      end)
    end,
  },
}

local secret = {
  list = {
    desc = "List secret names configured for this repo (values are never shown)",
    fn = function() run({ "gh", "secret", "list" }, { title = "gh secret list" }) end,
  },
  set = {
    desc = "Set a repo secret (name + value, value typed in plain text)",
    fn = function()
      ask("Secret name: ", function(name)
        ask("Secret value: ", function(value)
          vim.system({ "gh", "secret", "set", name, "--body", value }, { text = true }, function(result)
            vim.schedule(function()
              if result.code == 0 then
                vim.notify("Secret set: " .. name, vim.log.levels.INFO, { title = "gh secret set" })
              else
                vim.notify(result.stderr, vim.log.levels.ERROR)
              end
            end)
          end)
        end)
      end)
    end,
  },
  delete = {
    desc = "Pick a secret and delete it",
    fn = function()
      vim.system({ "gh", "secret", "list" }, { text = true }, function(result)
        vim.schedule(function()
          local names = {}
          for line in result.stdout:gmatch("[^\r\n]+") do table.insert(names, line:match("^(%S+)")) end
          pick(names, "Delete secret> ", function(name)
            run({ "gh", "secret", "delete", name }, { title = "gh secret delete" })
          end)
        end)
      end)
    end,
  },
}

local keys = {
  list_ssh = {
    desc = "List SSH keys registered to your GitHub account",
    fn = function() run({ "gh", "ssh-key", "list" }, { title = "gh ssh-key list" }) end,
  },
  add_ssh = {
    desc = "Upload a local public key file to your GitHub account",
    fn = function()
      ask("Path to public key file (e.g. ~/.ssh/id_ed25519.pub): ", function(path)
        ask("Title for this key: ", function(title)
          run({ "gh", "ssh-key", "add", vim.fn.expand(path), "--title", title }, { title = "gh ssh-key add" })
        end)
      end)
    end,
  },
  list_gpg = {
    desc = "List GPG keys registered to your GitHub account",
    fn = function() run({ "gh", "gpg-key", "list" }, { title = "gh gpg-key list" }) end,
  },
}

local auth = {
  status = {
    desc = "Show which GitHub account(s) gh is currently authenticated as",
    fn = function() run({ "gh", "auth", "status" }, { title = "gh auth status" }) end,
  },
  login = {
    desc = "Log in via the browser flow",
    fn = function() run({ "gh", "auth", "login", "--web" }, { title = "gh auth login" }) end,
  },
  switch = {
    desc = "Switch the active account among ones you're already logged into",
    fn = function()
      vim.system({ "gh", "auth", "status" }, { text = true }, function(result)
        vim.schedule(function()
          vim.notify(result.stdout, vim.log.levels.INFO, { title = "Current accounts" })
        end)
      end)
      ask("Account to switch to (username): ", function(user)
        run({ "gh", "auth", "switch", "--user", user }, { title = "gh auth switch" })
      end)
    end,
  },
  refresh_scopes = {
    desc = "Add an OAuth scope to your current token (e.g. project, read:org)",
    fn = function()
      ask("Additional scope to add: ", function(scope)
        run({ "gh", "auth", "refresh", "-s", scope }, { title = "gh auth refresh" })
      end)
    end,
  },
}

local ext = {
  list = {
    desc = "List installed gh extensions",
    fn = function() run({ "gh", "extension", "list" }, { title = "gh extension list" }) end,
  },
  install = {
    desc = "Install a gh extension by owner/name",
    fn = function()
      ask("Extension repo (owner/name): ", function(name)
        run({ "gh", "extension", "install", name }, { title = "gh extension install" })
      end)
    end,
  },
  upgrade_all = {
    desc = "Upgrade all installed gh extensions",
    fn = function() run({ "gh", "extension", "upgrade", "--all" }, { title = "gh extension upgrade" }) end,
  },
}

local codespace = {
  list = {
    desc = "List your active codespaces",
    fn = function() run({ "gh", "codespace", "list" }, { title = "gh codespace list" }) end,
  },
  create = {
    desc = "Create a new codespace for the current repo",
    fn = function() run({ "gh", "codespace", "create" }, { title = "gh codespace create" }) end,
  },
  stop = {
    desc = "Pick a running codespace and stop it",
    fn = function()
      run_json({ "gh", "codespace", "list", "--json", "name,displayName" }, function(cs)
        local items = {}
        for _, c in ipairs(cs) do table.insert(items, c.displayName .. " #" .. c.name) end
        pick(items, "Stop codespace> ", function(selection)
          local name = selection:match("#(%S+)$")
          if name then run({ "gh", "codespace", "stop", "-c", name }, { title = "gh codespace stop" }) end
        end)
      end)
    end,
  },
}

local api = {
  get = {
    desc = "Raw GET request to any GitHub API path — escape hatch for anything not wrapped here",
    fn = function()
      ask("API path (e.g. repos/:owner/:repo/traffic/views): ", function(path)
        run({ "gh", "api", path }, { title = "gh api" })
      end)
    end,
  },
}

-- ============================================================
-- Menu machinery
-- ============================================================

local categories = {
  { label = "Repo",       desc = "Create, clone, fork, sync, delete, visibility, archive", actions = repo },
  { label = "Release",    desc = "List, view, create, delete releases; upload assets",      actions = release },
  { label = "Actions/CI", desc = "CI runs and workflows: list, watch, rerun, cancel, trigger", actions = actions_ },
  { label = "Gist",       desc = "Create from buffer, list, view, delete gists",             actions = gist },
  { label = "Secret",     desc = "List, set, delete repo secrets",                           actions = secret },
  { label = "Keys",       desc = "SSH and GPG keys on your GitHub account",                  actions = keys },
  { label = "Auth",       desc = "Login status, switch accounts, add scopes",                actions = auth },
  { label = "Extension",  desc = "List, install, upgrade gh extensions",                     actions = ext },
  { label = "Codespace",  desc = "List, create, stop codespaces",                            actions = codespace },
  { label = "API",        desc = "Raw gh api escape hatch for anything unwrapped",           actions = api },
}

--- Build "label — desc" strings so the help text is visible right in the
--- picker, not hidden behind a separate lookup.
local function labeled(name, entry)
  return name:gsub("_", " ") .. "  —  " .. entry.desc
end

local function submenu(tbl, title, on_back)
  local items, lookup = {}, {}
  for name, entry in pairs(tbl) do
    local label = labeled(name, entry)
    table.insert(items, label)
    lookup[label] = entry.fn
  end
  table.sort(items)
  pick(items, title .. "> ", function(selection)
    if lookup[selection] then lookup[selection]() end
  end, on_back)
end

function M.menu()
  local items, lookup = {}, {}
  for _, c in ipairs(categories) do
    local label = c.label .. "  —  " .. c.desc
    table.insert(items, label)
    lookup[label] = c
  end
  pick(items, "gh> ", function(selection)
    local cat = lookup[selection]
    if cat then submenu(cat.actions, "gh " .. cat.label, M.menu) end
  end)
end

--- Full reference dump — every category, every action, every description,
--- in a scratch buffer you can scroll/search with normal Vim motions.
function M.help()
  local lines = { "# gh.lua — command reference", "" }
  for _, c in ipairs(categories) do
    table.insert(lines, "## " .. c.label .. " — " .. c.desc)
    local names = {}
    for name in pairs(c.actions) do table.insert(names, name) end
    table.sort(names)
    for _, name in ipairs(names) do
      table.insert(lines, string.format("  %-20s %s", name:gsub("_", " "), c.actions[name].desc))
    end
    table.insert(lines, "")
  end

  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
  vim.bo[buf].filetype = "markdown"
  vim.bo[buf].modifiable = false
  vim.bo[buf].bufhidden = "wipe"

  vim.cmd("tabnew")
  vim.api.nvim_win_set_buf(0, buf)
end

-- Expose sub-tables directly for dedicated keymaps, e.g.:
--   require("util.gh").repo.sync_fork.fn()
M.repo = repo
M.release = release
M.actions = actions_
M.gist = gist
M.secret = secret
M.keys = keys
M.auth = auth
M.ext = ext
M.codespace = codespace
M.api = api

return M
