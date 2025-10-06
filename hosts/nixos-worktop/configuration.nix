{ pkgs, vars, ... }:

{
  virtualisation = {
    docker = {
      enable = true;
      enableOnBoot = true;
    };  
  };

  systemd.services.gitea = {
    description = "Gitea Docker Container";
    after = [ "network.target" "docker.service" ];
    requires = [ "docker.service" ];
    serviceConfig = {
      Restart = "always";
      ExecStart = ''
        /run/current-system/sw/bin/docker run \
          --rm \
          --name gitea \
          -p 3000:3000 \
          -p 222:22 \
          -v /home/${vars.user}/Documents/gitea:/data \
          gitea/gitea:latest
      '';
      ExecStop = "/run/current-system/sw/bin/docker stop gitea";
    };
    wantedBy = [ "multi-user.target" ];
  };
  
  systemd.services.gitea-backup = {
    description = "Nightly Gitea backup (no verification)";
    path = [ pkgs.docker ];  # only docker needed
    serviceConfig = {
      Type = "oneshot";
      ExecStart = pkgs.writeShellScript "gitea-backup" ''
        set -euo pipefail

        CONTAINER="gitea"
        BACKUP_DIR="/home/${vars.user}/Documents/backups"
        FILE_NAME="gitea-backup.zip"
        TMP_PATH="/tmp/$FILE_NAME"

        mkdir -p "$BACKUP_DIR"

        echo "[INFO] Running gitea dump inside container..."
        docker exec -u git "$CONTAINER" \
          gitea dump -c /data/gitea/conf/app.ini -f "$TMP_PATH"

        echo "[INFO] Copying backup to host..."
        docker cp "$CONTAINER:$TMP_PATH" "$BACKUP_DIR/$FILE_NAME"

        echo "[INFO] Cleaning up inside container..."
        docker exec -u git "$CONTAINER" rm -f "$TMP_PATH"

        echo "[SUCCESS] Backup saved to: $BACKUP_DIR/$FILE_NAME"
      '';
    };
  };

  systemd.timers.gitea-backup = {
    description = "Run Gitea backup nightly at 5 AM";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "*-*-* 05:00:00";
      Persistent = true;
    };
  };
  
  networking.firewall.enable = true;
  networking.firewall.allowedTCPPorts = [ 2222 3000 ];
}
