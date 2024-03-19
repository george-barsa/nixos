{ config, pkgs, ... }:

{
  home.username = "george";
  home.homeDirectory = "/home/george";

  home.packages = with pkgs; [
        
  ];

  programs.vim.enable = true;

  programs.git = {
    enable = true;
    userName = "george-barsa";
    userEmail = "117371911+george-barsa@users.noreply.github.com";
  };

  programs.firefox = {
    enable = true;

    #  profiles = {
    #    default.extensions = with nur.repos.rycee.firefox-addons; [
    #      bitwarden
    #      ublock-origin
    #    ];
    #  };

    policies = {
      DisablePocket = true;
      DisableFirefoxAccounts = true;
      DisableFormHistory = true;
      DisplayBookmarksToolbar = "never";
      
      EnableTrackingProtection = {
        Value = true;
        Cryptomining = true;
        Fingerprinting = true;
      };

      FirefoxSuggest = {
        WebSuggestions = false;
        SponsoredSuggestions = false;
        ImproveSuggest = false;
      };

      Homepage.StartPage = "none";
      NewTabPage = false;
      OfferToSaveLogins = false;
      
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
