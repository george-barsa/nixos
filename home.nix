{ config, pkgs, pkgs-unstable, ... }:

{
  home.username = "george";
  home.homeDirectory = "/home/george";

  home.packages = [
    pkgs.helix
    pkgs.spotify
    pkgs.freerdp
    pkgs.discord
    pkgs.alacritty
    pkgs-unstable.obsidian
  ];

  programs.vim.enable = true;

  programs.git = {
    enable = true;
    userName = "george-barsa";
    userEmail = "117371911+george-barsa@users.noreply.github.com";
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
        Cache = true;
        Cookies = true;
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
  home.stateVersion = "23.11";

  programs.home-manager.enable = true;
}
