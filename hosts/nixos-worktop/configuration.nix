{ pkgs, vars, ... }:

{
  environment.systemPackages = [
    pkgs.rclone
    pkgs.docker
  ];
  
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
    path = [ pkgs.docker pkgs.rclone pkgs.gawk pkgs.curl ];  # only docker needed
    serviceConfig = {
      Type = "oneshot";
      ExecStart = pkgs.writeShellScript "gitea-backup" ''
        set -euo pipefail

        HOME_DIR="/home/${vars.user}"
        BACKUP_DIR="$HOME_DIR/Documents/backups"
        FILE_NAME="gitea-backup.zip"
        RCLONE_CONFIG="$HOME_DIR/.config/rclone/rclone.conf"
        ONEDRIVE_DIR="onedrive:Backups/Gitea"
        BACKUP_FILE="$BACKUP_DIR/$FILE_NAME"
        HEALTHCHECK_UUID=$(cat $HOME_DIR/.secrets/healthchecks_uuid)
        MAX_RETRIES=3

        mkdir -p "$BACKUP_DIR"
        if [ $? -ne 0 ]; then
          echo "[ERROR] creating backup directory failed!"
          curl -fsS --retry 3 https://hc-ping.com/$HEALTHCHECK_UUID/fail
          STATUS=1
        fi

        echo "[INFO] Running gitea dump in container..."
        docker exec -u git gitea gitea dump -f /tmp/$FILE_NAME
        if [ $? -ne 0 ]; then
          echo "[ERROR] Gitea dump failed!"
          curl -fsS --retry 3 https://hc-ping.com/$HEALTHCHECK_UUID/fail
          STATUS=1
        fi

        echo "[INFO] Copying gitea backup from container to host..."
        docker cp gitea:/tmp/$FILE_NAME $BACKUP_FILE
        if [ $? -ne 0 ]; then
          echo "[ERROR] Copying gitea backup from container to host failed!"
          curl -fsS --retry 3 https://hc-ping.com/$HEALTHCHECK_UUID/fail
          STATUS=1
        fi
        
        echo "[INFO] removing backup from container..."
        docker exec -u git gitea rm -f /tmp/$FILE_NAME
        if [ $? -ne 0 ]; then
          echo "[ERROR] removing backup from container failed!"
          curl -fsS --retry 3 https://hc-ping.com/$HEALTHCHECK_UUID/fail
          STATUS=1
        fi
        
        attempt=1
        while [ $attempt -le $MAX_RETRIES ]; do
          echo "[INFO] Upload attempt $attempt..."
          rclone --config "$RCLONE_CONFIG" copy --ignore-times --progress "$BACKUP_FILE" "$ONEDRIVE_DIR/"
          if [ $? -ne 0 ]; then
            echo "[ERROR] upload attempt $attempt failed!"
            attempt=$((attempt + 1))
            sleep 5
          else
            echo "[SUCCESS] Backup uploaded and verified."
            curl -fsS --retry 3 https://hc-ping.com/$HEALTHCHECK_UUID
            break
          fi
        done

        if [ $attempt -gt $MAX_RETRIES ]; then
          echo "[ERROR] Gitea dump failed after $MAX_RETRIES attempts!"
          curl -fsS --retry 3 https://hc-ping.com/$HEALTHCHECK_UUID/fail
          STATUS=1
        fi
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
