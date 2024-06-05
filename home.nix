{ pkgs, vars,  ... }:

{
  home.username = "${vars.user}";
  home.homeDirectory = "/home/${vars.user}";

  home.packages = with pkgs; [
    fastfetch
    fzf
    nil
    spotify
    freerdp
    discord
    logseq
    bitwig-studio
    gimp
  ];

  programs.bash = {
    enable = true;
    shellAliases = {
      fcd = "cd $(find . -type d -print | fzf)";
    };
  };

  programs.direnv.enable = true;

  programs.kitty = {
    enable = true;
    theme = "Gruvbox Dark";  
    settings.symbolMap = "U+23FB-U+23FE,U+2665,U+26A1,U+2B58,U+E000-U+E00A,U+E0A0-U+E0A3,U+E0B0-U+E0D4,U+E200-U+E2A9,U+E300-U+E3E3,U+E5FA-U+E6AA,U+E700-U+E7C5,U+EA60-U+EBEB,U+F000-U+F2E0,U+F300-U+F32F,U+F400-U+F4A9,U+F500-U+F8FF,U+F0001-U+F1AF0 Symbols Nerd Font Mono";
  };
  
  programs.starship = {
    enable = true;
    enableBashIntegration = true;
  };

  programs.helix = {
    enable = true;
    settings = {
      editor = {
        line-number = "relative";
        color-modes = true;
        true-color = true;
        cursorline = true;
        statusline = {
          left = ["mode" "spinner" "version-control" "file-name" "read-only-indicator" "file-modification-indicator"];
        };
        cursor-shape = {
          insert = "bar";
        };
      };
      keys.normal = {
        esc = ["collapse_selection" "keep_primary_selection"];
      };
      theme = "gruvbox";
    };
  };

  programs.git = {
    enable = true;
    userName = "george-barsa";
    userEmail = "117371911+george-barsa@users.noreply.github.com";
    extraConfig = {
      init.defaultBranch = "main";
    };
  };

  programs.firefox = {
    enable = true;

    policies = {
      DisableFirefoxAccounts = true;
      DisableFirefoxStudies = true;
      DisableFormHistory = true;
      DisablePocket = true;
      DisableTelemetry = true;
      DisplayBookmarksToolbar = "never";

      EnableTrackingProtection = {
        Value = true;
        Cryptomining = true;
        Fingerprinting = true;
      };
      
      ExtensionSettings = {
	      "uBlock0@raymondhill.net" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi";
          installation_mode = "force_installed";
        };
        "{446900e4-71c2-419f-a6a7-df9c091e268b}" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/bitwarden-password-manager/latest.xpi";
          installation_mode = "force_installed";
        };
      };

      FirefoxSuggest = {
        WebSuggestions = false;
        SponsoredSuggestions = false;
        ImproveSuggest = false;
      };

      Homepage.StartPage = "none";
      NewTabPage = false;
      OfferToSaveLogins = false;

      Preferences = {
        "browser.contentblocking.category" = { 
          Value = "strict"; 
        };
      };
      
      SanitizeOnShutdown = {
        Cache = false;
        Cookies = false;
        Downloads = false;
        FormData = true;
        History = false;
        Sessions = true;
        SiteSettings = true;
        OfflineApps = true;
      };      

      # SearchEngines.Default = "ddg@search.mozilla.org";
      SearchSuggestionsEnabled = false;
    };
  };

  # This value determines the home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update home Manager without changing this value. See
  # the home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "24.05";

  programs.home-manager.enable = true;
}
