local M = {}

-- Variable to store the job handle for the spraaktt process
local spraaktt_job = nil
local is_running = false
local output_lines = {}

-- Helper function to get the spraaktt directory path
local function get_spraaktt_dir()
  -- Get the path to this file and derive the spraaktt directory
  local current_file = debug.getinfo(1).source:match("@?(.*)")
  local current_dir = current_file:match("(.*/)"):gsub("/[^/]+/$", "/")
  return current_dir .. "../spraaktt/"
end

-- Function to start the spraaktt process (called during setup)
M.start_process = function()
  if spraaktt_job and vim.fn.jobstatus(spraaktt_job) == "run" then
    print("Spraaktt process is already running")
    return
  end

  -- Clear previous output
  output_lines = {}
  
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
            -- Check if this is a transcription result (not a command prompt)
            if not string.match(line, "Server started") and not string.match(line, "Enter command") then
              table.insert(output_lines, line)
              
              -- Update the current buffer with the new output
              vim.schedule(function()
                local bufnr = vim.api.nvim_get_current_buf()
                vim.api.nvim_buf_set_lines(bufnr, -1, -1, false, {line})
              end)
            end
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
      is_running = false
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

-- Function to send startc command to the spraaktt process
M.start = function()
  if not spraaktt_job or vim.fn.jobstatus(spraaktt_job) ~= "run" then
    print("Spraaktt process is not running. Please restart Neovim or reload the plugin.")
    return
  end

  -- Send the startc command to begin continuous transcription
  vim.fn.chansend(spraaktt_job, "startc\n")
  is_running = true
  print("Spraaktt continuous transcription started")
end

-- Function to send stopc command to the spraaktt process
M.stop = function()
  if not spraaktt_job or vim.fn.jobstatus(spraaktt_job) ~= "run" then
    print("Spraaktt process is not running")
    return
  end

  -- Send 'stopc' command to stop continuous transcription
  vim.fn.chansend(spraaktt_job, "stopc\n")
  is_running = false
  print("Spraaktt stopped")
end

-- Function to start the spraaktt process automatically when the plugin loads
M.setup = function(opts)
  opts = opts or {}
  M.start_process()
end

return M