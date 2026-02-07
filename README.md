# spraaktt.nvim

A Neovim plugin that integrates speech recognition capabilities using the spraaktt speech-to-text application. This plugin allows you to transcribe your speech directly into the current buffer.

## Features

- Speech transcription into the current buffer
- Simple start/stop controls

## Requirements

- Neovim >= 0.5
- Python 3.12+
- [uv](https://github.com/astral-sh/uv) (recommended) or pip for Python package management
- [spraaktt](https://github.com/VyacheslavVanin/spraaktt) submodule (included in this repository)

## Installation

Using [lazy.nvim](https://github.com/folke/lazy.nvim):

```lua
{
  "VyacheslavVanin/spraaktt.nvim",
  lazy = false,  -- This plugin should not be lazy-loaded since it starts a background job
  config = function()
    -- Configuration can be added here if needed
  end
}
```

## Commands

- `:SpraakttStart` - Starts speech transcription
- `:SpraakttStop` - Stops the speech transcription

## Usage

1. Open a buffer in Neovim where you want to transcribe speech
2. Run `:SpraakttStart` to begin transcription
3. Speak into your microphone - your speech will be transcribed to the current buffer
4. Run `:SpraakttStop` to stop the transcription

## Configuration

The plugin starts automatically when Neovim starts. The transcription will be added to whatever buffer is active when speech is detected.

## How it Works

This plugin interfaces with the spraaktt speech recognition application which uses Whisper (OpenAI) and PyTorch for speech-to-text conversion. The plugin manages the spraaktt process as a background job and streams the transcription results directly to your current Neovim buffer.

## Troubleshooting

- Make sure the spraaktt submodule is properly initialized: `git submodule update --init --recursive`
- Ensure Python dependencies are installed in the spraaktt directory
- Check that your microphone is properly configured and accessible to the system
