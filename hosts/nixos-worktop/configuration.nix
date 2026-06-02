{ pkgs, vars, ... }:

{
  environment.systemPackages = [
    pkgs.rclone
    pkgs.docker
    pkgs.rsync
    pkgs.unzip
  ];

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

  systemd.services.gitea = {
    description = "Gitea Docker Container";

    after = [
      "network.target"
      "docker.service"
    ];

    requires = [
      "docker.service"
    ];

    serviceConfig = {
      Restart = "always";

      ExecStart = ''
        /run/current-system/sw/bin/docker run \
          --rm \
          --name gitea \
          -p 3000:3000 \
          -p 222:22 \
          -e GITEA__server__ROOT_URL=http://192.168.0.101:3000/ \
          -v /home/${vars.user}/Documents/gitea:/data \
          gitea/gitea:latest
      '';

      ExecStop = "/run/current-system/sw/bin/docker stop gitea";
    };

    wantedBy = [ "multi-user.target" ];
  };

  systemd.services.gitea-backup = {
    restartIfChanged = false;
    description = "Nightly Gitea backup with incremental OneDrive sync";

    path = [
      pkgs.docker
      pkgs.rclone
      pkgs.rsync
      pkgs.unzip
      pkgs.gawk
      pkgs.curl
    ];

    serviceConfig = {
      Type = "oneshot";

      ExecStart = pkgs.writeShellScript "gitea-backup" ''
        set -euo pipefail

        HOME_DIR="/home/${vars.user}"

        BACKUP_DIR="$HOME_DIR/Documents/backups"

        FILE_NAME="gitea-backup.zip"

        ZIP_FILE="$BACKUP_DIR/$FILE_NAME"

        # persistent extracted backup directory
        EXTRACT_DIR="$BACKUP_DIR/gitea-backup"

        # temporary extraction directory
        TEMP_EXTRACT="$BACKUP_DIR/gitea-backup-new"

        RCLONE_CONFIG="$HOME_DIR/.config/rclone/rclone.conf"

        # destination on OneDrive
        ONEDRIVE_DIR="onedrive:Backups/Gitea"

        HEALTHCHECK_UUID=$(cat "$HOME_DIR/.secrets/healthchecks_uuid")

        MAX_RETRIES=3

        mkdir -p "$BACKUP_DIR"
        mkdir -p "$EXTRACT_DIR"

        fail() {
          echo "[ERROR] $1"

          curl -fsS --retry 3 \
            "https://hc-ping.com/$HEALTHCHECK_UUID/fail" || true

          exit 1
        }

        echo "[INFO] Running gitea dump in container..."

        docker exec -u git gitea \
          gitea dump -f "/tmp/$FILE_NAME" \
          || fail "Gitea dump failed"

        echo "[INFO] Copying backup zip from container..."

        docker cp \
          "gitea:/tmp/$FILE_NAME" \
          "$ZIP_FILE" \
          || fail "Copying backup zip failed"

        echo "[INFO] Removing temporary zip from container..."

        docker exec -u git gitea \
          rm -f "/tmp/$FILE_NAME" \
          || fail "Removing temporary zip from container failed"

        echo "[INFO] Preparing temporary extraction directory..."

        rm -rf "$TEMP_EXTRACT"
        mkdir -p "$TEMP_EXTRACT"

        echo "[INFO] Extracting backup zip..."

        unzip -oq "$ZIP_FILE" -d "$TEMP_EXTRACT" \
          || fail "Backup extraction failed"

        echo "[INFO] Updating persistent backup directory..."

        # IMPORTANT:
        # rsync preserves unchanged files so rclone only uploads differences.
        rsync -a --delete \
          "$TEMP_EXTRACT/" \
          "$EXTRACT_DIR/" \
          || fail "rsync update failed"

        echo "[INFO] Cleaning temporary extraction directory..."

        rm -rf "$TEMP_EXTRACT"

        echo "[INFO] Removing local backup zip..."

        rm -f "$ZIP_FILE"

        attempt=1

        while [ $attempt -le $MAX_RETRIES ]; do
          echo "[INFO] OneDrive sync attempt $attempt..."

          if rclone \
            --config "$RCLONE_CONFIG" \
            sync \
            --progress \
            --fast-list \
            --transfers 1 \
            --checkers 2 \
            --stats 30s \
            "$EXTRACT_DIR/" \
            "$ONEDRIVE_DIR/"
          then
            echo "[SUCCESS] Backup synced successfully."

            curl -fsS --retry 3 \
              "https://hc-ping.com/$HEALTHCHECK_UUID" || true

            exit 0
          fi

          echo "[ERROR] Sync attempt $attempt failed"

          attempt=$((attempt + 1))

          sleep 10
        done

        fail "Backup failed after $MAX_RETRIES attempts"
      '';
    };
  };

  systemd.timers.gitea-backup = {
    enable = true;

    description = "Run Gitea backup weekly";

    wantedBy = [ "timers.target" ];

    timerConfig = {
      OnCalendar = "weekly";
      Persistent = true;
    };
  };

  networking.firewall.enable = true;

  networking.firewall.allowedTCPPorts = [
    2222
    3000
  ];
}
