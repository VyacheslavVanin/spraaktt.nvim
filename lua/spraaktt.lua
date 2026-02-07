local M = {}

-- Variable to store the job handle for the spraaktt process
local spraaktt_job = nil
M.is_running = false
local output_lines = {}

-- Helper function to get the spraaktt directory path
local function get_spraaktt_dir()
  -- Get the path to this file and derive the spraaktt directory
  local current_file = debug.getinfo(1).source:match("@?(.*)")
  local current_dir = current_file:match("(.*/)"):gsub("/[^/]+/$", "/")
  return current_dir .. "spraaktt/"
end

-- Insert lines in current cursor position
local function insert_lines(lines)
    local cursor = vim.api.nvim_win_get_cursor(0)
    local current_line = cursor[1] - 1
    local current_col = cursor[2]

    local current_line = vim.api.nvim_get_current_line()
    local after = #current_line == current_col + 1
    vim.api.nvim_put(lines, 'c', after, true)
end

-- Function to start the spraaktt process (called during setup)
M.start_process = function()
  if spraaktt_job ~= nil then
    print("Spraaktt process is already running")
    return
  end

  local spraaktt_dir = get_spraaktt_dir()
  
  -- Check if uv is available
  local has_uv = vim.fn.executable('uv') == 1
  
  -- Start the spraaktt process (without sending startc command yet)
  local command
  if has_uv then
    command = {"uv", "run", "main.py"}
  else
    command = {"python", "main.py"}
  end
  
  spraaktt_job = vim.fn.jobstart(command, {
    cwd = spraaktt_dir,
    on_stdout = function(chan_id, data, event)
      if data and #data > 0 then
        for _, line in ipairs(data) do
          if line and line ~= "" then
              -- Update the current buffer with the new output
              vim.schedule(function()
                insert_lines({line})
              end)
          end
        end
      end
    end,
    on_stderr = function(chan_id, data, event)
      if data and #data > 0 then
        for _, line in ipairs(data) do
          if line and line ~= "" then
            print("Spraaktt Error: " .. line)
          end
        end
      end
    end,
    on_exit = function(chan_id, code, event)
      M.is_running = false
      spraaktt_job = nil
      print("Spraaktt process exited with code: " .. (code or "unknown"))
    end
  })

  if spraaktt_job > 0 then
    print("Spraaktt process started, waiting for commands")
  else
    print("Failed to start Spraaktt process")
  end
end

-- Function to send start command to the spraaktt process
M.start = function()
  if not spraaktt_job then
    print("Spraaktt process is not running. Please restart Neovim or reload the plugin.")
    return
  end

  -- Send the startc command to begin transcription
  vim.fn.chansend(spraaktt_job, "start\n")
  M.is_running = true
  print("Spraaktt transcription started")
end

-- Function to send stopc command to the spraaktt process
M.stop = function()
  if not spraaktt_job then
    print("Spraaktt process is not running")
    return
  end

  -- Send 'stop' command to stop transcription
  vim.fn.chansend(spraaktt_job, "stop\n")
  M.is_running = false
  print("Spraaktt stopped")
end

-- Function to start the spraaktt process automatically when the plugin loads
M.setup = function(opts)
  opts = opts or {}
  M.start_process()
end

return M
