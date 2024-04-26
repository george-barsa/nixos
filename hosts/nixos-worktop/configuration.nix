{ vars, host, ... }:

{
  networking.hostName = "${host}";

  services = {
    syncthing = {
      enable = true;
      user = "${vars.user}";
      dataDir = "/home/${vars.user}/Documents";
      configDir = "/home/${vars.user}/Documents/.config/syncthing";
      overrideDevices = true;
      overrideFolders = true;
      settings = {
        devices = {
          "nixos-worktop" = { id = "F2WEJDI-6ZFMTUK-FN2AGHL-J3CJZQL-YXSRYBH-GRKFS3N-SBTX5QP-6CLFZAQ"; };
          "george-pixel6a" = { id = "PJ7UURK-ZSDAEF6-BCIX5LG-CAHDGO4-2B7NXKU-FNEHIVB-VHSWAZ4-JDNVBQZ"; };
        };
        folders = {
          "logseq" = {
            path = "/home/${vars.user}/Documents/logseq";
            devices = [ "george-pixel6a" ];
          };
        };
      };
    };
  };
}
