{ pkgs, vars, ... }:

{
  environment.systemPackages = [
    pkgs.rclone
    pkgs.docker
    pkgs.rsync
    pkgs.unzip
  ];

  services.openssh.enable = true;

  services.power-profiles-daemon.enable = false;
  services.tlp.enable = true;

  services.tlp.settings = {
    START_CHARGE_THRESH_BAT0 = 60;
    STOP_CHARGE_THRESH_BAT0 = 80;
  };

  virtualisation = {
    docker = {
      enable = true;
      enableOnBoot = true;
    };
  };

  # Moved to nixos-thicktop.
  # systemd.services.gitea = { ... };

  # Not using spacetimedb anymore — left here commented out rather than
  # deleted in case it comes back.
  # systemd.services.spacetimedb = {
  #   description = "SpaceTimeDB Docker Container";
  #   after = [
  #     "network.target"
  #     "docker.service"
  #   ];
  #   requires = [
  #     "docker.service"
  #   ];
  #   serviceConfig = {
  #     Restart = "always";
  #     ExecStartPre = [
  #       "-/run/current-system/sw/bin/docker rm -f spacetimedb"
  #       # Docker auto-creates the bind-mount source as root:root if it
  #       # doesn't exist, but the image runs its own process as a non-root
  #       # `spacetime` user internally — world-writable so it can write
  #       # regardless of that user's in-container uid (single-user host,
  #       # not worth chasing the exact uid).
  #       "/run/current-system/sw/bin/mkdir -p /home/${vars.user}/Documents/spacetimedb/db /home/${vars.user}/Documents/spacetimedb/keys"
  #       "/run/current-system/sw/bin/chmod -R 777 /home/${vars.user}/Documents/spacetimedb"
  #     ];
  #     ExecStart = ''
  #       /run/current-system/sw/bin/docker run \
  #         --rm \
  #         --name spacetimedb \
  #         -p 3001:3001 \
  #         -v /home/${vars.user}/Documents/spacetimedb:/data \
  #         clockworklabs/spacetime:latest \
  #         start --listen-addr 0.0.0.0:3001 --data-dir /data/db --jwt-key-dir /data/keys
  #     '';
  #     ExecStop = "/run/current-system/sw/bin/docker stop spacetimedb";
  #   };
  #   wantedBy = [ "multi-user.target" ];
  # };

  # Moved to nixos-thicktop.
  # systemd.services.gitea-backup = { ... };
  # systemd.timers.gitea-backup = { ... };

  networking.firewall.enable = true;

  networking.firewall.allowedTCPPorts = [
    22
    2222
    3000
    3001
  ];
}
