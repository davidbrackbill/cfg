-- Bazel test picker with snacks
-- This is a utility module, not a plugin spec
-- It's loaded via keymaps in lazy-plugins.lua

-- ============================================================================
-- Data layer: bazel query runner, cache, label parser
-- ============================================================================

local function get_cache_path()
  local cwd = vim.uv.cwd()
  return cwd and (cwd .. '/.bazel-picker-cache.json') or nil
end

local function cache_exists()
  local cache_path = get_cache_path()
  return cache_path and vim.uv.fs_stat(cache_path) ~= nil
end

local function read_cache()
  local cache_path = get_cache_path()
  if not cache_path then
    return nil
  end

  local file = io.open(cache_path, 'r')
  if not file then
    return nil
  end

  local content = file:read('*a')
  file:close()

  local ok, data = pcall(vim.json.decode, content)
  return ok and data or nil
end

local function write_cache(items)
  local cache_path = get_cache_path()
  if not cache_path then
    return
  end

  local file = io.open(cache_path, 'w')
  if file then
    file:write(vim.json.encode(items))
    file:close()
  end
end

local function parse_label(label_str)
  -- //internal/experimentation:my_test → { pkg, target, path }
  label_str = label_str:match('^%s*(.-)%s*$')  -- trim
  if not label_str or label_str == '' then
    return nil
  end

  local pkg, target = label_str:match('^//([^:]+):(.+)$')
  if not pkg or not target then
    return nil
  end

  return {
    text = label_str,
    bazel_target = label_str,
    pkg = pkg,
    target = target,
    file = pkg .. '/' .. target,  -- drives tree structure
    label = target,
    sort = pkg .. '/' .. target,
    is_pkg = false,
    kind = 'test',
  }
end

-- ============================================================================
-- Bazel test picker
-- ============================================================================

local function bazel_test_picker()
  local snacks = require('snacks')

  local items = {}
  local cmd = "bazel query 'tests(//...)' --output label --keep_going 2>&1"
  local result = vim.fn.system(cmd)
  for line in result:gmatch('[^\n]+') do
    local item = parse_label(line)
    if item then
      table.insert(items, item)
    end
  end
  write_cache(items)

  snacks.picker.pick({
    title = 'Bazel Tests',
    items = items,

    -- Tree structure
    tree = true,
    sort = { fields = { 'sort' } },
    matcher = { sort_empty = true, fuzzy = true },

    -- Layout
    layout = { preset = 'sidebar' },
    preview = true,

    -- Format
    format = function(item)
      if not item then
        return
      end
      local icon = item.is_pkg and '' or ''
      local badge = item.kind or ''
      return {
        { icon .. ' ', 'SnacksPickerIcon' },
        { item.label, 'SnacksPickerFile' },
        { ' ' .. badge, 'SnacksPickerComment' },
      }
    end,
  })
end

-- Refresh cache
local function refresh_cache()
  write_cache({})
  local snacks = require('snacks')
  snacks.notify('Bazel picker cache cleared')
end

-- ============================================================================
-- Public API
-- ============================================================================

return {
  bazel_tests = bazel_test_picker,
  refresh_cache = refresh_cache,
}
