{ pkgs, ... }:

{
  vim = {
    lineNumberMode = "number";
    clipboard.enable = true;
    clipboard.registers = "unnamedplus";
    theme = {
      enable = true;
      name = "gruvbox";
      style = "dark";
    };
    terminal.toggleterm = {
      enable = true;
      lazygit.enable = true;
      mappings = {
        open = "<A-i>";
      };
      setupOpts = {
        start_in_insert = true;
        direction = "float";
      };
    };
    options = {
      whichwrap = "h,l";
    };

    maps.terminal = {
      "<S-BS>" = {
        action = "<BS>";
      };
      "<C-BS>" = {
        action = "<BS>";
      };
      "<M-S-BS>" = {
        action = "<BS>";
      };
      "<M-C-BS>" = {
        action = "<BS>";
      };
      "<C-S-BS>" = {
        action = "<BS>";
      };
      "<M-C-S-BS>" = {
        action = "<BS>";
      };
      "<S-Space>" = {
        action = "<Space>";
      };
      "<M-S-Space>" = {
        action = "<Space>";
      };
      "<M-C-Space>" = {
        action = "<Space>";
      };
      "<C-S-Space>" = {
        action = "<Space>";
      };
      "<M-C-S-Space>" = {
        action = "<Space>";
      };
      "<S-CR>" = {
        action = "<CR>";
      };
      "<C-CR>" = {
        action = "<CR>";
      };
      "<M-S-CR>" = {
        action = "<CR>";
      };
      "<M-C-CR>" = {
        action = "<CR>";
      };
      "<C-S-CR>" = {
        action = "<CR>";
      };
      "<M-C-S-CR>" = {
        action = "<CR>";
      };
      "<Esc>" = {
        action = "<C-\\><C-n>";
      };
    };
    keymaps = [
      {
        key = "j";
        mode = "n";
        silent = true;
        action = "gj";
      }
      {
        key = "k";
        mode = "n";
        silent = true;
        action = "gk";
      }
      {
        key = "<C-S>";
        mode = "n";
        silent = true;
        action = ":update<CR>";
      }
      {
        key = "<A-i>";
        mode = "t";
        silent = true;
        action = "<cmd>ToggleTerm<CR>";
      }
    ];

    statusline.lualine.enable = true;
    telescope.enable = true;
    autocomplete.nvim-cmp.enable = true;

    lsp = {
      formatOnSave = true;
      mappings = {
        format = "<leader>fm";
      };
      enable = true;
    };

    languages = {
      enableFormat = true;
      enableExtraDiagnostics = true;
      enableTreesitter = true;

      nix.enable = true;
      rust.enable = true;
      clang.enable = true;
      bash.enable = true;
    };
    diagnostics = {
      config = {
        virtual_lines = true;
        virtual_text = true;
      };
    };
    filetree.nvimTree = {
      enable = true;
      openOnSetup = false;
      mappings = {
        toggle = "<C-n>";
      };
      setupOpts.actions.open_file.quit_on_open = true;
    };
    tabline.nvimBufferline = {
      enable = true;
      mappings = {
        cycleNext = "<C-Tab>";
        cyclePrevious = "<C-S-Tab>";
      };
    };
    autopairs.nvim-autopairs.enable = true;
  };
}
